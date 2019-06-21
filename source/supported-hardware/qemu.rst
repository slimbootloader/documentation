.. _getting-started_qemu:


QEMU Virtual Platform
-----------------------


Building SBL
^^^^^^^^^^^^

To build |SPN| for QEMU Intel Q35 virtual platform::

    python BuildLoader.py build qemu

The output images are generated under ``Outputs/qemu/SlimBootloader.bin`` directory.

.. note:: QEMU virtual platform does not require stitching the |SPN| into an IFWI.



Boot to Shell on QEMU Emulator
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now test the newly built |SPN| image in QEMU emulator from command line::

  qemu-system-x86_64 -machine q35 -nographic -serial mon:stdio -pflash Outputs/qemu/SlimBootloader.bin

Console outputs::

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    ==================== OS Loader ====================
    Press any key within 1 second(s) to enter the command shell
    Shell>

.. hint:: To exit QEMU in Linux, type ctrl+a, then x. In Windows, type ctrl+c.


Boot to Yocto on QEMU Emulator
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


1. Download `QEMU Yocto Image <http://downloads.yoctoproject.org/releases/yocto/yocto-2.5/machines/genericx86-64/core-image-minimal-genericx86-64.hddimg>`_ to |SPN| top level source directory


2. Mount ``core-image-minimal-genericx86-64.hddimg`` locally and rename ``bzImage`` to ``vmlinuz``

Linux Users:: Use the commands below
  
    sudo mkdir /mnt/yocto
    sudo mount -o loop core-image-minimal-genericx86-64.hddimg /mnt/yocto
    sudo mv /mnt/yocto/bzImage /mnt/yocto/vmlinuz
    sudo umount /mnt/yocto

Windows Users:: Use the method below
  
  Windows users may need tools that allow mounting the hddimg as a virtual drive in Windows.
  Once mounted, the bzImage file can be renamed to vmlinuz as required by |SPN|.


3. Boot new Yocto image (without graphic console).

  Command for booting Yocto using |SPN|::

    qemu-system-x86_64 -machine q35 -m 256 -drive id=mydrive,if=none,file=core-image-minimal-genericx86-64.hddimg,format=raw -device ide-hd,drive=mydrive -nographic -serial mon:stdio -boot order=d -pflash Outputs/qemu/SlimBootloader.bin

  |SPN| should load Yocto and allow you to login.





