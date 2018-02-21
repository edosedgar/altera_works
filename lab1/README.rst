============================
 Altera Quartus II Makefile
============================

This can be used to compile your altera projects on the commandline,
i.e. without the GUI.

Usage
~~~~~~

In order to use this to build your project, drop all your HDL code into fpga.
Edit *quartus/Makefile* to suit your needs, most interesting variables there
should be:

* SRCS (your HDL code)
* PROJECT (your projects name?)
* TOP_LEVEL_ENTITY (your projects top level entity)
* FAMILY, PART and BOARDFILE (for pin assignments, and part selection)

Now you can create and build your project by::

  user$: make -C quartus

In order to program the FPGA device use::

  user$: make program
