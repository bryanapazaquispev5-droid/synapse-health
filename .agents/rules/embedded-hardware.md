# Embedded Hardware, Arduino & ESP32 Engineering Rules

When developing firmware, pinout configurations, hardware queries, or embedded system code:

## 0. Automated Hardware & Port Detection
- Proactively run PowerShell USB detection (`Get-CimInstance Win32_SerialPort` or `Get-PnpDevice -Class 'Ports','USB'`) or `arduino-cli board list` whenever a user asks about microcontrollers, COM ports, or device models.
- Map hardware VID/PID strings (e.g. `VID_2341` for Arduino, `VID_1A86` for CH340, `VID_10C4` for CP210x, `VID_303A` for Espressif Native USB) to identify the exact board model even if unplugged.

## 1. Hardware Safety & Voltage Integrity
- **Voltage Levels:** Arduino UNO operates at 5V logic. ESP32 family operates at **3.3V logic ONLY**. Never feed 5V signals directly into ESP32 GPIOs.
- **ESP32 Prohibited Flash Pins:** Never assign GPIO 6, 7, 8, 9, 10, or 11 (connected to internal SPI Flash).
- **ESP32 Strapping Pins:** Avoid using GPIO 0, 2, 12, 15 for active peripherals to prevent bootloader lockup.
- **ADC2 WiFi Restriction:** Avoid ADC2 pins when WiFi is enabled on ESP32; always use ADC1 (GPIO 32-39).

## 2. Firmware Architecture & Memory Protection
- **No Blocking `delay()`:** Always implement non-blocking `millis()` state machines (Arduino) or FreeRTOS tasks (`xTaskCreatePinnedToCore` / `vTaskDelay` on ESP32).
- **No Dynamic `String` Heap Allocation:** Use fixed-size `char[]` buffers with `snprintf` to prevent SRAM fragmentation on 8-bit AVR / RTOS tasks.
- **Flash String Wrapper:** Always wrap string literals with `F("...")` on AVR microcontrollers.

## 3. Toolchain & Compilation
- Leverage `arduino-cli` or PlatformIO (`pio run`) for automated compilation and verification.
