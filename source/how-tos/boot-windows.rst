.. _boot-windows:

Boot Windows
-----------------

|SPN| can boot Windows 10 by using |UEFI Payload|. This page provides a step-by-step guide how to build |SPN| with UEFI Payload.

.. |UEFI Payload| raw:: html

   <a href="https://github.com/tianocore/edk2-staging/tree/UEFIPayload" target="_blank">UEFI Payload</a>

**Prerequisites**

This guide requires |APL| (e.g. Leaf Hill CRB) to work with. |SPN| image is built with Visual Studio 2015.


**STEP 1:** Build UEFIPayload

We have verified this build with the following commits::

  * edk2-staging (UEFIPayload) repo: commit d4e13810ad077134a73727f93a06d2b138d88a25
  * edk2 repo: commit a653a525515698d80cbecc1ca3d0e8f48e7390a2

Steps::

  git clone https://github.com/tianocore/edk2-staging.git -b UEFIPayload UEFIPayload
  git clone --recurse-submodules https://github.com/tianocore/edk2.git edk2
  cd UEFIPayload\UefiPayloadPkg
  python BuildPayload.py ApolloLake X64 DEBUG

Example outputs::

    - Done -
    Build end time: 14:56:29, Jan.10 2019
    Build total time: 00:00:21

    Patched offset 0x00000000:[00000000] with value 0x00600320  # Payload Entry point
    Patched offset 0x00000004:[00000000] with value 0x00600000  # Payload execution base


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







