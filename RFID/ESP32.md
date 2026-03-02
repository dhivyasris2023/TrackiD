#include <SPI.h>
#include <MFRC522.h>

#define SS_PIN 5
#define RST_PIN 22

#define SCK_PIN 18
#define MISO_PIN 19
#define MOSI_PIN 23

MFRC522 rfid(SS_PIN, RST_PIN);

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("Starting RFID...");

  SPI.begin(SCK_PIN, MISO_PIN, MOSI_PIN, SS_PIN);

  rfid.PCD_Init();

  Serial.println("Place your card...");
}

void loop() {
  if (!rfid.PICC_IsNewCardPresent()) return;
  if (!rfid.PICC_ReadCardSerial()) return;

  Serial.print("Card UID: ");
  for (byte i = 0; i < rfid.uid.size; i++) {
    if (rfid.uid.uidByte[i] < 0x10) Serial.print("0");
    Serial.print(rfid.uid.uidByte[i], HEX);
    Serial.print(" ");
  }
  Serial.println();
  delay(1500);
}
