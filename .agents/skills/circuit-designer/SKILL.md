---
name: circuit-designer
description: >-
  Circuit design, schematic generation, and interactive visual wiring protocol for Arduino Uno and ESP32. Generates declarative Wokwi diagram.json simulation files and standalone interactive HTML/CSS/SVG visual breadboard viewers with physical step-by-step connection checklists.
---

# Circuit Designer & Visual Wiring Protocol (Wokwi & Interactive HTML5/SVG)

Based on [Wokwi Diagram Specs](https://wokwi.com/) and the modern Vector Circuit Viewer architecture, this skill empowers the AI agent to generate structured circuit layouts, interactive simulation diagrams (`diagram.json`), and standalone browser-ready HTML/SVG visual wiring guides with high visual fidelity.

---

## 1. Dual-Output Deliverables

When requested to design, wire, or document a circuit for **Arduino Uno** or **ESP32**, the agent produces two synchronized artifacts:

1. **`diagram.json` (Wokwi Simulation):**
   * Machine-readable format ready to simulate in [wokwi.com](https://wokwi.com) or VS Code Wokwi extension.
   * Defines exact parts (`type`, `id`, `top`, `left`, `attrs`) and pin-to-pin connections with wire colors.

2. **`circuit_viewer.html` (Modern Interactive SVG Visual Guide):**
   * Standalone, self-contained HTML5 + CSS + SVG file with zero external dependencies.
   * Includes functional concept previews (e.g. simulated displays, active LED states, servo motions).
   * Renders high-resolution vector blocks for the microcontroller (Arduino/ESP32) and all connected modules.
   * Uses smooth Bézier curve paths (`<path d="M ... C ..." />`) for color-coded jumper wires.
   * Features a detailed pinout mapping table with categorized badges (`badge-sig`, `badge-pwm`, `badge-i2c`, `badge-led`, `badge-pwr`).

---

## 2. Standard Wokwi `diagram.json` Specification

### Microcontroller Part Types:
* **Arduino UNO:** `wokwi-arduino-uno` (pins: `GND.1`, `GND.2`, `5V`, `3.3V`, `VIN`, `A0`-`A5`, `0`-`13`, `AREF`)
* **ESP32 DevKit v1:** `board-esp32-devkit-c-v4` or `wokwi-esp32-devkit-v1` (pins: `3V3`, `GND.1`, `GND.2`, `GND.3`, `5V`, `D0`-`D39`)

### Common Peripheral Types:
* **Resistor:** `wokwi-resistor` (attrs: `{"value": "220"}`)
* **LED:** `wokwi-led` (pins: `A` (anode), `C` (cathode); attrs: `{"color": "red"|"green"|"blue"|"yellow"}`)
* **Pushbutton:** `wokwi-pushbutton` (pins: `1.1`, `1.2`, `2.1`, `2.2`)
* **Temperature Sensor:** `wokwi-dht22` (pins: `VCC`, `SDA`, `NC`, `GND`)
* **OLED Display:** `wokwi-ssd1306` (pins: `GND`, `VCC`, `SCL`, `SDA`)
* **LCD Display:** `wokwi-lcd1602` (pins: `GND`, `VCC`, `SDA`, `SCL` via I2C backpack)
* **Servo Motor:** `wokwi-servo` (pins: `GND`, `V+`, `PWM`)
* **Relay Module:** `wokwi-relay-module` (pins: `VCC`, `GND`, `IN`, `NO`, `COM`, `NC`)
* **Breadboard:** `wokwi-breadboard`

### Standard Wire Color Coding:
* `red`: Power positive (5V / 3.3V / VCC).
* `black`: Ground (GND).
* `blue` / `green`: Digital signals, PWM, GPIOs.
* `yellow`: I2C SCL / SPI SCK / Analog signals.
* `orange`: I2C SDA / SPI MOSI.
* `purple`: SPI MISO / Interrupt signals.

---

## 3. Master Template: `circuit_viewer.html` (Modern Vector Architecture)

Every generated `circuit_viewer.html` must adhere to this structured layout:

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Nombre del Proyecto] - Diagrama & Guía de Conexión</title>
  <style>
    :root {
      --bg: #f8fafc;
      --card-bg: #ffffff;
      --card-border: #cbd5e1;
      --text: #0f172a;
      --text-muted: #475569;
      --accent: #0284c7;
      --success: #16a34a;
      --warning: #d97706;
      --danger: #dc2626;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: var(--bg);
      color: var(--text);
      padding: 24px;
      line-height: 1.5;
    }
    .container { max-width: 980px; margin: 0 auto; }
    h1 { font-size: 1.8rem; margin-bottom: 6px; color: #0f172a; }
    p.subtitle { color: var(--text-muted); margin-bottom: 24px; font-size: 1rem; }
    
    .card {
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 12px;
      padding: 24px;
      margin-bottom: 24px;
      box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
    }
    h2 { font-size: 1.25rem; margin-bottom: 14px; color: var(--accent); display: flex; align-items: center; gap: 8px; }
    
    .svg-wrapper {
      width: 100%;
      background: #ffffff;
      border-radius: 10px;
      border: 2px solid #cbd5e1;
      display: flex;
      justify-content: center;
      padding: 10px;
      margin-bottom: 18px;
    }
    svg { width: 100%; max-height: 520px; }

    .grid-preview {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 14px;
      margin: 16px 0;
    }
    .grid-box {
      border: 2px solid #cbd5e1;
      border-radius: 8px;
      padding: 14px;
      text-align: center;
      background: #f8fafc;
    }
    .grid-box.active {
      border-color: #eab308;
      background: #fefce8;
      box-shadow: 0 0 12px rgba(234, 179, 8, 0.4);
    }
    .indicator-dot {
      width: 16px;
      height: 16px;
      border-radius: 50%;
      display: inline-block;
      margin-bottom: 6px;
    }
    .dot-on { background: #eab308; box-shadow: 0 0 8px #eab308; }
    .dot-off { background: #94a3b8; }

    table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 0.92rem; }
    th, td { text-align: left; padding: 12px 14px; border-bottom: 1px solid var(--card-border); }
    th { background: #f1f5f9; color: var(--accent); font-weight: 700; }
    tr:nth-child(even) { background: #f8fafc; }

    .badge {
      display: inline-block;
      padding: 3px 8px;
      border-radius: 4px;
      font-weight: 700;
      font-size: 11px;
      text-transform: uppercase;
    }
    .badge-led { background: #eab308; color: #000; }
    .badge-sig { background: #0284c7; color: #fff; }
    .badge-pwm { background: #ea580c; color: #fff; }
    .badge-i2c { background: #7c3aed; color: #fff; }
    .badge-pwr { background: #dc2626; color: #fff; }
    .badge-gnd { background: #0f172a; color: #38bdf8; }
  </style>
</head>
<body>
  <div class="container">
    <h1>[Icono] [Nombre del Proyecto / Circuito]</h1>
    <p class="subtitle">[Descripción concisa del funcionamiento y objetivos del circuito].</p>

    <!-- 1. Concepto Visual & Estados -->
    <div class="card">
      <h2>💡 Estado Visual de los Módulos</h2>
      <div class="grid-preview">
        <!-- Tarjetas dinámicas de módulos y actuadores -->
      </div>
    </div>

    <!-- 2. Diagrama Esquemático Vectorial (SVG) -->
    <div class="card">
      <h2>📐 Esquema de Conexión del Sistema</h2>
      <div class="svg-wrapper">
        <svg viewBox="0 0 960 500" xmlns="http://www.w3.org/2000/svg">
          <!-- ARDUINO UNO O ESP32 -->
          <g transform="translate(30, 45)">
            <rect width="220" height="410" rx="10" fill="#00838f" stroke="#004d40" stroke-width="2" />
            <text x="110" y="45" font-size="16" fill="#ffffff" font-weight="bold" text-anchor="middle">ARDUINO UNO</text>
            <!-- Pin headers & labels -->
          </g>

          <!-- COMPONENTES EXTERNOS (Displays, Servos, Sensores, LEDs) -->
          <!-- ... -->

          <!-- CABLES VECTORIALES CURVOS (Bézier Curves) -->
          <!-- <path d="M 235,150 C 270,150 300,255 380,255" fill="none" stroke="#eab308" stroke-width="3.5" /> -->
        </svg>
      </div>
    </div>

    <!-- 3. Tabla Mapeo de Pines -->
    <div class="card">
      <h2>📌 Mapeo de Pines y Componentes</h2>
      <table>
        <thead>
          <tr>
            <th>Función del Sistema</th>
            <th>Componente</th>
            <th>Color / Identificador</th>
            <th>Pin de la Placa</th>
          </tr>
        </thead>
        <tbody>
          <!-- Filas de conexión -->
        </tbody>
      </table>
    </div>
  </div>
</body>
</html>
```
