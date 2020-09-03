.. _build-system:

Build System
-------------------------

|SPN| chooses EDK II build system to compile and build |SPN| image. EDK II build infrastructure provides a flexible framework supporting different platforms and extensive configuration capabilities.

It supports many tools chains including **GCC** on Linux and **Visual Studio** on Windows.

This choice also comes with two benefits:

* EDK II build tool is familiar to many UEFI/BIOS developers
* Open source EDK II libraries can be ported with smaller effort


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

.. note:: When verified boot is enabled, |SPN| release build requires IAS image format to boot OS.


.. _develop-on-windows:

Developing on Windows
^^^^^^^^^^^^^^^^^^^^^^

.. note:: Typically, Windows C compiler generates smaller code size compared to GCC build. This needs to be considered when allocating image size in |SPN| build.
