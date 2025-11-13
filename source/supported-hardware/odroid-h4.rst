.. odroid-h4-board:

|ODROID-H4| Board
---------------------

The |Hardkernel ODROID H4 board| (|ODROID-H4|) is an x86 maker board based on Intel platform Alder Lake-N. The ODROID boards are used in IoT, industrial automation, digital signage areas, etc.

Prerequisites
^^^^^^^^^^^^^^^^

|SPN| supports |ODROID-H4| maker board. To start developing |SPN|, the following equipment, software and environments are required:

* |Hardkernel ODROID H4 board|
* 3x 2.54mm pitch dupont wires and USB-UART adapter for debug uart output
* DediProg SF100/SF600 or CH341A programmer and SPI SOI8 clip (|instructions|).
* Linux host (see :ref:`running-on-linux` for details)
* Internet access

.. |Hardkernel ODROID H4 board| raw:: html

   <a href="https://www.hardkernel.com/shop/odroid-h4/" target="_blank">ODROID H4 board</a>

.. |instructions| raw:: html

   <a href="https://wiki.odroid.com/odroid-h3/hardware/restore_h3_bios_usbprogrammer" target="_blank">instructions</a>


Before You Start
^^^^^^^^^^^^^^^^^

.. warning:: As you plan to reprogram the SPI flash, it's a good idea to backup the pre-installed BIOS image first.


Boot the board and enter BIOS setup menu to get familiar with the board features and settings.

.. _ODROID-H4-debug-uart-pinout:

Early boot serial debug console can be reached via ITE IT8613E Super I/O UART located on EXT_HEAD1 header on the |ODROID-H4| board. Make sure you can observe serial output message running the factory BIOS first.

.. note:: To connect USB-UART debug adapter by direct wiring, refer to EXT_HEAD1 header pinout for UART:

  +--------+--------------+
  |  Pin   |    Signal    |
  +--------+--------------+
  |   6    |     GND      |
  +--------+--------------+
  |   8    |   UART_RX    |
  +--------+--------------+
  |   10   |   UART_TX    |
  +--------+--------------+


Building
^^^^^^^^^^

|ODROID-H4| board is based on Intel |ADLN|. To build Universal Payload run::

    git clone https://github.com/tianocore/edk2.git
    cd edk2
    git submodule update --init --checkout --recursive
    source edksetup.sh
    make -C BaseTools
    python ./UefiPayloadPkg/UniversalPayloadBuild.py -t GCC5 \
        -D CRYPTO_PROTOCOL_SUPPORT=TRUE -D SIO_BUS_ENABLE=TRUE \
        -D PERFORMANCE_MEASUREMENT_ENABLE=TRUE \
        -D MULTIPLE_DEBUG_PORT_SUPPORT=TRUE -D BOOTSPLASH_IMAGE=TRUE \
        -D BOOT_MANAGER_ESCAPE=TRUE


Copy the resulting ``Build/UefiPayloadPkgX64/UniversalPayload.elf`` to ``<sbl_tree>/PayloadPkg/PayloadBins/``.

To build |SPN|::

    python BuildLoader.py build odroidh4 -p "OsLoader.efi:LLDR:Lz4;UniversalPayload.elf:UEFI:Lzma"

The output images are generated under ``Outputs`` directory.

To build without UEFI Universal Payload change the PayloadID in ``<sbl_tree>/Platform/AlderlakeBoardPkg/CfgData/CfgDataExt_Odroid_H4.dlt`` to::

    GEN_CFG_DATA.PayloadId                     | ''
    

And run::

    python BuildLoader.py build odroidh4

Stitching
^^^^^^^^^^

Stitch |SPN| images with factory BIOS image using the stitch tool::

    python Platform/AlderlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/odroidh4/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME> -p 0xAAFFFF0C

    <BIOS_IMAGE>     : Input file. Factory BIOS extracted from UP Squared Pro 7000 Edge board.
    <SBL_IFWI_IMAGE> : Output file. New IFWI image with SBL in BIOS region.
    -p <value>       : 4-byte platform data for platform ID (e.g. 0C) and debug UART port index (e.g. FF - EC UART on port 0x3f8).

See :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.

Slimbootloader binary for capsule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Creating Slimbootloader binary for capsule image requires the following steps:

Build |SPN| for |ODROID-H4|::

  python BuildLoader.py build odroidh4 -p "OsLoader.efi:LLDR:Lz4;UniversalPayload.elf:UEFI:Lzma"

Run stitching process as described above to create a |SPN| IFWI binary ``sbl_odroidh4_ifwi.bin``::

  python Platform/AlderlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/odroidh4/SlimBootloader.bin -o sbl_odroidh4_ifwi.bin -p 0xAAFFFF0C

Extract ``bios.bin`` from |SPN| IFWI image::

  python BootloaderCorePkg/Tools/IfwiUtility.py extract -i sbl_odroidh4_ifwi.bin -p IFWI/BIOS -o bios.bin

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

Flash the IFWI image to |ODROID-H4| board using a SPI programmer. See |BIOS_CHIP_FLASHING| for additional details.


.. |BIOS_CHIP_FLASHING| raw:: html

   <a href="https://wiki.odroid.com/odroid-h3/hardware/restore_h3_bios_usbprogrammer" target="_blank">instructions</a>

**Good Luck!**
