.. _build-system:

Build System
------------

|SPN| chooses EDK II build system to compile and build |SPN| image. EDK II build infrastructure provides a flexible framework supporting different platforms and extensive configuration capabilities.

It supports many tools chains including **GCC** on Linux and **Visual Studio** on Windows.

This choice also comes with two benefits:

* EDK II build tool is familiar to many UEFI/BIOS developers
* Open source EDK II libraries can be ported with smaller effort

Build Process
^^^^^^^^^^^^^

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
~~~~~~~~~~~~~~~~~~~~~~~

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

  | 

* **Stage 1B**:

  * **Packaged As**: FD containing Stage1B FV, and FSP-M binary as a FILE
  * **Stage 1B FV**: Contains ``CfgDataInt.bin``, and Stage1B PEIM

  | 

* **Stage 2**:

  * **Packaged As**: FD containing Stage2 FV, and FSP-S binary as a FILE
  * **Stage 2 FV**: Contains ACPI Table, Vbt, Logo, and Stage2 PEIM

  | 

* **OsLoader**:

  * **Packaged As**: FD containing OsLoader FV

  | 

* **FwUpdate**:

  * **Packaged As**: FD containing Firmware Update FV
  * Note that FwUpdate is included only if ``ENABLE_FWU`` is enabled in ``BoardConfig.py``

* In addition to the Slim Bootloader Stages and the payloads, the final SBL image may include some other components like Microcode binaries,
  ACM binary, SBL container binaries, etc.

.. _post-build:

Post Build Image Construction
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Each stage and component of Slim Bootloader is individually built and then put together into one image at the end
  of the build process.
* The final image layout for Slim Bootloader can be defined in ``BoardConfig.py`` - ``GetImageLayout()``

  * If firmware resiliency is enabled, the layout will typically contain redundant copies of the boot-critical code.
    Check :ref:`firmware-resiliency-and-recovery` for more details.

* As discussed above, the final SBL image includes SBL stages and other components, examples of which are listed below:

  * These additional components included in the SBL image are placed in the non-redundant region of the image
  * The list of components in the final image in the final image is present in the ``GetImageLayout()`` function
  * Examples:

    * ``ACM.bin`` - Authenticated Code Module
    * ``MRCDATA.bin`` - Memory Reference Code Data, used to store Memory Reference Code training data
    * ``VARIABLE.bin`` - This region is used for ``GetVariable()`` and ``SetVariable()`` APIs provided by ``LiteVariableLib`` in ``BootloaderCommonPkg``
    * ``UCODE.bin`` - CPU Microcode

    * The components listed above are generated by the ``post_build()`` function in ``BuildLoader.py``

  * Payloads other than OsLoader and FW Update are built independently and the payload binary is packaged as ``EPAYLOAD.bin``
    to be included in the final SBL image

    * ``EPAYLOAD.bin`` - Payload for SBL - used for extra payloads (UEFI Payload, Linux, u-boot, etc.). Refer to :ref:`integrate-multiple-payloads`
      for more details.

  * SBL images can also include container images and SBL containers can be built with the container tool (:ref:`gen-container-tool`) and included in the
    SBL image as explained below (:ref:`adding-sbl-container`)


Patching of stages
~~~~~~~~~~~~~~~~~~

Patching of stages is done to allow for code simplicity and for faster booting. The addresses of certain elements like BFV, FIT, FlashMap, etc.
are pre-loaded into the SBL binary at pre-defined locations.


* **Stage 1A:**

  * The Boot Firmware Volume (BFV) address needs to be placed as the the last DWORD of memory. Thus, the BFV needs to be
    placed as the last DWORD of Stage 1A. And this BFV will be mapped to the memory address ``0xFFFFFFFC`` (top of memory - 4).

    Thus, in the image layout, BFV will be patched onto (top of Stage 1A - ``0x04``) address.

    .. note:: When passing a negative offset to ``patch_fv()``, it is considered relative to 4GB (``0xFFFFFFFF``)

          Thus, the final offset will be equal to : ``FileSize - (0xFFFFFFFF - offset + 1)``

          This can be seen in patching of BFV, FlashMap, and FIT.

  * Stage 1A Entry point is patched onto the Stage 1A ``__ModuleEntryPoint`` symbol address
  * Stage 1A Module base is patched onto entry point + 4
  * Address of VerInfo file (GUID: ``3473A022-C3C2-4964-B309-22B3DFB0B6CA``) is patched onto ``PcdVerInfoBase`` PCD
  * Address of PcdFileDataBase (GUID: ``EFAC3859-B680-4232-A159-F886F2AE0B83``) is patched onto ``PcdFileDataBase`` PCD
  * Address of FlashMap (GUID: ``3CEA8EF3-95FC-476F-ABA5-7EC5DFA1D77B``) is patched onto ``0xFFFFFFF8`` (top of Stage 1A - 0x08)
  * Address of Firmware Interface Table (FIT) is patched onto memory address ``0xFFFFFFC0`` (top of Stage 1A - 0x40)
  
    * FIT Signature Low, FIT Signature High, and FIT table max length are patched onto offsets 0, 4, and 8 respectively.
    * FIT entries  are generated by ``BuildLoader.py - update_fit_table()`` at build time.

  * Address of HashStore is patched onto  ``PcdHashStoreBase`` PCD

  | 

* **Stage 1B:**

  * Stage 1B entry point address is patched into the Stage 1B ``__ModuleEntryPoint`` symbol address
  * Stage 1B module based is patched onto entry point + 4
  * Address of Internal CfgDataBase (GUID: ``016E6CD0-4834-4C7E-BCFE-41DFB88A6A6D``) is patched onto ``PcdCfgDataIntBase`` PCD

  | 

* **Stage 2:**

  * Stage 2 entry point address is patched into the Stage 2 ``__ModuleEntryPoint`` symbol address
  * Stage 2 module based is patched onto entry point + 4
  * Address of VBT (GUID: ``E08CA6D5-8D02-43AE-ABB1-952CC787C933``) is patched onto ``PcdGraphicsVbtAddress`` PCD
  * Address of ACPI Table (GUID: ``7E374E25-8E01-4FEE-87F2-390C23C606CD``) address is patched onto ``PcdAcpiTablesAddress`` PCD
  * Address of Splash Logo (GUID: ``5E2D3BE9-AD72-4D1D-AAD5-6B08AF921590``) address is patched onto ``PcdSplashLogoAddress`` PCD

Post Build Customization
^^^^^^^^^^^^^^^^^^^^^^^^^^

|SPN| supports platform customizations by embedding configuration data in a dedicated region in the image. The configuration data region can be *patched* without recompiling the code. This feature is most useful in supporting multiple similar boards in a single |SPN| image.


.. _adding-sbl-container:

Adding an SBL Container
^^^^^^^^^^^^^^^^^^^^^^^

* It may be required to include additional binary components to the final SBL image.
* The required components can be added to the image as SBL containers
* ``GetContainerList()`` initially creates a blank list, and then adds each container entry into this list
* The list of containers included in the final SBL image can be seen in the platform's ``BoardConfig.py - GetContainerList()`` function
* ``GetContainerList()`` returns a list of containers. Each container entry is also a list consisting of several different fields shown
  in the example below
* Make sure that the existing entries in the function are being put into ``container_list`` as one list
* To create a new container, you will need to create a list where the first entry lists the container, and the remaining list the
  components inside it

  * Example:

    Adding files named ``test1``, ``test2``, ``test3`` to a container named "SBLC" will be done as follows:

    .. code-block:: python

        def GetContainerList (self):
          container_list = []
          ...
          ...
          container_list.append([
            # Name      |      File             |    CompressAlg  |               AuthType             | Key File                                       | Region Align   | Region Size |  Svn Info
            ('SBLC',      'SBLC.bin',                 '',             container_list_auth_type,        'KEY_ID_CONTAINER'+'_'+self._RSA_SIGN_TYPE,            0,                0     ,      0),
            ('TST1',      '/path/to/test1',           '',             container_list_auth_type,        'KEY_ID_CONTAINER_COMP'+'_'+self._RSA_SIGN_TYPE,       0,                0     ,      0),
            ('TST2',      '/path/to/test2',           '',             container_list_auth_type,        'KEY_ID_CONTAINER_COMP'+'_'+self._RSA_SIGN_TYPE,       0,                0     ,      0),
            ('TST3',      '/path/to/test3',           '',             container_list_auth_type,        'KEY_ID_CONTAINER_COMP'+'_'+self._RSA_SIGN_TYPE,       0,                0     ,      0)3
          ])
          ...
          ...

    This will create a container named ``SBLC.bin``

* This ``.bin`` file needs to be added to the SBL image layout so that it can be included in the final image

  * In the platform's ``BoardConfig.py``, we need to add the size of the required component.
  * In ``GetImageLayout()``, add the component to the non-redundant section
  * Example:

    .. code-block:: python

        class Board:
          ...
          ...
          self.SBLC_SIZE = 0x1000

          ...
          def GetImageLayout():
            ...
            ...
            img_list.extend ([
              ('NON_REDUNDANT.bin', [
                    #  File     |   Compression   |       Size      |    Stitch Mode     |     Stitch Position
                    ('SBLC.bin'   ,     ''        , self.SBLC_SIZE,   STITCH_OPS.MODE_FILE_PAD, STITCH_OPS.MODE_POS_TAIL),
                    ...
                    ...
                    ]
                )
            ])
            ...
            ...

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
