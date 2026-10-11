import midihelpers.*;

// MidiCore on its own: any device, raw bytes in, a note out on every click. For devices no helper covers.
MidiCore core;
String last = "nothing yet";

void setup() {
  size(500, 200);
  MidiCore.printMidiDevices();        // every input and output Java can see
  core = new MidiCore(this, "");      // change this: "" is every input; a substring picks one port
  core.connect();
}

void draw() {
  background(20);
  fill(255);
  text(core.status, 20, 40);
  text(last, 20, 80);
  core.poll(new MidiHandler() {
    public void midi(MidiMsg m) { last = m.toString() + " from " + m.device; }
  });
}

void mousePressed() { core.noteOn(1, 60, 100); }    // change this: what a click sends
void mouseReleased() { core.noteOff(1, 60); }
