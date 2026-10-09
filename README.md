# EMS-ESP Arduino PlatformIO framework builder [![ESP32 builder](https://github.com/emsesp/esp32-arduino-lib-builder/actions/workflows/parallel_build.yaml/badge.svg)](https://github.com/emsesp/esp32-arduino-lib-builder/actions/workflows/parallel_build.yaml)[![GitHub Releases](https://img.shields.io/github/downloads/emsesp/esp32-arduino-lib-builder/total?label=downloads)](https://github.com/emsesp/esp32-arduino-lib-builder/releases/latest)

This is a fork of Tasmota Arduino PlatformIO framework builder that builds the libraries for EMS-ESP instead of Tasmota.
https://github.com/Jason2866/esp32-arduino-lib-builder

The main difference is that it builds the libraries for EMS-ESP instead of Tasmota. The changea are int he file `configs/defconfig.ems-esp`

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

### Quick re-testing (-s skips reinstalling ESP-IDF and components)
```bash
./build.sh -s -t esp32
```

### Build on Ubuntu
```bash
./build.sh
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
