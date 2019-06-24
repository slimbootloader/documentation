Terminology and Acronyms
==========================

**SBL** Slim Bootloader

**UDK** UEFI Development Kit

**TPM** Trsuted Platform Module

**ASL** ACPI Source Language

**NASM** Assembler/Disassembler for Intel architecture.

FSP
  Firmware Support Package. FSP is a binary image embedded in |SPN| to initialize main memory and chipset for Intel SoCs. It provides a standardized API that boot loaders call into in order to initialize the silicon. These APIs are required in order to boot an OS.

  An FSP v2.0 compliant image consists of three subcomponents:

  * FSP-T (**T**\ emporary Memory or Cache-As-RAM Initialization)
  * FSP-M (**M**\ emory Initialization)
  * FSP-S (**S**\ ilicon Initialization)

IFWI
  Integrated FirmWare Image. A complete flashable SPI image including all required
  firmware ingredients to boot on Intel platforms.

Zephyr
  A small scalable open source RTOS for IoT embedded devices.

Dockers
  This software uses operating system level virtualization to develop and deliver software in package called containers. The software that hosts these containers is called Docker Engine.