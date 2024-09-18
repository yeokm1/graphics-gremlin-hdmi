# Graphics Gremlin HDMI

This is a modified version of the Graphics Gremlin ISA CGA/MDA graphics card to include a HDMI port. This is still based on the same Lattice ICE40HX4K FPGA.

(A production run has been made of this board. You can contact explit[at]mailbox[dot]org if you wish to purchase a unit.)

The latest revision now displays CGA colour 6 brown correctly. Since this project builds on the original project, it carries over some emulation inaccuracies in demos like 8088MPH and other applications.


<img src="images\gg-hdmi-board.jpg" width="600">

Top view of board

<img src="images\gg-hdmi-board-ports.jpg" width="800">

Left is the original Graphics Gremlin, right is my modified design.

# Demo videos

* Bootup and CGA compatibility tester (Brown fixed): https://www.youtube.com/watch?v=Ap-goSkkSUI
* Bootup and CGA compatibility tester (Deprecated): https://www.youtube.com/watch?v=xLy6on_o4YM
* 8088MPH: https://www.youtube.com/watch?v=WLpNmEhdTe4
* Area5150 (using CGA overscan): https://www.youtube.com/watch?v=9wYU6qMWlpE
* My talk on this project: https://www.youtube.com/watch?v=r_GiEIe_oZk

# Changes from original project

* Hardware changes
    * Added HDMI port by removing the RGBI DE9 port. Port positions adjusted to ease trace routing.
    * Added [TI TFP410](https://www.ti.com/product/TFP410) DVI transmitter (HDMI is compatible with DVI). HDMI is independent of the VGA/Composite output.
    * Test points for inputs to DVI transmitter.
    * Replaced the 3.3VDC 1A linear regulator with 3A as TFP410 is power hungry at up to 1A.
    * Added pin headers for power.
    * Added LED power indicators for 5V and 3.3V.
    * 2-layer -> 4-layer board to ease routing.
* HDL code changes
    * Selectable MDA colours (HDMI only)
    * Removed normal MDA bitstream as there is no more RGBI port.
    * Added CGA 70Hz mode.
    * Added CGA 60Hz overscan mode for demo and debug purposes.
    * Modified Scandoubler code to support Display Enable signal as required by DVI chip but not VGA.

Readme of the original Graphics Gremlin project can be found [here](original_README.md).

# How to replicate this board and use it?

1. [Fabrication guidelines](https://github.com/yeokm1/graphics-gremlin-hdmi/wiki/Fabrication-guidelines)

2. [Flashing FPGA bitstream](https://github.com/yeokm1/graphics-gremlin-hdmi/wiki/Flashing-bitstream)

3. [Testing the board](https://github.com/yeokm1/graphics-gremlin-hdmi/wiki/Testing-procedures)

4. Usage guide below:

# Switches position

## Switches 1 and 2 for MDA

These colours are applicable for the HDMI section only. 

| 1      | 2      | MDA colour |
|--------|--------|------------|
| open   | open   | Green      |
| open   | closed | Yellow     |
| closed | open   | White      |
| closed | closed | Red        |

<img src="images\gg-hdmi-mda-display.jpg" width="800">

Sample of the different colours when testing the card on my [486 PC](https://github.com/yeokm1/retro-configs/tree/master/desktops/generic-486-pc).

## Switches 1 and 2 for CGA

| Switch | CGA                                  |
|--------|--------------------------------------|
| 1      | closed=composite mode. open=VGA mode |
| 2      | closed=thin font. open=normal font   |

**Note that VGA and Composite cannot be used simultaneously.** No change from original Graphics Gremlin. HDMI will work on all modes.

## Switches 3 and 4

| 3      | 4      | Bitstream   | Function               |
|--------|--------|-------------|------------------------|
| open   | open   | Bitstream 0 | MDA 70Hz               |
| open   | closed | Bitstream 1 | CGA 70Hz               |
| closed | open   | Bitstream 2 | CGA 60Hz               |
| closed | closed | Bitstream 3 | CGA 60Hz with overscan |

### CGA 60 and 70Hz 
After internal scandoubling, the CGA 60Hz will produce a 640x400x60Hz output suitable for most VGA monitors. While this works for the HDMI LCD monitors I have tested, it is technically below the DVI specification of a minimum of 640x480x60Hz and 25.175Mhz pixel clock. 

To meet the specification in case some monitors insist, I have added another mode CGA 70Hz which will produce 640x400 at 70Hz. (Actually 71Hz due to precision limitations of clock multiplying) This 70Hz is however not compatible with composite displays including the one inside IBM5155.

### CGA 60Hz with overscan

The CGA overscan bitstream will show the overscan sections beyond the usual display area just short of Hsync and Vsync. Overscan is used in some demos like Area 5150. However not all HDMI monitors can accept this signal and/or display this properly.

I notice that while a monitor may initially accept this mode, tendency is it will randomly throw you display errors later.

**The purpose of this mode is just for debug and demo purposes**.

# Development info

## Directory structure

```
|-- fab: Gerbers, BOM and PDF schematic
|-- images: Images used in this repo
|-- isa-video: Kicad Design files
|-- verilog: Updated Verilog code to support HDMI
|-- vga_display_status: Vivado project to process ICE40 FPGA output to DVI transmiter that runs on my Mimas A7 FPGA board.
|-- 3d-bracket: Step and STL file for a 3D-printable bracket
```

## Verilog Toolchain

To compile the project, I used the following open source tool-chain on my Ubuntu running on WSL on Windows 11.

```bash
sudo apt install libftdi-dev cmake

sudo apt install build-essential libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-test-dev libboost-filesystem-dev libboost-iostreams-dev libeigen3-dev

sudo apt install tclsh clang tcl-dev libreadline-dev bison flex

# Icestorm
git clone https://github.com/YosysHQ/icestorm.git icestorm
cd icestorm
make -j$(nproc)
sudo make install
cd ..

# NextPNR
git clone https://github.com/YosysHQ/nextpnr nextpnr
cd nextpnr
cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local .
make -j$(nproc)
sudo make install
cd ..

# Yosys
git clone https://github.com/YosysHQ/yosys.git yosys
cd yosys
make -j$(nproc)
sudo make install
```

To program the bitstream to the board, I used `iceprog -p` from OSS CAD Suite. Follow the [flash instructions](https://github.com/yeokm1/graphics-gremlin-hdmi/wiki/Flashing-bitstream). 

## Code compilation

In my Ubuntu WSL:

```bash
cd verilog
mkdir build
make
```

```bash
# Program my provided bitstream
iceprog -p isavideo.binm

# Program newly compiled bitstream
iceprog -p build/isavideo.binm
```

## Special handling for brown colour

The PCB and code treats the palette value "I:0 R:1 G:1 B:0" specially to produce a brown instead of dark yellow as per the CGA standard.

```verilog
// video[1] is the original green value
assign hdmi_grn = video[1] ^ (hdmi_red & video[1] & (hdmi_blu ^ 1) & (hdmi_int ^ 1));
assign hdmi_grn_int = hdmi_int ^ (hdmi_red & video[1] & (hdmi_blu ^ 1) & (hdmi_int ^ 1));
```

This is done using the above boolean logic to lower the green value by using the dedicated hdmi_green_int pin. This logic is [provided by @spbnick](https://github.com/yeokm1/yeokm1.github.io/discussions/115#discussioncomment-7022872).

<img src="images\gg-hdmi-cga-test.jpg" width="600">

My IBM 5155 running the [CGA Compatibility Tester](https://github.com/MobyGamer/CGACompatibilityTester) displaying the colour palatte.

## Testing with Mimas A7 (Xilinx Artix 7)

As part of my testing, I also made a small FPGA test project using another FPGA board Mimas A7 based on the Xilinx Artix 7. 

<img src="images\gg-hdmi-with-mimas-a7.jpg" width="600">

The FPGA test board reads the raw RGBI, HS, VS, DE and CLK signals that are given to the DVI transmitter and displays the output using its own HDMI output.

The code is heavily based on the [HDMI_FPGA](https://github.com/dominic-meads/HDMI_FPGA/) project by Dominic Meads and runs on Vivado 2023.

## Releases

* 2.1 (9 Aug 2021): Initial release for GG (HDMI)
* 2.2 (17 Sept 2023): Extra Green control line for TFP410
* 2.3 (13 Oct 2023): Corrected VGA port footprint bug
* 2.4 (4 Jan 2024): Kicad 7.10, cleaned up schematic errors, removed unused traces, update pcb symbols and 3D models, cleaned up BOM. (No functional difference with 2.3)

## License
This work is licensed under a Creative Commons Attribution-ShareAlike 4.0
International License. See [https://creativecommons.org/licenses/by-sa/4.0/](https://creativecommons.org/licenses/by-sa/4.0/).
