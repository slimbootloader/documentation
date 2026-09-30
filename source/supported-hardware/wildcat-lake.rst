.. Wildcat-lake-rvp:

Wildcat Lake Platforms
-----------------------

.. note:: Intel\ |reg| Core\ |trade| Series 3 Processor, formally known as |WCL| family.

Supported Boards
^^^^^^^^^^^^^^^^^^^^^

|SPN| supports various platforms corresponding to |WCL|.

Each |WCL| board is assigned with a unique platform ID.

  +-------------------------+---------------+-------------------+---------------+------------+
  |        Board            |  Platform ID  | SPI Programmer    |     UART      |     PLAT   |
  +-------------------------+---------------+-------------------+---------------+------------+
  |      |WCL| DDR5 RVP     |     0x0008    |      J4J1         |     J9H1      |     wcl    |
  +-------------------------+---------------+-------------------+---------------+------------+
  |      |WCL| DDR5 CRB     |     0x0006    |      J1E2         |     J6K1      |     wcl    |
  +-------------------------+---------------+-------------------+---------------+------------+
  |      |WCL| LPDDR5       |     0x0007    |      J4J1         |     J9H1      |     wcl    |
  +-------------------------+---------------+-------------------+---------------+------------+



Debug UART
^^^^^^^^^^^

For |WCL| platforms, serial port connector location can be found from the above table for each supported target board.

.. note:: Configure host PuTTY or minicom to 115200bps, 8N1, no hardware flow control.

Building
^^^^^^^^^^

To build |SPN| for any |WCL| platform::

    python BuildLoader.py build <PLAT>
    
    <PLAT> = wcl

Note: The output images are generated under ``Outputs`` directory.


Stitching
^^^^^^^^^^

1. Gather |WCL| IFWI firmware image

  Users can either download the full IFWI image if the IFWI image release is available or read the existing IFWI image on the board using SPI programmer.
  This image contains additional firmware ingredients that are required boot on |WCL|.

.. note::
  ``StitchLoader.py`` currently does not support stitching with boot guard feature **enabled**.
  To stitch with Boot Guard enabled, please use ``StitchIfwi.py``.


2. Stitch |SPN| images into downloaded BIOS image::

    python Platform/WildcatlakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/<plat>/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME>

  where -i = Input file, -o = Output file, plat = wcl

For example, to stitch |SPN| IFWI image ``sbl_wcl_ifwi.bin`` from |WCL| downloaded firmware images::

    python Platform/WildcatlakeBoardPkg/Script/StitchLoader.py -i xxxx.bin -s Outputs/wcl/SlimBootloader.bin -o sbl_wcl_ifwi.bin

For more details on stitch tool, see :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.


Flashing
^^^^^^^^^

Flash the generated ``sbl_wcl_ifwi.bin`` to the target board using a DediProg SF100 or SF600 programmer.

.. note:: Refer the table above to identify the connector on the target board for SPI flash programmer. When using such device, please ensure:


    #. The alignment/polarity when connecting Dediprog to the board. 
    #. The power to the board is turned **off** while the programmer is connected (even when not in use).
    #. The programmer is set to update the flash from offset 0x0.


Capsule image for |WCL|
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Slimbootloader.bin image generated from the build steps above can be used to create a capsule image.
Please refer to :ref:`build-tool` on generating |SPN| image.

For all |WCL| platforms, the below command can be used::

    python ./BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS Outputs/<plat>/SlimBootloader.bin -k <Keys> -o FwuImage.bin

For more details on generating capsule image, please refer :ref:`generate-capsule`.


Triggering Firmware Update
^^^^^^^^^^^^^^^^^^^^^^^^^^^

|SPN| for |WCL| uses BIT16 of PMC I/O register (Over-Clocking WDT Control (OC_WDT_CTL) - Offset 54h) to trigger firmware update. When BIT16 is set, |SPN| will set the boot mode to FLASH_UPDATE.
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


Booting Ubuntu
^^^^^^^^^^^^^^^^^^^^^

See :ref:`boot-ubuntu` for more details.

You may need to change boot options to boot from USB. See :ref:`change-boot-options`.


