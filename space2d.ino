// ===============================
// SPACE SHOOTER ARDUINO CODE
// Joystick + RGB LED + Buzzer
// ===============================

const int xPin = A0;
const int yPin = A1;
const int buttonPin = 2;

const int redPin = 9;
const int greenPin = 10;
const int bluePin = 11;

const int buzzer = 8;

void setup() {
  Serial.begin(9600);

  pinMode(buttonPin, INPUT_PULLUP);

  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);

  pinMode(buzzer, OUTPUT);

  digitalWrite(redPin, LOW);
  digitalWrite(greenPin, LOW);
  digitalWrite(bluePin, LOW);
}

void loop() {

  // Read joystick
  int x = analogRead(xPin);
  int y = analogRead(yPin);

  // Button (1 = pressed)
  int button = !digitalRead(buttonPin);

  // Send to Processing
  Serial.print(x);
  Serial.print(",");
  Serial.print(y);
  Serial.print(",");
  Serial.println(button);

  // Receive commands from Processing
  if (Serial.available()) {

    char cmd = Serial.read();

    if (cmd == 'G') {
      // Full health (Green)
      digitalWrite(redPin, LOW);
      digitalWrite(greenPin, HIGH);
      digitalWrite(bluePin, LOW);
    }

    else if (cmd == 'Y') {
      // Medium health (Yellow)
      digitalWrite(redPin, HIGH);
      digitalWrite(greenPin, HIGH);
      digitalWrite(bluePin, LOW);
    }

    else if (cmd == 'R') {
      // Critical health (Red)
      digitalWrite(redPin, HIGH);
      digitalWrite(greenPin, LOW);
      digitalWrite(bluePin, LOW);
    }

    else if (cmd == 'F') {
      // Fire sound
      tone(buzzer, 1200, 50);
    }

    else if (cmd == 'H') {
      // Hit sound
      tone(buzzer, 600, 200);
    }

    else if (cmd == 'X') {
      // Game Over sound
      tone(buzzer, 400, 700);
    }
  }

  delay(20);
}