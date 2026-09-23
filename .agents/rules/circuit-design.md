# Circuit Design, Schematic & Visual Wiring Rules

When designing hardware circuits for Arduino Uno or ESP32:

## 1. Dual-Artifact Delivery
Always deliver circuit designs in two synchronized formats:
1. **Wokwi `diagram.json`**: For live browser/VS Code simulation and validation.
2. **Interactive `circuit_viewer.html`**: A standalone browser-viewable HTML5+SVG diagram with physical wiring checklists and color-coded wires (Red=VCC, Black=GND, Green/Blue=Signals, Yellow=I2C/SPI).

## 2. Electrical Protection Rules
- Never connect LEDs without current-limiting resistors (e.g. 220Ω - 330Ω).
- Never connect 5V output signals to 3.3V ESP32 inputs without voltage dividers or logic level shifters.
- Provide clear pull-up / pull-down resistor recommendations for buttons and I2C lines.
