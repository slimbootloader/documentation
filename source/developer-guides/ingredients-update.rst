.. _ingredients_upgrade:

Ingredients upgrade
-------------------

Slim Bootloader consumes many silicon specific binary components like the Firmware Support Package binary, the Microcode update, etc. The SBL build process includes steps to pull such binary components from other repositories. The aim of such automatic pulling is to provide an easier out of box developer experience.

However, developers may wish to use different versions of binary components for their specific project needs. The section below provides guidance on how to use different versions of such binary components.

FSP upgrade
***********

1. Rename new FSP binary and bsf file to ``Fsp.bsf`` and ``FspRel.bin`` and replace both files in ``Silicon\<platform_name>Pkg\FspBin``.

2. Replace ``Include\FspUpd.h FspsUpd.h FspmUpd.h FsptUpd.h`` to ``Silicon\<platform_name>Pkg\Include`` or ``Silicon\<platform_name>Pkg\FspBin``.

VBT upgrade
***********

Replace VBT binary and bsf or json file in ``Platform\<platform_name>BoardPkg\VbtBin``.

Microcode upgrade
*****************

Get the commit ID with latest microcode from `TianoCore <https://github.com/tianocore/edk2-non-osi>`__.

Update commit ID in ``Silicon\<platform_name>Pkg\Microcode\Microcoode.inf``.
