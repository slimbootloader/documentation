.. _stitch-tool:

Stitch Tool
------------

``StitchLoader.py`` is a utility to replace |SPN| image in a fully flashable IFWI image. It takes all system firmware components from a working IFWI image and replace the BIOS region with |SPN| components.

This tool is used to create two output files:

* IFWI image with SBL (-o option).
* |SPN| BIOS image for capsule update (-b option). See :ref:`firmware-update`.


The command line options to perform stitching::

  usage: StitchLoader.py [-h] -i IFWI_IN [-o IFWI_OUT] [-b BIOS_OUT]
                         [-s STITCH_IN] [-p PLAT_DATA]

  optional arguments:
    -h, --help            show this help message and exit
    -i IFWI_IN, --input-ifwi-file IFWI_IN
                          Specify input template IFWI image file path
    -o IFWI_OUT, --output-ifwi-file IFWI_OUT
                          Specify generated output IFWI image file path
    -b BIOS_OUT, --output-bios-region BIOS_OUT
                          Specify generated output BIOS region image file path
    -s STITCH_IN, --sitch-zip-file STITCH_IN
                          Specify input sitching zip package file path
    -p PLAT_DATA, --platform-data PLAT_DATA
                          Specify a platform specific data (HEX, DWORD) for
                          customization

**PLAT_DATA** is a DWORD containing platform data to configure debug UART port number. Format is defined below::

  For Apollo Lake:
    typedef struct {
        UINT8               PlatformId : 5;    /* Platform ID     */
        UINT8               Reserved1  : 3;
        UINT8               DebugUart  : 2;    /* UART port index */
        UINT8               Reserved2  : 6;
        UINT8               Reserved3;
        UINT8               Marker;            /* 'AA'            */
    } STITCH_DATA;

  For Coffee Lake Refresh and Whiskey Lake:
    typedef struct {
        UINT8               PlatformId : 5;    /* Platform ID     */
        UINT8               Reserved1  : 3;
        UINT8               DebugUart;         /* UART port index */
        UINT8               Reserved3;
        UINT8               Marker;            /* 'AA'            */
    } STITCH_DATA;



IFWI Image vs. |SPN| BIOS Image  
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

IFWI image is used as input to program SPI flash on the hardware, while |SPN| BIOS image is used as input file to create firmware update capsule image.
