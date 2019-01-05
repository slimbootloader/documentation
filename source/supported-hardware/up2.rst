.. _up2-board:

|UP2| Board
---------------------

The |UP Squared board| (|UP2|) is an x86 maker board based on Intel platform Apollo Lake. The UP boards are used in IoT, industrial automation, digital signage areas etc.

Prequisites
^^^^^^^^^^^^^^^^

|SPN| supports |UP2| maker board. To start developing |SPN|, the following equipment, software and environments are required:

* |UP2| kit (|Model N3350|)
* Custom SPI flashing cable (|instructions|).
* |USB 2.0 pin header cable| for debug uart output. OR `Make your own <up2-debug-uart-pinout_>`_.
* DediProg SF100 or SF600 programmer
* Linux host (see :ref:`running-on-linux` for details)
* Internet access

.. |UP Squared board| raw:: html

   <a href="https://up-board.org/upsquared/specifications/" target="_blank">UP Squared board</a>

.. |Model N3350| raw:: html

   <a href="https://up-shop.org/up-boards/94-up-squared-celeron-duo-core-4gb-memory32gb-emmc.html?search_query=n3350&results=5" target="_blank">Model N3350</a>

.. |instructions| raw:: html

   <a href="https://wiki.up-community.org/BIOS_chip_flashing_on_UP_Squared" target="_blank">instructions</a>

.. |USB 2.0 pin header cable| raw:: html

   <a href="https://up-shop.org/up-peripherals/110-usb-20-pin-header-cable.html" target="_blank">USB 2.0 pin header cable</a>


Board Setup
^^^^^^^^^^^^^^^^^

.. image:: /images/up2_setup.jpg
   :width: 600
   :alt: |UP2| Board Setup
   :align: center


Before You Start
^^^^^^^^^^^^^^^^^

.. warning:: As you plan to reprogram the SPI flash, it's a good idea to backup the preinstalled BIOS image first.


Boot the board and enter BIOS setup menu to get familar with the board features and settings.

|UP2| is pre-installed with Ubuntu Linux. Boot to Ubuntu and confirm the display, USB, network and other peripherals are working.

.. _up2-debug-uart-pinout:

Early boot serial debug console can be reached via UART0 located on CN16 header on the |UP2| board. Make sure you can observe serial output message running the factory BIOS first.

.. note:: To make your own UART debug adaptor by wiring, refer to CN16 Header Pinout for UART0:

  +--------+--------------+
  |  Pin   |    Signal    |
  +--------+--------------+
  |   8    |     GND      |
  +--------+--------------+
  |   9    |   UART_RX    |
  +--------+--------------+
  |   10   |   UART_TX    |
  +--------+--------------+



In order to boot Ubuntu from eMMC using |SPN|, it is required to copy the kernel image to the boot partition (FAT32 partition) on the eMMC.

Alternatively, you can boot Yocto OS from USB key without any changes.

You may use utilities (e.g. Rufus) to create a bootable USB key from the Yocto OS image downloaded.


Building
^^^^^^^^^^

|UP2| board is based on Intel |APL|. To build::

    python BuildLoader.py build apl

The output images are generated under ``Outputs`` directory.

See :ref:`getting-started` on how to building |SPN|.


Stitching
^^^^^^^^^^

Stitch |SPN| images with factory BIOS image using the stitch tool::

    python Platform/ApollolakeBoardPkg/Script/StitchLoader.py -i <BIOS_IMAGE> -s Outputs/apl/Stitch_Components.zip -o <SBL_IFWI_IMAGE> -p 0xAA00000E

    <BIOS_IMAGE>     : Input file. Factory BIOS extracted from |UP2| board.
    <SBL_IFWI_IMAGE> : Output file. New IFWI image with SBL in BIOS region.
    -p <value>       : 4-byte platform data for platform ID and debug UART port index.

See :ref:`stitch-tool` on how to stitching the flashing IFWI image with |SPN|.


Flashing
^^^^^^^^^

Flash the IFWI image to |UP2| board using a SPI programmer. See |BIOS_CHIP_FLASHING|.


.. |BIOS_CHIP_FLASHING| raw:: html

   <a href="https://wiki.up-community.org/BIOS_chip_flashing_on_UP_Squared" target="_blank">instructions</a>


.. _boot-yocto-usb:


Booting Yocto Linux from USB
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You may need to change boot options to boot from USB. See :ref:`change-boot-options`.

1. Download |APL| `Yocto Linux <http://downloads.yoctoproject.org/releases/yocto/yocto-2.0/machines/leafhill/leafhill-4.0-jethro-2.0.tar.bz2?bsp=leaf_hill>`_.
2. Create bootable USB key
3. Boot from USB key



.. _boot-ubuntu-emmc:

Booting Pre-installed Ubuntu from eMMC
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Booting Ubuntu from |SPN| requires a few extra steps because |SPN| default payload (OsLoader) loads kernel directly from boot partition, compared to UEFI BIOS which relies on GRUB 2 to boot Ubuntu.

1. Boot to Yocto Linux from USB.

See :ref:`boot-yocto-usb` for more details.


2. Copy vmlinuz and initrd file to ``/media/mmcblk0p1`` directory

.. code::

  sudo cp /media/mmcblk0p2/boot/vmlinuz-4.10.0-9-upboard /media/mmcblk0p1/vmlinuz
  sudo cp /media/mmcblk0p2/boot/initrd.img-4.10.0-9-upboard /media/mmcblk0p1/initrd


3. Create ``config.cfg`` file containing the following kernel command line and save it ``/media/mmcblk0p1`` directory

.. code::

  BOOT_IMAGE=/boot/vmlinuz-4.10.0-9-upboard root=/dev/mmcblk0p2 earlycon=uart8250,mmio32,0x82531000,115200n8 <eof>


**Good Luck!**
