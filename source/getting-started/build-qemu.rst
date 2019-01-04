.. _getting-started:

Getting Started With QEMU
==========================

If you are using Microsoft Visual Studio, see :ref:`running-on-windows`.

.. important:: Behind firewall? See :ref:`proxy-settings` first!

|

Step-by-Step
--------------

**Step 1 - Download Source Code**

Source code is available on GitHub::

  git clone git@github.com:slimbootloader/slimbootloader.git
  cd slimbootloader

Setup github account user email and user name::

  git config --global user.email "email@example.com"
  git config --global user.name "your name"


**Step 2 - Install GCC and Utilities to Compile**

.. note:: If you use Dockers, see :ref:`build-on-docker`.


Install required packages on Ubuntu::

  $ sudo apt-get install -y build-essential iasl python uuid-dev nasm openssl gcc-multilib qemu

See :ref:`running-on-linux` for specific versions.


**Step 3 - Build Image**

Build QEMU target by running::

  $ python BuildLoader.py build qemu

If build is successful, ``Outputs/qemu/SlimBootloader.bin`` is generated.


**Step 4 - Boot to Shell on QEMU Emulator**

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


**Step 5 - Boot to Yocto on QEMU Emulator**

1. Download `QEMU Yocto Image <http://downloads.yoctoproject.org/releases/yocto/yocto-2.5/machines/genericx86-64/core-image-minimal-genericx86-64.hddimg>`_ to |SPN| top level source directory


2. Mount ``core-image-minimal-genericx86-64.hddimg`` locally and rename ``bzImage`` to ``vmlinuz``

  Use the commands below::

    sudo mkdir /mnt/yocto
    sudo mount -o loop core-image-minimal-genericx86-64.hddimg /mnt/yocto
    sudo mv /mnt/yocto/bzImage /mnt/yocto/vmlinuz
    sudo umount /mnt/yocto

3. Boot new Yocto image (without graphic console).

  Command for booting Yocto using |SPN|::

    qemu-system-x86_64 -machine q35 -m 256 -drive id=mydrive,if=none,file=core-image-minimal-genericx86-64.hddimg,format=raw -device ide-hd,drive=mydrive -nographic -serial mon:stdio -boot order=d -pflash Outputs/qemu/SlimBootloader.bin

  |SPN| should load Yocto and allow you to login.





