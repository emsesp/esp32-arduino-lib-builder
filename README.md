# EMS-ESP Arduino PlatformIO framework builder [![ESP32 builder](https://github.com/emsesp/esp32-arduino-lib-builder/actions/workflows/parallel_build.yaml/badge.svg)](https://github.com/emsesp/esp32-arduino-lib-builder/actions/workflows/parallel_build.yaml)[![GitHub Releases](https://img.shields.io/github/downloads/emsesp/esp32-arduino-lib-builder/total?label=downloads)](https://github.com/emsesp/esp32-arduino-lib-builder/releases/latest)

This is a fork of Tasmota Arduino PlatformIO framework builder that builds the libraries for EMS-ESP instead of Tasmota.
https://github.com/Jason2866/esp32-arduino-lib-builder

The main difference is that it builds the libraries for EMS-ESP instead of Tasmota. The changes are in the file `configs/defconfig.ems-esp` (ESP-IDF settings) and in `tools/install-arduino.sh` (Arduino libraries that are left out). See [What is excluded for EMS-ESP?](#what-is-excluded-for-ems-esp) below.

### Setup on Ubuntu
```bash
sudo apt install -y git wget curl libssl-dev libncurses-dev flex bison gperf python3-setuptools cmake ninja-build ccache jq xz-utils
curl -LsSf https://astral.sh/uv/install.sh | sh
uv venv
uv pip install future pyelftools
```

### Testing
```bash
./build.sh -t esp32 -b idf-libs ems-esp
```

`-b idf-libs` only rebuilds the compiled libraries in `out/tools/esp32-arduino-libs/<chip>`. It does **not** repackage `out/framework-arduinoespressif32` or the archives in `dist/`, so those stay as they were after the last full build.

### Quick re-testing (-s skips reinstalling ESP-IDF and components)
```bash
./build.sh -s -t esp32
```

### Build on Ubuntu
A full build, which also creates the PlatformIO framework archives in `dist/`:
```bash
./build.sh
```
or for a single chip:
```bash
./build.sh -t esp32 ems-esp
```
### Using the User Interface

You can more easily build the libraries using the user interface found in the `tools/config_editor/` folder.
It is a Python script that allows you to select and edit the options for the libraries you want to build.
The script has mouse support and can also be pre-configured using the same command line arguments as the `build.sh` script.
For more information and troubleshooting, please refer to the [UI README](tools/config_editor/README.md).

To use it, follow these steps:

1. Make sure you have the following prerequisites:
  - Python 3.10 or later
  - All the dependencies listed in the previous section

2. Install the required UI packages using `uv pip install -r tools/config_editor/requirements.txt`.

3. Run `python3 tools/config_editor/app.py` from the repo root. It will automatically detect the path to the root of the repository. If you installed UI packages with `uv`, use `uv run python tools/config_editor/app.py` so the venv is used.

4. Configure the compilation and ESP-IDF options as desired.

5. Click on the "Compile Static Libraries" button to start the compilation process.

6. The script will show the compilation output in a new screen. Note that the compilation process can take many hours, depending on the number of libraries selected and the options chosen.

### Documentation

For more information about how to use the Library builder, please refer to this [Documentation page](https://docs.espressif.com/projects/arduino-esp32/en/latest/lib_builder.html?highlight=lib%20builder)


### What is excluded for EMS-ESP?

The EMS-ESP settings are now a last-wins overlay: `configs/defconfig.ems-esp` is applied after `defconfig.common` and `defconfig.<chip>` for every target in `builds.json` (esp32, s2, s3, c3, c6).

SPI Ethernet is **not** in the overlay. Turning it off breaks Arduino `ETH.cpp` (`spi_host_device_t`). Unused W5500/DM9051 objects are still dropped by the linker.

Supporting fixes: `-s` now sources ESP-IDF `export.sh` and reads `IDF_VERSION` from `version.txt`; the config editor works on Python 3.14; README install/run commands were corrected.

TinyUSB is pinned to a fixed commit in `tools/update-components.sh` (`TINYUSB_COMMIT`). Repeat runs fetch and check out that commit, then reapply the patches in `patches/tinyusb`. To move to a newer TinyUSB, change that commit.

#### Arduino libraries that are removed

`tools/install-arduino.sh` deletes these from the Arduino component after it is cloned or updated, so they are not compiled for any chip and are not in the framework package:

| Library | Why it is removed |
|---|---|
| `BLE`, `SimpleBLE`, `BluetoothSerial` | Bluetooth is disabled (`CONFIG_BT_ENABLED`). |
| `Matter`, `Zigbee`, `OpenThread`, `RainMaker`, `Insights` | Smart-home and cloud stacks that EMS-ESP does not use. |
| `ESP_NOW`, `WiFiProv` | Not used by EMS-ESP. |
| `WiFiClientSecure`, `NetworkClientSecure` | Not needed in the framework build. |
| `ESP_I2S`, `ESP_SR`, `ESP_Video`, `TFLiteMicro` | Audio, speech, video and ML are not used. |
| `SPIFFS` | Not used; EMS-ESP uses LittleFS. |
| `SD`, `SD_MMC`, `FFat` | No SD card or FAT filesystem is used. Suggested by Michael to cut build time. |
| `PPP` | No modem; PPP is disabled in lwIP. |
| `ESP32` | Not needed in the framework build. |

`SD`, `SD_MMC`, `FFat` and `PPP` are also listed in `ARDUINO_ALL_LIBRARIES` in the Arduino component's `CMakeLists.txt`, so the script removes them from that list as well. Otherwise CMake fails on the missing sources. The `docs`, `tests`, `package`, `idf_component_examples` and `tools/pre-commit` folders are removed too.

If EMS-ESP needs one of these libraries again, delete its `rm -rf` line in `tools/install-arduino.sh` (and, for `SD`, `SD_MMC`, `FFat` or `PPP`, the matching line in the `$SED` command below it).

| Config | Setting | What it is | Why it is changed |
|---|---|---|---|
| `CONFIG_BT_ENABLED` | off | Bluetooth / NimBLE stack | EMS-ESP does not use BT. Chip defconfigs turn NimBLE on; disabling it frees flash and IRAM. |
| `CONFIG_LWIP_PPP_SUPPORT` | off | PPP (cellular / modem) in lwIP | No modem path. Tasmota leaves this on; it pulls in extra lwIP and Arduino PPP code. |
| `CONFIG_LWIP_IP_FORWARD` | off | IP routing between interfaces | Tasmota uses this as a Wi‑Fi router. EMS-ESP is a gateway on one LAN, not a router. |
| `CONFIG_LWIP_IPV4_NAPT` | off | IPv4 NAT | Same as above: NAT is only needed if the device routes a private LAN to another interface. |
| `CONFIG_LWIP_IPV4_NAPT_PORTMAP` | off | NAT port-forward table | Dependent on NAPT; unused without routing. |
| `CONFIG_ULP_COPROC_ENABLED` | off | Ultra-low-power coprocessor | Not used. Chip defconfigs reserve ULP RAM for it. |
| `CONFIG_FREERTOS_GENERATE_RUN_TIME_STATS` | off | Per-task CPU-time counters | Debug/profiling. Tasmota enables it; EMS-ESP does not need the overhead. |
| `CONFIG_FREERTOS_USE_TRACE_FACILITY` | off | FreeRTOS trace / `vTaskList` support | Companion to run-time stats; extra RAM and code if left on. |
| `CONFIG_FREERTOS_ENABLE_TASK_SNAPSHOT` | off | Task snapshot for core dumps / GDB | Already off in common; forced off so a later file cannot re-enable it. |
| `CONFIG_ESP_MODEM_USE_PPP_MODE` | off | esp_modem PPP session | Follows PPP being off; no cellular modem. |
| `CONFIG_ESP_GDBSTUB_ENABLED` | off | Serial GDB stub in the firmware | Debug-only. Not wanted in a production EMS-ESP image. |
| `CONFIG_MDNS_ENABLE_CONSOLE_CLI` | off | mDNS commands on the IDF console | Extra console surface EMS-ESP does not expose. |
| `CONFIG_MDNS_ENABLE_BROWSE` | off | mDNS service browsing (client) | EMS-ESP advertises itself; it does not browse for other services. |
| `CONFIG_I2S_ISR_IRAM_SAFE` | off | I2S ISR placed in IRAM | Tasmota needs this for I2S + PSRAM. EMS-ESP does not use that path; turning it off saves IRAM. |
| `CONFIG_RINGBUF_PLACE_ISR_FUNCTIONS_INTO_FLASH` | off | Ring-buffer ISRs stored in flash | Tasmota puts them in flash to save IRAM. That forces UART ISR out of IRAM and panics (cache error) when the EMS or console UART fires during a flash read (Wi‑Fi stop, mDNS, NVS). |
| `CONFIG_UART_ISR_IN_IRAM` | on | UART ISR in IRAM | Required with the ringbuf change. UART must keep running while flash is unmapped. |
| `CONFIG_SPIRAM_MALLOC_ALWAYSINTERNAL` | `256` | Allocations up to this size (bytes) always use internal RAM | Small allocations stay in faster internal RAM instead of PSRAM. |
| `CONFIG_SPIRAM_MALLOC_RESERVE_INTERNAL` | `1024` | Internal RAM (bytes) kept out of PSRAM-capable allocations | Keeps some internal heap free for allocations that must be internal. |
| `CONFIG_LWIP_LOCAL_HOSTNAME` | `"ems-esp"` | Default DHCP / mDNS hostname | Identifies the device as EMS-ESP instead of the Tasmota default. |
| `CONFIG_TINYUSB_DESC_CDC_STRING` | `"EMS-ESP CDC Device"` | USB-serial product string (S2/S3) | Same branding on the USB CDC port. |