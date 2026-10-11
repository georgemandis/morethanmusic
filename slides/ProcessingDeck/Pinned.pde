// Pinned.pde - visuals built for one slide each, pinned from the markdown with <!-- visual: NAME -->.
// They draw at full resolution (drawHires) because text and fine lines blur through the 480x270 buffer.
// alpha is the same quiet/loud opacity the other visuals get.

// ------------------------------------------------------------------ bytes: [144, 60, 127] live
// Three big bytes top-right with their binary, and a device picker under them. The digits show the last
// message from the picked input (or from any input for "All inputs"), with the device name and how old
// it is. Until that device has sent something, the stick sweeps the two data bytes and 144 stays:
// left/right is data 1, up/down is data 2. Tab cycles the picker, the mouse clicks it. Default: the PipSqueak.
class BytesVisual implements Visual {
  float d1 = 60, d2 = 127;
  int picked = -1;                        // -1 = all inputs, else index into tap.ports
  boolean pickedOnce = false;
  PGraphics cache; String cacheKey = "";
  ArrayList<float[]> hits = new ArrayList<float[]>();   // x, y, w, h, index
  String name() { return VISUAL_NAMES[6]; }
  boolean usesBuffer() { return false; }
  void reset(int seed) { d1 = 60; d2 = 127; }
  void update(float p1, float p2) {
    d1 = constrain(d1 + p2 * 1.1f, 0, 127); d2 = constrain(d2 + p1 * 1.1f, 0, 127);
    if ((abs(p1) > 0.3f || abs(p2) > 0.3f) && frameCount % 30 == 0) println("bytes: stick -> [144, " + round(d1) + ", " + round(d2) + "]");
  }
  void draw(PGraphics pg, float alpha) {}

  TapPort pickedPort() {
    if (tap == null) return null;
    if (!pickedOnce) { TapPort p = tap.findByName("pipsqueak"); picked = p == null ? -1 : tap.ports.indexOf(p); pickedOnce = true; }
    if (picked >= tap.ports.size()) picked = -1;
    return picked < 0 ? tap.latest() : tap.ports.get(picked);
  }
  void cycle() { if (tap == null) return; pickedOnce = true; picked++; if (picked >= tap.ports.size()) picked = -1; println("bytes: showing " + (picked < 0 ? "all inputs" : tap.ports.get(picked).name)); }
  boolean click(float x, float y) {
    for (float[] h : hits) if (x >= h[0] && x <= h[0] + h[2] && y >= h[1] && y <= h[1] + h[3]) { pickedOnce = true; picked = (int) h[4]; println("bytes: showing " + (picked < 0 ? "all inputs" : tap.ports.get(picked).name)); return true; }
    return false;
  }

  void drawHires(PApplet app, float alpha) {
    float a = min(1, alpha * 2.4f), u = app.height / 1080.0f;
    TapPort port = pickedPort();
    boolean live = port != null && port.count > 0;
    int s = live ? port.status : 144, v1 = live ? port.d1 : round(d1), v2 = live ? port.d2 : round(d2);
    String device = live ? port.name + "  " + port.kind() : null;
    String key = s + "/" + v1 + "/" + v2 + "/" + device + "/" + mode + "/" + app.width + "x" + app.height;
    float blockW = 3 * 270 * u + 40 * u, blockH = 130 * 1.02f * u + 170 * u;
    if (cache == null || !key.equals(cacheKey)) {                 // redraw only on change
      if (cache == null || cache.width != round(blockW) || cache.height != round(blockH)) cache = createGraphics(round(blockW), round(blockH));
      cacheKey = key;
      cache.beginDraw(); cache.background(0, 0);
      float right = blockW - 20 * u, y = 0, size = 130 * u, colW = 270 * u;
      String[] parts = { str(s), str(v1), str(v2) };
      String[] labels = { "status", "data: which", "data: how much" };
      int[] cols = { color(255, 170, 90), TEXT, TEXT };
      for (int i = 0; i < 3; i++) {
        float cx = right - (2 - i) * colW - colW / 2;
        cache.textFont(font(serifFamily, java.awt.Font.PLAIN, size)); cache.textAlign(CENTER, BASELINE); cache.fill(cols[i]);
        cache.text(parts[i], cx, y + size * 0.8f);
        cache.textFont(font(monoFamily, java.awt.Font.PLAIN, 28 * u)); cache.textAlign(CENTER, TOP); cache.fill(CODE, 230);
        cache.text(bin(i == 0 ? s : i == 1 ? v1 : v2), cx, y + size * 1.02f);
        cache.textFont(font(sansFamily, java.awt.Font.PLAIN, 22 * u)); cache.fill(FADED, 220);
        cache.text(labels[i], cx, y + size * 1.02f + 40 * u);
      }
      cache.textAlign(RIGHT, TOP); cache.textFont(font(sansFamily, java.awt.Font.PLAIN, 22 * u)); cache.fill(FADED, 200);
      if (device != null) cache.text(device, right - 70 * u, y + size * 1.02f + 90 * u);
      else if (mode == INTERACTIVE) cache.text("left / right: data 1.  up / down: data 2", right, y + size * 1.02f + 90 * u);
      cache.endDraw();
    }
    float bx = app.width - 120 * u - blockW + 20 * u, by = 150 * u;
    tint(255, 255 * a); image(cache, bx, by); noTint();
    // age, outside the cache because it ticks
    if (live) {
      float age = (millis() - port.lastMillis) / 1000.0f;
      float ax = bx + blockW - 20 * u, ay = by + 130 * 1.02f * u + 90 * u;
      noStroke(); fill(age < 0.3f ? color(120, 230, 150) : FADED, 230 * a); circle(ax - 8 * u, ay + 12 * u, 10 * u);
      textAlign(RIGHT, TOP); textFont(font(monoFamily, java.awt.Font.PLAIN, 20 * u)); fill(FADED, 220 * a);
      text(age < 1 ? nf(age, 1, 1) + " s" : age < 60 ? round(age) + " s" : round(age / 60) + " m", ax - 20 * u, ay + 2 * u);
    }
    // the picker
    hits.clear();
    if (tap == null) return;
    float px = bx + 20 * u, py = by + blockH + 10 * u, rowH = 30 * u, size22 = 22 * u;
    textFont(font(sansFamily, java.awt.Font.PLAIN, size22)); textAlign(LEFT, TOP);
    for (int i = -1; i < tap.ports.size(); i++) {
      String label = i < 0 ? "All inputs" : tap.ports.get(i).name;
      boolean on = i == picked;
      float w = textWidth(label) + 36 * u, ry = py + (i + 1) * rowH;
      if (on) { noStroke(); fill(255, 28 * a); rect(px, ry - 3 * u, w, rowH - 2 * u, 8 * u); }
      noStroke(); fill(on ? color(120, 230, 150) : FADED, (on ? 230 : 140) * a); circle(px + 12 * u, ry + size22 * 0.55f, 8 * u);
      fill(on ? TEXT : FADED, (on ? 240 : 180) * a); text(label, px + 28 * u, ry);
      if (i >= 0 && tap.ports.get(i).count > 0) { fill(FADED, 150 * a); textFont(font(monoFamily, java.awt.Font.PLAIN, 18 * u)); text(tap.ports.get(i).count + "", px + w + 6 * u, ry + 3 * u); textFont(font(sansFamily, java.awt.Font.PLAIN, size22)); }
      hits.add(new float[] { px, ry - 3 * u, w + 60 * u, rowH, i });
    }
    fill(FADED, 150 * a); textFont(font(sansFamily, java.awt.Font.PLAIN, 18 * u));
    text("Tab or click picks the device", px, py + (tap.ports.size() + 1) * rowH + 6 * u);
  }
  String bin(int v) { String b = Integer.toBinaryString(v & 0xFF); while (b.length() < 8) b = "0" + b; return b; }
}

// ------------------------------------------------------------------ bananas: touch one, get a note
// Three bananas wired to a board. INTERACTIVE: left/right picks one, a push up touches it: a note-on
// ripple and the bytes it sends. Idle: they bob. When the slide carries a photo, the cartoon stays out of
// the way: only the ripples and the bytes draw, on top of the photo, from three spots along its bottom edge.
class BananasVisual implements Visual {
  int picked = 1; boolean touchArmed = true; float t = 0;
  ArrayList<float[]> ripples = new ArrayList<float[]>();   // banana index, age (s), note
  int[] notes = { 60, 62, 64 };
  String name() { return VISUAL_NAMES[7]; }
  boolean usesBuffer() { return false; }
  void reset(int seed) { picked = 1; ripples.clear(); t = 0; touchArmed = true; }
  void update(float p1, float p2) {
    t += 1 / 60.0f;
    if (p2 > 0.5f) picked = 2; else if (p2 < -0.5f) picked = 0; else if (abs(p2) < 0.2f && abs(p1) < 0.2f) { /* keep */ }
    if (abs(p2) < 0.2f && abs(p1) < 0.2f && picked != 1 && false) picked = 1;
    if (p1 > 0.6f && touchArmed) { touchArmed = false; ripples.add(new float[] { picked, 0, notes[picked] }); println("bananas: touched banana " + picked + " -> note " + notes[picked]); }
    else if (p1 < 0.3f) touchArmed = true;
    for (int i = ripples.size() - 1; i >= 0; i--) { ripples.get(i)[1] += 1 / 60.0f; if (ripples.get(i)[1] > 1.6f) ripples.remove(i); }
  }
  void draw(PGraphics pg, float alpha) {}
  boolean onPhoto() { return current().photo() != null && photoW > 0; }
  void drawAbove(PApplet app, float alpha) {
    if (!onPhoto()) return;
    float a = min(1, alpha * 2.2f), u = app.height / 1080.0f;
    for (int i = 0; i < 3; i++) {                                   // the three touch spots along the bottom edge
      float x = photoX + photoW * (0.25f + 0.25f * i), y = photoY + photoH - 24 * u;
      boolean hot = mode == INTERACTIVE && i == picked;
      noStroke(); fill(255, 225, 70, (hot ? 230 : 110) * a); circle(x, y, (hot ? 22 : 14) * u);
    }
    for (float[] r : ripples) {
      int i = (int) r[0]; float age = r[1], k = age / 1.6f;
      float x = photoX + photoW * (0.25f + 0.25f * i), y = photoY + photoH - 24 * u;
      noFill(); stroke(255, 230, 120, 230 * a * (1 - k)); strokeWeight(3 * u * (1 - k) + 1);
      circle(x, y, 40 * u + k * 420 * u);
      fill(CODE, 255 * a * (1 - k * k)); noStroke(); textAlign(CENTER, BOTTOM); textFont(font(monoFamily, java.awt.Font.PLAIN, 34 * u));
      text("[144, " + (int) r[2] + ", 127]", x, y - 60 * u - k * 80 * u);
    }
    if (mode == INTERACTIVE) { fill(FADED, 200 * a); textAlign(CENTER, TOP); textFont(font(sansFamily, java.awt.Font.PLAIN, 22 * u)); text("left / right picks a banana. push up to touch it", photoX + photoW / 2, photoY + photoH + 14 * u); }
  }
  void drawHires(PApplet app, float alpha) {
    if (onPhoto()) return;
    float a = min(1, alpha * 2.2f), u = app.height / 1080.0f;
    float cx = app.width * 0.73f, cy = app.height * 0.42f, spacing = 230 * u;
    float bx = cx, by = app.height * 0.80f;                      // the board
    noFill(); strokeWeight(2 * u);
    for (int i = 0; i < 3; i++) {
      float x = cx + (i - 1) * spacing, y = cy + sin(t * 1.3f + i) * 8 * u;
      stroke(180, 180, 190, 110 * a); line(x, y + 40 * u, bx + (i - 1) * 26 * u, by - 46 * u);   // clip lead
      boolean hot = mode == INTERACTIVE && i == picked;
      drawBanana(x, y, 150 * u, hot ? a : a * 0.75f, hot);
    }
    // the board: a disc with ten pixels that light on a touch
    noStroke(); fill(40, 60, 50, 200 * a); circle(bx, by, 110 * u);
    stroke(120, 150, 130, 160 * a); strokeWeight(1.5f * u); noFill(); circle(bx, by, 110 * u);
    float lit = 0; for (float[] r : ripples) lit = max(lit, 1 - r[1] / 1.6f);
    for (int k = 0; k < 10; k++) { float ang = k * TWO_PI / 10 - HALF_PI; noStroke(); fill(lerpColor(color(60, 70, 65), color(120, 255, 150), lit), 230 * a); circle(bx + cos(ang) * 40 * u, by + sin(ang) * 40 * u, 9 * u); }
    // ripples and the bytes they send
    for (float[] r : ripples) {
      int i = (int) r[0]; float age = r[1], k = age / 1.6f;
      float x = cx + (i - 1) * spacing, y = cy + sin(t * 1.3f + i) * 8 * u;
      noFill(); stroke(255, 230, 120, 220 * a * (1 - k)); strokeWeight(3 * u * (1 - k) + 1);
      circle(x, y, 60 * u + k * 420 * u);
      fill(CODE, 255 * a * (1 - k * k)); noStroke(); textAlign(CENTER, BOTTOM); textFont(font(monoFamily, java.awt.Font.PLAIN, 34 * u));
      text("[144, " + (int) r[2] + ", 127]", x, y - 100 * u - k * 60 * u);
    }
    if (mode == INTERACTIVE) { fill(FADED, 200 * a); textAlign(CENTER, TOP); textFont(font(sansFamily, java.awt.Font.PLAIN, 22 * u)); text("left / right picks a banana. push up to touch it", cx, by + 70 * u); }
  }
  void drawBanana(float x, float y, float len, float a, boolean hot) {
    pushMatrix(); translate(x, y); rotate(-0.5f);
    noStroke(); fill(hot ? color(255, 225, 70) : color(235, 200, 60), 235 * a);
    beginShape();
    vertex(-len * 0.5f, 0);
    bezierVertex(-len * 0.3f, -len * 0.42f, len * 0.3f, -len * 0.42f, len * 0.5f, 0);
    bezierVertex(len * 0.3f, -len * 0.12f, -len * 0.3f, -len * 0.12f, -len * 0.5f, 0);
    endShape(CLOSE);
    stroke(120, 90, 30, 220 * a); strokeWeight(3); line(-len * 0.5f, 0, -len * 0.56f, len * 0.05f); line(len * 0.5f, 0, len * 0.55f, len * 0.04f);
    popMatrix();
  }
}

// ------------------------------------------------------------------ hothand: three CCs mix a colour
// INTERACTIVE: left/right is X (red), up/down is Y (green), how far you push is Z (blue). Idle: the three
// drift on slow sines, like someone waving. The mix tints the whole slide.
class HotHandVisual implements Visual {
  float r = 90, g = 60, b = 40, t = 0; boolean driven = false;
  String name() { return VISUAL_NAMES[8]; }
  void reset(int seed) { r = 90; g = 60; b = 40; t = 0; }
  void update(float p1, float p2) {
    t += 1 / 60.0f;
    driven = abs(p1) > 0.1f || abs(p2) > 0.1f;
    if (driven) { r = constrain(r + p2 * 1.4f, 0, 127); g = constrain(g + p1 * 1.4f, 0, 127); b = lerp(b, 127 * min(1, (float) Math.sqrt(p1 * p1 + p2 * p2)), 0.1f); if (frameCount % 30 == 0) println("hothand: stick -> X " + round(r) + " Y " + round(g) + " Z " + round(b)); }
    else { r = lerp(r, 64 + 50 * sin(t * 0.37f), 0.01f); g = lerp(g, 64 + 50 * sin(t * 0.53f + 2), 0.01f); b = lerp(b, 64 + 50 * sin(t * 0.29f + 4), 0.01f); }
  }
  void draw(PGraphics pg, float alpha) { pg.background(color(r * 2, g * 2, b * 2)); }   // the whole slide takes the mix
  void drawHires(PApplet app, float alpha) {
    float a = min(1, alpha * 2.2f), u = app.height / 1080.0f;
    int mix = color(r * 2, g * 2, b * 2);
    float cx = app.width * 0.80f, baseY = app.height * 0.74f, barW = 90 * u, barH = 340 * u, gap = 60 * u;
    String[] axes = { "X", "Y", "Z" }; float[] vals = { r, g, b }; int[] cols = { color(255, 90, 90), color(110, 230, 120), color(110, 150, 255) };
    for (int i = 0; i < 3; i++) {
      float x = cx + (i - 1) * (barW + gap) - barW / 2;
      noStroke(); fill(255, 18 * a); rect(x, baseY - barH, barW, barH, 10 * u);
      fill(cols[i], 220 * a); rect(x, baseY - barH * vals[i] / 127, barW, barH * vals[i] / 127, 10 * u);
      fill(TEXT, 230 * a); textAlign(CENTER, TOP); textFont(font(sansFamily, java.awt.Font.BOLD, 30 * u)); text(axes[i], x + barW / 2, baseY + 12 * u);
      fill(CODE, 230 * a); textFont(font(monoFamily, java.awt.Font.PLAIN, 24 * u)); text("CC " + (i + 1) + " = " + round(vals[i]), x + barW / 2, baseY + 50 * u);
    }
    noStroke(); fill(mix, 255 * a); circle(cx, baseY - barH - 110 * u, 120 * u);
    stroke(255, 120 * a); strokeWeight(2 * u); noFill(); circle(cx, baseY - barH - 110 * u, 120 * u);
    fill(FADED, 220 * a); noStroke(); textAlign(CENTER, TOP); textFont(font(sansFamily, java.awt.Font.PLAIN, 22 * u));
    text(mode == INTERACTIVE ? "left / right: X.  up / down: Y.  how far: Z" : "X, Y, Z become red, green, blue", cx, baseY + 90 * u);
  }
}

// ------------------------------------------------------------------ qr: the slide's URLs as codes
// One code per URL on the slide, with the line after the URL as its label. One code sits bottom-right;
// two or more sit in a strip along the bottom that the text layout leaves free. Always full contrast,
// black on white, in every mode: a faded code does not scan from the back of the room. INTERACTIVE:
// up/down scales, left/right tilts with momentum and eases back.
class QRVisual implements Visual {
  ArrayList<QRCode> codes = new ArrayList<QRCode>(); String[] urls = new String[0], labels = new String[0];
  float scale = 1, tilt = 0, tiltVel = 0;
  String name() { return VISUAL_NAMES[9]; }
  boolean usesBuffer() { return false; }
  float reserveBottom(float u) { return codes.size() >= 2 ? 470 * u : 0; }
  void setTexts(String[] newUrls, String[] newLabels) {
    if (java.util.Arrays.equals(newUrls, urls)) { labels = newLabels; return; }
    urls = newUrls; labels = newLabels; codes.clear();
    for (String url : urls) {
      QRCode c = new QRCode(url); codes.add(c);
      println("qr: " + (c.ok ? "version " + c.version + ", " + c.size + "x" + c.size + " for " : "could not encode ") + url);
    }
  }
  void reset(int seed) { scale = 1; tilt = 0; tiltVel = 0; }
  void update(float p1, float p2) {
    scale = constrain(scale * (1 + p1 * 0.012f), 0.6f, 1.7f);
    tiltVel = (tiltVel + p2 * 0.004f) * 0.9f;
    tilt += tiltVel; tilt *= abs(p2) > 0.1f ? 1 : 0.97f;
    tilt = constrain(tilt, -1.1f, 1.1f);
    if ((abs(p1) > 0.3f || abs(p2) > 0.3f) && frameCount % 30 == 0) println("qr: stick -> scale " + nf(scale, 1, 2) + " tilt " + nf(tilt, 1, 2));
  }
  void draw(PGraphics pg, float alpha) {}
  void drawHires(PApplet app, float alpha) {
    int n = 0; for (QRCode c : codes) if (c.ok) n++;
    if (n == 0) return;
    float a = 1, u = app.height / 1080.0f;                            // full contrast in every mode, on purpose
    float box, gap = 90 * u, cy, x0;
    if (n == 1) { box = 400 * u * scale; cy = app.height * 0.72f; x0 = app.width * 0.865f - box / 2; }
    else { box = 360 * u * scale; cy = app.height - 80 * u - 180 * u * scale; x0 = app.width / 2.0f - (n * box + (n - 1) * gap) / 2; }
    int k = 0;
    for (int i = 0; i < codes.size(); i++) {
      QRCode code = codes.get(i);
      if (!code.ok) continue;
      float cx = x0 + box / 2 + k * (box + gap);
      drawCode(code, cx, cy, box, a, u);
      if (i < labels.length && labels[i] != null) { fill(TEXT, 230 * a); noStroke(); textAlign(CENTER, TOP); textFont(font(sansFamily, java.awt.Font.PLAIN, 24 * u)); text(labels[i], cx, cy + box / 2 + 10 * u); }
      k++;
    }
    if (mode == INTERACTIVE) { fill(FADED, 200 * a); textAlign(CENTER, TOP); textFont(font(sansFamily, java.awt.Font.PLAIN, 22 * u)); text("up / down: size.  left / right: tilt.  Scan it.", n == 1 ? x0 + box / 2 : app.width / 2.0f, cy + box / 2 + (n == 1 ? 16 : 44) * u); }
  }
  /** Rects every frame on purpose: 400 rects cost 1.5 ms. A cached image drawn scaled and tinted through
   *  JAVA2D measured 14 to 17 ms. */
  void drawCode(QRCode code, float cx, float cy, float box, float a, float u) {
    int m = code.size, quiet = 3; float cell = box / (m + 2 * quiet);
    pushMatrix(); translate(cx, cy);
    applyMatrix(cos(tilt), 0, 0, sin(tilt) * 0.22f, 1, 0);         // squash and shear: a tilted card
    noStroke(); fill(245, 245, 240, 255 * a); rect(-box / 2, -box / 2, box, box, 8 * u);
    fill(20, 22, 30, 255 * a);
    float ox = -box / 2 + quiet * cell, oy = -box / 2 + quiet * cell;
    for (int y = 0; y < m; y++) for (int x = 0; x < m; x++) if (code.module(x, y)) rect(ox + x * cell, oy + y * cell, cell + 0.5f, cell + 0.5f);
    popMatrix();
  }
}

/** A small QR encoder, no library: byte mode, level L, versions 1 to 5 (up to 106 bytes), Reed-Solomon
 *  over GF(256), standard placement, the eight masks scored with the first two penalty rules. */
class QRCode {
  boolean ok = false; int version, size; boolean[][] m, fn;
  final int[] DATA_CW = { 0, 19, 34, 55, 80, 108 }, EC_CW = { 0, 7, 10, 15, 20, 26 }, ALIGN = { 0, 0, 18, 22, 26, 30 };
  int[] exp = new int[512], log = new int[256];

  QRCode(String s) {
    byte[] data; try { data = s.getBytes("UTF-8"); } catch (Exception e) { return; }
    version = 0; for (int v = 1; v <= 5; v++) if (data.length <= DATA_CW[v] - 2) { version = v; break; }
    if (version == 0) return;
    size = 17 + 4 * version;
    for (int i = 0, x = 1; i < 255; i++) { exp[i] = x; log[x] = i; x <<= 1; if (x >= 256) x ^= 0x11D; }
    for (int i = 255; i < 512; i++) exp[i] = exp[i - 255];
    // bit stream: mode 0100, 8-bit count, bytes, terminator, pad bytes
    int dcw = DATA_CW[version];
    int[] bits = new int[dcw * 8]; int p = 0;
    p = put(bits, p, 4, 4); p = put(bits, p, data.length, 8);
    for (byte b : data) p = put(bits, p, b & 0xFF, 8);
    p = put(bits, p, 0, min(4, bits.length - p));
    while (p % 8 != 0) p++;
    int[] codewords = new int[dcw];
    for (int i = 0; i < dcw; i++) { int c = 0; for (int k = 0; k < 8; k++) c = (c << 1) | bits[i * 8 + k]; codewords[i] = c; }
    for (int i = p / 8, k = 0; i < dcw; i++, k++) codewords[i] = (k % 2 == 0) ? 0xEC : 0x11;
    int[] ec = reedSolomon(codewords, EC_CW[version]);
    int[] all = new int[dcw + ec.length];
    System.arraycopy(codewords, 0, all, 0, dcw); System.arraycopy(ec, 0, all, dcw, ec.length);
    // function patterns
    m = new boolean[size][size]; fn = new boolean[size][size];
    finder(0, 0); finder(size - 7, 0); finder(0, size - 7);
    for (int i = 0; i < 8; i++) { setFn(i, 7, false); setFn(7, i, false); setFn(size - 8 + i, 7, false); setFn(size - 8, i, false); setFn(i, size - 8, false); setFn(7, size - 8 + i, false); }
    for (int i = 8; i < size - 8; i++) { setFn(i, 6, i % 2 == 0); setFn(6, i, i % 2 == 0); }
    if (ALIGN[version] > 0) { int c = ALIGN[version]; for (int dy = -2; dy <= 2; dy++) for (int dx = -2; dx <= 2; dx++) setFn(c + dx, c + dy, max(abs(dx), abs(dy)) != 1); }
    setFn(8, size - 8, true);                                   // the dark module
    for (int i = 0; i < 9; i++) { reserve(i, 8); reserve(8, i); }
    for (int i = 0; i < 8; i++) { reserve(size - 1 - i, 8); reserve(8, size - 1 - i); }
    // place data, then choose a mask
    boolean[][] placed = new boolean[size][size];
    int bi = 0, total = all.length * 8;
    for (int right = size - 1; right >= 1; right -= 2) {
      if (right == 6) right = 5;
      for (int vert = 0; vert < size; vert++) {
        for (int j = 0; j < 2; j++) {
          int x = right - j; boolean upward = ((right + 1) & 2) == 0;
          int y = upward ? size - 1 - vert : vert;
          if (fn[y][x]) continue;
          boolean bit = bi < total && ((all[bi >> 3] >> (7 - (bi & 7))) & 1) == 1; bi++;
          placed[y][x] = bit;
        }
      }
    }
    int best = 0, bestScore = Integer.MAX_VALUE;
    for (int mask = 0; mask < 8; mask++) { apply(placed, mask); int sc = penalty(); if (sc < bestScore) { bestScore = sc; best = mask; } }
    apply(placed, best);
    ok = true;
  }

  boolean module(int x, int y) { return m[y][x]; }
  void setFn(int x, int y, boolean v) { if (x >= 0 && y >= 0 && x < size && y < size) { m[y][x] = v; fn[y][x] = true; } }
  void reserve(int x, int y) { fn[y][x] = true; }
  void finder(int x0, int y0) { for (int dy = 0; dy < 7; dy++) for (int dx = 0; dx < 7; dx++) { boolean on = dx == 0 || dx == 6 || dy == 0 || dy == 6 || (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4); setFn(x0 + dx, y0 + dy, on); } }
  int put(int[] bits, int p, int value, int n) { for (int i = n - 1; i >= 0; i--) bits[p++] = (value >> i) & 1; return p; }

  int[] reedSolomon(int[] data, int n) {
    int[] gen = { 1 };
    for (int i = 0; i < n; i++) { int[] g = new int[gen.length + 1]; for (int j = 0; j < gen.length; j++) { g[j] ^= gen[j]; g[j + 1] ^= mul(gen[j], exp[i]); } gen = g; }
    int[] rem = new int[n];
    for (int d : data) { int f = d ^ rem[0]; System.arraycopy(rem, 1, rem, 0, n - 1); rem[n - 1] = 0; if (f != 0) for (int j = 0; j < n; j++) rem[j] ^= mul(gen[j + 1], f); }
    return rem;
  }
  int mul(int a, int b) { return (a == 0 || b == 0) ? 0 : exp[log[a] + log[b]]; }

  void apply(boolean[][] placed, int mask) {
    for (int y = 0; y < size; y++) for (int x = 0; x < size; x++) if (!fn[y][x]) m[y][x] = placed[y][x] ^ maskBit(mask, y, x);
    int fmt = formatBits(mask);
    for (int i = 0; i < 15; i++) {
      boolean bit = ((fmt >> (14 - i)) & 1) == 1;
      // copy one: along row 8 then up column 8
      if (i < 6) m[8][i] = bit; else if (i == 6) m[8][7] = bit; else if (i == 7) m[8][8] = bit; else if (i == 8) m[7][8] = bit; else m[14 - i][8] = bit;
      // copy two: up column 8 from the bottom, then along row 8 at the right
      if (i < 7) m[size - 1 - i][8] = bit; else m[8][size - 15 + i] = bit;
    }
  }
  boolean maskBit(int mask, int i, int j) {
    switch (mask) {
      case 0: return (i + j) % 2 == 0; case 1: return i % 2 == 0; case 2: return j % 3 == 0; case 3: return (i + j) % 3 == 0;
      case 4: return (i / 2 + j / 3) % 2 == 0; case 5: return (i * j) % 2 + (i * j) % 3 == 0;
      case 6: return ((i * j) % 2 + (i * j) % 3) % 2 == 0; default: return ((i + j) % 2 + (i * j) % 3) % 2 == 0;
    }
  }
  int formatBits(int mask) {
    int data = (1 << 3) | mask;                                  // level L = 01
    int rem = data << 10;
    for (int i = 14; i >= 10; i--) if (((rem >> i) & 1) == 1) rem ^= 0x537 << (i - 10);
    return ((data << 10) | rem) ^ 0x5412;
  }
  int penalty() {
    int score = 0;
    for (int y = 0; y < size; y++) { int run = 1; for (int x = 1; x < size; x++) { if (m[y][x] == m[y][x - 1]) { run++; if (run == 5) score += 3; else if (run > 5) score++; } else run = 1; } }
    for (int x = 0; x < size; x++) { int run = 1; for (int y = 1; y < size; y++) { if (m[y][x] == m[y - 1][x]) { run++; if (run == 5) score += 3; else if (run > 5) score++; } else run = 1; } }
    for (int y = 0; y < size - 1; y++) for (int x = 0; x < size - 1; x++) if (m[y][x] == m[y][x + 1] && m[y][x] == m[y + 1][x] && m[y][x] == m[y + 1][x + 1]) score += 3;
    return score;
  }
}
