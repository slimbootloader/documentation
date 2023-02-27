.. _build-system:

Build System
------------

|SPN| chooses EDK II build system to compile and build |SPN| image. EDK II build infrastructure provides a flexible framework supporting different platforms and extensive configuration capabilities.

It supports many tools chains including **GCC** on Linux and **Visual Studio** on Windows.

This choice also comes with two benefits:

* EDK II build tool is familiar to many UEFI/BIOS developers
* Open source EDK II libraries can be ported with smaller effort

Build Process
--------------

|SPN| build process is implemented in top level build script ``BuildLoader.py``. The following diagram illustrates main steps:

.. graphviz:: /images/build_steps.dot

The generated files are located in ``Build/`` directory.

The |SPN| image, configuration data, and (generated) helper scripts, are located in ``Outputs/`` directory.

.. Note:: To assist debugging, the build process also generates ``SlimBootloader.txt`` file which contains flash layout details for each component in |SPN| image.



.. _pre-build:

Pre Build Customization
^^^^^^^^^^^^^^^^^^^^^^^^

|SPN| build system provides build time customization. Before the build, one can modify the configuration file ``Platform/<Platform_Foo>/BoardConfig.py`` based on requirement, image footprint, or hardware features etc.

Prebuild process determines the build time configuration by generating multiple files, among those are:

==================           ================
File                         Description
==================           ================
Platform.dsc                 Finalized platform configuration based on ``BoardConfig.py``
ConfigDataStruct.h           C header file for configuration data structure based on ``*.yaml`` file
ConfigDataBlob.h             C file for *Internal* configuration data with default values
==================           ================

See :ref:`customize-build` for more details.


.. _build-sbl:

Build |SPN|
^^^^^^^^^^^^^

|SPN| master build script ``BuildLoader.py`` provides many options to compile images. To get help::

  python BuildLoader.py build -h

Set env variable for SBL Key directory::

    $set SBL_KEY_DIR=$(SBL_ROOT)\..\SblKeys\

Build |SPN| for a supported platform::

  python BuildLoader.py build <platform_name>

Clean up files generated during build process::

  python BuildLoader.py clean

Final |SPN| image(s) should be generated under ``Outputs/<platform_name>`` directory


See :ref:`build-tool` for more details.

Build Details per Stage
^^^^^^^^^^^^^^^^^^^^^^^

Slim Bootloader is built in stages and more information on each stage is given below.

* **Stage 1A**:

  * **Packaged As**: FD containing Stage1A FV, and FSP-T binary as a FILE
  * **Stage 1A FV**:

    * Contains ``ResetVector``, ``VerInfo``, ``FlashMap``, ``FitTable``, ``HashStore``, ``PEIPcdDataBase``, and Stage1A PEIM
    * Stage 1A contains a module called VTF (Volume Top File) which is placed at the top within the Stage 1A FV.
      The VTF contains the reset vector code and hence the VTF needs to be placed at an appropriate
      address so that the reset vector code in the the Vtf0 file (Identified by the GUID ``1BA0062E-C779-4582-8566-336AE8F78F09``)
      aligns with the reset vector of Intel x86 architecture.

      The entry point for the Stage1A module within the Stage1A FV (``_ModuleEntryPoint``) is placed as
      the first DWORD of the built FV. The reset vector code from the Vtf0 jumps to this address and continues
      from the ``_ModuleEntryPoint`` defined in ``SecEntry.nasm``.


* **Stage 1B**:

  * **Packaged As**: FD containing Stage1B FV, and FSP-M binary as a FILE
  * **Stage 1B FV**: Contains ``CfgDataInt.bin``, and Stage1B PEIM

* **Stage 2**:

  * **Packaged As**: FD containing Stage2 FV, and FSP-S binary as a FILE
  * **Stage 2 FV**: Contains ACPI Table, Vbt, Logo, and Stage2 PEIM


.. _post-build:

Post Build Customization
^^^^^^^^^^^^^^^^^^^^^^^^^^

|SPN| supports platform customizations by embedding configuration data in a dedicated region in the image. The configuration data region can be *patched* without recompiling the code. This feature is most useful in supporting multiple similar boards in a single |SPN| image.


.. _release-build:

Release vs Debug Build
^^^^^^^^^^^^^^^^^^^^^^^^^^

|SPN| build system provides building debug or release images. Debug build contains verbose log messages for debugging, while release build image is deployed in a production environment. It contains minimum log messages to the console, and in some cases, may be built with more secure configurations, compared to debug build image.

Build system builds debug |SPN| image by default. To build a release image::

  python BuildLoader.py build <target> -r

.. note:: When verified boot is enabled, |SPN| release build requires container image format to boot OS.


.. _develop-on-windows:

Developing on Windows
^^^^^^^^^^^^^^^^^^^^^^

.. note:: Typically, Windows C compiler generates smaller code size compared to GCC build. This needs to be considered when allocating image size in |SPN| build.
