// ProcessingDeck.pde - the intro deck as a Processing sketch, driven by a useMIDI PipSqueak.
// Keyboard and mouse stand in when there is no stick.
//
// Reads ../Processing Day MIDI Workshop Slides.md (Deck.pde). The Obsidian deck is the fallback.
//
// Stick: click cycles NAVIGATE, LASER, INTERACTIVE. NAVIGATE: left/right slide, up/down fragment.
// LASER: the red dot, trail fades in 2 s. INTERACTIVE: up/down and left/right play the background.
// Keys: arrows, space, Home/End, v visual, r reload, f fullscreen, h help, d debug, shift-Q quit.
// Esc does nothing. Flags: --window[=WxH], --display=N, --slide=N, --frags=N, --mode=..., --shot=path.
// Self-test flags are above selfTestStep().

import java.io.File;
import java.util.HashSet;

final String MD_NAME = "Processing Day MIDI Workshop Slides.md";

PipSqueak stick;                                 // built in setup(), data/pipsqueak.json may configure it
InputTap tap;                                    // every MIDI input, for the bytes slides (Inputs.pde)
Deck deck;
String deckPath = "";
// hot reload: poll mtime twice a second, reload once it has sat still for 300 ms
long deckMtime = 0, pendingMtime = -1; int pendingSince = 0, lastPoll = 0; String watchPath = null;
String toast = null; int toastUntil = 0;
int slide = 0, revealed = 0;

final int NAVIGATE = 0, LASER = 1, INTERACTIVE = 2;
final String[] MODE_NAMES = { "NAVIGATE", "LASER", "INTERACTIVE" };
int mode = NAVIGATE;

// command-line flags
boolean argWindow = false; int argW = 1280, argH = 720;
boolean argFullscreen = false;        // --fullscreen; the default is a window
int argSlide = 0, argFrags = 0, argMode = NAVIGATE, argDensity = 0, argDisplay = 0; String argShot = null, argMd = null;
boolean argNoViz = false, argDemo = false, argNoStick = false, argTestF = false; int argInterp = 0, shotT0 = 0;   // interp 0 nearest, 1 bilinear (28 ms a frame here)
String[] argKeys = null, argMidi = null, argTapMidi = null; String argQr = null;
// profiler: nanoseconds per stage over the shot window, frames 90 to 150
long profVisual = 0, profBlit = 0, profHires = 0, profSlide = 0, profLaser = 0, profFrame = 0; int profFrames = 0;
long profLoad = 0, profBlend = 0, profDraw = 0;   // inside blitViz

// look
int BG, TEXT, TITLE, FADED, CODE, LASER_RED;
String serifFamily, sansFamily, monoFamily;
HashMap<String, PFont> fontCache = new HashMap<String, PFont>();
float ui = 1;                                    // sizes are for 1080 rows, scaled by this

// visuals
PGraphics viz;
Visual visual; int visualKind = -1;
int[] rerolls = new int[0];
final int[] VISUAL_ORDER = { 2, 0, 3, 1, 4 };    // consecutive slides never share a kind
float vizAlpha = 0.15, vizTarget = 0.15;
final float VIZ_QUIET = 0.15, VIZ_LOUD = 0.40;

// laser
PVector laserPos = new PVector(), laserVel = new PVector();
ArrayList<float[]> trail = new ArrayList<float[]>();   // x, y, millis
final int TRAIL_MS = 2000;

// stick navigation, edge-triggered: a held stick moves one step. No edges in the first half second after
// connect: the helper is still learning the unit's map and rest position, and a hand on the stick at
// launch must not turn pages.
boolean navArmed = true; int navQuietUntil = 0, argNavQuiet = 500;
boolean mouseActive = false;
boolean showHelp = false, showDebug = false;
HashSet<Integer> heldKeys = new HashSet<Integer>();
String standInNote = null;
// debug overlay (key d)
ArrayList<String> rawLog = new ArrayList<String>();   // last raw messages, newest last
int rawCount = 0, lastRawMillis = -1;
String lastNavEdge = "(none yet)"; int lastNavMillis = -1;
boolean wantFullscreen = false;      // set in settings(); applied once the window exists
float contentTop, contentHeight, contentRight;    // last layout, for the dimming panel
float photoX, photoY, photoW, photoH;             // where the slide's photo landed this frame, 0 when none
HashMap<String, PImage> photos = new HashMap<String, PImage>();   // key: path @ width

// ------------------------------------------------------------------ startup
void settings() {
  parseArgs();
  // Processing's fullScreen() aborts the JVM on macOS 26 (AppKit refuses its menu-bar change off the
  // main thread), so start as a window and let toggleFullscreen() take the display on the first frames.
  size(argW, argH);
  if (argFullscreen && !argWindow) wantFullscreen = true;   // f toggles at any time
  pixelDensity(argDensity > 0 ? argDensity : 1);   // density 2 on a Retina laptop halves the frame rate
}

void parseArgs() {
  if (args == null) return;
  for (String a : args) {
    if (a.equals("--fullscreen") || a.equals("--full")) argFullscreen = true;
    else if (a.equals("--window") || a.equals("--windowed")) argWindow = true;
    else if (a.startsWith("--window=")) { argWindow = true; String[] wh = split(a.substring(9), 'x'); if (wh.length == 2) { argW = int(wh[0]); argH = int(wh[1]); } }
    else if (a.startsWith("--slide=")) argSlide = int(a.substring(8)) - 1;
    else if (a.startsWith("--frags=")) argFrags = int(a.substring(8));
    else if (a.startsWith("--mode=")) { String m = a.substring(7).toLowerCase(); argMode = m.startsWith("l") ? LASER : m.startsWith("i") ? INTERACTIVE : NAVIGATE; }
    else if (a.startsWith("--shot=")) argShot = a.substring(7);
    else if (a.startsWith("--md=")) argMd = a.substring(5);
    else if (a.startsWith("--density=")) argDensity = int(a.substring(10));
    else if (a.startsWith("--display=")) argDisplay = int(a.substring(10));
    else if (a.equals("--noviz")) argNoViz = true;
    else if (a.equals("--demo")) argDemo = true;
    else if (a.equals("--nostick")) argNoStick = true;
    else if (a.equals("--test-f")) argTestF = true;
    else if (a.equals("--help")) showHelp = true;
    else if (a.equals("--debug")) showDebug = true;
    else if (a.startsWith("--keys=")) argKeys = split(a.substring(7), ',');
    else if (a.startsWith("--midi=")) argMidi = split(a.substring(7), ',');
    else if (a.startsWith("--tapmidi=")) argTapMidi = split(a.substring(10), ',');   // self-test: name:status:d1:d2 into the input tap, one every 10 frames from frame 30
    else if (a.startsWith("--qr=")) argQr = a.substring(5);     // self-test: dump the slide's QR code to <path>.png and <path>.txt
    else if (a.startsWith("--interp=")) argInterp = int(a.substring(9));
    else if (a.startsWith("--navquiet=")) argNavQuiet = int(a.substring(11));   // self-test: the no-navigation window after connect, ms
    else println("unknown flag " + a);
  }
}

void setup() {
  frameRate(60);
  surface.setTitle("Processing Deck");
  if (argWindow) surface.setResizable(true);
  BG = color(17, 18, 24); TEXT = color(235, 232, 224); TITLE = color(255, 250, 240);
  FADED = color(150, 150, 162); CODE = color(190, 225, 255); LASER_RED = color(255, 59, 48);
  serifFamily = pickFamily(new String[] { "Georgia", "Palatino", "Iowan Old Style", "Times New Roman", "Serif" });
  sansFamily = pickFamily(new String[] { "Helvetica Neue", "Helvetica", "Arial", "SansSerif" });
  monoFamily = pickFamily(new String[] { "Menlo", "Monaco", "Consolas", "Courier New", "Monospaced" });
  println("fonts: titles " + serifFamily + ", body " + sansFamily + ", code " + monoFamily);
  viz = createGraphics(VW, VH);
  viz.beginDraw(); viz.background(0, 0); viz.endDraw();

  File cfg = dataFile("pipsqueak.json");
  if (cfg.isFile()) { stick = new PipSqueak(this, null, loadJSONObject(cfg)); println("PipSqueak config loaded from data/pipsqueak.json"); }
  else stick = new PipSqueak(this);
  if (!argNoStick) stick.connect(); else println("--nostick: PipSqueak not opened");
  navQuietUntil = millis() + argNavQuiet;
  tap = new InputTap(this);
  if (!stick.connected()) {
    standInNote = "No PipSqueak. Arrows and space are the stick. The mouse steers in LASER and INTERACTIVE.";
    println(standInNote);
  }

  loadDeck();
  goTo(constrain(argSlide, 0, deck.slides.size() - 1));
  revealed = constrain(argFrags, 0, deck.slides.get(slide).fragments);
  setMode(argMode);
  laserPos.set(width / 2.0, height / 2.0);
}

String pickFamily(String[] candidates) {
  String[] available = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getAvailableFontFamilyNames();
  for (String c : candidates) for (String a : available) if (a.equalsIgnoreCase(c)) return a;
  return candidates[candidates.length - 1];
}

/** Fonts are built from java.awt so bold and italic faces work on every platform. Cached per size. */
PFont font(String family, int style, float size) {
  int sz = max(4, round(size));
  String key = family + "/" + style + "/" + sz;
  PFont f = fontCache.get(key);
  if (f == null) { f = new PFont(new java.awt.Font(family, style, sz), true); fontCache.put(key, f); }
  return f;
}

// ------------------------------------------------------------------ the deck
/** Parse the markdown. Slide and fragment stay (clamped), visuals re-pin. If the file is missing or
 *  the parse throws, the old deck stays and the error is toasted. */
void loadDeck() {
  String[] candidates = argMd != null
    ? new String[] { argMd }
    : new String[] { sketchPath(".." + File.separator + MD_NAME), sketchPath("data" + File.separator + MD_NAME), dataPath(MD_NAME), MD_NAME, "slides" + File.separator + MD_NAME };
  if (deck != null && !deckPath.equals("(none)")) candidates = new String[] { deckPath };   // reloads re-read the same file
  watchPath = candidates[0];                                                                  // polled even while missing
  File found = null;
  for (String c : candidates) { File f = new File(c); if (f.isFile()) { found = f; break; } }
  Deck fresh = null; String error = null;
  if (found == null) error = "deck file not found: " + (candidates.length == 1 ? candidates[0] : MD_NAME);
  else {
    try {
      String[] lines = loadStrings(found);
      if (lines == null) throw new RuntimeException("could not read " + found.getName());
      fresh = new Deck(lines);
      if (fresh.slides.size() == 0) throw new RuntimeException("no slides in " + found.getName());
    } catch (Exception e) { error = "reload failed: " + e.getMessage(); fresh = null; }
  }
  if (fresh == null) {
    if (found != null) deckMtime = found.lastModified();     // do not retry the bad version until it changes
    if (deck != null) { println(error + ", keeping the current deck"); showToast(error); return; }
    println("No '" + MD_NAME + "' next to the sketch folder or in data/. Showing a placeholder.");
    fresh = new Deck(new String[] { "# Deck not found", "", "Put '" + MD_NAME + "' one folder above this sketch, or pass --md=path.", "", "---", "## (empty)" });
    deckPath = "(none)";
  } else {
    deckPath = found.getAbsolutePath();
    deckMtime = found.lastModified();
  }
  boolean reload = deck != null;
  deck = fresh;
  if (rerolls.length != deck.slides.size()) rerolls = new int[deck.slides.size()];
  println((reload ? "Deck reloaded: " : "Deck: ") + deck.slides.size() + " slides, " + deck.fragments + " fragments, from " + deckPath);
  slide = constrain(slide, 0, deck.slides.size() - 1);
  revealed = constrain(revealed, 0, deck.slides.get(slide).fragments);
  visualKind = -1;
  pickVisual();
  if (reload) showToast("reloaded: " + deck.slides.size() + " slides, " + deck.fragments + " fragments");
}

/** From draw(), twice a second: did the deck file change? Wait for the mtime to settle first. */
void pollDeckFile() {
  if (watchPath == null || millis() - lastPoll < 500) return;
  lastPoll = millis();
  long m = new File(deckPath.equals("(none)") ? watchPath : deckPath).lastModified();   // 0 while an editor is mid-save
  if (m == deckMtime || m == 0) { if (m == deckMtime) pendingMtime = -1; return; }
  if (m != pendingMtime) { pendingMtime = m; pendingSince = millis(); return; }
  if (millis() - pendingSince >= 300) { pendingMtime = -1; loadDeck(); }
}

void showToast(String msg) { toast = msg; toastUntil = millis() + 1600; }

void drawToast() {
  if (toast == null) return;
  int left = toastUntil - millis();
  if (left <= 0) { toast = null; return; }
  float a = min(1, left / 400.0f), size = 22 * ui;
  textFont(font(sansFamily, java.awt.Font.PLAIN, size)); textAlign(CENTER, CENTER);
  float w = textWidth(toast) + 48 * ui, h = size * 2.1f, x = width / 2.0f, y = height - 90 * ui;
  noStroke(); fill(toast.startsWith("reloaded") ? color(60, 140, 90) : color(170, 60, 60), 230 * a); rect(x - w / 2, y - h / 2, w, h, h / 2);
  fill(255, 255 * a); text(toast, x, y - size * 0.08f);
}

Slide current() { return deck.slides.get(slide); }

void goTo(int index) {
  index = constrain(index, 0, deck.slides.size() - 1);
  boolean changed = index != slide;
  slide = index;
  revealed = 0;                       // a new slide starts with no fragments
  if (changed || visual == null) pickVisual();
}
void nextSlide() { if (slide < deck.slides.size() - 1) goTo(slide + 1); }
void prevSlide() { if (slide > 0) goTo(slide - 1); }
void revealNext() { revealed = min(revealed + 1, current().fragments); }
void hideLast() { revealed = max(revealed - 1, 0); }

void pickVisual() {
  int kind;
  int pinned = visualIndex(current().visual);
  if (pinned >= 0) {                                   // the pin first, then v cycles the others
    int n = VISUAL_NAMES.length, r = rerolls[slide] % n;
    kind = r == 0 ? pinned : ((pinned + r) % n);
  } else kind = VISUAL_ORDER[(slide + rerolls[slide]) % VISUAL_ORDER.length];
  visual = makeVisual(kind);
  visualKind = kind;
  if (visual instanceof QRVisual) { String[][] ul = slideUrls(current()); ((QRVisual) visual).setTexts(ul[0], ul[1]); if (argQr != null) dumpQr((QRVisual) visual, argQr); }
  visual.reset(slide * 7919 + rerolls[slide] * 131 + 17);
  viz.beginDraw(); viz.background(0, 0); viz.endDraw();
}

void dumpQr(QRVisual q, String path) {
  int n = 0;
  for (int i = 0; i < q.codes.size(); i++) {
    QRCode code = q.codes.get(i);
    if (!code.ok) continue;
    String p = path + (q.codes.size() > 1 ? "-" + (i + 1) : "");
    int m = code.size, cell = 12, quiet = 4, px = (m + 2 * quiet) * cell;
    PGraphics g = createGraphics(px, px);
    g.beginDraw(); g.background(255); g.noStroke(); g.fill(0);
    StringBuilder sb = new StringBuilder();
    for (int y = 0; y < m; y++) { for (int x = 0; x < m; x++) { if (code.module(x, y)) g.rect((x + quiet) * cell, (y + quiet) * cell, cell, cell); sb.append(code.module(x, y) ? '1' : '0'); } sb.append('\n'); }
    g.endDraw(); g.save(p + ".png"); saveStrings(p + ".txt", split(sb.toString().trim(), '\n'));
    println("qr dump: " + p + ".png/.txt (" + m + "x" + m + ", version " + code.version + ") for " + q.urls[i]);
    n++;
  }
  if (n == 0) println("qr dump: no code");
}

/** Every http(s) token on a slide, in order, with the body line after each one as its label. */
String[][] slideUrls(Slide s) {
  ArrayList<String> urls = new ArrayList<String>(), labels = new ArrayList<String>();
  for (int i = 0; i < s.blocks.size(); i++) {
    for (String w : s.blocks.get(i).plain().split("\\s+")) {
      if (!w.startsWith("http://") && !w.startsWith("https://")) continue;
      urls.add(w.replaceAll("[\\]\\)\\.,]+$", ""));
      String label = null;
      if (i + 1 < s.blocks.size() && s.blocks.get(i + 1).type == B_PARA && !s.blocks.get(i + 1).plain().contains("http")) label = s.blocks.get(i + 1).plain().trim();
      labels.add(label);
    }
  }
  return new String[][] { urls.toArray(new String[0]), labels.toArray(new String[0]) };
}

/** Index of a visual by part of its name ("teapot", "life", "julia"), -1 if unknown. */
int visualIndex(String name) {
  if (name == null) return -1;
  String n = name.toLowerCase();
  for (int i = 0; i < VISUAL_NAMES.length; i++) {
    String v = VISUAL_NAMES[i].toLowerCase();
    if (v.contains(n) || n.contains(v.split(" ")[0]) || (n.contains("tree") && v.contains("l-system")) || (n.contains("langton") && v.contains("ant"))) return i;
  }
  println("unknown visual '" + name + "'. Known: " + join(VISUAL_NAMES, ", "));
  return -1;
}

void setMode(int m) {
  mode = (m + 3) % 3;
  if (frameCount > 1) println("mode: " + MODE_NAMES[mode]);
  vizTarget = mode == INTERACTIVE ? VIZ_LOUD : VIZ_QUIET;
  navArmed = false;                   // the click wobbles the stick, do not navigate on it
  if (mode == LASER) { laserPos.set(width / 2.0, height / 2.0); laserVel.set(0, 0); }   // the old trail keeps fading
}
void cycleMode() { setMode(mode + 1); }

// ------------------------------------------------------------------ frame
void draw() {
  ui = height / 1080.0;
  handleStick();

  float p1 = 0, p2 = 0;
  if (mode == INTERACTIVE) {
    float[] s = stickOrMouse(); p1 = s[1]; p2 = s[0];
    if (heldKeys.contains(UP)) p1 = 1; else if (heldKeys.contains(DOWN)) p1 = -1;       // keyboard twin
    if (heldKeys.contains(RIGHT)) p2 = 1; else if (heldKeys.contains(LEFT)) p2 = -1;
  }
  vizAlpha = lerp(vizAlpha, vizTarget, 0.08);
  long t0 = System.nanoTime();
  background(BG);
  long t1 = System.nanoTime(), t2 = t1;
  if (!argNoViz) {
    visual.update(p1, p2);
    if (visual.usesBuffer()) {
      viz.beginDraw(); visual.draw(viz, vizAlpha); viz.endDraw();
      t2 = System.nanoTime();
      blitViz();
    }
  }
  long t3 = System.nanoTime();
  visual.drawHires(this, vizAlpha);
  long t4 = System.nanoTime();
  drawSlide();
  long t5 = System.nanoTime();
  drawLaser();                       // every frame so the trail fades, input only in LASER
  long t6 = System.nanoTime();
  if (frameCount > 90) { profVisual += t2 - t1; profBlit += t3 - t2; profHires += t4 - t3; profSlide += t5 - t4; profLaser += t6 - t5; profFrame += t6 - t0; profFrames++; }
  drawCorner();
  pollDeckFile();
  if (tap != null) tap.maybeRescan(millis());
  drawToast();
  if (showHelp) drawHelp();
  if (showDebug) drawDebug();

  selfTestStep();
  if (argShot != null && frameCount == 90) shotT0 = millis();
  if (argShot != null && frameCount == 150) { float fps = 60000.0 / max(1, millis() - shotT0); save(argShot); println("saved " + argShot + " at " + nf(fps, 0, 1) + " fps over the last 60 frames, " + width + "x" + height + " @" + pixelDensity + " | slide " + (slide + 1) + ", " + revealed + " fragments, " + MODE_NAMES[mode] + ", stick " + (stick.connected() ? "connected" : "stand-in"));
    float n = max(1, profFrames) * 1e6f;
    println("profile ms/frame: visual " + nf(profVisual / n, 1, 2) + "  blit " + nf(profBlit / n, 1, 2) + "  hires " + nf(profHires / n, 1, 2) + "  text " + nf(profSlide / n, 1, 2) + "  laser " + nf(profLaser / n, 1, 2) + "  draw() total " + nf(profFrame / n, 1, 2) + "  (" + visual.name() + ")  [blit: loadPixels " + nf(profLoad / n, 1, 2) + " blend " + nf(profBlend / n, 1, 2) + " drawImage " + nf(profDraw / n, 1, 2) + "]");
    exit(); }
}

/** Composite the small buffer over the whole window. JAVA2D scales a translucent image in software
 *  (bicubic by default), which cost ~200 ms a frame at 4K. So: blend the buffer against the background
 *  colour ourselves (130k pixels, about a millisecond), then draw it as an opaque image with
 *  nearest-neighbour scaling (2 ms; bilinear measured 28 ms on the dev laptop, --interp=1 to compare).
 *  Falls back to tint() + image() on any other renderer. */
java.awt.image.BufferedImage vizRGB; int[] vizData;
void blitViz() {
  java.awt.Graphics2D g2 = (g instanceof processing.awt.PGraphicsJava2D) ? ((processing.awt.PGraphicsJava2D) g).g2 : null;
  if (g2 == null) { tint(255, vizAlpha * 255); image(viz, 0, 0, width, height); noTint(); return; }
  int pw = viz.pixelWidth, ph = viz.pixelHeight;
  if (vizRGB == null || vizRGB.getWidth() != pw || vizRGB.getHeight() != ph) {
    vizRGB = new java.awt.image.BufferedImage(pw, ph, java.awt.image.BufferedImage.TYPE_INT_RGB);
    vizData = ((java.awt.image.DataBufferInt) vizRGB.getRaster().getDataBuffer()).getData();
  }
  long b0 = System.nanoTime();
  viz.loadPixels();
  long b1 = System.nanoTime();
  int[] src = viz.pixels;
  int bgR = (BG >> 16) & 255, bgG = (BG >> 8) & 255, bgB = BG & 255, a255 = round(vizAlpha * 255);
  for (int i = 0; i < src.length; i++) {
    int c = src[i];
    int a = ((c >>> 24) * a255) / 255;
    int r = bgR + ((((c >> 16) & 255) - bgR) * a) / 255;
    int gg = bgG + ((((c >> 8) & 255) - bgG) * a) / 255;
    int b = bgB + (((c & 255) - bgB) * a) / 255;
    vizData[i] = (r << 16) | (gg << 8) | b;
  }
  long b2 = System.nanoTime();
  Object old = g2.getRenderingHint(java.awt.RenderingHints.KEY_INTERPOLATION);
  g2.setRenderingHint(java.awt.RenderingHints.KEY_INTERPOLATION, argInterp == 0 ? java.awt.RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR : java.awt.RenderingHints.VALUE_INTERPOLATION_BILINEAR);
  g2.drawImage(vizRGB, 0, 0, width, height, null);
  if (old != null) g2.setRenderingHint(java.awt.RenderingHints.KEY_INTERPOLATION, old);
  long b3 = System.nanoTime();
  if (frameCount > 90) { profLoad += b1 - b0; profBlend += b2 - b1; profDraw += b3 - b2; }
}

// ------------------------------------------------------------------ self test (command line only)
// --keys=R,R,U,D,S,... posts one key every 10 frames from frame 30 (R/L/U/D arrows, S space, H home,
// E end, or a letter), held 4 frames so the PipSqueak stand-in sees it. --midi=status:d1:d2,... injects
// one raw message every 10 frames from frame 30. --demo swings the stick in a circle. --test-f calls
// the fullscreen toggle at frame 30.
void selfTestStep() {
  if (argKeys != null) {
    int rel = frameCount - 30;
    if (rel >= 0 && rel % 10 < 5 && (rel % 10 == 0 || rel % 10 == 4) && rel / 10 < argKeys.length) postTestKey(argKeys[rel / 10].trim(), rel % 10 == 0);
  }
  if (argMidi != null) {                      // --midi=176:7:70,176:10:126,... one raw message every 10 frames from frame 30
    int rel = frameCount - 30;
    if (rel >= 0 && rel % 10 == 0 && rel / 10 < argMidi.length) {
      String[] b = split(argMidi[rel / 10].trim(), ':');
      if (b.length == 3) stick.core.inject(int(b[0]), int(b[1]), int(b[2]));
    }
  }
  if (argTapMidi != null && tap != null) {
    int rel = frameCount - 30;
    if (rel >= 0 && rel % 10 == 0 && rel / 10 < argTapMidi.length) {
      String[] b = split(argTapMidi[rel / 10].trim(), ':');
      TapPort p = b.length == 4 ? tap.findByName(b[0]) : null;
      if (p != null) p.inject(int(b[1]), int(b[2]), int(b[3])); else println("--tapmidi: no input matching " + argTapMidi[rel / 10]);
    }
  }
  if (argDemo && frameCount > 20) {
    float t = frameCount * 0.05;
    stick.core.inject(0xB0, stick.config.xCC, (int) (stick.config.xCenter + 50 * cos(t)));
    stick.core.inject(0xB0, stick.config.yCC, (int) (stick.config.yCenter + 50 * sin(t)));
  }
  if (argTestF && frameCount == 30) toggleFullscreen();
  if (wantFullscreen && frameCount == 2) { wantFullscreen = false; toggleFullscreen(); }
}

void postTestKey(String k, boolean press) {
  int action = press ? processing.event.KeyEvent.PRESS : processing.event.KeyEvent.RELEASE;
  char key; int code;
  if (k.equals("R")) { key = CODED; code = RIGHT; } else if (k.equals("L")) { key = CODED; code = LEFT; }
  else if (k.equals("U")) { key = CODED; code = UP; } else if (k.equals("D")) { key = CODED; code = DOWN; }
  else if (k.equals("H")) { key = CODED; code = java.awt.event.KeyEvent.VK_HOME; } else if (k.equals("E")) { key = CODED; code = java.awt.event.KeyEvent.VK_END; }
  else if (k.equals("S")) { key = ' '; code = 32; }
  else if (k.equals("TAB")) { key = TAB; code = 9; }
  else { key = k.charAt(0); code = java.awt.event.KeyEvent.getExtendedKeyCodeForChar(key); }
  postEvent(new processing.event.KeyEvent(null, millis(), action, 0, key, code));
}

// ------------------------------------------------------------------ debug overlay (key d)
// The helper calls these for every message, so they double as a raw tap.
void controlChange(int channel, int number, int value) { logRaw("CC ch " + channel + "  #" + number + " = " + value + "   [" + (0xB0 | (channel - 1)) + ", " + number + ", " + value + "]"); }
void noteOn(int channel, int note, int velocity) { logRaw("NOTE ON ch " + channel + "  n" + note + " v" + velocity + "   [" + (0x90 | (channel - 1)) + ", " + note + ", " + velocity + "]"); }
void noteOff(int channel, int note, int velocity) { logRaw("NOTE OFF ch " + channel + "  n" + note + " v" + velocity + "   [" + (0x80 | (channel - 1)) + ", " + note + ", " + velocity + "]"); }
void logRaw(String line) {
  rawCount++; lastRawMillis = millis();
  if (rawCount == 1 || rawCount % 100 == 0) println("stick: message " + rawCount + " from '" + stick.core.inputName + "': " + line);
  rawLog.add(nf(millis() / 1000.0, 1, 2) + "  " + line);
  while (rawLog.size() > 8) rawLog.remove(0);
}

void drawDebug() {
  float size = 20 * ui, lh = size * 1.35, pad = 24 * ui, w = 820 * ui;
  PipSqueakConfig c = stick.config;
  String[] lines = {
    "stick debug  (d hides)",
    "input: " + (stick.connected() ? "'" + stick.core.inputName + "'" : "not connected, stand-in") + "   filter '" + stick.core.inputFilter + "'   received " + stick.core.received,
    "config: profile '" + c.profile + "' auto " + c.auto + "   x cc" + c.xCC + " centre " + c.xCenter + " [" + c.xMin + ".." + c.xMax + "]   y cc" + c.yCC + " centre " + c.yCenter + " [" + c.yMin + ".." + c.yMax + "]   button " + (c.buttonNote >= 0 ? "note " + c.buttonNote : "cc" + c.buttonCC + " >= " + c.buttonThreshold) + "   deadzone " + c.deadzone,
    "raw: x " + stick.rawX + "  y " + stick.rawY + "   ->  x " + nf(stick.x, 1, 2) + "  y " + nf(stick.y, 1, 2) + "  mag " + nf(stick.magnitude, 1, 2) + "  pressed " + stick.pressed,
    "nav: armed " + navArmed + "   last edge: " + lastNavEdge + (lastNavMillis >= 0 ? "  " + nf((millis() - lastNavMillis) / 1000.0, 1, 1) + " s ago" : ""),
    "messages: " + rawCount + (lastRawMillis >= 0 ? "   last " + nf((millis() - lastRawMillis) / 1000.0, 1, 1) + " s ago" : "   none yet"),
    "mouse stand-in: " + mouseActive + "   mode " + MODE_NAMES[mode],
    "last raw messages"
  };
  float h = (lines.length + max(1, rawLog.size())) * lh + pad * 2;
  float x = width - w - 24 * ui, y = 24 * ui;
  noStroke(); fill(BG, 225); rect(x, y, w, h, 12 * ui);
  stroke(255, 200, 80, 120); noFill(); rect(x, y, w, h, 12 * ui); noStroke();
  textFont(font(monoFamily, java.awt.Font.PLAIN, size * 0.85)); textAlign(LEFT, TOP);
  int i = 0;
  for (String l : lines) { fill(i == 0 ? color(255, 200, 80) : TEXT); text(l, x + pad, y + pad + i * lh); i++; }
  if (rawLog.size() == 0) { fill(FADED); text("nothing yet. move the stick.", x + pad, y + pad + i * lh); }
  for (String l : rawLog) { fill(CODE); text(l, x + pad, y + pad + i * lh); i++; }
}

// ------------------------------------------------------------------ stick and stand-ins
void handleStick() {
  if (stick.justPressed() && stick.connected()) cycleMode();   // space is handled in keyPressed
  if (mode != NAVIGATE || !stick.connected()) return;           // the stand-in stick only steers
  if (millis() < navQuietUntil) { navArmed = false; return; }   // settle first; re-arms once the stick is back at rest
  float x = stick.x, y = stick.y, m = max(abs(x), abs(y));
  if (navArmed && m > 0.6) {
    navArmed = false;
    String edge;
    if (abs(x) >= abs(y)) { if (x > 0) { nextSlide(); edge = "RIGHT: next slide"; } else { prevSlide(); edge = "LEFT: previous slide"; } }
    else { if (y > 0) { revealNext(); edge = "UP: reveal"; } else { hideLast(); edge = "DOWN: hide"; } }
    lastNavEdge = edge + "  (x " + nf(x, 1, 2) + ", y " + nf(y, 1, 2) + ")"; lastNavMillis = millis();
    println("stick nav: " + lastNavEdge + "  -> slide " + (slide + 1) + ", " + revealed + " fragments");
  } else if (!navArmed && m < 0.3) navArmed = true;
}

/** -1..1 x and y (y up). The real stick, else the keyboard stand-in, else the mouse once it has moved. */
float[] stickOrMouse() {
  if (stick.connected() || stick.magnitude > 0 || !mouseActive) return new float[] { stick.x, stick.y };
  return new float[] { constrain(mouseX / (float) width * 2 - 1, -1, 1), constrain(-(mouseY / (float) height * 2 - 1), -1, 1) };
}

// ------------------------------------------------------------------ laser
void drawLaser() {
  int now = millis();
  if (mode == LASER) {
    float[] s = stickOrMouse();
    float tx = width / 2.0 + s[0] * width * 0.48, ty = height / 2.0 - s[1] * height * 0.48;
    laserVel.x = (laserVel.x + (tx - laserPos.x) * 0.14) * 0.72;    // spring toward the stick, like the kaleidoscope pen
    laserVel.y = (laserVel.y + (ty - laserPos.y) * 0.14) * 0.72;
    laserPos.add(laserVel);
    if (trail.size() == 0 || dist(trail.get(trail.size() - 1)[0], trail.get(trail.size() - 1)[1], laserPos.x, laserPos.y) > 0.5)
      trail.add(new float[] { laserPos.x, laserPos.y, now });
  } else if (trail.size() > 0 && now - trail.get(trail.size() - 1)[2] < 50) {
    trail.add(new float[] { laserPos.x, laserPos.y, now - 50 });    // a break, so the next LASER session does not join this trail
  }
  while (trail.size() > 0 && now - trail.get(0)[2] > TRAIL_MS) trail.remove(0);
  if (trail.size() == 0 && mode != LASER) return;

  noFill(); strokeCap(ROUND); strokeJoin(ROUND);
  for (int i = 1; i < trail.size(); i++) {
    float[] a = trail.get(i - 1), b = trail.get(i);
    if (b[2] - a[2] > 400) continue;                                  // gap between two LASER sessions
    float life = 1 - (now - b[2]) / (float) TRAIL_MS;
    stroke(LASER_RED, 230 * life * life);
    strokeWeight(7 * ui * (0.4 + 0.6 * life));
    line(a[0], a[1], b[0], b[1]);
  }
  if (mode != LASER) return;
  noStroke();
  fill(LASER_RED, 60); circle(laserPos.x, laserPos.y, 44 * ui);
  fill(LASER_RED, 160); circle(laserPos.x, laserPos.y, 26 * ui);
  fill(255, 120, 110); circle(laserPos.x, laserPos.y, 12 * ui);
}

// ------------------------------------------------------------------ slide rendering
void drawSlide() {
  Slide s = current();
  float margin = 120 * ui, maxW = width - 2 * margin, topMargin = 90 * ui;
  Block photo = s.photo();
  if (photo != null) maxW = width * 0.5f - margin - 30 * ui;   // text keeps the left half, the photo takes the right
  float reserve = visual.reserveBottom(ui);                   // a visual may keep the bottom of the slide for itself
  float scale = 1;
  contentRight = margin;
  float h = layoutSlide(s, margin, 0, maxW, false, scale);
  float avail = height - reserve - 2 * topMargin;
  if (h > avail) { scale = max(0.6, avail / h); contentRight = margin; h = layoutSlide(s, margin, 0, maxW, false, scale); }
  float y0 = max(topMargin, (height - reserve - h) / 2);
  contentTop = y0; contentHeight = h;

  float dim = map(vizAlpha, VIZ_QUIET, VIZ_LOUD, 0, 170);   // text stays readable when the background is loud
  if (dim > 2) { noStroke(); fill(BG, dim); rect(margin - 40 * ui, y0 - 30 * ui, (contentRight - margin) + 80 * ui, h + 50 * ui, 18 * ui); }

  layoutSlide(s, margin, y0, maxW, true, scale);
  photoW = photoH = 0;
  if (photo != null) drawPhoto(photo, width * 0.5f + 30 * ui, y0, width - margin - (width * 0.5f + 30 * ui), max(h, 420 * ui));
  visual.drawAbove(this, vizAlpha);
}

/** The slide's photo, fitted into the box on the right, aspect kept, rounded corners, thin border. The file
 *  is read once and resized once to its drawn width, so the per-frame draw is a plain 1:1 blit. */
void drawPhoto(Block b, float bx, float by, float bw, float bh) {
  File f = new File(b.src);
  if (!f.isAbsolute()) f = new File(new File(deckPath).getParentFile(), b.src);
  PImage src = photos.get(f.getPath());
  if (src == null && !photos.containsKey(f.getPath())) {       // first sight: load, or remember that it is missing
    src = f.isFile() ? loadImage(f.getPath()) : null;
    if (src != null && src.width <= 0) src = null;
    photos.put(f.getPath(), src);
    println("photo: " + (src != null ? src.width + "x" + src.height + " " : "missing ") + f.getPath());
  }
  if (src == null) {                                            // fall back to the alt text, italic and faded
    richText(b.spans, bx, by, bw, 30 * ui, FADED, sansFamily, false, true, true);
    return;
  }
  float k = min(bw / src.width, bh / src.height);
  int w = max(1, round(src.width * k)), h = max(1, round(src.height * k));
  String key = f.getPath() + "@" + w;
  PImage fitted = photos.get(key);
  if (fitted == null) { fitted = src.copy(); fitted.resize(w, h); photos.put(key, fitted); }
  float x = bx + (bw - w) / 2, y = by, r = 18 * ui;
  photoX = x; photoY = y; photoW = w; photoH = h;
  java.awt.Graphics2D g2 = (g instanceof processing.awt.PGraphicsJava2D) ? ((processing.awt.PGraphicsJava2D) g).g2 : null;
  if (g2 != null) { g2.setClip(new java.awt.geom.RoundRectangle2D.Float(x, y, w, h, r * 2, r * 2)); image(fitted, x, y); g2.setClip(null); }
  else image(fitted, x, y);
  noFill(); stroke(TEXT, 70); strokeWeight(1.5f * ui); rect(x, y, w, h, r); noStroke();
}

float layoutSlide(Slide s, float x, float y, float maxW, boolean doDraw, float scale) {
  float yy = y;
  for (Block b : s.blocks) yy += renderBlock(b, x, yy, maxW, doDraw, scale);
  return yy - y;
}

float renderBlock(Block b, float x, float y, float maxW, boolean doDraw, float scale) {
  switch (b.type) {
    case B_TITLE: {
      float size = (b.level == 1 ? 96 : b.level == 2 ? 78 : 64) * ui * scale;
      float h = richText(b.spans, x, y, maxW, size, TITLE, serifFamily, false, false, doDraw);
      return h + size * 0.45;
    }
    case B_PARA: {
      float size = 40 * ui * scale;
      return richText(b.spans, x, y, maxW, size, TEXT, sansFamily, false, false, doDraw) + size * 0.55;
    }
    case B_FRAGMENT: {
      float size = 40 * ui * scale, indent = b.bullet ? size * 1.3 : 0;
      boolean visible = b.fragmentIndex < revealed;
      if (doDraw && visible && b.bullet) { fill(FADED); textFont(font(sansFamily, java.awt.Font.PLAIN, size)); textAlign(LEFT, BASELINE); text("•", x + size * 0.3, y + size * 0.95); }
      float h = richText(b.spans, x + indent, y, maxW - indent, size, TEXT, sansFamily, false, false, doDraw && visible);
      return h + size * 0.55;
    }
    case B_IMAGE: {
      float size = 30 * ui * scale;
      return richText(b.spans, x, y, maxW, size, FADED, sansFamily, false, true, doDraw) + size * 0.9;
    }
    case B_TABLE: return table(b, x, y, maxW, 34 * ui * scale, doDraw);
    case B_PHOTO: return 0;                 // drawn by drawPhoto() in the right column
  }
  return 0;
}

/** Word-wrapped styled text. Returns the height used. */
float richText(ArrayList<Span> spans, float x, float y, float maxW, float size, int baseColor, String family, boolean forceBold, boolean forceItalic, boolean doDraw) {
  float lineH = size * 1.32, cx = x, baseline = y + size * 0.95;
  textAlign(LEFT, BASELINE);
  for (Span sp : spans) {
    boolean bold = sp.bold || forceBold, italic = sp.italic || forceItalic;
    PFont f = sp.code ? font(monoFamily, java.awt.Font.PLAIN, size * 0.88)
                      : font(family, (bold ? java.awt.Font.BOLD : 0) | (italic ? java.awt.Font.ITALIC : 0), size);
    textFont(f);
    float spaceW = textWidth(' ');
    String[] words = sp.text.split(" ", -1);
    for (int i = 0; i < words.length; i++) {
      if (i > 0 && cx > x) cx += spaceW;
      String w = words[i];
      if (w.length() == 0) continue;
      float tw = textWidth(w);
      if (cx > x && cx + tw > x + maxW) { cx = x; baseline += lineH; }
      contentRight = max(contentRight, cx + tw);
      if (doDraw) {
        if (sp.code) {
          boolean last = i == words.length - 1;
          float bx = cx - (i == 0 ? size * 0.15 : spaceW), bw = tw + (i == 0 ? size * 0.15 : spaceW) + (last ? size * 0.15 : 0);
          noStroke(); fill(255, 22); rect(bx, baseline - size * 0.8, bw, size * 1.05); fill(CODE);
        }
        else fill(bold && baseColor == TEXT ? TITLE : baseColor);
        text(w, cx, baseline);
      }
      cx += tw;
    }
  }
  return (baseline + size * 0.3) - y;
}

float table(Block b, float x, float y, float maxW, float size, boolean doDraw) {
  if (b.rows.size() == 0) return 0;
  int cols = 0; for (String[] r : b.rows) cols = max(cols, r.length);
  float pad = size * 0.9, rowH = size * 1.75;
  float[] colW = new float[cols];
  for (int r = 0; r < b.rows.size(); r++) {
    textFont(font(sansFamily, r == 0 ? java.awt.Font.BOLD : java.awt.Font.PLAIN, size));
    for (int c = 0; c < b.rows.get(r).length; c++) colW[c] = max(colW[c], textWidth(b.rows.get(r)[c]) + pad);
  }
  float total = 0; for (float w : colW) total += w;
  float shrink = total > maxW ? maxW / total : 1;
  contentRight = max(contentRight, x + total * shrink);
  if (doDraw) {
    textAlign(LEFT, CENTER);
    for (int r = 0; r < b.rows.size(); r++) {
      float ry = y + r * rowH, cx = x;
      textFont(font(sansFamily, r == 0 ? java.awt.Font.BOLD : java.awt.Font.PLAIN, size));
      fill(r == 0 ? TITLE : TEXT);
      String[] row = b.rows.get(r);
      for (int c = 0; c < row.length; c++) { text(row[c], cx + pad * 0.3, ry + rowH / 2 - size * 0.05); cx += colW[c] * shrink; }
      stroke(TEXT, r == 0 ? 140 : 40); strokeWeight(r == 0 ? 2 : 1);
      line(x, ry + rowH, x + total * shrink, ry + rowH);
    }
    noStroke();
  }
  return b.rows.size() * rowH + size * 0.8;
}

// ------------------------------------------------------------------ chrome
void drawCorner() {
  float size = 20 * ui, m = 28 * ui;
  textFont(font(sansFamily, java.awt.Font.PLAIN, size));
  textAlign(RIGHT, BOTTOM);
  int dot = mode == LASER ? LASER_RED : mode == INTERACTIVE ? color(90, 220, 140) : color(140, 140, 150);
  String label = MODE_NAMES[mode];
  fill(TEXT, 140); text(label, width - m, height - m);
  noStroke(); fill(dot, mode == NAVIGATE ? 150 : 230);
  circle(width - m - textWidth(label) - size * 0.9, height - m - size * 0.42, size * 0.55);
  textAlign(LEFT, BOTTOM); fill(TEXT, 90);
  text((slide + 1) + " / " + deck.slides.size() + "   ·   " + visual.name(), m, height - m);
}

void drawHelp() {
  float size = 24 * ui, lh = size * 1.5, w = 1560 * ui, pad = 40 * ui;
  String shortPath = deckPath.length() > 90 ? "\u2026" + deckPath.substring(deckPath.length() - 90) : deckPath;
  String[] lines = {
    "Stick" + (stick.connected() ? "  (" + stick.core.inputName + ")" : "  (none. arrows, space and the mouse stand in)"),
    "   click            NAVIGATE, LASER, INTERACTIVE, round again",
    "   NAVIGATE         left / right: slide.  up / down: fragment",
    "   LASER            the red dot. The trail fades in two seconds",
    "   INTERACTIVE      play the background. up / down and left / right",
    "",
    "Keyboard",
    "   arrows / space   slide, fragment, mode. In INTERACTIVE the arrows play the visual",
    "   Home / End       first / last slide          PageUp / PageDown   previous / next",
    "   v  another visual for this slide           r  reload the markdown",
    "   f  fullscreen                              h  this help          shift-Q  quit",
    "   z  recenter the stick, hands off           c  clear the laser trail",
    "   d  stick debug                             w  teapot wireframe / solid",
    "   Tab  next device on the bytes slides (or click the list)",
    "",
    "Deck: " + shortPath,
    "Slides: " + deck.slides.size() + "   fragments: " + deck.fragments + "   this slide: " + revealed + " / " + current().fragments + "   background: " + visual.name()
  };
  float h = lines.length * lh + pad * 2;
  float x = (width - w) / 2, y = (height - h) / 2;
  noStroke(); fill(BG, 235); rect(x, y, w, h, 16 * ui);
  stroke(TEXT, 60); noFill(); rect(x, y, w, h, 16 * ui); noStroke();
  textAlign(LEFT, TOP);
  for (int i = 0; i < lines.length; i++) {
    boolean head = lines[i].length() > 0 && lines[i].charAt(0) != ' ';
    textFont(font(head ? sansFamily : monoFamily, head ? java.awt.Font.BOLD : java.awt.Font.PLAIN, head ? size : size * 0.85));
    fill(head ? TITLE : TEXT);
    text(lines[i], x + pad, y + pad + i * lh);
  }
}

// ------------------------------------------------------------------ keyboard and mouse
void keyPressed() {
  if (key == ESC) { key = 0; return; }                   // Esc must not end the show
  if (key == TAB) { if (visual instanceof BytesVisual) ((BytesVisual) visual).cycle(); return; }   // Tab has no other job
  if (key == CODED) {
    if (keyCode == java.awt.event.KeyEvent.VK_HOME) { goTo(0); return; }
    if (keyCode == java.awt.event.KeyEvent.VK_END) { goTo(deck.slides.size() - 1); return; }
    if (keyCode == java.awt.event.KeyEvent.VK_PAGE_UP) { prevSlide(); return; }
    if (keyCode == java.awt.event.KeyEvent.VK_PAGE_DOWN) { nextSlide(); return; }
    // The keyboard always works. With no device the helper also turns these keys into stick motion,
    // which steers in LASER and INTERACTIVE; handleStick() only navigates from a real stick, so a press
    // never counts twice. Auto-repeat is ignored.
    if (heldKeys.contains(keyCode)) return;
    heldKeys.add(keyCode);
    if (mode == INTERACTIVE) return;                       // the arrows play the visual, read in draw()
    if (keyCode == LEFT) prevSlide(); else if (keyCode == RIGHT) nextSlide();
    else if (keyCode == UP) revealNext(); else if (keyCode == DOWN) hideLast();
    return;
  }
  switch (key) {
    case ' ': cycleMode(); break;
    case 'v': case 'V': rerolls[slide]++; pickVisual(); println("slide " + (slide + 1) + ": " + visual.name()); break;
    case 'r': case 'R': loadDeck(); if (toast != null && toast.startsWith("reloaded")) toast += " (r)"; break;
    case 'f': case 'F': toggleFullscreen(); break;
    case 'h': case 'H': case '?': showHelp = !showHelp; break;
    case 'd': case 'D': showDebug = !showDebug; break;
    case 'w': case 'W': if (visual instanceof TeapotVisual) { TeapotVisual t = (TeapotVisual) visual; t.wireframe = !t.wireframe; println("teapot: " + (t.wireframe ? "wireframe" : "solid")); } break;
    case 'Q': exit(); break;
    case 'c': case 'C': trail.clear(); break;
    case 'z': case 'Z': stick.recenter(); println("recentering. hands off for half a second"); break;
  }
}

void keyReleased() { if (key == CODED) heldKeys.remove(Integer.valueOf(keyCode)); }
void mouseMoved() { mouseActive = true; }
void mousePressed() { visual.click(mouseX, mouseY); }           // only the bytes picker listens
void mouseDragged() { mouseActive = true; }

void toggleFullscreen() {
  try {
    java.awt.Frame frame = ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
    java.awt.GraphicsDevice dev = frame.getGraphicsConfiguration().getDevice();
    surface.setResizable(true);
    if (dev.getFullScreenWindow() == frame) { dev.setFullScreenWindow(null); surface.setSize(1280, 720); }
    else dev.setFullScreenWindow(frame);
  } catch (Exception e) {
    println("no fullscreen toggle here (" + e + "), resizing to the display instead");
    surface.setResizable(true); surface.setSize(displayWidth, displayHeight); surface.setLocation(0, 0);
  }
}
