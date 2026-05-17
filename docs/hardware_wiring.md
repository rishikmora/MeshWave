# Hardware Wiring Guide

Target hardware:

- ESP32 development board.
- SX1276 or SX1262 LoRa module.
- 915 MHz antenna for US915, or the correct antenna for your regional plan.
- Stable 3.3V power supply.

## ESP32 to SX1276

| ESP32 Pin | LoRa Pin | Purpose |
| --- | --- | --- |
| 3V3 | VCC | 3.3V only |
| GND | GND | Ground |
| GPIO 5 | SCK | SPI clock |
| GPIO 19 | MISO | SPI MISO |
| GPIO 27 | MOSI | SPI MOSI |
| GPIO 18 | NSS/CS | SPI chip select |
| GPIO 14 | RESET | Radio reset |
| GPIO 26 | DIO0 | RX done interrupt |

Attach the antenna before transmitting. Operating a LoRa module without an antenna can damage the radio front-end.

## Power

- Use a dedicated 3.3V regulator with enough current headroom for transmit peaks.
- Keep antenna feed away from noisy switching regulators.
- Add battery voltage sensing through a resistor divider and calibrate firmware before field use.

## Range Notes

50km+ paths require excellent line of sight, elevated antennas, suitable spreading factors, and legal transmit power. MeshWave is designed for relay chains so each single hop does not need to cover the entire path.
