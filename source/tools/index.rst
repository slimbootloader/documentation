Tools
=======

|SPN| provides the development tools to support building, stitching and configuring the output images.

.. _build-tool:

Build Command
---------------

``BuildLoader.py`` compiles source code with all the *magics* to generate output image(s) with *slim* footprint. It provides two subcommands: build and clean.


You can build |SPN| with the following options:

* Build for a supported target
* Debug or release build
* Use debug image of FSP
* Change your payload files
* Attach a version data structure of your own

Command Syntax::

    python BuildLoader.py <subcommand> <target> <options>

    <subcommand>  : build or clean
    <target>      : board name (e.g. apl or qemu)


Windows and Linux share the same command line options as follows. For example, for ``build`` subcommand::

    usage: BuildLoader.py build [-h] [-r] [-v] [-fp FSPPATH] [-fd] [-p PAYLOAD] board

    positional arguments:
    board                 Board Name (apl, qemu)

    optional arguments:
      -h, --help            show this help message and exit
      -r, --release         Release build
      -v, --usever          Use board version file
      -fp FSPPATH           FSP binary path relative to FspBin in Silicon folder
      -fd, --fspdebug       Use debug FSP binary
      -p PAYLOAD, --payload PAYLOAD
                            Payload file name

|SPN| supports a single image supporting up to 32 board configurations for the same type of board or platform. To add multi-board support, see :ref:`configuration-feature`.

.. _ias-tool:

IAS Tool
----------

``iasimage`` is a utility for creating Intel Automotive Service (IAS) images in a binary file format understood by |SPN| to load and initialize Operating Systems or Hypervisors.

This tool is available on GitHub: |https://github.com/intel/iasimage|

.. |https://github.com/intel/iasimage| raw:: html

   <a href="https://github.com/intel/iasimage" target="_blank">https://github.com/intel/iasimage</a>


.. _stitch-tool:

Stitch Tool
----------------

``StitchLoader.py`` is a utility to replace |SPN| image in a fully flashable IFWI image. It takes all system firmware components from a working IFWI image and replace the BIOS region with |SPN| components.

This tool is used to create two output files:

* IFWI image with SBL (-o option).
* |SPN| BIOS image for capsule update (-b option). See :ref:`create-capsule`.


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

  typedef struct {
    UINT8               PlatformId : 5;    /* Platform ID      */
    UINT8               Reserved1  : 3;
    UINT8               DebugUart  : 2;    /* UART port index */
    UINT8               Reserved2  : 6;
    UINT8               Reserved3;
    UINT8               Marker;            /* 'AA'            */
  } STITCH_DATA;



IFWI Image vs. |SPN| BIOS Image  
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

IFWI image is used as intput to program SPI flash on the hardware, while |SPN| BIOS image is used as input file to create firmware update capsule image.


.. _configuration-tool:

|CFGTOOL|
--------------------

``ConfigEditor.py`` is a GUI program provided in |SPN| to allow user to customize board specific settings. You will need this tool in porting or customizing a new board. It provides features to load a platform configuration file (``*.dsc``) and generate board configuration delta file (``*.dlt``). This tool can be used in pre-build or post-build process.

This tool depends on Python GUI tool kit **Tkinter**. It runs on both Windows and Linux.

Running |CFGTOOL|::

    python BootloaderCorePkg/Tools/ConfigEditor.py

