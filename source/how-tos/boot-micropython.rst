.. _boot-micropython:

Boot MicroPython
-----------------

|MicroPython| is a lean and efficient implementation of the Python 3 programming language
that includes a small subset of the Python standard library. MicroPython can be built as
a standalone module that can be launched by SBL's OsLoader payload. This can then be used
to run python based applications.

Below are the steps to enable MicroPython for SBL QEMU platform. Similar steps can be
followed to enable it on other platforms.

.. |MicroPython| raw:: html

   <a href="https://micropython.org" target="_blank">MicroPython</a>

How to Build MicroPython Payload Module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#. Clone latest SBL tree and prepare the build environment following :ref:`build-steps`.
   Here, assume SBL is cloned into directionary named 'SlimBoot'. ::

     git clone https://github.com/slimbootloader/slimbootloader.git SlimBoot

#. Clone MicroPython payloads repo into SBL tree root directory named 'PayloadModPkg'. ::

     cd SlimBoot
     git clone https://github.com/slimbootloader/payloads.git PayloadModPkg
     cd PayloadModPkg
     git submodule update --init
     cd ..
     python PayloadModPkg\MicroPython\Tools\prep.py

#. Build MicroPython module binary.
   Currently, only Windows VS2017 Community build environment is tested for MicroPython build. ::

     python BuildLoader.py build_dsc -p PayloadModPkg\PayloadModPkg.dsc -d MICRO_PYTHON

#. Copy generated MicroPython payload module binary to payload binary directory.
   The MicroPython.efi file path might change depending on the selected build toolchain. ::

     mkdir PayloadPkg\PayloadBins
     copy Build\PayloadModPkg\DEBUG_VS2017\IA32\MicroPython.efi PayloadPkg\PayloadBins /y


How to Integrate MicroPython into Slim Bootloader
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#. Ensure MicroPython.efi is located in PayloadPkg\PayloadBins directory.
   If not, please build MicroPython payload module as mentioned above.

#. Enable a python based application.  Here use the implemented example SBL Setup.
   Add or modify so that "self.ENABLE_SBL_SETUP = 1" is in related BoardConfig.py
   Board.__init__(). For QEMU, the file is located at Platform\QemuBoardPkg\BoardConfig.py.

#. Build Slim Bootloader as normal. ::

     python BuildLoader.py build qemu -k

#. Boot QEMU and enable MicroPython setup payload module launching. ::

     qemu-system-x86_64 -m 256M -cpu max -machine q35 -serial telnet:127.0.0.1:8888,server
     -drive if=pflash,format=raw,file=Outputs\qemu\SlimBootloader.bin -boot order=a

#. Start a telnet console using Putty telnet 127.0.0.1 port 8888 to connect to QEMU.
   Make sure the console screen is set to 100 x 30 with Linux keypad for terminal keyboard.

#. Once booted, it will launch MicroPython first, and then run a python script located at:
   BootloaderCorePkg\Tools\SblSetup.py. A screenshot is captured as below:

.. image:: /images/sbl_setup.jpg


How to Enable MicroPython for Other Platforms
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#. To run MicroPython on other platforms, the similar steps can be followed as QEMU.
   If the intention is to run some other python script other than SblSetup.py,  please
   set "self.ENABLE_PAYLOD_MODULE = 1" instead of "self.ENABLE_SBL_SETUP = 1" in BoardConfig.py.

#. It might be required to define a new container for it if it is not already there.
   Please refer to QEMU BoardConfig.py to see how to define a container for MicroPython.
   Assume the container signature is 'SETP', and it contains the following components::

     MPYM: Required.  MicroPython.efi binary.
     STPY: Required.  MicroPython script file to launch.
     CFGJ: Optional.  Generated CfgDataDef.json file by build. Only required if need to run SblSetup.py.
     CFGD: Optional.  Spare space to store the new CFGDATA. Only required if need to run SblSetup.py.

#. Add SETP.bin container into the Flash layout in non-redundant region. Adjust the the
   region size accordingly so that the build can complete successfully.

#. Add a boot option to boot to MicroPython.
   It can be done using ConfigEditor.py to add new boot option or modify an existing boot option.
   The new boot option in the platform should have the parameters as below ::

     Boot Device Type: Memory
     File System Type: Auto
     Normal OS info  : !SETP/MPYM:STPY

#. MicroPython now can be launched as a standard boot option for Slim Bootloader. ::

     Jumping into FV/PE32 ...

     Starting MicroPython ...
     HASH verification for usage (0x00000000) with Hash Alg (0x2): Success
     Hello world!
     MicroPython v1.12-700-g0e6ef4035 on 2020-09-04; SBL with x86
     >>>
     >>>
     >>
