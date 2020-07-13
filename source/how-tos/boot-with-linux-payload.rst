.. _boot-with-linux-payload:
.. _LinuxBoot: https://www.linuxboot.org/
.. _Linux.zip: https://github.com/slimbootloader/slimbootloader/files/4463548/QemuLinux.zip

Boot Linux as a Payload
------------------------------

|SPN| can boot Linux kernel as a payload from flash directly. It can also
support LinuxBoot_.  |br|
Currently, transitioning to LinuxBoot is only supported
from |SPN| Stage2.


This page provides a step-by-step how to build SBL with Linux payload for QEMU and LeafHill platforms.
The similar steps can be applied to other platforms.

Prepare Linux images
=========================================

1. Create PayloadBins directory in PayloadPkg::

    mkdir PayloadPkg\PayloadBins

2. Copy linux kernel, initrd image and kernel command line file to PayloadBins directory.
   For convenience, a pre-built customized small kernel image Linux.zip_ is used here.
   Unzip the files into PayloadPkg\PayloadBins using 7-zip tool ::

    7z x QemuLinux.zip -oPayloadPkg\PayloadBins


Enable Linux Payload for LeafHill
===========================================

1. Adjust kernel boot command line file config.cfg to use UART2 for serial console output.
   The file contents is as below::

    init=/init root=/dev/ram0 rw 3 console=ttyS2,115200

2. Enable Linux payload support by adding following to Platform/ApollolakeBoardPkg/BoardConfig.py ::

    self.ENABLE_LINUX_PAYLOAD = 1

4. Adjust flash layout to provide enough space for EPLD component to store linux kernel, initrd image and command line file.
   It can be done by modifying specific component size definitions in Platform/ApollolakeBoardPkg/BoardConfig.py ::

    self.EPAYLOAD_SIZE = 0x200000
    self.PAYLAOD_SIZE  = 0

5. Change the default boot payload ID to Linux Payload in Platform/ApollolakeBoardPkg/CfgData/CfgData_Int_LeafHill.dlt ::

    GEN_CFG_DATA.PayloadId  |  'LINX'

6. Build Slim Bootloader with Linux Payload ::

    python BuildLoader.py build apl -p config.cfg:OSLD;vmlinuz:LINX;config.cfg:CMDL;initrd:INRD

   Note::

    '-p' takes multiple components separated by ';'. The 1st component will be built into PLD and the remaining components will be built into EPLD.
    In this example, since PLD is not used at all, a dummy file config.cfg is provided to satisfy build requirements.

7. Stitch, flash and boot.  It should boot to Linux shell console on LeafHill board serial port UART2.
   Please follow :ref:`supported-hardware` to build a flashable image for the target platform.



Enable Linux Payload for QEMU
===========================================

1. Change the default boot payload ID to Linux Payload in Platform/QemuBoardPkg/CfgData/CfgDataExt_Brd1.dlt by adding ::

    GEN_CFG_DATA.PayloadId  |  'LINX'

2. Build Slim Bootloader with Linux Payload using command ::

    python BuildLoader.py build qemu -p config.cfg:OSLD;vmlinuz:LINX;config.cfg:CMDL;initrd:INRD

3. Test Linux Payload boot on QEMU using command ::

    qemu-system-x86_64 -cpu max -machine q35 -m 256 -serial stdio -boot order=d -pflash Outputs/qemu/SlimBootloader.bin

   The following boot log should be seen on console ::

    ============= Intel Slim Bootloader STAGE1A =============
    SBID: SB_QEMU
    ...

    ============= Intel Slim Bootloader STAGE1B =============
    QEMU Flash: Attempting flash detection at FFC00000
    ...

    ============= Intel Slim Bootloader STAGE2 =============
    Unmapping Stage
    ...

    Jump to payload
    Switch to LongMode and jump to 64-bit kernel entrypoint ...
    Linux version 5.5.2 (mxma@mxma-ubuntu) (gcc version 7.4.0 (Ubuntu 7.4.0-1ubuntu1~16.04~ppa1)) #7 SMP Sat Apr 4 11:27:23 PDT 2020
    Command line: init=/init root=/dev/ram0 rw 3 console=ttyS0,115200

    acpi_rsdp=0xEB04000
    x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
    x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
    x86/fpu: Supporting XSAVE feature 0x008: 'MPX bounds registers'
    x86/fpu: Supporting XSAVE feature 0x010: 'MPX CSR'
    x86/fpu: Supporting XSAVE feature 0x200: 'Protection Keys User registers'
    x86/fpu: xstate_offset[3]:  960, xstate_sizes[3]:   64
    x86/fpu: xstate_offset[4]: 1024, xstate_sizes[4]:   64
    x86/fpu: xstate_offset[9]: 2688, xstate_sizes[9]:    8
    x86/fpu: Enabled xstate features 0x21b, context size is 2696 bytes, using 'standard' format.
    BIOS-provided physical RAM map:
    BIOS-e820: [mem 0x0000000000000000-0x000000000009ffff] usable
    BIOS-e820: [mem 0x00000000000a0000-0x00000000000fffff] reserved
    BIOS-e820: [mem 0x0000000000100000-0x000000000eafffff] usable
    BIOS-e820: [mem 0x000000000eb00000-0x000000000eb03fff] reserved
    BIOS-e820: [mem 0x000000000eb04000-0x000000000eb6bfff] ACPI data
    BIOS-e820: [mem 0x000000000eb6c000-0x000000000eb73fff] ACPI NVS
    BIOS-e820: [mem 0x000000000eb74000-0x000000000fffffff] reserved
    BIOS-e820: [mem 0x00000000ffc00000-0x00000000ffffffff] reserved
    NX (Execute Disable) protection: active
    SMBIOS 2.5 present.
    DMI: Intel Corporation Unknown/Unknown, BIOS XXXX.XXX.XXX.XXX Unknown
    tsc: Fast TSC calibration using PIT
    tsc: Detected 1896.001 MHz processor
    last_pfn = 0xeb00 max_arch_pfn = 0x400000000
    x86/PAT: Configuration [0-7]: WB  WT  UC- UC  WB  WT  UC- UC
    Using GB pages for direct mapping
    RAMDISK: [mem 0x0ece5000-0x0ed47fff]
    Allocated new RAMDISK: [mem 0x0ea9d000-0x0eaff55f]
    Move RAMDISK from [mem 0x0ece5000-0x0ed4755f] to [mem 0x0ea9d000-0x0eaff55f]
    ACPI: Early table checksum verification disabled
    ACPI: RSDP 0x00000000000FFF80 000024 (v02 OEMID )
    ACPI: XSDT 0x000000000EB040E0 00004C (v01 OEMID  OEMTABLE 00000005 CREA 0100000D)
    ACPI: FACP 0x000000000EB04210 00010C (v05 OEMID  OEMTABLE 00000005 CREA 0100000D)
    ACPI: DSDT 0x000000000EB044E0 00109D (v02 OEMID  APL-SOC  00000000 INTL 20160422)
    ACPI: FACS 0x000000000EB04320 000040
    ACPI: FACS 0x000000000EB04320 000040
    ACPI: HPET 0x000000000EB04360 000038 (v01 OEMID  OEMTABLE 00000005 CREA 0100000D)
    ACPI: APIC 0x000000000EB043A0 00005A (v03                 00000000      00000000)
    ACPI: MCFG 0x000000000EB04400 00003C (v01                 00000001      00000000)
    ACPI: FPDT 0x000000000EB04440 000044 (v01 INTEL  OEMTABLE 00000005 CREA 0100000D)
    Zone ranges:
      DMA32    [mem 0x0000000000001000-0x000000000eafffff]
      Normal   empty
    Movable zone start for each node
    Early memory node ranges
      node   0: [mem 0x0000000000001000-0x000000000009ffff]
      node   0: [mem 0x0000000000100000-0x000000000eafffff]
    Zeroed struct page in unavailable ranges: 97 pages
    Initmem setup node 0 [mem 0x0000000000001000-0x000000000eafffff]
    ACPI: PM-Timer IO Port: 0x408
    ACPI: LAPIC_NMI (acpi_id[0xff] high level lint[0x1])
    IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
    ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
    ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
    Using ACPI (MADT) for SMP configuration information
    ACPI: HPET id: 0x0 base: 0xfed00000
    smpboot: Allowing 1 CPUs, 0 hotplug CPUs
    [mem 0x10000000-0xffbfffff] available for PCI devices
    clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
    setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:1 nr_node_ids:1
    percpu: Embedded 40 pages/cpu s132440 r0 d31400 u2097152
    Built 1 zonelists, mobility grouping on.  Total pages: 59149
    Kernel command line: init=/init root=/dev/ram0 rw 3 console=ttyS0,115200
     acpi_rsdp=0xEB04000
    Dentry cache hash table entries: 32768 (order: 6, 262144 bytes, linear)
    Inode-cache hash table entries: 16384 (order: 5, 131072 bytes, linear)
    mem auto-init: stack:off, heap alloc:off, heap free:off
    Memory: 222488K/240252K available (6146K kernel code, 289K rwdata, 676K rodata, 752K init, 992K bss, 17764K reserved, 0K cma-reserved)
    rcu: Hierarchical RCU implementation.
    rcu:    RCU restricting CPUs from NR_CPUS=64 to nr_cpu_ids=1.
    rcu: RCU calculated value of scheduler-enlistment delay is 25 jiffies.
    rcu: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=1
    NR_IRQS: 4352, nr_irqs: 256, preallocated irqs: 16
    Console: colour dummy device 80x25
    printk: console [ttyS0] enabled
    ACPI: Core revision 20191018
    clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
    APIC: Switch to symmetric I/O mode setup
    ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
    clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x36a8d4a2582, max_idle_ns: 881590642256 ns
    Calibrating delay loop (skipped), value calculated using timer frequency.. 3792.00 BogoMIPS (lpj=7584004)
    pid_max: default: 4096 minimum: 301
    Mount-cache hash table entries: 512 (order: 0, 4096 bytes, linear)
    Mountpoint-cache hash table entries: 512 (order: 0, 4096 bytes, linear)
    Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
    Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
    Spectre V1 : Mitigation: usercopy/swapgs barriers and __user pointer sanitization
    Spectre V2 : Mitigation: Full AMD retpoline
    Spectre V2 : Spectre v2 / SpectreRSB mitigation: Filling RSB on context switch
    Speculative Store Bypass: Vulnerable
    Freeing SMP alternatives memory: 8K
    smpboot: CPU0: AMD QEMU TCG CPU version 2.5+ (family: 0x6, model: 0x6, stepping: 0x3)
    Performance Events: PMU not available due to virtualization, using software events only.
    rcu: Hierarchical SRCU implementation.
    smp: Bringing up secondary CPUs ...
    smp: Brought up 1 node, 1 CPU
    smpboot: Max logical packages: 1
    smpboot: Total of 1 processors activated (3792.00 BogoMIPS)
    devtmpfs: initialized
    clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
    thermal_sys: Registered thermal governor 'step_wise'
    thermal_sys: Registered thermal governor 'user_space'
    cpuidle: using governor ladder
    ACPI: bus type PCI registered
    PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
    PCI: not using MMCONFIG
    PCI: Using configuration type 1 for base access
    ACPI: Added _OSI(Module Device)
    ACPI: Added _OSI(Processor Device)
    ACPI: Added _OSI(3.0 _SCP Extensions)
    ACPI: Added _OSI(Processor Aggregator Device)
    ACPI: Added _OSI(Linux-Dell-Video)
    ACPI: Added _OSI(Linux-Lenovo-NV-HDMI-Audio)
    ACPI: Added _OSI(Linux-HPI-Hybrid-Graphics)
    ACPI: 1 ACPI AML tables successfully acquired and loaded
    ACPI: Interpreter enabled
    ACPI: (supports S0 S5)
    ACPI: Using IOAPIC for interrupt routing
    PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
    [Firmware Info]: PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] not reserved in ACPI motherboard resources
    PCI: not using MMCONFIG
    PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
    ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
    acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MSI HPX-Type3]
    acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
    PCI host bridge to bus 0000:00
    pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
    pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
    pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
    pci_bus 0000:00: root bus resource [mem 0x80000000-0xdfffffff window]
    pci_bus 0000:00: root bus resource [bus 00-ff]
    pci 0000:00:00.0: [8086:29c0] type 00 class 0x060000
    pci 0000:00:01.0: [1234:1111] type 00 class 0x030000
    pci 0000:00:01.0: reg 0x10: [mem 0x90000000-0x90ffffff pref]
    pci 0000:00:01.0: reg 0x18: [mem 0x80045000-0x80045fff]
    pci 0000:00:01.0: reg 0x30: [mem 0x00000000-0x0000ffff pref]
    pci 0000:00:01.0: BAR 0: assigned to efifb
    pci 0000:00:02.0: [8086:10d3] type 00 class 0x020000
    pci 0000:00:02.0: reg 0x10: [mem 0x80020000-0x8003ffff]
    pci 0000:00:02.0: reg 0x14: [mem 0x80000000-0x8001ffff]
    pci 0000:00:02.0: reg 0x18: [io  0x2060-0x207f]
    pci 0000:00:02.0: reg 0x1c: [mem 0x80040000-0x80043fff]
    pci 0000:00:02.0: reg 0x30: [mem 0x00000000-0x0003ffff pref]
    pci 0000:00:1f.0: [8086:2918] type 00 class 0x060100
    pci 0000:00:1f.0: quirk: [io  0x0400-0x047f] claimed by ICH6 ACPI/GPIO/TCO
    pci 0000:00:1f.2: [8086:2922] type 00 class 0x010601
    pci 0000:00:1f.2: reg 0x20: [io  0x2040-0x205f]
    pci 0000:00:1f.2: reg 0x24: [mem 0x80044000-0x80044fff]
    pci 0000:00:1f.3: [8086:2930] type 00 class 0x0c0500
    pci 0000:00:1f.3: reg 0x20: [io  0x2000-0x203f]
    ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
    ACPI: PCI Interrupt Link [LNKA] (IRQs 5 10 11) *0
    ACPI: PCI Interrupt Link [LNKB] (IRQs 5 10 11) *0
    ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 11) *0
    ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 11) *0
    SCSI subsystem initialized
    ACPI: bus type USB registered
    usbcore: registered new interface driver usbfs
    usbcore: registered new interface driver hub
    usbcore: registered new device driver usb
    PCI: Using ACPI for IRQ routing
    clocksource: Switched to clocksource tsc-early
    ACPI: Failed to create genetlink family for ACPI event
    pnp: PnP ACPI init
    pnp 00:01: disabling [io  0x0440-0x044f] because it overlaps 0000:00:1f.0 BAR 7 [io  0x0400-0x047f]
    system 00:01: [io  0x01e0-0x01ef] has been reserved
    system 00:01: [io  0x0160-0x016f] has been reserved
    system 00:01: [io  0x0278-0x027f] has been reserved
    system 00:01: [io  0x0370-0x0371] has been reserved
    system 00:01: [io  0x0378-0x037f] has been reserved
    system 00:01: [io  0x0678-0x067f] has been reserved
    system 00:01: [io  0x0778-0x077f] has been reserved
    system 00:01: [io  0x0800] has been reserved
    system 00:01: [io  0xafe0-0xafe3] has been reserved
    system 00:01: [io  0xb000-0xb03f] has been reserved
    system 00:01: [mem 0xfec00000-0xfec00fff] could not be reserved
    system 00:01: [mem 0xfee00000-0xfeefffff] has been reserved
    pnp: PnP ACPI: found 8 devices
    clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
    pci 0000:00:02.0: BAR 6: assigned [mem 0x80080000-0x800bffff pref]
    pci 0000:00:01.0: BAR 6: assigned [mem 0x80050000-0x8005ffff pref]
    pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
    pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
    pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
    pci_bus 0000:00: resource 7 [mem 0x80000000-0xdfffffff window]
    pci 0000:00:01.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
    PCI: CLS 0 bytes, default 64
    Trying to unpack rootfs image as initramfs...
    Freeing initrd memory: 396K
    workingset: timestamp_bits=62 max_order=16 bucket_order=0
    io scheduler mq-deadline registered
    io scheduler kyber registered
    efifb: probing for efifb
    efifb: framebuffer at 0x90000000, using 1876k, total 1875k
    efifb: mode is 800x600x32, linelength=3200, pages=1
    efifb: scrolling: redraw
    efifb: Truecolor: size=8:8:8:8, shift=24:16:8:0
    Console: switching to colour frame buffer device 100x37
    fb0: EFI VGA frame buffer device
    Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
    00:04: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
    brd: module loaded
    loop: module loaded
    ahci 0000:00:1f.2: can't derive routing for PCI INT A
    ahci 0000:00:1f.2: PCI INT A: no GSI
    ahci 0000:00:1f.2: AHCI 0001.0000 32 slots 6 ports 1.5 Gbps 0x3f impl SATA mode
    ahci 0000:00:1f.2: flags: 64bit ncq only
    scsi host0: ahci
    scsi host1: ahci
    scsi host2: ahci
    scsi host3: ahci
    scsi host4: ahci
    scsi host5: ahci
    ata1: SATA max UDMA/133 abar m4096@0x80044000 port 0x80044100 irq 24
    ata2: SATA max UDMA/133 abar m4096@0x80044000 port 0x80044180 irq 24
    ata3: SATA max UDMA/133 abar m4096@0x80044000 port 0x80044200 irq 24
    ata4: SATA max UDMA/133 abar m4096@0x80044000 port 0x80044280 irq 24
    ata5: SATA max UDMA/133 abar m4096@0x80044000 port 0x80044300 irq 24
    ata6: SATA max UDMA/133 abar m4096@0x80044000 port 0x80044380 irq 24
    usbcore: registered new interface driver usb-storage
    sdhci: Secure Digital Host Controller Interface driver
    sdhci: Copyright(c) Pierre Ossman
    usbcore: registered new interface driver usbhid
    usbhid: USB HID core driver
    IPI shorthand broadcast: enabled
    random: get_random_bytes called from 0xffffffff81030d09 with crng_init=0
    sched_clock: Marking stable (1122889738, 290366226)->(1520783472, -107527508)
    ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
    ata3.00: ATAPI: QEMU DVD-ROM, 2.5+, max UDMA/100
    ata3.00: applying bridge limits
    ata3.00: configured for UDMA/100
    ata6: SATA link down (SStatus 0 SControl 300)
    ata5: SATA link down (SStatus 0 SControl 300)
    ata1: SATA link down (SStatus 0 SControl 300)
    ata4: SATA link down (SStatus 0 SControl 300)
    ata2: SATA link down (SStatus 0 SControl 300)
    scsi 2:0:0:0: CD-ROM            QEMU     QEMU DVD-ROM     2.5+ PQ: 0 ANSI: 5
    Freeing unused kernel image (initmem) memory: 752K
    Write protecting the kernel read-only data: 10240k
    Freeing unused kernel image (text/rodata gap) memory: 2044K
    Freeing unused kernel image (rodata/data gap) memory: 1372K
    Run /init as init process
    tsc: Refined TSC clocksource calibration: 1895.971 MHz
    clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x36a89bbdbb4, max_idle_ns: 881590521235 ns
    clocksource: Switched to clocksource tsc

      #####################################
      #                                   #
      #    Welcome to "Minimal Linux"     #
      #                                   #
      #####################################

    /$

