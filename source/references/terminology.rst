Terminology and Acronyms
==========================

FSP
  Firmware Support Package. FSP is a binary image embedded in |SPN| to initialize main memory and chipset for Intel SoCs. It provides a standardized API that boot loaders call into in order to initialize the silicon. These APIs are required in order to boot an OS.

  An FSP v2.0 compliant image consists of three subcomponents:

  * FSP-T (**T**\ emporary Memory or Cache-As-RAM Initialization)
  * FSP-M (**M**\ emory Initialization)
  * FSP-S (**S**\ ilicon Initialization)

IFWI
  Integrated FirmWare Image. A complete flashable SPI image including all required
  firmware ingredients to boot on Intel platforms.

