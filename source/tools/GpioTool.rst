.. _gpio-convert-tool:

Gpio Tool
---------

``GenGpioData.py`` is a utility that converts the GPIO pin data from one format to other. The formats currently supported are [h, csv, txt, dsc, yaml, dlt]. ``h, csv, txt`` formats are external to |SPN| and ``dsc, yaml, dlt`` formats are known to |SPN|. So, this tool provides a way to convert one of the ``h, csv, txt`` to ``dsc, yaml, dlt`` and vice-versa.

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

* dsc, yaml, dlt::

    Please take a look at your project's dsc, yaml and dlt files for this format.

 - example::

        dsc  :   # !BSF SUBT:{GPIO_TMPL:GPP_A07: 0x031885E1: 0x00070619}

        yaml :   - !expand { CFGHDR_TMPL : [ PSD_CFG_DATA, 0x800, 0, 0 ] }

        dlt  :   GPIO_CFG_DATA.GpioPinConfig0_GPP_A07 | 0x031885E1

                 GPIO_CFG_DATA.GpioPinConfig1_GPP_A07 | 0x00070619

