.. alder-lake-rvp:

Alder Lake Platforms
-----------------------

.. note:: 12th Generation Intel\ |reg| Core\ |trade| Processor, formally known as |ADL| family.

Supported Boards
^^^^^^^^^^^^^^^^^^^^^

|SPN| supports various platforms corresponding to |ADL|-S, |ADL|-P, |ADL|-PS, |ADL|-N, |LAZB| (|SAZB|) and |ASL| Processors.

Each |ADL| board is assigned with a unique platform ID.

  +-------------------------+---------------+----------------+---------------+---------------+
  |        Board            |  Platform ID  | SPI Programmer |     UART      |     PLAT      |
  +-------------------------+---------------+----------------+---------------+---------------+
  |      |ADLS| DDR4        |     0x0017    |      J1G2      |     U6J1      |     adls      |
  +-------------------------+---------------+----------------+---------------+---------------+
  |      |ADLS| DDR5        |     0x001B    |      J1G2      |     U6J1      |     adls      |
  +-------------------------+---------------+----------------+---------------+---------------+
  |      |ADLP| DDR5        |     0x0012    |      J1C1      |     J9J3      |     adlp      |
  +-------------------------+---------------+----------------+---------------+---------------+
  |      |ADLP| LPDDR5      |     0x0013    |      J1C1      |     J9J3      |     adlp      |
  +-------------------------+---------------+----------------+---------------+---------------+
  |      |ADLP| LPDDR4      |     0x0010    |      J1C1      |     J9J3      |     adlp      |
  +-------------------------+---------------+----------------+---------------+---------------+
  |      |ADLPS| DDR5 RVP   |     0x000B    |      J25       |     J109      |     adlps     |
  +-------------------------+---------------+----------------+---------------+---------------+
  |      |ADLPS| DDR5 CRB   |     0x000D    |      J31       |     J34       |     adlps     |
  +-------------------------+---------------+----------------+---------------+---------------+
  |      |ADLN| DDR5 CRB    |     0x000A    |      J2E2      |     J9A1      |     adln      |
  +-------------------------+---------------+----------------+---------------+---------------+
  |      |SAZB| LPDDR5 CRB  |     0x0009    |      J30       |     J32       |     azb       |
  +-------------------------+---------------+----------------+---------------+---------------+
  |      ASL DDR5 CRB       |     0x000A    |      J2E2      |     J9A1      |     adln      |
  +-------------------------+---------------+----------------+---------------+---------------+

Debug UART
^^^^^^^^^^^

For |ADL| platforms, serial port connector location can be found from the above table for each supported target board.

.. note:: Configure host PuTTY or minicom to 115200bps, 8N1, no hardware flow control.

Building
^^^^^^^^^^

To build |SPN| for any |ADL| platform::

    python BuildLoader.py build <PLAT>
    
    <PLAT> = adlp, adls, adlps, adln, azb

.. note:: adln platform option supports both ADL-N and ASL platforms.

The output images are generated under ``Outputs`` directory.


Stitching
^^^^^^^^^^

1. Gather |ADL| IFWI firmware image

  Users can either download the full IFWI image if the IFWI image release is available or read the existing IFWI image on the board using SPI programmer.
  This image contains additional firmware ingredients that are required boot on |ADL|.

.. note::
  ``StitchLoader.py`` currently does not support stitching with boot guard feature **enabled**.
  To stitch with Boot Guard enabled, please use ``StitchIfwi.py``.


2. Stitch |SPN| images into downloaded BIOS image::

    python Platform/AlderlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/<plat>/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME>

  where -i = Input file, -o = Output file, plat = adls/adlp

For example, to stitch |SPN| IFWI image ``sbl_adls_ifwi.bin`` from |ADLS| downloaded firmware images::

    python Platform/AlderlakeBoardPkg/Script/StitchLoader.py -i xxxx.bin -s Outputs/adls/SlimBootloader.bin -o sbl_adls_ifwi.bin

For more details on stitch tool, see :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.


Flashing
^^^^^^^^^

Flash the generated ``sbl_adlx_ifwi.bin`` to the target board using a DediProg SF100 or SF600 programmer.

.. note:: Refer the table above to identify the connector on the target board for SPI flash programmer. When using such device, please ensure:


    #. The alignment/polarity when connecting Dediprog to the board. 
    #. The power to the board is turned **off** while the programmer is connected (even when not in use).
    #. The programmer is set to update the flash from offset 0x0.


Capsule image for |ADL|
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Slimbootloader.bin image generated from the build steps above can be used to create a capsule image.
Please refer to :ref:`build-tool` on generating |SPN| image.

For all |ADL| platforms, the below command can be used::

    python ./BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS Outputs/<plat>/SlimBootloader.bin -k <Keys> -o FwuImage.bin

For more details on generating capsule image, please refer :ref:`generate-capsule`.


Triggering Firmware Update
^^^^^^^^^^^^^^^^^^^^^^^^^^^

|SPN| for |ADL| uses BIT16 of PMC I/O register (Over-Clocking WDT Control (OC_WDT_CTL) - Offset 54h) to trigger firmware update. When BIT16 is set, |SPN| will set the boot mode to FLASH_UPDATE.
Please refer to :ref:`firmware-update` on how to trigger firmware update flow.
Below is an example:

To trigger firmware update in |SPN| shell:

1. Copy ``FwuImage.bin`` into root directory on FAT partition of a USB key

2. Boot and press any key to enter |SPN| shell

3. Type command ``fwupdate`` from shell

   |SPN| will reset the platform and initiate firmware update flow. The platform will reset *multiple* times to complete the update process.

   A sample boot messages from console::

    Shell> fwupdate
    ...
    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 18
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    Jump to payload
    ...
    Starting Firmware Update
    ...
    =================Read Capsule Image==============
    ...
    ................
    Finished     1%
    ...
    Finished    99%
    ...
    ...
    
    Reset required to proceed with the firmware update.

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP1
    MODE: 18
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    =================Read Capsule Image==============
    ...
    ................
    Finished     1%
    ...
    Finished    99%
    Updating 0x002B1000, Size:0x0A000
    ...............
    Finished   100%
    Set next FWU state: 0x7C
    Firmware Update status updated to reserved region
    Set next FWU state: 0x77
    Reset required to proceed with the firmware update.
    ...
    ==================== OS Loader ====================

    Starting Kernel ...


Booting Yocto Linux
^^^^^^^^^^^^^^^^^^^^^

You may need to change boot options to boot from USB. See :ref:`change-boot-options`.

1. Download Yocto Linux
2. Create bootable USB key. For example: In Windows, Rufus can be used. In Linux, etcher app can be used.
3. Boot the bootable OS image from USB key on the board.


See :ref:`dynamic-platform-id` for more details.

To customize board configurations in ``*.dlt`` file, make sure to specify ``PlatformId`` to the corresponding values for the board.

See :ref:`configuration-tool` for more details.


