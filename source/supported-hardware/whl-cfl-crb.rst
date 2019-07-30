.. _whl-cfl-crb:

WHL-CFL CRB Boards
-----------------------

.. note:: 8th and 9th Generation Intel® Core Processor Families formally known as |WHL| and |CFLR| platform.

Supported Boards
^^^^^^^^^^^^^^^^^^^^^

|SPN| supports **Whiskey Lake, Coffee Lake Refresh Desktop S8+2 and Coffee Lake Refresh Mobile H6+2** CRB platforms.
  

Building
^^^^^^^^^^

To build |SPN| for |WHL| and |CFLR| platforms::

    python BuildLoader.py build cfl

The output images are generated under ``Outputs`` directory.


Stitching
^^^^^^^^^^

1. Gather |WHL| or |CFLR| IFWI firmware image

  This image contains additional firmware ingredients that are required to boot on |WHL| or |CFLR|.

.. note::
  ``StitchLoader.py`` currently only supports stitching with boot guard feature **disabled**. 


2. Stitch |SPN| images into downloaded BIOS image::

    python Platform/CoffeelakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE_NAME> -s Outputs/cfl/Stitch_Components.zip -o <SBL_IFWI_IMAGE_NAME>

    where -i = Input file, -o = Output file.

For example, stitching |SPN| IFWI image ``sbl_cfl_ifwi.bin`` from |CFLR| firmware image::

    python Platform/CoffeelakeBoardPkg/Script/StitchLoader.py -i xxxx.bin -s Outputs/cfl/Stitch_Components.zip -o sbl_cfl_ifwi.bin

For more details on stitch tool, see :ref:`stitch-tool` on how to stitch the IFWI image with |SPN|.


Flashing
^^^^^^^^^

Flash the generated ``sbl_cfl_ifwi.bin`` to the target board using DediProg SF100 or SF600 programmer.

.. note:: Please check the alignment/polarity when connecting Dediprog to the board. Please power off the board before connecting the Dediprog.
.. note:: Please set the dediprog  to flash the ifwi binary from offset 0

SPI Header to connect dediprog for CRB platforms is provided in the table below.

  +---------------------------+--------------+
  |            Board          |   Connector  |
  +---------------------------+--------------+
  |            |WHL|          |    **J3H1**  |
  +---------------------------+--------------+
  |           |CFLSR|         |    **J7H1**  |
  +---------------------------+--------------+
  |           |CFLHR|         |    **J7H2**  |
  +---------------------------+--------------+

.. note:: Please disconnect Deidprog before powering up the board again.


Debug UART
^^^^^^^^^^^

Serial port connector for CRB platforms is provided in the table below

  +---------------------------+--------------+
  |            Board          |   Connector  |
  +---------------------------+--------------+
  |            |WHL|          |    **J8J1**  |
  +---------------------------+--------------+
  |           |CFLSR|         |    **J9B7**  |
  +---------------------------+--------------+
  |           |CFLHR|         |    **J4A1**  |
  +---------------------------+--------------+

.. note:: Configure host PuTTY or minicom to 115200bps, 8N1, no hardware flow control.

Booting Yocto Linux from USB
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You may need to change boot options to boot from USB. See :ref:`change-boot-options`.

1. Download Yocto Linux
2. Create bootable USB key. For example: In Windows, Rufus can be used. In Linux, etcher app can be used.
3. Boot the bootable OS image from USB key on the board.

Booting Ubuntu
^^^^^^^^^^^^^^^^^^^^^

See :ref:`boot-ubuntu` for more details.

You may need to change boot options to boot from USB. See :ref:`change-boot-options`.

Board ID Assignments
^^^^^^^^^^^^^^^^^^^^^

Each CRB board is assigned a unique platform ID

  +---------------------------+---------------+
  |            Board          |  Platform ID  |
  +---------------------------+---------------+
  |            |WHL|          |     0x1       |
  +---------------------------+---------------+
  |           |CFLSR|         |     0x2       |
  +---------------------------+---------------+
  |           |CFLHR|         |     0x3       |
  +---------------------------+---------------+


See :ref:`dynamic-platform-id` for more details.

To customize board configurations in ``*.dlt`` file, make sure to specify ``PlatformId`` to the corresponding values for the board.

See :ref:`configuration-tool` for more details.
