Peripheral terminal description
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This Verilog project implements basic protocol to communicate with
the FPGA over UART interface.

**Request**:

  [Command][Length][Base address][Payload][CRC-16]

Payload is transmitted if **command** is not read-based

**Answer**:

  [Command][Length][Base address][Payload][CRC-16]

Payload is transmitted if **command** is not write-based

The terminal proccesses the following commands:

* 0x00 - Write Payload To Registers
* 0x80 - Read Payload from Registers
* 0x01 - Write Payload To MMC Memory
* 0x81 - Read Payload from MMC Memory

The registers set is quite simple:

  BASE ADDRESS + 0x0000 => LED[7:0]

  BASE ADDRESS + 0x0001 => DISP[15:8]

  BASE ADDRESS + 0x0002 => DISP[7:0]

  BASE ADDRESS + 0x0003 => Button[3:0]

To calculate the next address to be used it is required to calculate one
according to the following rule:

  ADDRESS = BASE ADDRESS + (0..Length)

Usage
~~~~~~

Now you can create and build your project by::

  user$: make -C quartus

In order to program the FPGA device use::

  user$: make program
