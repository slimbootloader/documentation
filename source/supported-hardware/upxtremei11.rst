.. _upx11-board:

|UPX11| Board
---------------------

The |UP Xtreme i11 board| (|UPX11|) is an x86 maker board based on Intel platform Tiger Lake UP3. The UP boards are used in IoT, industrial automation, digital signage areas, etc.

Prerequisites
^^^^^^^^^^^^^^^^

|SPN| supports |UPX11| maker board. To start developing |SPN|, the following equipment, software and environments are required:

* |UP Xtreme i11 board|
* Custom SPI flashing cable (|instructions|).
* |USB 2.0 pin header cable| for debug uart output. OR `Make your own <upx11-debug-uart-pinout_>`_.
* DediProg SF100 or SF600 programmer
* Linux host (see :ref:`running-on-linux` for details)
* Internet access

.. |UP Xtreme i11 board| raw:: html

   <a href="https://up-shop.org/up-xtreme-i11-boards-series.html" target="_blank">UP Xtreme i11 board</a>

.. |instructions| raw:: html

   <a href="https://wiki.up-community.org/BIOS_chip_flashing_on_UP_Squared" target="_blank">instructions</a>

.. |USB 2.0 pin header cable| raw:: html

   <a href="https://up-shop.org/up-peripherals/110-usb-20-pin-header-cable.html" target="_blank">USB 2.0 pin header cable</a>


Board Setup
^^^^^^^^^^^^^^^^^

.. image:: /images/upx11_setup.jpg
   :width: 600
   :alt: |UPX11| Board Setup
   :align: center


Before You Start
^^^^^^^^^^^^^^^^^

.. warning:: As you plan to reprogram the SPI flash, it's a good idea to backup the pre-installed BIOS image first.


Boot the board and enter BIOS setup menu to get familiar with the board features and settings.

.. _upx11-debug-uart-pinout:

Early boot serial debug console can be reached via UART2 located on CN11 header on the |UPX11| board. Make sure you can observe serial output message running the factory BIOS first.

.. note:: To make your own UART debug adapter by direct wiring, refer to CN11 Header Pinout for UART2:

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

|UPX11| board is based on Intel |TGL|. To build::

    python BuildLoader.py build tgl

The output images are generated under ``Outputs`` directory.


Stitching
^^^^^^^^^^

Stitch |SPN| images with factory BIOS image using the stitch tool::

    python Platform/TigerlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/tgl/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME> -p 0xAA000204

    <BIOS_IMAGE>     : Input file. Factory BIOS extracted from UP Xtreme i11 board.
    <SBL_IFWI_IMAGE> : Output file. New IFWI image with SBL in BIOS region.
    -p <value>       : 4-byte platform data for platform ID (e.g. 04) and debug UART port index (e.g. 02).

.. Note:: StitchLoader.py script works only if Boot Guard in the base image is not enabled, and the silicon is not fused with Boot Guard enabled.
          If Boot Guard is enabled, please use StitchIfwi.py script instead.

See :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.


Slimbootloader binary for capsule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Creating Slimbootloader binary for capsule image requires the following steps:

Build |SPN| for |UPX11|::

  python BuildLoader.py build tgl

Run stitching process as described above to create a |SPN| IFWI binary ``sbl_upx11_ifwi.bin``::

  python Platform/TigerlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/tgl/SlimBootloader.bin -o sbl_upx11_ifwi.bin -p 0xAA000204

Extract ``bios.bin`` from |SPN| IFWI image::

  python BootloaderCorePkg/Tools/IfwiUtility.py extract -i sbl_upx11_ifwi.bin -p IFWI/BIOS -o bios.bin

Generate capsule update image ``FwuImage.bin``::

  python BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS bios.bin -k KEY_ID_FIRMWAREUPDATE_RSA3072 -o FwuImage.bin


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

Flash the IFWI image to |UPX11| board using a SPI programmer. Header CN20 on the board should be used, see |BIOS_CHIP_FLASHING| for additional details.


.. |BIOS_CHIP_FLASHING| raw:: html

   <a href="https://wiki.up-community.org/BIOS_chip_flashing_on_UP_Squared" target="_blank">instructions</a>

**Good Luck!**
