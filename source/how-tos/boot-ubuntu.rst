.. _boot-ubuntu:

Boot Ubuntu
------------

|SPN| can boot Ubuntu Linux using |SPN| with default OS loader. This page provides a step-by-step guide how to do so.

The following steps have been verified with Ubuntu Linux 18.04 LTS (64-bit).

.. important:: Traditional Linux booting using vmlinuz, initrd, and config.cfg is only supported with the debug build of |SPN| or if you have **self.HAVE_VERIFIED_BOOT = 0** in your BoardConfig.py; you can test using debug build initially but for release build support consider packaging the vmlinuz, initrd, and config.cfg into container image format. See :ref:`create-container-boot-image` for more details.

**STEP 1:** Build |SPN|

.. note:: The BoardConfig.py option **self.ENABLE_GRUB_CONFIG = 1** should be set when building |SPN|.

**STEP 2:** Flash IFWI image to the board

**STEP 3:** Download Ubuntu Desktop 18.04 ISO image from Ubuntu website

**STEP 4:** Create a USB flash drive from the ISO image with Rufus tool

**STEP 5:** Boot from USB flash drive

From serial console, boot to shell and select USB boot::

  boot   -> s  -> 0  -> 3 -> q

Continue boot by typing “exit” in the shell

**STEP 6:** Follow instructions to install Ubuntu

During this step, it is required to create a custom partition layout for SBL to boot after installation.

1. Boot Menu should show up on serial console.  Select ‘1’ to install Ubuntu.

2. Follow the instruction to install Ubuntu as normal.

.. image:: /images/sbl_ubuntu_1.png
         :width: 600
         :alt: Install Ubuntu 1 of 5

3. During the “Installation type:” page in installation, select “Something else” option.

.. image:: /images/sbl_ubuntu_2.png
         :width: 600
         :alt: Install Ubuntu 2 of 5

4. Create a new FAT32 partition before installation

.. image:: /images/sbl_ubuntu_3.png
         :width: 600
         :alt: Install Ubuntu 3 of 5


It might warn you about no mount point for FAT32 partition, just press “Continue” button.

.. image:: /images/sbl_ubuntu_4.png
         :width: 600
         :alt: Install Ubuntu 4 of 5

5. Finish the installation unless it askes to reboot. Don’t hit reboot button, instead, press 
the ‘x’ to close the message box.  It returns to the Ubuntu desktop.

.. image:: /images/sbl_ubuntu_5.png
         :width: 600
         :alt: Install Ubuntu 5 of 5


6. Open a terminal console and copy kernel files to the FAT partition created in previous step

Run:

.. code-block:: bash

    sudo mount  /dev/mmcblk1p1 /mnt   # mmcblk1p1 is the FAT partition on eMMC. Change it to the actual partition name on your board
    sudo mkdir  /mnt2
    sudo mount  /dev/mmcblk1p2 /mnt2  # mmcblk1p2 is the EXT4 partition on eMMC. Change it to the actual partition name on your board
    sudo cp /mnt2/boot/vmlinuz-* /mnt/vmlinuz # vmlinuz-* will correspond to some version of the kernel you have, ex. vmlinuz-5.4.0-42-generic
    sudo cp /mnt2/boot/initrd.img-* /mnt/initrd # initrd.img-* will correspond to some version of the kernel's initrd you have, ex. initrd.img-5.4.0-42-generic
    sudo echo "root=/dev/mmcblk1p2  ro  quiet splash"  > /mnt/config.cfg   # mmcblk1p2 is the EXT4 partition on eMMC. Change it to the actual partition name on your board
    sudo unmount /mnt2
    sudo unmount /mnt   # IMPORTANT: this ensures config.cfg is written to eMMC


7. Remove USB flash drive and reboot

|SPN| should boot to Ubuntu automatically from eMMC now.

.. note:: If you encounter any error loading the vmlinuz or initrd files due to space allocation issues you may need to increase the value of your **self.PLD_HEAP_SIZE** set in your board's BoardConfig.py and re-build |SPN| and flash as a new IFWI.
