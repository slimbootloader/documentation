.. _boot-windows:

Boot Windows with UEFI Payload
------------------------------

|SPN| can boot Windows 10 by using `UEFI Payload <https://github.com/tianocore/edk2>`_. EDK II includes UefiPayloadPkg to build an UEFI payload that |SPN| can launch.

This page provides a step-by-step on guide how to build |SPN| with UEFI Payload.


**References**

`UEFI Payload Build Instructions <https://github.com/tianocore/edk2/blob/master/UefiPayloadPkg/BuildAndIntegrationInstructions.txt>`_

 
**Note**

Visual Studio 2015 is used for building both the UEFI payload as well as |SPN|.
PYTHON_HOME environment variable needs to be set

**Note**

EDK II build relies on a set of tools provided in the BaseTools folder. This is the primary set of tools for processing EDK II content. 

When EDK II is cloned fresh, a one time build of BaseTools is required and its done using the following command::

    edksetup.bat rebuild

**Note**

Please note that the open source UefiPayload source is designed to be a generic payload. It consumes |SPN| produced HOB data structures to get information about the platform like memory map, ACPI tables, etc. This basically allows the UefiPayload to be used with |SPN| without needing any platform porting.

To allow for the UefiPayload to be a generic payload, the payload default build includes an emulated UEFI Variable driver. This emulated variable driver maintains the UEFI variable storage in memory and is **NOT** persistent across any type of reboots. 

**Note**

This guide uses |APL| platform as a reference for build instructions and commands. 


**STEP 1:** Build UEFIPayload

We have verified this build with the following commit::

  * edk2 repo: commit 42d8be0eaac5e7e109f487d4e241847e815b077a

Steps::

  git clone --recurse-submodules https://github.com/tianocore/edk2.git edk2
  cd edk2
  git checkout 42d8be0eaac5e7e109f487d4e241847e815b077a
  git submodule update --recursive
  edksetup.bat
  build -a IA32 -a X64 -p UefiPayloadPkg\UefiPayloadPkgIa32X64.dsc -b DEBUG -t VS2015x86 -D BOOTLOADER=SBL

Example outputs::

    - Done -
    Build end time: 11:09:28, Apr.23 2019
    Build total time: 00:01:48

The **UEFIPAYLOAD.fd** will be built in *edk2\\Build\\UefiPayloadPkgX64\\DEBUG_VS2015x86\\FV*


**STEP 2:** Build |SPN| with UEFIPayload

Download source code at the same **level** as edk2 source code::

  git clone https://github.com/slimbootloader/slimbootloader.git sbl

Copy UEFIPayload image::

  mkdir sbl\PayloadPkg\PayloadBins
  copy edk2\Build\UefiPayloadPkgX64\DEBUG_VS2015x86\FV\UEFIPAYLOAD.fd sbl\PayloadPkg\PayloadBins\UEFIPAYLOAD.fd

Insert the following line to file ``sbl\Platform\ApollolakeBoardPkg\CfgData\CfgData_Int_LeafHill.dlt``::

  GEN_CFG_DATA.PayloadId                   | 'UEFI'

Build::

  cd sbl
  python BuildLoader.py build apl -p "OsLoader.efi:LLDR:Lz4;UEFIPAYLOAD.fd:UEFI:Lzma"

Stitch::

  python Platform\ApollolakeBoardPkg\Script\StitchLoader.py -i <LEAFHILL_8MB_IFWI> -s Outputs\apl\Stitch_Components.zip -o sbl_lfh_ifwi_uefi64.bin

  <LEAFHILL_8MB_IFWI>: Leaf Hill 8MB IFWI image

Example outputs::

    ADD ROOT/IFWI/BP1/SBPDT/BpdtObb/PROV ...
    Done!
    ADD ROOT/IFWI/BP1/SBPDT/BpdtObb/EPLD ...
    Done!
    ADD ROOT/IFWI/BP1/SBPDT/BpdtObb/UVAR ...
    Done!
    Patching Slim Bootloader Flash Map table ...
    Flash map was patched successfully!
    Creating IFWI image ...
    Done!


The final generate IFWI can be found as ``sbl_lfh_ifwi_uefi64.bin`` (8MB in size) in the working directory


**STEP 3:** Flash

Use DediProg, you can flash ``sbl_lfh_ifwi_uefi64.bin`` to SPI flash on Leaf Hill CRB.


**STEP 4:** Install Windows 10 from USB flash drive

Follow https://www.microsoft.com/en-us/software-download/windows10 to create Windows 10 USB installer.

Boot from USB flash drive and follow instructions on the screen to complete Windows installation.
