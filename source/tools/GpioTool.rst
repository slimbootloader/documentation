.. _gpio-convert-tool:

Gpio Data Convert Tool
----------------------

``GenDataConvert.py`` is a utility that converts the GPIO pin data from one format to other. The formats currently supported are [h, csv, txt, yaml, dlt]. ``h, csv, txt`` formats are external to |SPN| and ``yaml, dlt`` formats are known to |SPN|. So, this tool provides a way to convert one of the ``h, csv, txt`` to one of ``yaml, dlt`` and vice-versa.

* Usage::

    usage:  GpioDataConvert.py [-h]
            -if INP_FMT
            -cf CFG_FILE
            -of {yaml,dlt,h,csv,txt}
            [-o OUT_PATH]
            [-t {old,new}]
            -p {def,h,lp,s,p}

    -if     Input data file, must have [yaml, dlt] or [h , csv, txt] file extension
    -cf     Config file containing inputs like Group Info(dict with name & index in GPIO_GROUP_INFO in Gpio Lib code)
    -of     Output SBL format, either [h, csv, txt] or [yaml, dlt]
    -o      Output directory/file
    -t      Determine the GPIO template format. For new platforms, please use new format.
    -p      PCH series to get the correct gpio group info

.. note::

    Refer to last section in this page for additional porting info.

Each of the previously mentioned supported formats is as follows:

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

* yaml, dlt::

    Please take a look at your project's yaml and dlt files for this format.

 - example::

        yaml :   - !expand { GPIO_TMPL : [ GPP_A00, 0x0350A3A3,  0x0000221F ] }

        dlt  :   GPIO_CFG_DATA.GpioPinConfig0_GPP_A07 | 0x031885E1

                 GPIO_CFG_DATA.GpioPinConfig1_GPP_A07 | 0x00070619



Additional Porting Info
^^^^^^^^^^^^^^^^^^^^^^^^

While using the tool for gpio pin data creation for a new platform, a GpioDataConfig.py (-cf CFG_FILE) file needs to be created. See the example of a similar config file for an existing platform. This input config file must have a grp_info_*** dictionary. To create this dictionary:

First, locate the GPIO_GROUP_INFO table from the GpioSiLib.c (must be created prior to this) for the new platform.

 - example::

    GLOBAL_REMOVE_IF_UNREFERENCED GPIO_GROUP_INFO mPchLpGpioGroupInfo[] = {
    {PID_GPIOCOM0, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_PAD_OWN,  R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_HOSTSW_OWN,  R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_GPI_IS, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_GPI_IE, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_GPI_GPE_STS, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_GPI_GPE_EN, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_SMI_STS, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_SMI_EN, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_NMI_STS, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_NMI_EN, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_PADCFGLOCK,  R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_PADCFGLOCKTX,   R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_B_PADCFG_OFFSET,  GPIO_VER2_PCH_LP_GPIO_GPP_B_PAD_MAX}, //TGL PCH-LP GPP_B
    {PID_GPIOCOM0, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_T_PAD_OWN,  R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_T_HOSTSW_OWN,  R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_T_GPI_IS, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_T_GPI_IE, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_T_GPI_GPE_STS, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_T_GPI_GPE_EN, NO_REGISTER_FOR_PROPERTY,            NO_REGISTER_FOR_PROPERTY,           NO_REGISTER_FOR_PROPERTY,            NO_REGISTER_FOR_PROPERTY,           R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_T_PADCFGLOCK,  R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_T_PADCFGLOCKTX,   R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_T_PADCFG_OFFSET,  GPIO_VER2_PCH_LP_GPIO_GPP_T_PAD_MAX}, //TGL PCH-LP GPP_T
    {PID_GPIOCOM0, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_A_PAD_OWN,  R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_A_HOSTSW_OWN,  R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_A_GPI_IS, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_A_GPI_IE, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_A_GPI_GPE_STS, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_A_GPI_GPE_EN, NO_REGISTER_FOR_PROPERTY,            NO_REGISTER_FOR_PROPERTY,           NO_REGISTER_FOR_PROPERTY,            NO_REGISTER_FOR_PROPERTY,           R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_A_PADCFGLOCK,  R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_A_PADCFGLOCKTX,   R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_A_PADCFG_OFFSET,  GPIO_VER2_PCH_LP_GPIO_GPP_A_PAD_MAX}, //TGL PCH-LP GPP_A
    {PID_GPIOCOM5, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_R_PAD_OWN,  R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_R_HOSTSW_OWN,  R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_R_GPI_IS, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_R_GPI_IE, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_R_GPI_GPE_STS, R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_R_GPI_GPE_EN, NO_REGISTER_FOR_PROPERTY,            NO_REGISTER_FOR_PROPERTY,           NO_REGISTER_FOR_PROPERTY,            NO_REGISTER_FOR_PROPERTY,           R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_R_PADCFGLOCK,  R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_R_PADCFGLOCKTX,   R_GPIO_VER2_PCH_LP_GPIO_PCR_GPP_R_PADCFG_OFFSET,  GPIO_VER2_PCH_LP_GPIO_GPP_R_PAD_MAX}, //TGL PCH-LP GPP_R
    };

Each key to the grp_info_*** dictionary will be the string 'GPP_*', where '*' is the group (gpio group's name) that is being referred to in the above table's each row.

 - example::

    GPP_B is a key coming from above table's first  entry.
    GPP_T is a key coming from above table's second entry.
    ...

Value for each 'key' (GPP_*) will be the index of the group info entry for group '*' in the above table.

 - example::

    grp_info_***[GPP_B] = 0.
    grp_info_***[GPP_T] = 1.
    ...

Final dictionary looks like:

 - example::

    grp_info_lp = {
    # Grp     Index
    'GPP_B' : [ 0x0],
    'GPP_T' : [ 0x1],
    'GPP_A' : [ 0x2],
    'GPP_R' : [ 0x3],
    }
