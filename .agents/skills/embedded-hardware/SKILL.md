---
name: embedded-hardware
description: >-
  Hardware detection, USB/COM port discovery, VID/PID board identification, disconnected device history inspection, and embedded systems protocol for Arduino (Uno, Nano, Mega, Leonardo) and ESP32 (WROOM, S3, C3, CAM). Enforces strict hardware safety, GPIO conflict prevention, non-blocking timers (millis/FreeRTOS), memory optimization (PROGMEM/no-String), and automated arduino-cli/PlatformIO compilation.
---

# Embedded Hardware & Microcontrollers Protocol (Arduino & ESP32)

Based on [claudius-ars/embedded-agent-skills](https://github.com/claudius-ars/embedded-agent-skills), [arduino/arduino-cli](https://github.com/arduino/arduino-cli), and [platformio/platformio-core](https://github.com/platformio/platformio-core), this skill provides hardware discovery, pinout validation, memory optimization, and compilation standards for microcontrollers.

---

## 0. Automated Hardware & Port Detection Protocol (Live & Historical)

Whenever the user asks about connected, disconnected, or available microcontrollers:

1. **Live USB / COM Port Detection:**
   * Run PowerShell:
     ```powershell
     Get-CimInstance Win32_SerialPort | Select-Object DeviceID, Description, PNPDeviceID
     ```
   * Or run `arduino-cli board list` to detect officially registered FQBNs.

2. **Historical USB Detection (Disconnected Devices):**
   * Even if physically unplugged, Windows stores hardware records. Run:
     ```powershell
     Get-PnpDevice -Class 'Ports','USB' | Where-Object { $_.FriendlyName -match 'Arduino|CH340|CP210|FTDI|USB-SERIAL|Silicon Labs' -or $_.InstanceId -match 'VID_2341|VID_1A86|VID_10C4|VID_0403' } | Select-Object FriendlyName, Status, InstanceId, Present
     ```

3. **VID / PID Microcontroller Reference Table:**
   * `VID_2341`: Official Arduino (Uno = `PID_0043` / `PID_0001`, Mega = `PID_0042`, Leonardo = `PID_8036`).
   * `VID_1A86` (`PID_7523`): CH340 (Standard on Arduino clones and ESP32 DevKit).
   * `VID_10C4` (`PID_EA60`): CP2102 / CP2104 (Common on NodeMCU and ESP32).
   * `VID_0403` (`PID_6001`): FTDI FT232R.
   * `VID_303A`: Espressif Native USB (ESP32-S2, ESP32-S3, ESP32-C3).

---

## 1. Safety & Electrical Rules (Zero Hardware Damage)

1. **Logic Voltage Levels:**
   * **Arduino UNO / Nano / Mega:** 5V logic. Safe for 5V sensors.
   * **ESP32 Family:** **3.3V logic ONLY.** Never connect 5V signals directly to ESP32 GPIOs without a bidirectional level shifter or resistor voltage divider.
2. **ESP32 GPIO Traps & Prohibitions:**
   * **DO NOT USE (Integrated SPI Flash):** GPIO 6, 7, 8, 9, 10, 11 (causes immediate boot crash).
   * **Strapping Pins (Affects Boot Mode):** GPIO 0 (Boot/Flash), GPIO 2 (Must be LOW during flash), GPIO 12 (MTDI / Boot voltage), GPIO 15 (MTDO). Avoid using these for active peripherals if possible.
   * **ADC2 + WiFi Conflict:** When WiFi is active, ADC2 (GPIO 0, 2, 4, 12, 13, 14, 15, 25, 26, 27) cannot be used for analog reads (`analogRead`). Use **ADC1** (GPIO 32, 33, 34, 35, 36, 39) instead.
   * **Input-Only Pins (No internal pull-up/down):** GPIO 34, 35, 36, 39.

---

## 2. Firmware Architecture & Non-Blocking Execution

1. **Ban on Blocking `delay()`:**
   * In production firmware, `delay()` is prohibited in the main loop.
   * **Arduino:** Use `millis()` delta state machines:
     ```cpp
     unsigned long previousMillis = 0;
     const unsigned long intervalMs = 500;
     if (millis() - previousMillis >= intervalMs) {
       previousMillis = millis();
       // Non-blocking task
     }
     ```
   * **ESP32:** Use FreeRTOS tasks and timers:
     ```cpp
     xTaskCreatePinnedToCore(sensorTask, "SensorTask", 4096, NULL, 1, &taskHandle, 1);
     vTaskDelay(pdMS_TO_TICKS(500));
     ```

2. **Memory Management (Anti-Heap Fragmentation):**
   * **Prohibited:** Never use dynamic `String` on Arduino UNO (2 KB SRAM) or tight ESP32 loops. Use `char[]` buffers with `snprintf()`.
   * **Flash Strings:** Always wrap literal strings in the `F()` macro on AVR: `Serial.println(F("System initialized"));`.
   * **Constants:** Store lookup tables and bitmaps in Flash using `PROGMEM` (AVR) or `const` (ESP32).

---

## 3. Peripheral Pinout Cheat Sheet

### Arduino UNO (ATmega328P - 5V)
* **I2C:** SDA = A4, SCL = A5
* **SPI:** MOSI = D11, MISO = D12, SCK = D13, SS = D10
* **UART:** RX = D0, TX = D1
* **PWM:** D3, D5, D6, D9, D10, D11
* **External Interrupts:** D2 (INT0), D3 (INT1)

### ESP32 (WROOM-32 - 3.3V)
* **I2C Default:** SDA = GPIO 21, SCL = GPIO 22
* **SPI Default (VSPI):** MOSI = GPIO 23, MISO = GPIO 19, SCK = GPIO 18, CS = GPIO 5
* **UART Default (UART0):** RX = GPIO 3, TX = GPIO 1
* **ADC1 (Safe with WiFi):** GPIO 32, 33, 34, 35, 36 (VP), 39 (VN)
* **DAC (Analog Out):** GPIO 25 (DAC1), GPIO 26 (DAC2)
* **Hardware PWM (LEDC):** Any output-capable GPIO using `ledcAttachChannel` / `ledcWrite`.

---

## 4. Compilation & Toolchain (arduino-cli & PlatformIO)

### arduino-cli Workflow:
1. **List boards/ports:** `arduino-cli board list`
2. **Compile Arduino UNO:** `arduino-cli compile --fqbn arduino:avr:uno path/to/sketch`
3. **Compile ESP32:** `arduino-cli compile --fqbn esp32:esp32:esp32 path/to/sketch`
4. **Upload Firmware:** `arduino-cli upload -p COM3 --fqbn <fqbn> path/to/sketch`
5. **Install Libraries:** `arduino-cli lib install "LibraryName"`

### PlatformIO (`platformio.ini`) Workflow:
* Run `pio run` to build.
* Run `pio run --target upload` to flash.
* Run `pio device monitor` to view serial logs.
