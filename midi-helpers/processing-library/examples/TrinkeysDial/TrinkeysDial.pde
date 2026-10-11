import midihelpers.*;

// Trinkeys: the slider sets the hue, the knob turns a dial, touch pads flash the board's pixel.
// No boards: LEFT / RIGHT move the slider, T touches it; the knob has no stand-in without a second window,
// so the dial follows the mouse. Edit the lines marked "change this".
SlideTrinkey slide;
RotaryTrinkey knob;
float angle = 0;

void setup() {
  size(600, 400);
  colorMode(HSB, 360, 100, 100);
  slide = new SlideTrinkey(this);    // change this: new SlideTrinkey(this, "name") if it isn't found
  knob = new RotaryTrinkey(this);
  slide.connect();
  knob.connect();
}

void draw() {
  background(slide.value * 360, 60, 30);          // change this: slide.value is 0..1
  angle += knob.delta * 0.3;                      // clicks since last frame, + clockwise
  if (!knob.connected()) angle = map(mouseX, 0, width, 0, TWO_PI);
  translate(width / 2, height / 2);
  stroke(0, 0, 100);
  strokeWeight(knob.pressed ? 12 : 4);
  line(0, 0, cos(angle) * 120, sin(angle) * 120);  // change this: the dial
  noStroke();
  fill(0, 0, slide.touched || knob.touched ? 100 : 50);
  circle(0, 0, 30);
}

void touchPressed() { slide.pixel(60); knob.pixel(64); }   // the pad lights the board for a second
void keyPressed() { if (key == 't') slide.pixel(60); }
