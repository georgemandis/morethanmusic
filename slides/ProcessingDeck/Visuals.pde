// Visuals.pde - the backgrounds, one per slide, drawn into a small buffer (VW x VH) that the sketch
// scales up and composites at low opacity behind the text.
//
// p1 / p2 are the stick's y and x in INTERACTIVE, -1..1, both 0 otherwise. draw() gets the buffer
// between beginDraw() and endDraw(); alpha is the opacity the sketch will composite at.

interface Visual {
  String name();
  void reset(int seed);
  void update(float p1, float p2);
  void draw(PGraphics pg, float alpha);
  /** Optional: draw at full resolution on the main canvas, after the buffer, before the text. */
  default void drawHires(PApplet app, float alpha) {}
  /** False when the visual never draws into the buffer, so the composite is skipped. */
  default boolean usesBuffer() { return true; }
  /** Height to keep free at the bottom of the slide, in pixels; the text is laid out above it. */
  default float reserveBottom(float ui) { return 0; }
  /** A mouse click at x, y. True when the visual used it. */
  default boolean click(float x, float y) { return false; }
  /** Optional: draw after the slide's text and photo, on top. */
  default void drawAbove(PApplet app, float alpha) {}
}

final int VW = 480, VH = 270;
final String[] VISUAL_NAMES = { "Game of Life", "L-system tree", "Julia zoom", "Lissajous doodle", "Langton's ant", "Teapot", "Bytes", "Bananas", "Hot Hand", "QR code" };

Visual makeVisual(int kind) {
  switch (kind) {
    case 0: return new LifeVisual();
    case 1: return new TreeVisual();
    case 2: return new JuliaVisual();
    case 3: return new LissajousVisual();
    case 5: return new TeapotVisual();
    case 6: return new BytesVisual();
    case 7: return new BananasVisual();
    case 8: return new HotHandVisual();
    case 9: return new QRVisual();
    default: return new AntVisual();
  }
}

/** A seeded hue per slide. Saturation stays low so the text wins. */
int tintFor(java.util.Random r, float s, float b) {
  colorMode(HSB, 360, 100, 100);
  int c = color(r.nextInt(360), s, b);
  colorMode(RGB, 255);
  return c;
}

int hsb(float h, float s, float b) {
  colorMode(HSB, 360, 100, 100);
  int c = color((h % 360 + 360) % 360, s, b);
  colorMode(RGB, 255);
  return c;
}

// ------------------------------------------------------------------ 1. Game of Life
class LifeVisual implements Visual {
  int cols = 96, rows = 54, cell = 5;
  int[] age, next;
  float acc = 0, hue;
  java.util.Random r;
  String name() { return VISUAL_NAMES[0]; }
  void reset(int seed) {
    r = new java.util.Random(seed);
    age = new int[cols * rows]; next = new int[cols * rows];
    hue = r.nextInt(360);
    for (int i = 0; i < age.length; i++) age[i] = r.nextFloat() < 0.28 ? 1 : 0;
  }
  void update(float p1, float p2) {
    float stepsPerSecond = p1 >= 0 ? lerp(5, 40, p1) : lerp(5, 0.5, -p1);     // up = faster, down = slower
    acc += stepsPerSecond / 60.0;
    while (acc >= 1) { step(); acc -= 1; }
    if (abs(p2) > 0.15) {                                                     // left/right: stir new cells in on that side
      int count = (int) (abs(p2) * 6);
      for (int k = 0; k < count; k++) {
        float cx = p2 > 0 ? lerp(cols * 0.5, cols - 1, r.nextFloat()) : lerp(0, cols * 0.5, r.nextFloat());
        int x = constrain((int) cx, 0, cols - 1), y = r.nextInt(rows);
        age[y * cols + x] = 1;
      }
    }
  }
  void step() {
    int alive = 0;
    for (int y = 0; y < rows; y++) {
      int ym = (y + rows - 1) % rows, yp = (y + 1) % rows;
      for (int x = 0; x < cols; x++) {
        int xm = (x + cols - 1) % cols, xp = (x + 1) % cols;
        int n = (age[ym * cols + xm] > 0 ? 1 : 0) + (age[ym * cols + x] > 0 ? 1 : 0) + (age[ym * cols + xp] > 0 ? 1 : 0)
              + (age[y * cols + xm] > 0 ? 1 : 0) + (age[y * cols + xp] > 0 ? 1 : 0)
              + (age[yp * cols + xm] > 0 ? 1 : 0) + (age[yp * cols + x] > 0 ? 1 : 0) + (age[yp * cols + xp] > 0 ? 1 : 0);
        int a = age[y * cols + x];
        int v = (a > 0 && (n == 2 || n == 3)) ? min(a + 1, 60) : (a == 0 && n == 3 ? 1 : 0);
        next[y * cols + x] = v;
        if (v > 0) alive++;
      }
    }
    int[] t = age; age = next; next = t;
    if (alive < cols * rows / 60) for (int k = 0; k < 40; k++) age[r.nextInt(age.length)] = 1;   // do not let it die out
  }
  void draw(PGraphics pg, float alpha) {
    pg.background(0, 0);
    pg.noStroke();
    for (int y = 0; y < rows; y++) for (int x = 0; x < cols; x++) {
      int a = age[y * cols + x];
      if (a == 0) continue;
      pg.fill(hsb(hue + a * 2, 55, a == 1 ? 100 : 70));
      pg.rect(x * cell, y * cell, cell - 1, cell - 1);
    }
  }
}

// ------------------------------------------------------------------ 2. L-system tree
class TreeVisual implements Visual {
  String sentence; int segments;
  float baseAngle, angleOffset = 0, lengthScale = 1, grown = 0, sway = 0, hue, unitLen, originX, originY;
  java.util.Random r;
  String name() { return VISUAL_NAMES[1]; }
  void reset(int seed) {
    r = new java.util.Random(seed);
    hue = r.nextInt(360);
    int pick = r.nextInt(3);
    String axiom, ruleF, ruleX; int iterations;
    if (pick == 0)      { axiom = "F"; ruleF = "FF+[+F-F-F]-[-F+F+F]"; ruleX = "X";  iterations = 4; baseAngle = 22.5; }
    else if (pick == 1) { axiom = "X"; ruleF = "FF"; ruleX = "F[+X][-X]FX";          iterations = 6; baseAngle = 25.7; }
    else                { axiom = "X"; ruleF = "FF"; ruleX = "F-[[X]+X]+F[+FX]-X";   iterations = 5; baseAngle = 22.5; }
    sentence = axiom;
    for (int i = 0; i < iterations; i++) {
      StringBuilder sb = new StringBuilder();
      for (int k = 0; k < sentence.length(); k++) {
        char c = sentence.charAt(k);
        if (c == 'F') sb.append(ruleF); else if (c == 'X') sb.append(ruleX); else sb.append(c);
      }
      sentence = sb.toString();
    }
    segments = 0; for (int k = 0; k < sentence.length(); k++) if (sentence.charAt(k) == 'F') segments++;
    grown = 0; angleOffset = 0; lengthScale = 1; sway = r.nextFloat() * TWO_PI;
    fit();
  }
  /** Walk the sentence once at unit length for its bounds, then size it to the buffer. */
  void fit() {
    float x = 0, y = 0, heading = -HALF_PI, minX = 0, maxX = 0, minY = 0, maxY = 0;
    float ang = radians(baseAngle);
    float[] stack = new float[3 * 64]; int sp = 0;
    for (int k = 0; k < sentence.length(); k++) {
      char c = sentence.charAt(k);
      if (c == 'F') { x += cos(heading); y += sin(heading); minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y); }
      else if (c == '+') heading += ang;
      else if (c == '-') heading -= ang;
      else if (c == '[' && sp < stack.length - 3) { stack[sp++] = x; stack[sp++] = y; stack[sp++] = heading; }
      else if (c == ']' && sp >= 3) { heading = stack[--sp]; y = stack[--sp]; x = stack[--sp]; }
    }
    float w = max(1, maxX - minX), h = max(1, maxY - minY);
    unitLen = min(VW * 0.9 / w, VH * 0.92 / h);
    originX = VW * 0.5 - (minX + maxX) * 0.5 * unitLen;
    originY = VH * 0.97 - maxY * unitLen;
  }
  void update(float p1, float p2) {
    grown = min(1, grown + 1 / 150.0);
    sway += 0.012;
    angleOffset = constrain(angleOffset + p1 * 0.4, -20, 20);          // up/down bends every joint
    lengthScale = constrain(lengthScale + p2 * 0.01, 0.5, 1.3);         // left/right shrinks/stretches
  }
  void draw(PGraphics pg, float alpha) {
    pg.background(0, 0);
    pg.stroke(hsb(hue, 45, 95)); pg.strokeWeight(1.2); pg.noFill();
    float len = unitLen * lengthScale;
    float ang = radians(baseAngle + angleOffset + sin(sway) * 2.5);
    float x = originX, y = originY, heading = -HALF_PI;
    float[] stack = new float[3 * 64]; int sp = 0;
    int budget = (int) (segments * grown), drawn = 0;
    for (int k = 0; k < sentence.length() && drawn < budget; k++) {
      char c = sentence.charAt(k);
      if (c == 'F') { float nx = x + cos(heading) * len, ny = y + sin(heading) * len; pg.line(x, y, nx, ny); x = nx; y = ny; drawn++; }
      else if (c == '+') heading += ang;
      else if (c == '-') heading -= ang;
      else if (c == '[' && sp < stack.length - 3) { stack[sp++] = x; stack[sp++] = y; stack[sp++] = heading; }
      else if (c == ']' && sp >= 3) { heading = stack[--sp]; y = stack[--sp]; x = stack[--sp]; }
    }
  }
}

// ------------------------------------------------------------------ 3. Julia zoom
class JuliaVisual implements Visual {
  int w = 240, h = 135;
  PImage img; int[] palette = new int[256];
  float zoom = 1, cAngle, cRadius, zoomVel = 0, cx = 0, cy = 0, hue;
  java.util.Random r;
  String name() { return VISUAL_NAMES[2]; }
  void reset(int seed) {
    r = new java.util.Random(seed);
    img = createImage(w, h, ARGB);
    hue = r.nextInt(360);
    cAngle = r.nextFloat() * TWO_PI; cRadius = 0.7885;
    zoom = 1; zoomVel = 0;
    cx = (r.nextFloat() - 0.5) * 0.6; cy = (r.nextFloat() - 0.5) * 0.6;
    for (int i = 0; i < 256; i++) {
      float t = i / 255.0;
      int c = hsb(hue + t * 120, 60 - t * 30, 40 + 60 * pow(t, 0.6));
      int a = (int) (255 * pow(t, 0.7));                                   // far outside fades to the background
      palette[i] = i == 255 ? color(0, 0) : ((a << 24) | (c & 0xFFFFFF));   // the set's interior stays transparent
    }
  }
  void update(float p1, float p2) {
    cAngle += 0.0025 + p2 * 0.02;                     // left/right spins the c parameter around the cardioid
    zoomVel = lerp(zoomVel, p1 * 0.03, 0.1);          // up zooms in, down zooms out
    zoom *= 1 + zoomVel + 0.0015 * sin(frameCount * 0.01);
    zoom = constrain(zoom, 0.5, 60);
  }
  void draw(PGraphics pg, float alpha) {
    float cr = cRadius * cos(cAngle), ci = cRadius * sin(cAngle);
    float scale = 3.0 / zoom, aspect = w / (float) h;
    int maxIter = 40;
    img.loadPixels();
    for (int py = 0; py < h; py++) {
      float y0 = cy + (py / (float) h - 0.5) * scale;
      for (int px = 0; px < w; px++) {
        float x = cx + (px / (float) w - 0.5) * scale * aspect, y = y0;
        int i = 0;
        while (i < maxIter) {
          float xx = x * x, yy = y * y;
          if (xx + yy > 4) break;
          y = 2 * x * y + ci; x = xx - yy + cr; i++;
        }
        img.pixels[py * w + px] = i >= maxIter ? palette[255] : palette[(i * 255 / maxIter) & 255];
      }
    }
    img.updatePixels();
    pg.background(0, 0);
    pg.image(img, 0, 0, VW, VH);
  }
}

// ------------------------------------------------------------------ 4. Lissajous doodle
class LissajousVisual implements Visual {
  float a, b, phase, t = 0, ratioDrift = 0, hue; int pens;
  float[] px, py;
  boolean first = true;
  java.util.Random r;
  String name() { return VISUAL_NAMES[3]; }
  void reset(int seed) {
    r = new java.util.Random(seed);
    hue = r.nextInt(360);
    a = 1 + r.nextInt(4); b = 1 + r.nextInt(5); if (a == b) b++;
    phase = r.nextFloat() * PI; pens = 2 + r.nextInt(2);
    px = new float[pens]; py = new float[pens];
    t = 0; ratioDrift = 0; first = true;
  }
  void update(float p1, float p2) {
    ratioDrift += p1 * 0.004;                          // up/down detunes the frequency ratio
    ratioDrift = constrain(ratioDrift, -1, 1);
    phase += 0.002 + p2 * 0.03;                        // left/right slides the phase
    t += 0.012;
  }
  void draw(PGraphics pg, float alpha) {
    if (first) { pg.background(0, 0); first = false; }
    pg.noStroke(); pg.fill(0, 0, 0, 10); pg.rect(0, 0, VW, VH);     // slow fade of the trail
    pg.strokeWeight(1.5); pg.noFill();
    float cx = VW / 2.0, cy = VH / 2.0, rx = VW * 0.46, ry = VH * 0.44;
    for (int k = 0; k < pens; k++) {
      float tt = t + k * 0.7;
      float nx = cx + sin((a + ratioDrift) * tt + phase + k * 0.3) * rx;
      float ny = cy + sin(b * tt + k * 0.5) * ry;
      pg.stroke(hsb(hue + k * 40, 55, 95));
      if (t > 0.012) pg.line(px[k], py[k], nx, ny);
      px[k] = nx; py[k] = ny;
    }
  }
}

// ------------------------------------------------------------------ 5. Langton's ant
class AntVisual implements Visual {
  int cols = 160, rows = 90, cell = 3;
  int[] grid; String rule; int ants;
  int[] ax, ay, ad;
  float hue;
  java.util.Random r;
  String name() { return VISUAL_NAMES[4]; }
  void reset(int seed) {
    r = new java.util.Random(seed);
    hue = r.nextInt(360);
    String[] rules = { "RL", "LLRR", "LRRRRRLLR", "RRLLLRLLLRRR", "LLRRRLRLRLLR" };
    rule = rules[r.nextInt(rules.length)];
    grid = new int[cols * rows];
    ants = 1 + r.nextInt(3);
    ax = new int[ants]; ay = new int[ants]; ad = new int[ants];
    for (int i = 0; i < ants; i++) { ax[i] = cols / 2 + r.nextInt(31) - 15; ay[i] = rows / 2 + r.nextInt(17) - 8; ad[i] = r.nextInt(4); }
  }
  void update(float p1, float p2) {
    int steps = p1 >= 0 ? (int) lerp(40, 600, p1) : (int) lerp(40, 2, -p1);     // up = faster
    float wobble = abs(p2) * 0.05;                                               // left/right: random turns
    for (int s = 0; s < steps; s++) for (int i = 0; i < ants; i++) {
      int idx = ay[i] * cols + ax[i];
      int state = grid[idx];
      char turn = rule.charAt(state % rule.length());
      if (wobble > 0 && r.nextFloat() < wobble) turn = p2 > 0 ? 'R' : 'L';
      ad[i] = (ad[i] + (turn == 'R' ? 1 : 3)) % 4;
      grid[idx] = (state + 1) % rule.length();
      if (ad[i] == 0) ay[i]--; else if (ad[i] == 1) ax[i]++; else if (ad[i] == 2) ay[i]++; else ax[i]--;
      ax[i] = (ax[i] + cols) % cols; ay[i] = (ay[i] + rows) % rows;
    }
  }
  void draw(PGraphics pg, float alpha) {
    pg.background(0, 0);
    pg.noStroke();
    int states = rule.length();
    for (int y = 0; y < rows; y++) for (int x = 0; x < cols; x++) {
      int s = grid[y * cols + x];
      if (s == 0) continue;
      pg.fill(hsb(hue + s * (120.0 / states), 50, 45 + 50 * s / (float) states));
      pg.rect(x * cell, y * cell, cell, cell);
    }
    pg.fill(255);
    for (int i = 0; i < ants; i++) pg.rect(ax[i] * cell - 1, ay[i] * cell - 1, cell + 2, cell + 2);
  }
}

// ------------------------------------------------------------------ 6. Utah teapot (<!-- visual: teapot -->)
// Processing 4.5.6 will not create a P3D buffer inside a JAVA2D sketch ("createGraphics() with P3D or
// OPENGL requires size() to use P2D or P3D"), so this is a small software renderer: the 32 patches are
// tessellated once at 8 segments a side, projected each frame, depth-sorted and flat-shaded into the buffer.
class TeapotVisual implements Visual {
  final int SEG = 8;
  float[] mx, my, mz;                 // model-space vertices, centred, unit radius
  int[] tri;                          // 3 indices per triangle
  int[] quad;                         // 4 indices per quad, for the wireframe
  float[] px, py, pz;                 // per frame: projected x/y, view-space z
  float[] vx, vy;                     // per frame: view-space x/y (for normals)
  long[] order;                       // depth key << 32 | triangle index
  float angY = 0.6f, angX = -0.35f, velY = 0, velX = 0, hue;
  float fullHold = 0; boolean fullArmed = true;
  public boolean wireframe = false;
  java.util.Random r;
  String name() { return VISUAL_NAMES[5]; }

  void reset(int seed) {
    r = new java.util.Random(seed);
    hue = 30 + r.nextInt(30);                                    // warm, like porcelain
    if (mx == null) tessellate();
    angY = 0.6f; angX = -0.35f; velY = 0.006f; velX = 0;
  }

  void tessellate() {
    int perPatch = (SEG + 1) * (SEG + 1), n = TEAPOT_PATCH_COUNT * perPatch;
    mx = new float[n]; my = new float[n]; mz = new float[n];
    float[] bu = new float[4], bv = new float[4];
    for (int p = 0; p < TEAPOT_PATCH_COUNT; p++) {
      for (int i = 0; i <= SEG; i++) {
        bernstein(i / (float) SEG, bu);
        for (int j = 0; j <= SEG; j++) {
          bernstein(j / (float) SEG, bv);
          float x = 0, y = 0, z = 0;
          for (int a = 0; a < 4; a++) for (int b = 0; b < 4; b++) {
            int idx = TEAPOT_PATCHES[p * 16 + a * 4 + b] * 3;
            float w = bu[a] * bv[b];
            x += TEAPOT_VERTICES[idx] * w; y += TEAPOT_VERTICES[idx + 1] * w; z += TEAPOT_VERTICES[idx + 2] * w;
          }
          int k = p * perPatch + i * (SEG + 1) + j;
          mx[k] = x; my[k] = z; mz[k] = -y;                        // data is z-up: make y up, keep it right-handed
        }
      }
    }
    // centre and scale to unit radius
    float minX = 1e9f, maxX = -1e9f, minY = 1e9f, maxY = -1e9f, minZ = 1e9f, maxZ = -1e9f;
    for (int k = 0; k < n; k++) { minX = min(minX, mx[k]); maxX = max(maxX, mx[k]); minY = min(minY, my[k]); maxY = max(maxY, my[k]); minZ = min(minZ, mz[k]); maxZ = max(maxZ, mz[k]); }
    float cx = (minX + maxX) / 2, cy = (minY + maxY) / 2, cz = (minZ + maxZ) / 2;
    float rad = 0;
    for (int k = 0; k < n; k++) { mx[k] -= cx; my[k] -= cy; mz[k] -= cz; rad = max(rad, (float) Math.sqrt(mx[k] * mx[k] + my[k] * my[k] + mz[k] * mz[k])); }
    for (int k = 0; k < n; k++) { mx[k] /= rad; my[k] /= rad; mz[k] /= rad; }
    tri = new int[TEAPOT_PATCH_COUNT * SEG * SEG * 6];
    quad = new int[TEAPOT_PATCH_COUNT * SEG * SEG * 4];
    int t = 0, q = 0;
    for (int p = 0; p < TEAPOT_PATCH_COUNT; p++) for (int i = 0; i < SEG; i++) for (int j = 0; j < SEG; j++) {
      int a = p * perPatch + i * (SEG + 1) + j, b = a + 1, c = a + SEG + 1, d = c + 1;
      tri[t++] = a; tri[t++] = c; tri[t++] = b;
      tri[t++] = b; tri[t++] = c; tri[t++] = d;
      quad[q++] = a; quad[q++] = b; quad[q++] = d; quad[q++] = c;
    }
    px = new float[n]; py = new float[n]; pz = new float[n]; vx = new float[n]; vy = new float[n];
    order = new long[tri.length / 3];
    println("teapot: " + TEAPOT_PATCH_COUNT + " patches, " + n + " vertices, " + (tri.length / 3) + " triangles");
  }

  void bernstein(float t, float[] out) {
    float u = 1 - t;
    out[0] = u * u * u; out[1] = 3 * t * u * u; out[2] = 3 * t * t * u; out[3] = t * t * t;
  }

  /** p2 spins around Y, p1 tilts around X, with momentum. Near-full deflection kicks the spin. Full
   *  deflection held a second toggles wireframe; release before it can toggle again. */
  void update(float p1, float p2) {
    float mag = (float) Math.sqrt(p1 * p1 + p2 * p2);
    velY += p2 * 0.0035f;
    velX += p1 * 0.0030f;
    if (mag > 0.95f) { velY *= 1.04f; velX *= 1.02f; }
    velY *= 0.975f; velX *= 0.96f;
    if (mag < 0.05f && abs(velY) < 0.006f) velY = lerp(velY, 0.006f, 0.03f);   // idle: slow auto-spin
    velY = constrain(velY, -0.25f, 0.25f); velX = constrain(velX, -0.2f, 0.2f);
    angY += velY; angX += velX;
    if (mag > 0.3f && frameCount % 30 == 0) println("teapot: stick p1 " + nf(p1, 1, 2) + " p2 " + nf(p2, 1, 2) + "  spin " + nf(velY, 1, 3) + "  tilt " + nf(velX, 1, 3) + (wireframe ? "  wireframe" : ""));
    if (mag > 0.97f) { if (fullArmed) { fullHold += 1 / 60.0f; if (fullHold >= 1) { wireframe = !wireframe; fullArmed = false; } } }
    else { fullHold = 0; fullArmed = true; }
  }

  void draw(PGraphics pg, float alpha) {
    pg.background(0, 0);
    float cy = cos(angY), sy = sin(angY), cx = cos(angX), sx = sin(angX);
    float camZ = 3.2f, focal = VH * 1.05f, ox = VW * 0.70f, oy = VH * 0.54f;
    int n = mx.length;
    for (int k = 0; k < n; k++) {
      float x1 = mx[k] * cy + mz[k] * sy, z1 = -mx[k] * sy + mz[k] * cy, y1 = my[k];   // spin around Y
      float y2 = y1 * cx - z1 * sx, z2 = y1 * sx + z1 * cx;                              // tilt around X
      float zc = z2 + camZ, sc = focal / zc;
      px[k] = ox + x1 * sc; py[k] = oy - y2 * sc; pz[k] = zc; vx[k] = x1; vy[k] = y2;
    }
    if (wireframe) {
      pg.noFill(); pg.stroke(hsb(hue, 25, 95)); pg.strokeWeight(0.8f);
      for (int q = 0; q < quad.length; q += 4) {
        int a = quad[q], b = quad[q + 1], c = quad[q + 2], d = quad[q + 3];
        pg.line(px[a], py[a], px[b], py[b]); pg.line(px[a], py[a], px[c], py[c]);
        if ((q / 4) % SEG == SEG - 1) pg.line(px[b], py[b], px[d], py[d]);   // close the far edge of each row
        if ((q / 4) % (SEG * SEG) >= SEG * (SEG - 1)) pg.line(px[c], py[c], px[d], py[d]);
      }
      return;
    }
    int m = tri.length / 3;
    for (int t = 0; t < m; t++) {                                     // far first: key = -depth as sortable bits
      float d = pz[tri[t * 3]] + pz[tri[t * 3 + 1]] + pz[tri[t * 3 + 2]];
      int bits = Float.floatToIntBits(-d); bits ^= (bits >> 31) & 0x7FFFFFFF;   // make negative floats sort correctly
      order[t] = ((long) bits << 32) | t;
    }
    java.util.Arrays.sort(order);
    float lx = -0.4f, ly = 0.75f, lz = -0.55f;                      // light from upper left, toward the camera
    float ll = (float) Math.sqrt(lx * lx + ly * ly + lz * lz); lx /= ll; ly /= ll; lz /= ll;
    // No anti-aliasing: it leaves hairline seams between triangles and costs twice as much.
    java.awt.Graphics2D g2 = (pg instanceof processing.awt.PGraphicsJava2D) ? ((processing.awt.PGraphicsJava2D) pg).g2 : null;
    Object aa = null;
    if (g2 != null) { aa = g2.getRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING); g2.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING, java.awt.RenderingHints.VALUE_ANTIALIAS_OFF); }
    pg.noStroke();
    for (int o = 0; o < m; o++) {
      int t = (int) (order[o] & 0xFFFFFFFFL) * 3, a = tri[t], b = tri[t + 1], c = tri[t + 2];
      float sx1 = px[b] - px[a], sy1 = py[b] - py[a], sx2 = px[c] - px[a], sy2 = py[c] - py[a];
      if (abs(sx1 * sy2 - sy1 * sx2) < 0.05f) continue;                       // degenerate on screen
      // flat shading from the view-space normal, two-sided because the patch winding is not consistent
      float ux = vx[b] - vx[a], uy = vy[b] - vy[a], uz = pz[b] - pz[a];
      float wx = vx[c] - vx[a], wy = vy[c] - vy[a], wz = pz[c] - pz[a];
      float nx = uy * wz - uz * wy, ny = uz * wx - ux * wz, nz = ux * wy - uy * wx;
      float nl = (float) Math.sqrt(nx * nx + ny * ny + nz * nz); if (nl == 0) continue;
      float lambert = abs((nx * lx + ny * ly + nz * lz) / nl);
      float rim = 1 - abs(nz / nl);                                            // edges catch some light
      float bright = 22 + 70 * lambert + 10 * rim;
      pg.fill(hsb(hue, 34 - 16 * lambert, bright));
      pg.triangle(px[a], py[a], px[b], py[b], px[c], py[c]);
    }
    if (g2 != null && aa != null) g2.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING, aa);
  }
}
