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

The range of address to be covered is calculated in the following way::

  ADDRESS = BASE ADDRESS + (0..Length)

Examples
~~~~~~~~

Default settings::

  BASE ADDRESS: 0x4900

  CRC16 Polynomial: 0x1021

  Initial CRC16 value: 0xFFFF

  Final CRC16 Xor value: 0x0000

  Input and result are not reflected

* To read one byte from MMC memory::

  0x81 0x01 0x49 0x00 0xAF 0x28

* To write one byte to MMC memory::

  0x01 0x01 0x49 0x00 0x00 0x4E 0x05

* To turn LED0 on::

  0x00 0x01 0x49 0x00 0x01 0xF4 0xA5

* To show "BABE" on the seven-segment display::

  0x00 0x02 0x49 0x01 0xBA 0xBE 0x57 0x9B

Usage
~~~~~~

To build project::

  user$: make -C quartus

In order to program the FPGA device use::

  user$: make program
