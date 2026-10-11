#include <MIDIUSB.h>
#include <Adafruit_CircuitPlayground.h>

int red = 0;
int green = 0;
int blue = 0;

void setup() {
  CircuitPlayground.begin();
  Serial.begin(9600);
}

void loop() {
  midiEventPacket_t rx;
  rx = MidiUSB.read();

  //    Serial.println("Listening...");
  if (rx.header == 9) {
    CircuitPlayground.clearPixels();
    Serial.print("Received: ");
    Serial.print(rx.header, DEC);
    Serial.print("-");
    Serial.print(rx.byte1, DEC);
    Serial.print("-");
    Serial.print(rx.byte2, DEC);
    Serial.print("-");
    Serial.println(rx.byte3, DEC);

    // set red value
    if (rx.byte1 == 144) red = rx.byte2 + rx.byte3;

    // set gsreen value
    if (rx.byte1 == 145) green = rx.byte2 + rx.byte3;

    // set blue value
    if (rx.byte1 == 146) blue = rx.byte2 + rx.byte3;

    for (int x = 0; x < 10; x++) {
      CircuitPlayground.setPixelColor(x, red, green, blue);
    }

  }
}
