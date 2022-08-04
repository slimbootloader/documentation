.. _boot-netboot:

Netboot / PXE boot with UEFI Payload
------------------------------------

Some users may choose to boot their operating system over a network. \
This guide shows how to use Netboot to enable booting over a network.

`netboot.xyz <https://netboot.xyz/>`_ lets you PXE boot various operating system installers or utilities over the network. \
`iPXE <https://ipxe.org/>`_ is an open source network boot firmware. It provides a full PXE implementation.

netboot.xyz can be built as an UEFI Application and can be included in the UEFI Payload. The UEFI Payload can be customized \
to launch the netboot.xyz application as a boot target.

The steps below provide instruction on how to build UEFI Payload with netboot.xyz application -

**Steps:**

1. Clone the ``edk2`` repository.

2. Create a new directory inside ``edk2\UefiPayloadPkg`` called ``NetBoot``.

3. Create a new directory inside ``edk2\UefiPayloadPkg\NetBoot`` called ``X64``.

4. Download the netboot.xyz binary from `here <https://boot.netboot.xyz/ipxe/netboot.xyz.efi>`_ \
   and place it into the directory created above - i.e. inside ``edk2\UefiPayloadPkg\NetBoot\X64``

5. Create a new file called ``NetBoot.inf`` in ``edk2\UefiPayloadPkg\NetBoot`` and paste the following contents in it -

.. code-block:: text
  :linenos:

  ##  @file
  #  This is the Netboot binary file.
  #
  #  Copyright (c) 2021, Intel Corporation. All rights reserved.<BR>
  #
  #  This program and the accompanying materials
  #  are licensed and made available under the terms and conditions of the BSD License
  #  which accompanies this distribution. The full text of the license may be found at
  #  http://opensource.org/licenses/bsd-license.php
  #  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
  #  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
  #
  #
  ##
  ##

  [Defines]
    INF_VERSION                    = 0x00010006
    BASE_NAME                      = NetBoot
    FILE_GUID                      = 4CDF2DAE-B4C7-482C-B468-99C812911FF5
    MODULE_TYPE                    = UEFI_APPLICATION
    VERSION_STRING                 = 1.0

  [Binaries.X64]
    PE32|X64/NetBoot.efi|*

6. Open ``edk2\UefiPayloadPkg\UefiPayloadPkg.dec`` and add the following line in the ``[Guids]`` section -

.. code-block:: text

  gUefiPayloadNetBootAppGuid = { 0x4cdf2dae, 0xb4c7, 0x482c, { 0xb4, 0x68, 0x99, 0xc8, 0x12, 0x91, 0x1f, 0xf5 } }

7. Open ``edk2\UefiPayloadPkg\UefiPayloadPkg.fdf`` and add the following line at the end of the ``[FV.DXEFV]`` section.

.. code-block:: text

  # NetBoot
  INF  RuleOverride = BINARY USE = X64 UefiPayloadPkg/NetBoot/NetBoot.inf

8. In the same file, comment out the line in the ``Shell`` part under the ``[FV.DXEFV]`` section.

9. Open ``edk2\UefiPayloadPkg\Library\PlatformBootManagerLib\PlatformBootManager.c`` and add the following line in the ``PlatformBootManagerAfterConsole`` function after ``EfiBootManagerRefreshAllBootOption()`` call -

.. code-block:: C

  // Register Netboot
  PlatformRegisterFvBootOption (&gUefiPayloadNetBootAppGuid, L"Netboot (iPXE)", LOAD_OPTION_ACTIVE);

10. Open ``edk2\UefiPayloadPkg\Library\PlatformBootManagerLib\PlatformBootManagerLib.inf`` and add the following line in the ``[Guids]`` section -

.. code-block:: text

  gUefiPayloadNetBootAppGuid

11. Build the UEFI Payload: `UEFI Payload Build Instructions <https://github.com/tianocore/edk2/blob/master/UefiPayloadPkg/BuildAndIntegrationInstructions.txt>`_

12. Copy the generated ``UEFIPAYLOAD.fd`` into ``slimbootloader\PayloadPkg\PayloadBins\UefiNetBoot.fd``

13. Build SBL for your platform

.. code-block:: text

  python BuildLoader.py build <platform> -p "OsLoader.efi:LLDR:Lz4;UefiNetBoot.fd:UEFI:Lzma"

14. Flash and boot