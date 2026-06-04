.. granite-rapids-d-kaseyville:

Granite Rapids-D (Kaseyville) Reference Platform (RP)
-----------------------------------------------------

.. note:: Intel\ |reg| Xeon\ |trade| Processor family, formally known as |GNRD| (Kaseyville).

Supported Boards
^^^^^^^^^^^^^^^^

|SPN| supports Kaseyville reference platforms corresponding to |GNRD|.

Platform variants and IDs:

  +--------------------------+---------------+--------------------------+--------------------------+
  |      Board Variant       |  Platform ID  | Build Target             | Notes                    |
  +--------------------------+---------------+--------------------------+--------------------------+
  | |KSV| RP                 |    0x000E     | ksv                      | Reference platform       |
  +--------------------------+---------------+--------------------------+--------------------------+

.. note:: SPI and UART header designators can vary across Kaseyville board revisions. Confirm connector names from board collateral for your exact board stepping.

Debug UART
^^^^^^^^^^

For |GNRD| platforms, use the board-specific debug UART header from your platform collateral.

.. note:: Configure host PuTTY or minicom to 115200bps, 8N1, no hardware flow control.

Building
^^^^^^^^

To build |SPN| for |GNRD| platform::

  python BuildLoader.py build ksv -a x64

Release build command form::

  python BuildLoader.py build ksv -a x64 -r

Example of UEFI payload stitching during build::

  python BuildLoader.py build ksv -a x64 -p "OsLoader.efi:LLDR:Lz4;UefiPldX64.fd:UEFI:Lzma"

Note: The output images are generated under ``Outputs/ksv`` directory.


Stitching
^^^^^^^^^

1. Gather |GNRD| IFWI firmware image

  Users can either download the full IFWI image if the IFWI image release is available or read the existing IFWI image on the board using SPI programmer.
  This image contains additional firmware ingredients that are required to boot on |GNRD|.

.. note::
  ``StitchLoader.py`` currently does not support stitching with boot guard feature **enabled**.
  To stitch with Boot Guard enabled, please use ``StitchIfwi.py``.


2. Stitch |SPN| images into downloaded BIOS image::

    python Platform/KaseyvilleBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/ksv/SlimBootloader.bin -o <SBL_IFWI_IMAGE_NAME>

  where -i = Input file, -o = Output file

For example, to stitch |SPN| IFWI image ``sbl_ifwi_ksv.bin`` from |GNRD| downloaded firmware images::

    python Platform/KaseyvilleBoardPkg/Script/StitchLoader.py -i xxxx.bin -s Outputs/ksv/SlimBootloader.bin -o sbl_ifwi_ksv.bin

To view IFWI stitching options::

    python Platform/KaseyvilleBoardPkg/Script/StitchIfwi.py -h

Another stitching example::

    python Platform/KaseyvilleBoardPkg/Script/StitchIfwi.py -s Outputs/ksv/Stitch_Components.zip -c Platform/KaseyvilleBoardPkg/Script/StitchIfwiConfig.py -w c:\Stitching -t dtpm -b fvme -p ksv

For more details on stitch tool, see :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.


Flashing
^^^^^^^^

Flash the generated ``sbl_ifwi_ksv.bin`` to the target board using a DediProg SF100 or SF600 programmer.

.. note:: When using SPI programmer, please ensure:


    #. The alignment/polarity when connecting Dediprog to the board.
    #. The power to the board is turned **off** while the programmer is connected (even when not in use).
    #. The programmer is set to update the flash from offset 0x0.


Capsule image for |GNRD|
^^^^^^^^^^^^^^^^^^^^^^^^^

The Slimbootloader.bin image generated from the build steps above can be used to create a capsule image.
Please refer to :ref:`build-tool` on generating |SPN| image.

For |GNRD| platform, the below command can be used::

  python ./BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS Outputs/ksv/SlimBootloader.bin -k <Keys> -o FwuImage.bin -a AUTO -s RSA_PSS

For more details on generating capsule image, please refer :ref:`generate-capsule`.


Triggering Firmware Update
^^^^^^^^^^^^^^^^^^^^^^^^^^

Please refer to :ref:`firmware-update` on how to trigger firmware update flow.
Below is an example:

To trigger firmware update in |SPN| shell:

1. Copy ``FwuImage.bin`` into root directory on FAT partition of a USB key

2. Boot and press any key to enter |SPN| shell

3. Type command ``fwupdate`` from shell

   |SPN| will reset the platform and initiate firmware update flow. The platform will reset *multiple* times to complete the update process.


Booting Linux
^^^^^^^^^^^^^

For booting Linux using OsLoader payload, see :ref:`boot-ubuntu`.

To customize board configurations in ``*.dlt`` file, see :ref:`configuration-tool` for more details.
