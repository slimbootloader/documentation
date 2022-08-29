.. _boot-pxe-uboot:

PXE Boot Through U-Boot Payload
-------------------------------

Some users may prefer to boot their operating system over a network. \
This guide below shows how to achieve that using U-Boot as a payload for SBL.

We leverage existing PXE functionality in U-Boot to enable PXE boot.

Steps:

* Set up a TFTP server for serving PXE boot files

* U-Boot can be built as a payload for Slim Bootloader. Please refer to `this <https://slimbootloader.github.io/how-tos/boot-with-u-boot-payload.html>`_ \
  page for generic build Instructions.

U-Boot Confiugration to enable PXE Boot Support
===============================================

#. Below are steps for enabling PXE Boot support in U-Boot

    * After running ``make slimbootloader_defconfig`` according to the guide linked above, run

       .. code-block:: text

         $ make menuconfig

    * Enable ``pxe`` under the ``Command Line Interface`` section as shown.
    
       .. image:: /images/uboot-pxe/1_cmdline_pxe.png
          :width: 1500px

    * Enable ``dhcp`` option under the ``Network Commands`` section inside ``Command Line Interface``.

       .. image:: /images/uboot-pxe/2_dhcp.png
          :width: 750px

    * Enable ``Use the 'serverip' env var for tftp`` under the ``Networking Support`` section as shown.

       .. image:: /images/uboot-pxe/3_serverip.png
          :width: 1500px

    * Additionally, you might need to enable the driver for your system's network controller.

#. Save the config through the menu. You can run ``make savedefconfig`` to save this configuration. \
   It will be saved in a file named ``defconfig`` in the root of your U-Boot source.

U-Boot Device Tree Changes
==========================

#. Now, we need to add a few things to the U-Boot device tree for Slim Bootloader target to make sure that U-Boot is able to find the network device. \
   Below are the steps for QEMU target -

#. Add the following code block to the ``pci`` section of ``u-boot/arch/x86/dts/slimbootloader.dts`` so it looks like this -

    .. code-block:: text

        pci {
            compatible = "pci-x86";
            #address-cells = <3>;
            #size-cells = <2>;
            u-boot,dm-pre-reloc;
            ranges = <0x02000000 0x0 0x80000000 0x80000000 0 0x60000000>;
        };

    * The ``ranges`` property describes the MMIO window for PCI devices. You can get the starting address for this window from your platform's \
      ``BoardConfig.py`` file. It is listed as ``self.PCI_MEM32_BASE``. In case of QEMU, the window starts at ``0x80000000``.

    * We can assume that the window extends up to the PCI Express Base Address (``self.PCI_EXPRESS_BASE``), which is ``0xE0000000`` for QEMU.

    * The last value in the ranges property describes the size of the MMIO window. Thus, we set it to ``0x60000000``.

    * For more details on the PCI ranges property, you can refer to the device tree documentation `here <https://elinux.org/Device_Tree_Usage#PCI_Address_Translation>`_.

Build Slim Bootloader with U-Boot as Payload
============================================

#. Build U-Boot

#. Copy the generated ``u-boot-dtb.bin`` binary to ``slimbootloader/PayloadPkg/PayloadBins/u-boot-dtb.bin``.

#. Set SBL's ``PayloadId`` to ``U-BT``.

#. Build Slim Bootloader with U-Boot as Payload.

    .. code-block:: text

        $ python BuildLoader.py build <platform> -p "OsLoader.efi:LLDR:Lzma;u-boot-dtb.bin:U-BT:Lzma"

U-Boot Shell PXE Boot Commands
==============================

#. Once booted to U-Boot shell, enter the following commands to boot over the network.

    .. code-block:: text

        => dhcp
        => setenv serverip <tftp server address>
        => setenv pxefile_addr_r 0x1000000
        => setenv ramdisk_addr_r 0x2000000
        => setenv initrd_addr_r 0x3000000
        => setenv kernel_addr_r 0x4000000
        => pxe get
        => pxe boot

#. You should now see U-Boot load the operating system.

    .. image:: /images/uboot-pxe/4_pxeboot_log.png

