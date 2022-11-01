.. _boot-with-linux-payload:

Boot Linux as a Payload
-----------------------

SBL can boot the Linux Kernel as a payload from flash directly, which is similar to the LinuxBoot approach. 

Linux payload is not intended to be a runtime production kernel; rather, it is meant to replace \
specific boot firmware functionality using Linux kernel capabilities and then boot the actual \
production kernel on the machine using kexec. This could be done by implementing PXE booting \
in userspace, or finding a kernel on a mounted disk, etc. Please refer to the FAQ here - https://www.linuxboot.org/page/faq

When Linux payload kernel boots it needs a root file system that provides boot and startup utilities. \
The initramfs is a root file system that is embedded within the firmware image itself. It is intended \
to be placed in a flash device along with the Linux kernel as part of the firmware image. \
The initramfs is essentially a set of directories bundled into a single cpio archive. \
(please refer here - https://github.com/linuxboot/book/blob/master/components/README.md)


At boot time, SBL loads the Linux kernel bzImage and initramfs into memory and starts the kernel. The kernel checks \
for the presence of the initramfs, unpacks it, mounts it as ``/`` and runs ``/init``.

There are many ways of building initramfs. Two different approaches using Busybox and U-Root are provided below.

**References:** `LinuxBoot <https://www.linuxboot.org>`_.

Below is a step-by-step guide on how to boot Linux as a payload with SBL.

Building the Kernel
===================

* The kernel should have the following properties:
    * Should be small enough to fit in flash
    * Should have compressed initramfs support
        * initramfs is usually compressed using gzip or xz to reduce its size. So, the kernel \
          should have support to unpack it during boot.
        * e.g. - ``CONFIG_RD_GZIP`` for a gzip compressed initramfs.

* The kernel can be built from the standard Linux kernel source at \
  `kernel.org <https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git>`_.

Building the initramfs
======================

Busybox
^^^^^^^

* `Busybox <https://busybox.net>`_ is a software suite that bundles together userspace Linux utilities. \
  This can be used to create an initramfs.
* A minimal Busybox configuration file can be obtained from Buildroot \
  `here <https://github.com/buildroot/buildroot/blob/master/package/busybox/busybox-minimal.config>`_.

U-Root
^^^^^^

* `U-Root <https://github.com/u-root>`_ provides userspace Linux utilities implemented in the Go programming language.
* U-Root requires the kernel to support features needed for the Go programming language. (futex and epoll support)
* U-Root also provides a way to create an initramfs: `Instructions <https://github.com/u-root/u-root#usage>`_.

    .. note::
        U-Root can be used to build an initramfs that can facilitate PXE boot. More details are covered in a later section.

.. note::

    Both Busybox and U-Root can be configured to build smaller images. For more details, check their respective websites.

Pre-built image
===============

For convenience, a pre-built image is provided with a Linux 6.1 Kernel and a Busybox based initramfs is \
provided here: :download:`PrebuiltLinuxImage.zip <../binaries/linux-payload/PrebuiltLinuxImage.zip>`

Kernel Configuration
^^^^^^^^^^^^^^^^^^^^

* A minimal kernel config, used for the above kernel, is provided here: :download:`Kernel Config <../binaries/linux-payload/prebuilt_kernel_config>`
* The pre-built kernel was built with the kernel source at the following commit ID: ``aae703b02f92bde9264366c545e87cec451de471``

Enabling Linux Payload for SBL
==============================

#. Enable Linux payload support by adding following to ``Platform/<PlatformPkg>/BoardConfig.py``

    .. code-block:: text

        self.ENABLE_LINUX_PAYLOAD = 1

#. Adjust flash layout to provide enough space for EPLD component to store linux kernel, initrd image and command line file.
   It can be done by modifying specific component size definitions in ``Platform/<PlatformPkg>/BoardConfig.py``

    .. code-block:: text

        self.EPAYLOAD_SIZE = 0x004F0000

    .. note::

        ``EPAYLOAD_SIZE`` given here is for supplied pre-built kernel image. Actual size should be configured according to your kernel and initramfs sizes.

        You will also have to adjust ``self.NON_REDUNDANT_SIZE`` and ``self.SLIMBOOTLOADER_SIZE`` to account for the larger EPLD component.

#. Increase SBL reserved memory size so as to allow loading Linux kernel and initramfs (requires more memory).
   This can be done by modifying the line below in ``Platform/<PlatformPkg>/BoardConfig.py``

    .. code-block:: text

        self.LOADER_RSVD_MEM_SIZE = 0x00900000

#. Change the default boot payload ID to Linux Payload

    .. code-block:: text

        GEN_CFG_DATA.PayloadId  |  'LINX'

#. Copy the Linux Kernel image, initramfs, and kernel command line files to ``PayloadPkg/PayloadBins/``.

#. Build Slim Bootloader with Linux Payload

    .. code-block:: text

        python BuildLoader.py build <platform> -p "dummy.txt:OSLD;bzImage:LINX;cmdline.txt:CMDL;initramfs.cpio.gz:INRD"

    .. note::

        ``-p`` takes multiple components separated by a ``;``. The 1st component will be built into PLD and the remaining components will be built into EPLD.
        In this example, since PLD is not used at all, a dummy file is provided to satisfy build requirements.

#. Stitch, flash and boot.  It should boot to the Linux shell console on the serial port.
   Please follow :ref:`supported-hardware` to build a flashable image for the target platform.

Serial Output with Linux shell prompt
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: text

    ============= Intel Slim Bootloader STAGE1A =============
    SBID: SB_QEMU
    ...

    ============= Intel Slim Bootloader STAGE1B =============
    Host Bridge Device ID:0x29C0
    Board ID:0x1 - Loading QEMU!
    QEMU Flash: Attempting flash detection at FF9AF000
    ...

    ============= Intel Slim Bootloader STAGE2 =============
    Unmapping Stage
    ...
    Loading Payload ID LINX
    Loading Component EPLD:LINX
    Registering container EPLD
    HASH verification for usage (0x00001000) with Hash Alg (0x2): Success
    SignType (0x2) SignSize (0x180)  SignHashAlg (0x2)
    RSA verification for usage (0x00001000): Success
    HASH verification for usage (0x00000000) with Hash Alg (0x2): Success
    Load Payload ID 0x584E494C @ 0x00800000
    Found bzimage Signature
    BzImage Format Payload
    Loading Component EPLD:CMDL
    HASH verification for usage (0x00000000) with Hash Alg (0x2): Success
    Kernel command line:
    root=/dev/ram0 rw 3 console=ttyS0,115200


    Loading Component EPLD:INRD
    HASH verification for usage (0x00000000) with Hash Alg (0x2): Success
    InitRD is loaded at 0xEC2D000:0xC4761
    Found bzimage Signature
    MP Init (Done)
    Call FspNotifyPhase(40) ... Success
    Call FspNotifyPhase(F0) ... Success
    HOB @ 0x0EEC0000
    Created 4 OS boot options (Current: 31)
    TPM Lib Private Data not found
    Unable to get log area for TCG 2.0 format events !!
    Stage2 stack: 0x40000 (stack used 0xA60, HOB used 0x1548, 0x3E058 free)
    Stage2 heap: 0x8C0000 (0x2934D0 used, 0x62CB30 free, 0x3DA2A3 max used)
    Payload entry: 0x0EE5EAEA
    Jump to payload

    Switch to LongMode and jump to 64-bit kernel entrypoint ...
    Linux version 6.1.0-rc1+ (atharva@alele-mobl1) (gcc (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0, GNU ld (GNU Binutils for Ubuntu) 2.34) #12 SMP Fri Oct 21 15:58:13 PDT 2022
    Command line: root=/dev/ram0 rw 3 console=ttyS0,115200


    x86/fpu: x87 FPU will use FXSAVE
    signal: max sigframe size: 1040
    BIOS-provided physical RAM map:
    BIOS-e820: [mem 0x0000000000000000-0x000000000009ffff] usable
    BIOS-e820: [mem 0x00000000000a0000-0x00000000000fffff] reserved
    BIOS-e820: [mem 0x0000000000100000-0x000000000e58bfff] usable
    BIOS-e820: [mem 0x000000000e58c000-0x000000000e58ffff] reserved
    BIOS-e820: [mem 0x000000000e590000-0x000000000e5f7fff] ACPI data
    BIOS-e820: [mem 0x000000000e5f8000-0x000000000e5fffff] ACPI NVS
    BIOS-e820: [mem 0x000000000e600000-0x000000000fffffff] reserved
    BIOS-e820: [mem 0x00000000ff9af000-0x00000000ffffffff] reserved
    NX (Execute Disable) protection: active
    tsc: Fast TSC calibration using PIT
    tsc: Detected 1804.804 MHz processor
    last_pfn = 0xe58c max_arch_pfn = 0x400000000
    x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WB  WT  UC- UC
    RAMDISK: [mem 0x0ec2d000-0x0ecf1fff]
    Allocated new RAMDISK: [mem 0x0e4c7000-0x0e58b760]
    Move RAMDISK from [mem 0x0ec2d000-0x0ecf1760] to [mem 0x0e4c7000-0x0e58b760]
    ACPI: Early table checksum verification disabled
    ACPI: RSDP 0x000000000E590000 000024 (v02 OEMID )
    ACPI: XSDT 0x000000000E5900E0 00005C (v01 OEMID  OEMTABLE 00000005 CREA 0100000D)
    ACPI: FACP 0x000000000E590210 00010C (v05 OEMID  OEMTABLE 00000005 CREA 0100000D)
    ACPI: DSDT 0x000000000E5904E0 001BD9 (v02 OEMID  APL-SOC  00000000 INTL 20220331)
    ACPI: FACS 0x000000000E590320 000040
    ACPI: FACS 0x000000000E590320 000040
    ACPI: HPET 0x000000000E590360 000038 (v01 OEMID  OEMTABLE 00000005 CREA 0100000D)
    ACPI: APIC 0x000000000E5903A0 00005A (v03                 00000000      00000000)
    ACPI: MCFG 0x000000000E590400 00003C (v01                 00000001      00000000)
    ACPI: FPDT 0x000000000E590440 000044 (v01 INTEL  OEMTABLE 00000005 CREA 0100000D)
    ACPI: BGRT 0x000000000E5920C0 000038 (v01 OEMID  OEMTABLE 00000005 CREA 0100000D)
    ACPI: TEST 0x000000000E592100 00002C (v01 OEMID  OEMTABLE 00000001 CREA 01000001)
    ACPI: Reserving FACP table memory at [mem 0xe590210-0xe59031b]
    ACPI: Reserving DSDT table memory at [mem 0xe5904e0-0xe5920b8]
    ACPI: Reserving FACS table memory at [mem 0xe590320-0xe59035f]
    ACPI: Reserving FACS table memory at [mem 0xe590320-0xe59035f]
    ACPI: Reserving HPET table memory at [mem 0xe590360-0xe590397]
    ACPI: Reserving APIC table memory at [mem 0xe5903a0-0xe5903f9]
    ACPI: Reserving MCFG table memory at [mem 0xe590400-0xe59043b]
    ACPI: Reserving FPDT table memory at [mem 0xe590440-0xe590483]
    ACPI: Reserving BGRT table memory at [mem 0xe5920c0-0xe5920f7]
    ACPI: Reserving TEST table memory at [mem 0xe592100-0xe59212b]
    Zone ranges:
    DMA32    [mem 0x0000000000001000-0x000000000e58bfff]
    Normal   empty
    Movable zone start for each node
    Early memory node ranges
    node   0: [mem 0x0000000000001000-0x000000000009ffff]
    node   0: [mem 0x0000000000100000-0x000000000e58bfff]
    Initmem setup node 0 [mem 0x0000000000001000-0x000000000e58bfff]
    On node 0, zone DMA32: 1 pages in unavailable ranges
    On node 0, zone DMA32: 96 pages in unavailable ranges
    On node 0, zone DMA32: 6772 pages in unavailable ranges
    ACPI: PM-Timer IO Port: 0x408
    ACPI: LAPIC_NMI (acpi_id[0xff] high level lint[0x1])
    IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
    ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
    ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
    ACPI: Using ACPI (MADT) for SMP configuration information
    ACPI: HPET id: 0x0 base: 0xfed00000
    smpboot: Allowing 1 CPUs, 0 hotplug CPUs
    [mem 0x10000000-0xff9aefff] available for PCI devices
    clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
    setup_percpu: NR_CPUS:64 nr_cpumask_bits:1 nr_cpu_ids:1 nr_node_ids:1
    percpu: Embedded 40 pages/cpu s131688 r0 d32152 u2097152
    Built 1 zonelists, mobility grouping on.  Total pages: 57704
    Kernel command line: root=/dev/ram0 rw 3 console=ttyS0,115200

    ...

    Please press Enter to activate this console. input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input3
    tsc: Refined TSC clocksource calibration: 1804.779 MHz
    clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x1a03cc1362c, max_idle_ns: 440795245324 ns
    clocksource: Switched to clocksource tsc

    / #
    / # uname -a
    Linux (none) 6.1.0-rc1+ #12 SMP Fri Oct 21 15:58:13 PDT 2022 x86_64 GNU/Linux
    / #


PXE Boot using Linux & U-Root
=============================

U-Root Build
^^^^^^^^^^^^

U-Root includes utilities that enable PXE Boot. The U-Root initramfs should be built with the following \
command to include the PXE utilities. We compress the initramfs using xz to make it fit into flash.

.. code-block:: text

    $ ./u-root -o initramfs.cpio core ./cmds/boot/pxeboot

    $ xz --check=crc32 -9 --lzma2=dict=1MiB \
    --stdout initramfs.cpio \
    | dd conv=sync bs=512 \
    of=initramfs.cpio.xz

Kernel Configuration
^^^^^^^^^^^^^^^^^^^^

The Linux Kernel being used should have the following options enabled (in addition to the ones mentioned above). \
Most of these should be enabled by default unless you ran ``make tinyconfig`` to configure the kernel.

* Go language program support (``CONFIG_FUTEX`` and ``CONFIG_EPOLL``)
* devtmpfs support (``CONFIG_DEVTMPFS``)
* Kexec support (``CONFIG_KEXEC``)
* Kexec file based system call (``CONFIG_KEXEC_FILE``)
* EFI runtime service support (``CONFIG_EFI``)
* EFI stub support (``CONFIG_EFI_STUB``)
* Network driver for your machine's network interface

PXE Booting
^^^^^^^^^^^

* You should have a TFTP server set up to serve the PXE boot files.

* Commands to perform PXE Boot in U-Root:

    .. code-block:: text

        /# dhclient -ipv6=false

        /# pxeboot -ipv6=false -file <pxe_config_filename> -server <server_ip_address>

* After running the above commands, you should be able to see the operating system loading.

* Shown below is a snippet from performing PXE Boot on the :ref:`Tiger Lake RVP Board <tiger-lake-rvp>`

.. code-block:: text

    
    ============= Intel Slim Bootloader STAGE1A =============
    SBID: SBL_TGL
    ...

    ============= Intel Slim Bootloader STAGE1B =============
    ...
    Loading Component FLMP:SG02
    HASH verification for usage (0x00000002) with Hash Alg (0x2): Success
    Loaded STAGE2 @ 0x47A03000

    ============= Intel Slim Bootloader STAGE2 =============
    ...
    Loading Payload ID LINX
    Loading Component EPLD:LINX
    ...
    Kernel command line:
    console=ttyS0,115200 quiet


    Loading Component EPLD:INRD
    HASH verification for usage (0x00000000) with Hash Alg (0x2): Success
    InitRD is loaded at 0x4770F000:0x2D2600
    Found bzimage Signature
    ...
    Jump to payload

    Switch to LongMode and jump to 64-bit kernel entrypoint ...
    e1000e 0000:00:1f.6: The NVM Checksum Is Not Valid
    1998/01/04 22:46:15 Welcome to u-root!
                                _
    _   _      _ __ ___   ___ | |_
    | | | |____| '__/ _ \ / _ \| __|
    | |_| |____| | | (_) | (_) | |_
    \__,_|    |_|  \___/ \___/ \__|

    init: 1998/01/04 22:46:15 no modules found matching '/lib/modules/*.ko'
    /# dhclient -ipv6=false
    1998/01/04 22:46:22 Bringing up interface eth0...
    1998/01/04 22:46:24 Attempting to get DHCPv4 lease on eth0
    1998/01/04 22:46:39 Got DHCPv4 lease on eth0: DHCPv4 Message
    opcode: BootReply
    hwtype: Ethernet
    hopcount: 0
    transaction ID: 0x8af9e5d6
    num seconds: 0
    flags: Unicast (0x00)
    client IP: 0.0.0.0
    your IP: 10.165.242.41
    server IP: 0.0.0.0
    gateway IP: 10.165.242.3
    client MAC: 00:15:17:78:cd:50
    server hostname:
    bootfile name:
    options:
        Subnet Mask: fffffe00
        Router: 10.165.242.1
        Domain Name Server: 10.248.2.1, 10.22.224.196, 10.3.86.116
        Domain Name: jf.intel.com
        IP Addresses Lease Time: 96h0m0s
        DHCP Message Type: ACK
        Server Identifier: 10.22.224.196
        Renew Time Value: [0 2 163 0]
        Rebinding Time Value: [0 4 157 64]
    1998/01/04 22:46:39 Configured eth0 with IPv4 DHCP Lease IP 10.165.242.41/23
    1998/01/04 22:46:39 Finished trying to configure all interfaces.
    /# pxeboot -ipv6=false -file default -server 10.165.242.94
    1998/01/04 22:50:04 Skipping DHCP for manual target..
    1998/01/04 22:50:04 Boot URI: tftp://10.165.242.94/default
    1998/01/04 22:50:04 Parsing boot files as iPXE failed, trying other formats...: config file is not ipxe as it does not start with #!ipxe
    1998/01/04 22:50:04 Trying to parse file as a non config Image...
    1998/01/04 22:50:04 Parsing boot file as FIT image failed: invalid FDT magic, got 0x23204175, expected 0xd00dfeed
    1998/01/04 22:50:04 failed to parse boot file as simple file: exhausted all supported simple file types
    1998/01/04 22:50:05 Got config file tftp://10.165.242.94/pxelinux.cfg/default:
    # Automatically created by OE
    ALLOWOPTIONS 1
    SERIAL 0 115200
    DEFAULT Graphics console boot
    TIMEOUT 50
    PROMPT 0
    ui vesamenu.c32
    menu title Select kernel options and boot kernel
    menu tabmsg Press [Tab] to edit, [Return] to select
    LABEL Serial console boot 64
    KERNEL /bzImage-qemu64
    APPEND initrd=/initrd LABEL=boot root=/dev/ram0  console=ttyS0,115200



    Welcome to LinuxBoot's Menu

    Enter a number to boot a kernel:

    01. Serial console boot 64

    02. Reboot

    03. Enter a LinuxBoot shell


    Enter an option ('01' is the default, 'e' to edit kernel cmdline):
    > 1
    [    0.000000] Linux version 5.15.62-yocto-standard (oe-user@oe-host) (x86_64-poky-linux-gcc (GCC) 11.3.0, GNU ld (GNU Binutils) 2.38.20220708) #1 SMP PREEMPT Mon Aug 22 15:16:08 UTC 2022
    [    0.000000] Command line: initrd=/initrd LABEL=boot root=/dev/ram0 console=ttyS0,115200
    ...
    [    0.000000] SMBIOS 3.3 present.
    [    0.000000] DMI: Intel Corporation TigerLake Client Platform/TigerLake H DDR4 SODIMM RVP, BIOS SB_TGL.001.001.000.001.006.00011.D-505209D9C37F4A
    ...
    [    0.119842] BIOS vendor: Intel Corporation; Ver: SB_TGL.001.001.000.001.006.00011.D-505209D9C37F4AFE-dirty; Product Version: 0.1
    ...
    [    1.547048] smpboot: Estimated ratio of average max frequency by base frequency (times 1024): 1772
    [    1.547048] smpboot: CPU0: 11th Gen Intel(R) Core(TM) i7-11850HE @ 2.60GHz (family: 0x6, model: 0x8d, stepping: 0x1)
    [    1.547118] Performance Events: PEBS fmt4+-baseline,  AnyThread deprecated, Icelake events, 32-deep LBR, full-width counters, Intel PMU driver.
    [    1.548048] ... version:                5
    [    1.549048] ... bit width:              48
    [    1.550048] ... generic registers:      8
    [    1.551049] ... value mask:             0000ffffffffffff
    [    1.552048] ... max period:             00007fffffffffff
    [    1.553048] ... fixed-purpose events:   4
    [    1.554048] ... event mask:             0001000f000000ff
    [    1.555099] rcu: Hierarchical SRCU implementation.
    [    1.556210] smp: Bringing up secondary CPUs ...
    [    1.557081] x86: Booting SMP configuration:
    [    1.558049] .... node  #0, CPUs:        #1  #2  #3  #4  #5  #6  #7  #8  #9 #10 #11 #12 #13 #14 #15
    ...
