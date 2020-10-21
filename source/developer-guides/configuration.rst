.. _configuration-feature:

Configuration
---------------------

Ease of platform and board customization is one of the most important design goal of creating |SPN|. It has many benefits from both system perspective and business use cases. For example,

* By using a centralized configuration infrastructure code, it is easier to manage all configuration related data in all boot stages in the same way
* Because configuration data is *packed* into a central region in |SPN| image, it is easier to customize these changes, or add security protection, or optimize its footprint.
* By defining a standardized human readable configuration format, it is easier to create tools to provide user interface to manage many platform configurations.


|SPN| has two sets of configuration data in the image

**Internal configuration data**
  Software default values. It is unchangeable once |SPN| is built. In case of external configuration data is not available or corrupted, internal data is loaded instead.


**External configuration data**
  Platform specific data which is configurable by tools. It can be protected with user provided key.


|SPN| configuration infrastructure includes the following and is designed to support multiple boards with one firmware image. 

* Configuration declarations in YAML files
* Configuration deltas in DLT files
* Configuration tools


.. _Configuration Files and Configuration Flow:


YAML Files
^^^^^^^^^^^^
* All platform configuration settings including memory, silicon, GPIO, OS boot policy, security settings etc are declared in a custom format and uses YAML Syntax 
  (:ref:`configuration-spec`).
* YAML configuration files, in general are located in project specific board folder, while some common configuration files are located at Platform\CommonBoardPkg\CfgData. 
* For example, you can find the configuration files for Apollo Lake platform under Platform\ApollolakeBoardPkg\CfgData folder.

Please note that you may find many YAML files. However, only CfgDataDef.yaml is the primary file used for the platform configuration, and other sub YAML files will be 
included by the primary YAML file to provide component specific configuration.

The main platform configuration file is specified in CfgDataDef.yaml. An example configuration file in YAML syntax is provided below.

.. image:: /images/ConfigDefYaml.PNG


DLT Files
^^^^^^^^^^^^^

* DLT (delta) files are used to provide overrides to settings in YAML files to address board-level differences, including GPIO, boot policy, PCIE configuration, security settings etc.
* DLT files contain unique Platform ID, and build tools will apply the settings to firmware images based on the platform ID.
* DLT file that overrides configuration parameters for all boards (board id 0) is also supported. A typical use case is in case of Platform ID as explained below.

DLT file can be generated in different ways:

* Change any existing settings, and save it to DLT file with Configuration Editor Tool.
* Load values from an existing binary file, and then save the changes as DLT file. 

A project may include multiple DLT files to handle multiple boards and are included in the project's BoardConfig.py file as below. 
self._CFGDATA_EXT_FILE    = ['CfgData_Ext_Def.dlt', 'CfgData_Ext_Gpmrb.dlt']

.. image:: /images/ConfigDlt.PNG


Configuration Flow
^^^^^^^^^^^^^^^^^^^^^^^^^^
.. image:: /images/ConfigFlow.PNG


During |SPN| build, the configuration data in the YAML files are parsed by the configuration tools to generate the header files as well as the configuration binary. 
In addition to generating and stitching of configuration binaries through |SPN| build process, editing of configuration parameters post build is also supported.

Post-build configuration update can be done with the project's configuration YAML/DLT files and the updated configuration binary can be restitched without having to rebuild |SPN|
project. Please see :ref:`config-steps` for details.

All the configuration tools required by the configuration process can be found under BootloaderCorePkg/Tools folder.



Configuration Editor Tool
^^^^^^^^^^^^^^^^^^^^^^^^^^
|SPN| supports a Configuration Editor Tool (ConfigEditor.py) to configure firmware settings with graphics UI. This tool is included in |SPN| source package at BootloaderCorePkg/Tools.

.. image:: /images/CfgEditOpen.png

.. image:: /images/CfgEditDefYaml.png


.. _platform-id:

Platform ID
^^^^^^^^^^^^^

.. note:: Platform ID and board ID are used interchangeably in this section

|SPN| uses platform ID to select the associated configuration data. The platform ID can be specified at build time or dynamically detected from GPIO pins at runtime. At the beginning of Stage 1B (``GetBoardIdFromGpioPins()``), |SPN| attempts to load GPIO platform ID by tag ``CDATA_PID_GPIO_TAG``. If the tag is found, the actual platform ID value is read from the GPIO pins. Otherwise, |SPN| uses static platform ID.

|SPN| supports up to 32 platform IDs. Note that Platform ID **0** served to carry the default CFGDATA values defined in the CfgDataDef.yaml file. So it cannot be used for a real board. So technically, SBL can support upto 31 boards.

.. note:: In addition to board specific delta files, a DLT file that overrides configuration parameters for all boards (board id 0) is also supported. If platform ID needs to be configurable without source, DLT file for board ID 0 is required. This is useful when common board settings are to be changed without changing the platform configuration YAML file.



Platform Configuration Files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. _static-platform-id:

Platform ID Configuration
"""""""""""""""""""""""""""""""""

Provide platform ID (1-15) value in board configuration file (``*.dlt``):

.. code::

  PLATFORMID_CFG_DATA.PlatformId                  | 0x7


.. _dynamic-platform-id:

Platform ID Detection using GPIOs
""""""""""""""""""""""""""""""""""""""""""

1. Configure designated **4** GPIO pins in board configuration file using |CFGTOOL|.

2. Provide platform ID value (0-15) in board configuration file (``*.dlt``):

.. code::

  PLATFORMID_CFG_DATA.PlatformId                  | 0x9

.. note:: Internally, |SPN| adds 16 to Platform ID detected using GPIOs in order not to conflict with static IDs.


Common Configuration Categories
"""""""""""""""""""""""""""""""""
|SPN| comes with commonly used configurable options for a given platform. One can add new configurations (``Platform/<platform_foo>/CfgData/*.yaml``) and Stage 1B board specific code (``Platform/<platform_foo>/Library/Stage1BBoardInitLib/``)

Configuration data are grouped by categories:

* GPIO
* Memory and eMMC tuning
* Graphics related
* Device related (USB, eMMC etc)
* Security
* Boot options
* Feature related (e.g., log level)
* ...

Configuration data is loaded and verified in Stage1B. Once loaded, |SPN| groups related configuration item by *tags* and the data can be retrieved by calling function ``FindConfigDataByTag()``. For example, ``CDATA_USB_TAG``.


.. _config-steps:

Step-by-step Configuration Flow
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Users will need to have the following prerequisites to begin the flow.

Files
"""""

-  Top-level YAML file, CfgDataDef.yaml, and Internal/External .DLT files.

-  Default configuration data, CfgDataInt.bin and/or CfgData_Default.dlt

-  RSA key file.

Tools
"""""

-  CfgDataStitch.py, CfgDataTool.py, ConfigEditor.py, GenCfgData.py

Process
"""""""

**Load:**

Open *ConfigEditor* GUI tool, ConfigEditor.py.

Load top-level CfgDataDef.yaml file. Now the platform settings with
default values are shown in the *ConfigEditor*.

Load board-specific DLT file (e.g., CfgData_Ext_Up2.dlt, and so on).
Once this is loaded, *ConfigEditor* will display the overwritten values
as specified in the DLT file.

**Change values:**

If user choose to change additional settings, it can be done at this
time either in the DLT file directly or using *ConfigEditor*. For a
different platform, make sure to set/modify the platform ID value
accordingly. Then save the changes back into the DLT file (or) it can
also be saved as a binary file using *ConfigEditor*. New DLT file or new
binary that is created will then have the newly changed settings.

**Stitch into final image:**

Open a command window and cd into the location of the CfgDataStitch.py
folder.

Run this Python\* script in the command window: **CfgDataStitch.py -h**
for parameters for this script.

Example::

  python CfgDataStitch.py -i sbl_ifwi_old.bin -k ConfigTestKey_Priv_RSA3072.pem -s SblOpen\BootloaderCorePkg\Tools -c . -o sbl_ifwi_patched.bin -p <<platform ID>>

Once the above script is run successfully, the new configuration data is
patched and the new IFWI image has been created.

**Boot:**

Users can now flash the new image that contains the changed
configuration values onto the board, then boot to SBL shell and check
boot options that are changed with the new values.


.. Note:: An example pre build configuration flow to configure GPIOs can be found here https://slimbootloader.github.io/how-tos/configure_gpio.html#gpio-config-data

.. Note:: An example post build configuration flow to configure Boot Options can be found here https://slimbootloader.github.io/how-tos/change-boot-option.html#change-at-post-build-time



Example Console Outputs
"""""""""""""""""""""""""

External configuration data for board (platform 1) is loaded::

  ============= Intel Slim Bootloader STAGE1B =============
  ...
  BoardID: 0001
  Load External Cfg data...BIOS
  Load EXT CFG Data @ 0xFEF05FF8:0x0080 ... Success
  HASH Verification Success! Component Type (4)
  RSA Verification Success!
  ...
  Load Security Cfg Data
  ...
  Load Memory Cfg Data
  ...
  Load Graphics Cfg Data
  ...

