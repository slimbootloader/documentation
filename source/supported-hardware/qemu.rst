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


3. Boot new Yocto image (with graphic console).

  Command for booting Yocto using |SPN|::

    qemu-system-x86_64 -machine q35 -m 256 -drive id=mydrive,if=none,file=core-image-minimal-genericx86-64.hddimg,format=raw -device ide-hd,drive=mydrive -serial mon:stdio -boot order=d -pflash Outputs/qemu/SlimBootloader.bin

  |SPN| should load Yocto and allow you to login from graphics console with username 'root'.


Boot to a Container Image on QEMU
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A container image encapsulates the boot image and a cryptographic signature which is used to verify the integrity of the boot image for secure boot purposes.

Below are the steps to create and boot a container image on QEMU:

#. Create a container image of your boot image using the following guide: :ref:`Create Container Boot Image <create-container-boot-image>`

    .. note::
      Make sure you use the correct type of container. For details on which type to use, \
      refer to the :ref:`Container Tool documentation <container-formats>`.

#. Once you have the container image ``container.bin`` created, it needs to be copied to the disk image to be used with QEMU. For example, the disk \
   image can be the Yocto disk image as mentioned in the above section.

#. Copy the created ``container.bin`` to the mounted disk image.

#. Now, we need to set which boot file to use using the Config Editor tool.

#. Open the config editor and set your boot options as shown in the image below. Note that \
   the ``container.bin`` is the path to the container on the disk. In this example, the file \
   is placed in the root directory of the disk.
   Refer to the :ref:`Change Boot Options <change-boot-options>` guide for detailed instructions.

    .. image:: /images/boot_to_container_qemu_cfgedit.png
      :width: 800px

#. Build SBL for QEMU

#. Start QEMU. The ``-hda`` option will connect the virtual disk image as a SATA drive to QEMU.

    .. code-block:: text

      qemu-system-x86_64 -m 1G -machine q35 -serial mon:stdio -nographic -pflash Outputs/qemu/SlimBootloader.bin -hda <path/to/disk_image>

