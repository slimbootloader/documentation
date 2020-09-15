.. _build-tool:

Build Tool
-----------

``BuildLoader.py`` compiles source code with all the *magics* to generate output image(s). It provides two subcommands: build and clean.


You can build |SPN| with the following options:

* Build for a supported target
* Debug or release build
* Use debug image of FSP
* Change your payload files
* Attach a version data structure of your own

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


