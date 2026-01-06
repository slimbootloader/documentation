.. _up2-twl-board:

|UP2TWL| Board
---------------------

The |UP Squared Pro TWL board| (|UP2TWL|) is an x86 maker board based on Intel platform Twin Lake. The UP boards are used in AI development, edge computing, industrial-grade applications, etc.

Prerequisites
^^^^^^^^^^^^^^^^

|SPN| supports |UP2TWL| maker board. To start developing |SPN|, the following equipment, software and environments are required:

* |UP Squared Pro TWL board|
* Custom SPI flashing cable (|instructions|).
* |USB 2.0 pin header cable| for debug uart output. OR `Make your own <UP2TWL-debug-uart-pinout_>`_.
* DediProg SF100 or SF600 programmer
* Linux host (see :ref:`running-on-linux` for details)
* Internet access

.. |UP Squared Pro TWL board| raw:: html

   <a href="https://up-shop.org/default/up-squared-pro-twl-ai-dev-kit.html" target="_blank">UP Squared Pro TWL board</a>

.. |instructions| raw:: html

   <a href="https://wiki.up-community.org/BIOS_chip_flashing_on_UP_Squared" target="_blank">instructions</a>

.. |USB 2.0 pin header cable| raw:: html

   <a href="https://up-shop.org/usb-2-0-pin-header-cable.html" target="_blank">USB 2.0 pin header cable</a>


Board Setup
^^^^^^^^^^^^^^^^^

.. image:: /images/up2_twl_setup.jpg
   :width: 600
   :alt: |UP2TWL| Board Setup
   :align: center


Before You Start
^^^^^^^^^^^^^^^^^

.. warning:: As you plan to reprogram the SPI flash, it's a good idea to backup the pre-installed BIOS image first.


Boot the board and enter BIOS setup menu to get familiar with the board features and settings.

.. _UP2TWL-debug-uart-pinout:

Early boot serial debug console can be reached via UART1 located on CN14 header on the |UP2TWL| board. Make sure you can observe serial output message running the factory BIOS first.

.. note:: To make your own UART debug adapter by direct wiring, refer to CN14 Header Pinout for UART1:

  +--------+--------------+
  |  Pin   |    Signal    |
  +--------+--------------+
  |   8    |     GND      |
  +--------+--------------+
  |   9    |   UART_RX    |
  +--------+--------------+
  |   10   |   UART_TX    |
  +--------+--------------+


Building
^^^^^^^^^^

|UP2TWL| board is based on Intel |TWL|. To build::

    python BuildLoader.py build uptwl

The output images are generated under ``Outputs`` directory.


Stitching
^^^^^^^^^^

Stitch |SPN| images with factory BIOS image using the stitch tool::

    python Platform/AlderlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/uptwl/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME> -p 0xAA00011E

    <BIOS_IMAGE>     : Input file. Factory BIOS extracted from UP Squared Pro TWL board.
    <SBL_IFWI_IMAGE> : Output file. New IFWI image with SBL in BIOS region.
    -p <value>       : 4-byte platform data for platform ID (e.g. 1E) and debug UART port index (e.g. 01).

.. Note:: StitchLoader.py script works only if Boot Guard in the base image is not enabled, and the silicon is not fused with Boot Guard enabled.
          If Boot Guard is enabled, please use StitchIfwi.py script instead.

See :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.

Slimbootloader binary for capsule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Creating Slimbootloader binary for capsule image requires the following steps:

Build |SPN| for |UP2TWL|::

  python BuildLoader.py build uptwl

Run stitching process as described above to create a |SPN| IFWI binary ``sbl_up2_twl_ifwi.bin``::

  python Platform/AlderlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/uptwl/SlimBootloader.bin -o sbl_up2_twl_ifwi.bin -p 0xAA00011E

Extract ``bios.bin`` from |SPN| IFWI image::

  python BootloaderCorePkg/Tools/IfwiUtility.py extract -i sbl_up2_twl_ifwi.bin -p IFWI/BIOS -o bios.bin

Generate capsule update image ``FwuImage.bin``::

  python BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS bios.bin -k KEY_ID_FIRMWAREUPDATE_RSA3072 -o FwuImage.bin



For more details on generating capsule image, please refer :ref:`generate-capsule`.

Triggering Firmware Update
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Please refer to :ref:`firmware-update` on how to trigger firmware update flow.
Below is an example:

To trigger firmware update in |SPN| shell:

1. Copy ``FwuImage.bin`` into root directory on FAT partition of a USB key

2. Boot and press any key to enter |SPN| shell

3. Type command ``fwupdate`` from shell

   Observe |SPN| resets the platform and performs update flow. It resets *multiple* times to complete the update process.

Flashing
^^^^^^^^^

Flash the IFWI image to |UP2TWL| board using a SPI programmer. Header CN18 on the board should be used, see |BIOS_CHIP_FLASHING| for additional details.


.. |BIOS_CHIP_FLASHING| raw:: html

   <a href="https://wiki.up-community.org/BIOS_chip_flashing_on_UP_Squared" target="_blank">instructions</a>

**Good Luck!**
