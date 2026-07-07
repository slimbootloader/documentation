.. _release-26-06:

Release 26.06 Highlights
------------------

Slim Bootloader 26.06 includes new common libraries, firmware update
enhancements, UI tooling, payload improvements, crypto library updates,
and new platform support.

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - Area
     - Updates
   * - ACPI
     - MADT, DMAR, and MCFG common library support
   * - Common libraries
     - Common PsdLib, AMT library, TopSwap library, and I2C library
   * - HECI
     - Common HECI library cleanup
   * - Firmware update
     - Enhancements to skip specific fields and regions
   * - Payload support
     - TXT support for RPL through the UEFI payload
   * - OsLoader
     - Added flags for extra image support and shell build support
   * - UI and tooling
     - SBL GUI Builder Tool and Simple UI setup support
   * - Crypto
     - IppCryptoLib migration to 2.0 for x64
   * - Platforms
     - Added support for GNR-D, BTL-S 12P, and the AAEON UP SQUARED PRO TWL board


What's New
~~~~~~~~~~

Common Library Improvements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This release adds common ACPI library support for MADT, DMAR, and MCFG,
along with new shared PsdLib, AMT, TopSwap, and I2C libraries. The common
HECI library has also been cleaned up to improve shared code reuse across
platforms.

Firmware Update Enhancements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Firmware update support now includes enhancements to skip specific fields
and regions, giving platforms finer control over update behavior.

Payload Updates
^^^^^^^^^^^^^^^

Slim Bootloader 26.06 adds TXT support for RPL through the UEFI payload.
It also adds OsLoader flags for extra image support and shell build support.

UI and Tooling
^^^^^^^^^^^^^^

The release introduces the SBL GUI Builder Tool and Simple UI setup support,
making |PN| configuration and setup workflows easier to use.

Crypto Library Update
^^^^^^^^^^^^^^^^^^^^^

IppCryptoLib has been migrated to version 2.0 for x64 builds.

New Platform Support
^^^^^^^^^^^^^^^^^^^^

Slim Bootloader 26.06 adds support for the following platforms and boards:

* GNR-D
* BTL-S 12P
* AAEON UP SQUARED PRO TWL board
