Tools
=======

|SPN| provides the development tools to support building, stitching and configuring the output images.

.. _build-tool:

Build Command
---------------

``BuildLoader.py`` compiles source code with all the *magics* to generate output image(s) with *slim* footprint. It provides two subcommands: build and clean.


You can build |SPN| with the following options:

* Build for a supported target
* Debug or release build
* Use debug image of FSP
* Change your payload files
* Attach a version data structure of your own

Command Syntax::

    python BuildLoader.py <subcommand> <target> <options>

    <subcommand>  : build or clean
    <target>      : board name (e.g. apl or qemu)


Windows and Linux share the same command line options as follows. For example, for ``build`` subcommand::

    usage: BuildLoader.py build [-h] [-r] [-v] [-fp FSPPATH] [-fd] [-p PAYLOAD] board

    positional arguments:
    board                 Board Name (apl, qemu)

    optional arguments:
      -h, --help                      Show this help message and exit
      -r, --release                   Release build
      -v, --usever                    Use board version file
      -fp FSPPATH                     FSP binary path relative to FspBin in Silicon folder
      -fd, --fspdebug                 Use debug FSP binary
      -p PAYLOAD, --payload PAYLOAD   Payload file name


For a list of platforms supported::

  pthon BuildLoader.py build -h


If build is successful, ``Outputs`` folder will contain the build binaries. One of the output files will be ``Stitch_Components.zip`` which will be used in the stitching step.


|SPN| supports a single image supporting up to 32 board configurations for the same type of board or platform. To add multi-board support, see :ref:`configuration-feature`.


.. _ias-tool:

IAS Tool
----------

``iasimage`` is a utility for creating Intel Automotive Service (IAS) images in a binary file format understood by |SPN| to load and initialize Operating Systems or Hypervisors.

This tool is available on GitHub: |https://github.com/intel/iasimage|

.. |https://github.com/intel/iasimage| raw:: html

   <a href="https://github.com/intel/iasimage" target="_blank">https://github.com/intel/iasimage</a>


.. _gen-container-tool:

Container Tool
--------------

``GenContainer.py`` is a tool used to generate the container images in a binary file format.

A container is an encapsulation of multiple components as depicted in the following image:

.. image:: /images/Cont.PNG
   :alt: Container structure

Following operations are supported::

    usage: GenContainer.py [-h] {view,create,extract,replace,sign} ...

    positional arguments:
      {view,create,extract,replace,sign}
                            command
        view                display a container image
        create              create a container image
        extract             extract a component image
        replace             replace a component image
        sign                compress and sign a component image

    optional arguments:
      -h, --help            show this help message and exit

* view::

    usage: GenContainer.py view [-h] -i IMAGE

    optional arguments:
      -h, --help  show this help message and exit
      -i IMAGE    Container input image

 - example::

    python GenContainer.py view -i ContainerImage.bin

* create::

    usage: GenContainer.py create [-h] (-l LAYOUT | -cl COMP_LIST [COMP_LIST ...])
                                  [-t IMG_TYPE] [-o OUT_PATH] [-k KEY_PATH]
                                  [-cd COMP_DIR] [-td TOOL_DIR]

    optional arguments:
      -h, --help            show this help message and exit
      -l LAYOUT             Container layout intput file if no -cl
      -cl COMP_LIST [COMP_LIST ...]
                            List of each component files, following XXXX:FileName format
      -t IMG_TYPE           Container Image Type : [NORMAL, CLASSIC, MULTIBOOT]
      -o OUT_PATH           Container output directory/file
      -k KEY_PATH           Input key directory/file
      -cd COMP_DIR          Componet image input directory
      -td TOOL_DIR          Compression tool directory

 - example::

    python GenContainer.py create -cl CMDL:cmdline.txt KRNL:vmlinuz INRD:initrd -o Out

    or

    python GenContainer.py create -l layout.txt -o Out

.. note::

    layout.txt can look like following::

      # Container Layout File
      #
      #    Name ,  ImageFile      ,CompAlg  ,  AuthType,       KeyFile                 , Alignment,  Size
      # ===================================================================================================
        ( 'BOOT', 'Out'           , ''      , 'RSA2048', 'TestSigningPrivateKey.pem'   ,  0x10,       0),  <--- Container Hdr
        ( 'CMDL', 'cmdline.txt'   , 'Lz4'   , 'RSA2048', 'TestSigningPrivateKey.pem'   ,  0,          0),  <--- Component Entry 1
        ( 'KRNL', 'vmlinuz'       , 'Lz4'   , 'RSA2048', 'TestSigningPrivateKey.pem'   ,  0,          0),  <--- Component Entry 2
        ( 'INRD', 'initrd'        , 'Lz4'   , 'RSA2048', 'TestSigningPrivateKey.pem'   ,  0x1000,     0),  <--- Component Entry 3
        ( '_SG_', ''              , 'Dummy' , 'SHA2_256',''                            ,  0,          0),  <--- _SG_ MONO SIGN Component

    If you provide the full path or a file/dir name to output or key, in both layout.txt and command line,
    command line options will always overwrite the values in layout.txt.


* extract::

    usage: GenContainer.py extract [-h] -i IMAGE [-n COMP_NAME] [-od OUT_DIR]
                                  [-td TOOL_DIR]

    optional arguments:
      -h, --help    show this help message and exit
      -i IMAGE      Container input image path
      -n COMP_NAME  Component name to extract
      -od OUT_DIR   Output directory
      -td TOOL_DIR  Compression tool directory
 
 - example::

    python GenContainer.py extract -i ContainerImage.bin -od ExtDir

* replace::

    usage: GenContainer.py replace [-h] -i IMAGE [-o NEW_NAME] -n COMP_NAME -f
                                  COMP_FILE [-c {lz4,lzma,dummy}] [-k KEY_FILE]
                                  [-od OUT_DIR] [-td TOOL_DIR]

    optional arguments:
      -h, --help           show this help message and exit
      -i IMAGE             Container input image path
      -o NEW_NAME          Container new output image name
      -n COMP_NAME         Component name to replace
      -f COMP_FILE         Component input file path
      -c {lz4,lzma,dummy}  compression algorithm
      -k KEY_FILE          Private key file path to sign component
      -od OUT_DIR          Output directory
      -td TOOL_DIR         Compression tool directory

 - example::

    python GenContainer.py replace -i ContainerImage.bin -od Out -n CMDL -f new_cmdline.txt

* sign::

    usage: GenContainer.py sign [-h] -f COMP_FILE [-o SIGN_FILE]
                                [-c {lz4,lzma,dummy}] [-a {rsa2048,sha256,none}]
                                [-k KEY_FILE] [-od OUT_DIR] [-td TOOL_DIR]

    optional arguments:
      -h, --help            show this help message and exit
      -f COMP_FILE          Component input file path
      -o SIGN_FILE          Signed output image name
      -c {lz4,lzma,dummy}   compression algorithm
      -a {rsa2048,sha256,none}
                            authentication algorithm
      -k KEY_FILE           Private key file path to sign component
      -od OUT_DIR           Output directory
      -td TOOL_DIR          Compression tool directory

 - example::

    python GenContainer.py sign -f <ComponentImage/ContainerImage.bin> -c lz4 -td <path-to-Lz4Compress.exe>


.. _gpio-convert-tool:

Gpio Tool
---------

``GenGpioData.py`` is a utility that converts the GPIO pin data from one format to other. The formats currently supported are [h, csv, txt, dsc, dlt]. ``h, csv, txt`` formats are external to |SPN| and ``dsc, dlt`` formats are known to |SPN|. So, this tool provides a way to convert one of the ``h, csv, txt`` to ``dsc, dlt`` and vice-versa.

Each of the above mentioned formats is as follows:

* h::

    This format expects an instance of the following GPIO_INIT_CONFIG structure:

    typedef struct {
        UINT32 PadMode          : 5;
        UINT32 HostSoftPadOwn   : 2;
        UINT32 Direction        : 6;
        UINT32 OutputState      : 2;
        UINT32 InterruptConfig  : 9;
        UINT32 PowerConfig      : 8;
        UINT32 ElectricalConfig : 9;
        UINT32 LockConfig       : 4;
        UINT32 OtherSettings    : 9;
        UINT32 RsvdBits         : 10;
    } GPIO_CONFIG;

    typedef struct {
        CHAR8          *GpioPad;
        GPIO_CONFIG     GpioConfig;
    } GPIO_INIT_CONFIG;

 - example::

    static GPIO_INIT_CONFIG mGpioTable[] =
    {
        // GpioPad        Pmode            GPI_IS        GpioDir    GPIOTxState      RxEvCfg/GPIRoutConfig        PadRstCfg            Term           LockConfig
        {  GPP_A7,  { GpioPadModeGpio, GpioHostOwnGpio, GpioDirIn, GpioOutDefault, GpioIntLevel | GpioIntApic, GpioHostDeepReset, GpioTermWpu20K, GpioPadConfigUnlock }},
    };

.. note::

    ``GpioPad`` should follow the below rule::

        GPP_<group_name><pad_num>

        group_name = A single letter describing the group for this pad

        pad_num    = Pad Number inside the group

    Each of the GPIO pad config fields can take the values as given below (these are common across all formats)::

         typedef enum = {
            GpioHardwareDefault     = 0x0,
            GpioPadModeGpio         = 0x1,
            GpioPadModeNative1      = 0x3,
            GpioPadModeNative2      = 0x5,
            GpioPadModeNative3      = 0x7,
            GpioPadModeNative4      = 0x9,
            GpioPadModeNative5      = 0xB,
        } GPIO_PAD_MODE;

        typedef enum = {
            GpioHostOwnDefault      = 0x0,
            GpioHostOwnAcpi         = 0x1,
            GpioHostOwnGpio         = 0x3,
        } GPIO_HOSTSW_OWN;

        typedef enum = {
            GpioDirDefault          = 0x0,
            GpioDirInOut            = (0x1 | (0x1 << 3)),
            GpioDirInInvOut         = (0x1 | (0x3 << 3)),
            GpioDirIn               = (0x3 | (0x1 << 3)),
            GpioDirInInv            = (0x3 | (0x3 << 3)),
            GpioDirOut              = 0x5,
            GpioDirNone             = 0x7,
        } GPIO_DIRECTION;

        typedef enum = {
            GpioOutDefault          = 0x0,
            GpioOutLow              = 0x1,
            GpioOutHigh             = 0x3,
        } GPIO_OUTPUT_STATE;

        typedef enum = {
            GpioIntDefault          = 0x0,
            GpioIntDis              = 0x1,
            GpioIntNmi              = 0x3,
            GpioIntSmi              = 0x5,
            GpioIntSci              = 0x9,
            GpioIntApic             = 0x11,
            GpioIntLevel            = (0x1 << 5),
            GpioIntEdge             = (0x3 << 5),
            GpioIntLvlEdgDis        = (0x5 << 5),
            GpioIntBothEdge         = (0x7 << 5),
        } GPIO_INT_CONFIG;

        typedef enum = {
            GpioResetDefault        = 0x00,
            GpioResumeReset         = 0x01,
            GpioHostDeepReset       = 0x03,
            GpioPlatformReset       = 0x05,
            GpioDswReset            = 0x07,
        } GPIO_RESET_CONFIG;

        typedef enum = {
            GpioTermDefault         = 0x0,
            GpioTermNone            = 0x1,
            GpioTermWpd5K           = 0x5,
            GpioTermWpd20K          = 0x9,
            GpioTermWpu1K           = 0x13,
            GpioTermWpu2K           = 0x17,
            GpioTermWpu5K           = 0x15,
            GpioTermWpu20K          = 0x19,
            GpioTermWpu1K2K         = 0x1B,
            GpioTermNative          = 0x1F,
        } GPIO_ELECTRICAL_CONFIG;

        typedef enum = {
            GpioLockDefault         = 0x0,
            GpioPadConfigUnlock     = 0x3,
            GpioPadConfigLock       = 0x1,
            GpioOutputStateUnlock   = 0xC,
            GpioPadUnlock           = 0xF,
            GpioPadLock             = 0x5,
        } GPIO_LOCK_CONFIG;

* csv::

    This format expects Gpio pad config info in the following order:

        GpioPad, PadMode, HostSoftPadOwn, Direction, OutputState, InterruptConfig, PowerConfig, ElectricalConfig, LockConfig

 - example::

    GPP_A7,GpioPadModeGpio,GpioHostOwnGpio,GpioDirIn,GpioOutDefault,GpioIntLevel|GpioIntApic,GpioHostDeepReset,GpioTermWpu20K,GpioPadConfigUnlock

* txt::

    This format is used when the Pad Config DWords are read/programmed from/to the GPIO Community registers on the platform.

        GpioPad:<host_sw_own>:<pad_cfg_lock>:<pad_cfg_lock_tx>:<pad_cfg_dw0>:<pad_cfg_dw1>

    host_sw_own     = Value of the HostSoftPadOwnership register that contains this pin

    pad_cfg_lock    = Value of the PadConfigurationLock register that contains this pin

    pad_cfg_lock_tx = Value of the PadConfigurationLockTxState register that contains this pin

    pad_cfg_dw0     = Value of the PadConfigurationDw0 register for this pin

    pad_cfg_dw1     = Value of the PadConfigurationDw1 register for this pin

 - example::

    GPP_A07:0x0001A880:0x01FCF77F:0x01FE5FFF:0x40100102:0x0000301F

* dsc, dlt::

    Please take a look at your project's dsc and dlt files for this format.

 - example::

        dsc :   # !BSF SUBT:{GPIO_TMPL:GPP_A07: 0x031885E1: 0x00070619}

        dlt :   GPIO_CFG_DATA.GpioPinConfig0_GPP_A07 | 0x031885E1

                GPIO_CFG_DATA.GpioPinConfig1_GPP_A07 | 0x00070619

.. _stitch-tool:

Stitch Tool
----------------

``StitchLoader.py`` is a utility to replace |SPN| image in a fully flashable IFWI image. It takes all system firmware components from a working IFWI image and replace the BIOS region with |SPN| components.

This tool is used to create two output files:

* IFWI image with SBL (-o option).
* |SPN| BIOS image for capsule update (-b option). See :ref:`update-firmware`.


The command line options to perform stitching::

  usage: StitchLoader.py [-h] -i IFWI_IN [-o IFWI_OUT] [-b BIOS_OUT]
                         [-s STITCH_IN] [-p PLAT_DATA]

  optional arguments:
    -h, --help            show this help message and exit
    -i IFWI_IN, --input-ifwi-file IFWI_IN
                          Specify input template IFWI image file path
    -o IFWI_OUT, --output-ifwi-file IFWI_OUT
                          Specify generated output IFWI image file path
    -b BIOS_OUT, --output-bios-region BIOS_OUT
                          Specify generated output BIOS region image file path
    -s STITCH_IN, --sitch-zip-file STITCH_IN
                          Specify input sitching zip package file path
    -p PLAT_DATA, --platform-data PLAT_DATA
                          Specify a platform specific data (HEX, DWORD) for
                          customization

**PLAT_DATA** is a DWORD containing platform data to configure debug UART port number. Format is defined below::

  typedef struct {
    UINT8               PlatformId : 5;    /* Platform ID      */
    UINT8               Reserved1  : 3;
    UINT8               DebugUart  : 2;    /* UART port index */
    UINT8               Reserved2  : 6;
    UINT8               Reserved3;
    UINT8               Marker;            /* 'AA'            */
  } STITCH_DATA;



IFWI Image vs. |SPN| BIOS Image  
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

IFWI image is used as input to program SPI flash on the hardware, while |SPN| BIOS image is used as input file to create firmware update capsule image.


.. _configuration-tool:

|CFGTOOL|
--------------------

``ConfigEditor.py`` is a GUI program provided in |SPN| to allow user to customize board specific settings. You will need this tool in porting or customizing a new board. It provides features to load a platform configuration file (``*.dsc``) and generate board configuration delta file (``*.dlt``). This tool can be used in pre-build or post-build process.

This tool depends on Python GUI tool kit **Tkinter**. It runs on both Windows and Linux.

Running |CFGTOOL|::

    python BootloaderCorePkg/Tools/ConfigEditor.py

