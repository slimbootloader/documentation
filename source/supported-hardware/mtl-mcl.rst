.. MTL-MCL-board:

|MTL-MCL| Board
---------------------------------

The Intel McLaren Island Reference Design Board (|mtl-mcl|) is an x86 maker board based on Intel platform Meteor Lake. The boards are used in IoT, industrial automation, digital signage areas, etc.

Prerequisites
^^^^^^^^^^^^^^^^

|SPN| supports |Intel McLaren Island Reference Design Board|. To start developing |SPN|, the following equipment, software and environments are required:

* |Intel McLaren Island Reference Design Board|
* DediProg SF600 programmer
* Linux host or windows host (see :ref:`running-on-linux` or :ref:`running-on-windows` for details)
* Internet access

.. |Intel McLaren Island Reference Design Board| raw:: html

   <a href="https://www.seavo.com/en/products/products-info_itemid_558.html" target="_blank">Intel McLaren Island Reference Design Board</a>

.. |instructions| raw:: html

   <a href="https://wiki.up-community.org/BIOS_chip_flashing_on_UP_Squared" target="_blank">instructions</a>

Board Setup
^^^^^^^^^^^^^^^^^

.. image:: /images/mcl-setup.jpg
   :width: 600
   :alt: |MTL-MCL| Board Setup
   :align: center


Before You Start
^^^^^^^^^^^^^^^^^

.. warning:: As you plan to reprogram the SPI flash, it's a good idea to backup the pre-installed BIOS image first.


Boot the board and enter BIOS setup menu to get familiar with the board features and settings.

Debug UART
^^^^^^^^^^^

Serial port connector is the micro-usb connector, the location is near the sata port.

.. note:: Configure host PuTTY or minicom to 115200bps, 8N1, no hardware flow control.

Building
^^^^^^^^^^

|Intel McLaren Island Reference Design Board| is based on Intel |MTL|. To build::

    python BuildLoader.py build mtl

The output images are generated under ``Outputs`` directory.

Stitching
^^^^^^^^^^

Stitch |SPN| images with factory BIOS image using the stitch tool::

    python Platform/MeteorlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/mtl/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME> -p 0xAA00001F

    <BIOS_IMAGE>     : Input file. Factory BIOS extracted from McLaren Island board.
    <SBL_IFWI_IMAGE> : Output file. New IFWI image with SBL in BIOS region.
    -p <value>       : 4-byte platform data for platform ID (e.g. 1F) and debug UART port index (e.g. 00).

See :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.

Stitch SBL images with IFWI ingredients::

    python Platform/MeteorlakeBoardPkg/Script/StitchIfwi.py  -b fvme
    -s Outputs/mtl/Stitch_Components.zip
    -c Platform/MeteorlakeBoardPkg/Script/StitchIfwiConfig_mcl.py
    -w /Stitchifwi_components_mtl -p mtlp -d 0xAA00001F

.. Note:: StitchLoader.py script works only if Boot Guard in the base image is not enabled, and the silicon is not fused with Boot Guard enabled.
          If Boot Guard is enabled, please use StitchIfwi.py script instead.


Slimbootloader binary for capsule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Slimbootloader.bin image generated from the build steps above can be used to create a capsule image.
Please refer to :ref:`build-tool` on generating |SPN| image.

For all |MTL| platforms, the below command can be used::

    python ./BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS Outputs/<plat>/SlimBootloader.bin -k <Keys> -o FwuImage.bin

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

Flash the generated SBL_IFWI_IMAGE_NAME to the target board using a DediProg SF600 programmer.

.. note:: Refer the table above to identify the connector on the target board for SPI flash programmer. When using such device, please ensure:


    #. The alignment/polarity when connecting Dediprog to the board. 
    #. The power to the board is turned **off** while the programmer is connected (even when not in use).
    #. The programmer is set to update the flash from offset 0x0.


**Good Luck!**
