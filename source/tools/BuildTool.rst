.. _build-tool:

Build Tool
-----------

Introduction
^^^^^^^^^^^^

``BuildLoader.py`` compiles source code with all the *magics* to generate output image(s). It provides two subcommands: build and clean.


You can build |SPN| with the following options:

* Build for a supported target
* Debug or release build
* Use debug image of FSP
* Change your payload files
* Attach a version data structure of your own

Usage
^^^^^

Command Syntax::

    python BuildLoader.py <subcommand> <target> <options>

    <subcommand>  : build or build_dsc or clean
    <target>      : board name (e.g. apl, qemu, etc.)


Windows and Linux share the same command line options as follows. For example, for ``build`` subcommand::

    usage: BuildLoader.py build [-h] [-r] [-v] [-fp FSPPATH] [-fd] [-p PAYLOAD] board

    positional arguments:
    board                 Board Name (apl, qemu, etc.)

    optional arguments:
      -h, --help                      Show this help message and exit
      -r, --release                   Release build
      -v, --usever                    Use board version file
      -fp FSPPATH                     FSP binary path relative to FspBin in Silicon folder
      -fd, --fspdebug                 Use debug FSP binary
      -p PAYLOAD, --payload PAYLOAD   Payload file name


For a list of platforms supported::

  python BuildLoader.py build ?


If build is successful, ``Outputs`` folder will contain the build binaries. One of the output files will be ``Stitch_Components.zip`` which will be used in the stitching step.


|SPN| supports a single image supporting up to 32 board configurations for the same type of board or platform. To add multi-board support, see :ref:`configuration-feature`.

Working
^^^^^^^

The overall flow of the build process is shown below:

* Environment initialization
* Early build initialization

  * Toolchains and dependencies are verified
  * BaseTools are compiled

* Board build hook: ``pre-build: before``

  * Create build directory
  * Generate dlt file from CfgData

* Pre-build:

  * Make sure SBL signing keys exist
  * Build or grab FSP
  * Create Firmware Interface Table (FIT)
  * Create Bootloader Version Info file
  * Create VBT
  * Create DSC file for build
  * Rebase FSP
  * Create config data
  * Build reset vector // Note - clarify

* Board build hook: ``pre-build:after``

  * User can specify if any processing needs to be done at this point and can add relevant functionality to this build hook

* Call EDK-II's ``build`` command

* Board build hook: ``post-build: before``

  * User can specify if any processing needs to be done at this point and can add relevant functionality to this build hook

* Post-build:

  * Generate binaries for:

    * UEFI Variable Storage
    * ACM and Diagnostic ACM
    * MRC Training Data
    * Bootloader Variable storage
    * Microcode
    * Payload and EPayload
    * FW Update

  * Generate container images
  * Patch stages
  * Create redundant components
  * Stitch

* Board build hook: ``post-build: after``

  * User can specify if any processing needs to be done at this point and can add relevant functionality to this build hook