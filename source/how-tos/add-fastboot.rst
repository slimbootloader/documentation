.. _add-fastboot:

Add Fastboot Support
---------------------

This page guides you to integrate an external fastboot executable in |SPN|. The steps described are also applicable to any **MultiBoot** format executables.

Fastboot protocol allows communication between host and device bootloader via USB or Ethernet. Fastboot image can be loaded as a boot option configured in |SPN|. Typically fastboot is used to provision OS images to eMMC with fastboot utility or similar GUI-based tools (E.g. |PFT|).

.. |PFT| raw:: html

   <a href="https://01.org/node/2463" target="_blank">Intel® Platform Flash Tool Lite</a>

Load from USB
^^^^^^^^^^^^^^^^^

The following steps provide an example to enable fastboot feature from **USB** key for |UP2| board.

**Step 1:** Download fastboot executable from |FB|

.. |FB| raw:: html

   <a href="https://github.com/intel/kernelflinger/tree/master/prebuilt/board/APL_UP2" target="_blank">here</a>


**Step 2:** Download and install open source IAS tool from |IAS|

.. |IAS| raw:: html

   <a href="https://github.com/intel/iasimage" target="_blank">here</a>


**Step 3:** Package fastboot.elf into IAS image format

  Run::

    iasimage create -o iasimage.bin -d <private_key> -i 0x40000 cmdline.txt fastboot.elf


    <private_key>: BootloaderCorePkg/Tools/Keys/TestSigningPrivateKey.pem
    cmdline.txt  : Not required for fastboot to work. Create an empty file for it


**Step 4:** Copy IAS image ``iasimage.bin`` into the **first** FAT partition on USB flash drive


**Step 5:** Build, stitch and flash |SPN| to |UP2|

  Follow :ref:`up2-board` to build a flashable image and prepare |UP2| for booting.

**Step 6:** Boot and switch |SPN| into fastboot mode from shell interface

   #. Upon reset, press any key to enter |SPN| shell prompt

   #. Type ``boot`` to swap boot option index between last and first

   #. Type ``exit`` to boot into fastboot mode

   Expected serial output::

        Starting MB Kernel ...

        ...
        Group    =000000FF
        Command  =0000000C
        IsRespone=00000001
        Result   =00000000
        RequestedActions   =00000000
        USB for fastboot transport layer selected


**Step 7:** Test fastboot connections between host and |UP2|

  Run::

    fastboot devices


Load from SPI
^^^^^^^^^^^^^^^^^

You can also add fastboot into SBL image and program it into SPI flash.


**Step 1:** Once you created ``iasimage.bin``, copy it into |SPN| directory::

    cp iasimage.bin Platform/ApollolakeBoardPkg/SpiIasBin/iasimage1.bin


**Step 2:** Build, stitch and flash |SPN| to |UP2|


**Step 3:** Boot and switch |SPN| into fastboot mode from shell interface

   #. Upon reset, press any key to enter |SPN| shell prompt

   #. Type ``boot`` to swap boot option index between last and first

   #. Type ``exit`` to boot into fastboot mode

   Expected serial output::

        Starting MB Kernel ...

        ...
        Group    =000000FF
        Command  =0000000C
        IsRespone=00000001
        Result   =00000000
        RequestedActions   =00000000
        USB for fastboot transport layer selected


**Step 4:** Install and test fastboot connections between host and |UP2|

  Connect USB cable between host and |UP2| OTG port.

  Run::

    sudo apt-get install fastboot

    fastboot devices

.. note:: Provisioning complete Linux OS image requires GPT table, kernel image and root file system. The procedure depends Linux distro release package format. This guide only provides the initial mechanism to enable fastboot protocol.
