.. _enable-pre-os-payload:

Enable Pre-OS Payload Support
-----------------------------

Pre-OS payload support is an additional feature supported by |SPN| via OS Loader payload in which OS Loader will load both the main OS and a pre-OS payload into memory and will pass control to the pre-OS payload instead of the main OS. After the pre-OS payload finishes execution it is expected that the pre-OS payload will pass control to the main OS that OS Loader previously loaded into memory.

Pre-OS payload support can only be enabled or disabled at build time.

In ``BoardConfig.py`` change/add the following entry::

  self.ENABLE_PRE_OS_CHECKER   = 1

A pre-OS payload binary needs to be provided in the ``Platform/<Platform_Foo>/Binaries/`` directory and named as ``PreOsChecker.bin``.

When this is enabled the OS Loader payload should be used in FV format so that ``PreOsChecker.bin`` is included into the payload per the ``BootloaderCorePkg/BootloaderCorePkg.fdf`` [FV.OsLoader] section.

To use OS Loader payload as an FV in |SPN| run the ``BuildLoader.py`` command with the ``-p`` argument as given below::

  python BuildLoader.py build <platform_name> -p OsLoader.Fv:LLDR:Lz4
