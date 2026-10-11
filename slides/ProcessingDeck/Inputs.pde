// Inputs.pde - a tap on every MIDI input, for the bytes slides: which device sent what, last.
// Separate from the PipSqueak helper, which owns one input; CoreMIDI shares ports, so both can listen.
// Device list via CoreMidi4J (code/) by reflection when it is there, so hot-plug works; else plain Java.

import javax.sound.midi.*;

public class InputTap {
  ArrayList<TapPort> ports = new ArrayList<TapPort>();
  int lastScan = -100000, rescanEveryMs = 3000, generation = 0;   // generation bumps when the list changes
  java.lang.reflect.Method cm4jList = null;
  String providerNote = "";

  InputTap(PApplet app) {
    try {
      Class<?> c = Class.forName("uk.co.xfactorylibrarians.coremidi4j.CoreMidiDeviceProvider");
      boolean loaded = (Boolean) c.getMethod("isLibraryLoaded").invoke(null);
      if (loaded) { cm4jList = c.getMethod("getMidiDeviceInfo"); providerNote = "CoreMidi4J " + c.getMethod("getLibraryVersion").invoke(null) + ": inputs refresh on plug-in"; }
      else providerNote = "CoreMidi4J present but its native library did not load";
    } catch (ClassNotFoundException e) { providerNote = "plain Java MIDI: inputs are whatever was plugged in at launch";
    } catch (Throwable t) { providerNote = "CoreMidi4J failed (" + t.getClass().getSimpleName() + ")"; }
    println("inputs: " + providerNote);
    app.registerMethod("dispose", this);
    rescan();
  }

  MidiDevice.Info[] infos() throws Exception {
    if (cm4jList != null) return (MidiDevice.Info[]) cm4jList.invoke(null);
    return MidiSystem.getMidiDeviceInfo();
  }

  /** Every few seconds: open inputs that appeared, drop the ones that vanished. */
  void maybeRescan(int now) { if (now - lastScan > rescanEveryMs) { lastScan = now; rescan(); } }

  void rescan() {
    MidiDevice.Info[] all;
    try { all = infos(); } catch (Exception e) { return; }
    ArrayList<String> seen = new ArrayList<String>();
    boolean changed = false;
    for (MidiDevice.Info info : all) {
      try {
        MidiDevice d = MidiSystem.getMidiDevice(info);
        if (d instanceof Sequencer || d instanceof Synthesizer || d.getMaxTransmitters() == 0) continue;
        String key = info.getName() + "|" + info.getDescription() + "|" + info.getVendor();
        seen.add(key);
        if (find(key) != null) continue;
        TapPort p = new TapPort(key, baseName(info.getName()));
        d.open(); p.device = d; p.transmitter = d.getTransmitter(); p.transmitter.setReceiver(p);
        ports.add(p); changed = true;
      } catch (Exception e) { /* vanished between the two calls, or busy */ }
    }
    for (int i = ports.size() - 1; i >= 0; i--) if (!seen.contains(ports.get(i).key)) { ports.get(i).close(); ports.remove(i); changed = true; }
    if (changed) { generation++; StringBuilder sb = new StringBuilder(); for (TapPort p : ports) sb.append(p.name).append(" | "); println("inputs: " + ports.size() + ": " + sb); }
  }

  TapPort find(String key) { for (TapPort p : ports) if (p.key.equals(key)) return p; return null; }
  TapPort findByName(String part) { String l = part.toLowerCase(); for (TapPort p : ports) if (p.name.toLowerCase().contains(l)) return p; return null; }

  /** The most recent message across every port, or null. */
  TapPort latest() { TapPort best = null; for (TapPort p : ports) if (p.count > 0 && (best == null || p.lastMillis > best.lastMillis)) best = p; return best; }

  /** CoreMidi4J prefixes "CoreMIDI4J - "; CoreMIDI appends the direction. Strip both. */
  String baseName(String raw) {
    String n = raw.startsWith("CoreMIDI4J - ") ? raw.substring(13) : raw;
    if (n.endsWith(" Out")) n = n.substring(0, n.length() - 4); else if (n.endsWith(" In")) n = n.substring(0, n.length() - 3);
    return n.trim();
  }

  public void dispose() { for (TapPort p : ports) p.close(); ports.clear(); }
}

public class TapPort implements Receiver {
  String key, name;
  MidiDevice device; Transmitter transmitter;
  volatile int status = -1, d1, d2, count = 0, lastMillis = -1;
  TapPort(String key, String name) { this.key = key; this.name = name; }
  public void send(MidiMessage m, long t) {
    if (!(m instanceof ShortMessage)) return;
    ShortMessage s = (ShortMessage) m;
    status = s.getStatus(); d1 = s.getData1(); d2 = s.getData2(); lastMillis = millis(); count++;
    if (count == 1 || count % 200 == 0) println("inputs: " + name + " [" + status + ", " + d1 + ", " + d2 + "]  #" + count);
  }
  /** Self-test: as if the device had sent it. */
  void inject(int st, int a, int b) { status = st; d1 = a; d2 = b; lastMillis = millis(); count++; }
  public void close() { try { if (transmitter != null) transmitter.close(); if (device != null && device.isOpen()) device.close(); } catch (Exception e) {} }
  String kind() {
    int type = status & 0xF0;
    return type == 0x90 && d2 > 0 ? "note on" : type == 0x90 || type == 0x80 ? "note off" : type == 0xB0 ? "CC" : type == 0xE0 ? "pitch bend" : type == 0xC0 ? "program" : "status " + status;
  }
}
