.. _upx12-13th-board:

|UPX12RPLP| Board
---------------------

The |UP Xtreme i12 13th board| (|UPX12RPLP|) is an x86 maker board based on Intel platform Raptor Lake-P. The UP boards are used in IoT, industrial automation, digital signage areas, etc.

Prerequisites
^^^^^^^^^^^^^^^^

|SPN| supports |UPX12RPLP| maker board. To start developing |SPN|, the following equipment, software and environments are required:

* |UP Xtreme i12 13th board|
* Custom SPI flashing cable (|instructions|).
* |USB 2.0 pin header cable| for debug uart output. OR `Make your own <upx12-debug-uart-pinout_>`_.
* DediProg SF100 or SF600 programmer
* Linux host (see :ref:`running-on-linux` for details)
* Internet access

.. |UP Xtreme i12 13th board| raw:: html

   <a href="https://www.aaeon.com/en/p/up-board-up-squared-i12" target="_blank">UP Xtreme i12 13th board</a>

.. |instructions| raw:: html

   <a href="https://wiki.up-community.org/BIOS_chip_flashing_on_UP_Squared" target="_blank">instructions</a>

.. |USB 2.0 pin header cable| raw:: html

   <a href="https://up-shop.org/usb-2-0-pin-header-cable.html" target="_blank">USB 2.0 pin header cable</a>


Board Setup
^^^^^^^^^^^^^^^^^

.. image:: /images/upxi12rplp_setup.jpg
   :width: 600
   :alt: |UPX12RPLP| Board Setup
   :align: center


Before You Start
^^^^^^^^^^^^^^^^^

.. warning:: As you plan to reprogram the SPI flash, it's a good idea to backup the pre-installed BIOS image second.


Boot the board and enter BIOS setup menu to get familiar with the board features and settings.

.. _upx12-debug-uart-pinout:

Early boot serial debug console can be reached via UART1 located on CN9 header on the |UPX12RPLP| board. Make sure you can observe serial output message running the factory BIOS first.

.. note:: To make your own UART debug adapter by direct wiring, refer to CN9 Header Pinout for UART1:

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

|UPX12RPLP| board is based on Intel |RPLP|. To build::

    python BuildLoader.py build rplp

The output images are generated under ``Outputs`` directory.


Stitching
^^^^^^^^^^

Stitch |SPN| images with factory BIOS image using the stitch tool::

    python Platform/AlderlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/rplp/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME> -p 0xAA000114

    <BIOS_IMAGE>     : Input file. Factory BIOS extracted from UP Xtreme i12 13th board.
    <SBL_IFWI_IMAGE> : Output file. New IFWI image with SBL in BIOS region.
    -p <value>       : 4-byte platform data for platform ID (e.g. 14) and debug UART port index (e.g. 01).

.. Note:: StitchLoader.py script works only if Boot Guard in the base image is not enabled, and the silicon is not fused with Boot Guard enabled.
          If Boot Guard is enabled, please use StitchIfwi.py script instead.

See :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.

Slimbootloader binary for capsule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
A capsule image could ecapsulate a Slimbootloader image to be used in firmware update mechanism. More information is described in :ref:`firmware-update`.

For the process running properly, an IFWI image programmed on board with TOP SWAP size configuration is required.

.. note:: Enabling TOP SWAP size configuration requires additional firmware components and tools.

Creating Slimbootloader binary for capsule image requires the following steps:

Build |SPN| for |UPX12RPLP|::

  python BuildLoader.py build rplp

Edit the 4-byte platform data in Slimbootloader image by *Hexedit* or equivalent hexdecimal editor.

Go to top of TOP SWAP A at address 0xCFFFF4, edit ``14 01 00 AA`` as below
::

  00CFFFF0   90 90 EB B9  14 01 00 AA  A4 50 FF FF  00 50 FF FF  ................

Go to top of TOP SWAP B at address 0xC7FFF4, edit ``14 01 00 AA`` as below
::

  00C7FFF0   90 90 EB B9  14 01 00 AA  A4 50 FF FF  00 50 FF FF  ................

For more details on TOP SWAP regions, please refer :ref:`flash-layout`

Generate capsule update image ``FwuImage.bin``::

  python BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS Outputs/rplp/SlimBootloader.bin -k KEY_ID_FIRMWAREUPDATE_RSA3072 -o FwuImage.bin

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

Flash the IFWI image to |UPX12RPLP| board using a SPI programmer. Header CN19 on the board should be used, see |BIOS_CHIP_FLASHING| for additional details.


.. |BIOS_CHIP_FLASHING| raw:: html

   <a href="https://wiki.up-community.org/BIOS_chip_flashing_on_UP_Squared" target="_blank">instructions</a>

**Good Luck!**
