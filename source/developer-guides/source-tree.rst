Source Tree Structure
---------------------

|SPN| source code is organized into common and platform specific folders::

 |<source>/
 |-- BuildLoader.py
 |-- BootloaderCommonPkg/
 |-- BootloaderCorePkg/
 |   |-- Stage1A/
 |   |-- Stage1B/
 |   |-- Stage2/
 |   `-- Tools/
 |-- PayloadPkg/
 |   |-- OsLoader/
 |   `-- FirmwareUpdate/
 |-- Platform/
 `-- Silicon/

Here's a brief description of each of these folders:

BuildLoader.py
  Top-level build script. Performs tool chain setup, pre-build, configuration, compilation and post-build steps.

BootloaderCommonPkg
  Common libraries for all stages of boot flow

BootloaderCorePkg/Stage1A
  Stage1A code initializes platform from reset vector till Cache-As-RAM (CAR) is setup. It then transfers control to Stage1B.

  It invokes FSP-T.

BootloaderCorePkg/Stage1B
  Stage1B code initializes platform from CAR to the point system memory is fully initialized. It then transfers control to Stage2.

  It invokes FSP-M.

BootloaderCorePkg/Stage2
  Stage2 code performs additional platform initialization and transfers control to payload.

  It invokes FSP-S.

BootloaderCorePkg/Tools
  Contains helper and common scripts for build and configuration during build process

PayloadPkg/OsLoader
  Contains files that implement OS boot logic from boot media.

PayloadPkg/FirmwareUpdate
  Contains files that implement platform-independent logic to perform firmware update flow instead of booting OS.

Platform
  Board specific code for a supported platform.

Silicon
  Silicon specific code for a supported SoC.


.. _package-dependency:

Package Dependency
^^^^^^^^^^^^^^^^^^^^

|SPN| source tree contains multiple packages (subdirectories) that are organized in a manner to provide modularity and ease of use when extending new features or porting for a new board. The following rules shall be followed when one makes code changes:

* ``BootloaderCorePkg`` and ``PayloadPkg`` are mutually exclusive. They should **not** have code dependency to one or the other.
* ``PayloadPkg`` should **not** have dependency to code under ``Platform`` or ``Silicon`` directories. ``PayloadPkg`` should only depends on libraries in ``BootloaderCommonPkg``.

The source tree is organized as core, silicon and platform. A typical platform porting requires code change only in the platform directories.
