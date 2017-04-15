# lcdDMD

lcdDMD is a verilog project that generate an HDMI signal in order to simulate a DMD (Dot Matrix Display).

The generated signal is compatible with Toshiba panel LTA149B780F

- Native resolution is 1280x390
- DMD resolution is 128x39 (each dot 5x5 pixels and each pixel is separated by 2 pixels)


This project is mean to be used with the Pluto-IIx-hdmi board (Xilinx Spartan3 - XC3S200A) from KNJN and the code is based on the HDMI sample project provided with the board
  
[http://www.knjn.com/FPGA-RS232.html]


# Install

- Open the .ise project with Webpack ISE (successfully compile with v14.7)
- Run 'Synthesis'
- Run 'Implement Design'
- Run 'Generate Programming File'

Note: There will warnings but who cares

- Upload the bitfile with the fpgaconf application


License
----

WTFPL
[https://en.wikipedia.org/wiki/WTFPL]

