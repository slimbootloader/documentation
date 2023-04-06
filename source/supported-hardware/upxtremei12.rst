.. _upx12-board:

|UPX12| Board
---------------------

The |UP Xtreme i12 board| (|UPX12|) is an x86 maker board based on Intel platform Alder Lake-P. The UP boards are used in IoT, industrial automation, digital signage areas, etc.

Prerequisites
^^^^^^^^^^^^^^^^

|SPN| supports |UPX12| maker board. To start developing |SPN|, the following equipment, software and environments are required:

* |UP Xtreme i12 board|
* Custom SPI flashing cable (|instructions|).
* |USB 2.0 pin header cable| for debug uart output. OR `Make your own <upx12-debug-uart-pinout_>`_.
* DediProg SF100 or SF600 programmer
* Linux host (see :ref:`running-on-linux` for details)
* Internet access

.. |UP Xtreme i12 board| raw:: html

   <a href="https://up-shop.org/up-xtreme-i12-series.html" target="_blank">UP Xtreme i12 board</a>

.. |instructions| raw:: html

   <a href="https://wiki.up-community.org/BIOS_chip_flashing_on_UP_Squared" target="_blank">instructions</a>

.. |USB 2.0 pin header cable| raw:: html

   <a href="https://up-shop.org/usb-2-0-pin-header-cable.html" target="_blank">USB 2.0 pin header cable</a>


Board Setup
^^^^^^^^^^^^^^^^^

.. image:: /images/upx12_setup.jpg
   :width: 600
   :alt: |UPX12| Board Setup
   :align: center


Before You Start
^^^^^^^^^^^^^^^^^

.. warning:: As you plan to reprogram the SPI flash, it's a good idea to backup the pre-installed BIOS image first.


Boot the board and enter BIOS setup menu to get familiar with the board features and settings.

.. _upx12-debug-uart-pinout:

Early boot serial debug console can be reached via UART1 located on CN9 header on the |UPX12| board. Make sure you can observe serial output message running the factory BIOS first.

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

|UPX12| board is based on Intel |ADLP|. To build::

    python BuildLoader.py build adlp

The output images are generated under ``Outputs`` directory.


Stitching
^^^^^^^^^^

Stitch |SPN| images with factory BIOS image using the stitch tool::

    python Platform/AlderlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/adlp/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME> -p 0xAA000104

    <BIOS_IMAGE>     : Input file. Factory BIOS extracted from UP Xtreme i12 board.
    <SBL_IFWI_IMAGE> : Output file. New IFWI image with SBL in BIOS region.
    -p <value>       : 4-byte platform data for platform ID (e.g. 04) and debug UART port index (e.g. 01).

.. Note:: StitchLoader.py script works only if Boot Guard in the base image is not enabled, and the silicon is not fused with Boot Guard enabled.
          If Boot Guard is enabled, please use StitchIfwi.py script instead.

See :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.

Flashing
^^^^^^^^^

Flash the IFWI image to |UPX12| board using a SPI programmer. Header CN19 on the board should be used, see |BIOS_CHIP_FLASHING| for additional details.


.. |BIOS_CHIP_FLASHING| raw:: html

   <a href="https://wiki.up-community.org/BIOS_chip_flashing_on_UP_Squared" target="_blank">instructions</a>

**Good Luck!**
