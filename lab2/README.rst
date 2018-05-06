Peripheral terminal description
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This Verilog project implements basic protocol to communicate with
the FPGA over UART interface.

**Request**::

  [Command][Length][Base address][Payload][CRC-16]

Payload is transmitted if **command** is not read-based

**Answer**::

  [Command][Length][Base address][Payload][CRC-16]

Payload is transmitted if **command** is not write-based

The terminal proccesses the following commands:

* 0x00 - Write Payload To Registers
* 0x80 - Read Payload from Registers
* 0x01 - Write Payload To MMC Memory
* 0x81 - Read Payload from MMC Memory

The registers set to be accessed is quite small::

  BASE ADDRESS + 0x0000 => LED[7:0]

  BASE ADDRESS + 0x0001 => DISP[15:8]

  BASE ADDRESS + 0x0002 => DISP[7:0]

  BASE ADDRESS + 0x0003 => Button[3:0]

The range of address to be covered is calculated in the following way:

  ADDRESS = BASE ADDRESS + (0..Length)

Usage
~~~~~~

To build project::

  user$: make -C quartus

In order to program the FPGA device use::

  user$: make program
