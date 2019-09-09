.. _configuration-feature:

Configuration
---------------------

Ease of platform and board customization is one of the most important design goal of creating |SPN|. It has many benefits from both system perspective and business use cases. For example,

* By using a centralized configuration infrastructure code, it is easier to manage all configuration related data in all boot stages in the same way
* Because configuration data is *packed* into a central region in |SPN| image, it is easier to customize these changes, or add security protection, or optimize its footprint.
* By defining a standardized human readable configuration format, it is easier to create tools to provide user interface to manage many platform configurations.

After all, |SPN| is designed for embedded systems where a vast diversity of platform settings exists for the same generation of silicon.

Configuration Editor Tool
^^^^^^^^^^^^^^^^^^^^^^^^^^
|SPN| supports Configuration Editor Tool to configure firmware settings with graphics UI. This tool is included in |SPN| source package at /SblOpen/BootloaderCorePkg/Tools.


|SPN| has two sets of configuration data in the image:

Internal configuration data
  Software default values. It is unchangeable once |SPN| is built. In case of external configuration data is not available or corrupted, internal data is loaded instead.

External configuration data
  Platform specific data which is configurable by tools. It can be protected with user provided key.

.. _Configuration Files and Configuration Flow:

One firmware image can support configuration requirements of multiple platforms. To support this, Slim Bootloader solution creates DSC file and DLT file to handle board level differences.

.. image:: /images/Config1.jpg
         :width: 600
         :alt: Install Ubuntu 1 of 5

Configuration Flow
^^^^^^^^^^^^^^^^^^^^^^^^^^
.. image:: /images/Config2.jpg
         :width: 600
         :alt: Install Ubuntu 1 of 5

_DSC File
^^^^^^^^^^^^
* DSC file is the heart of all platform settings including memory, silicon, GPIO, OS boot policy, security settings etc.
* DSC file, in general is located in project specific board folder. 
* For example, you can find DSC file for APL platform under SblOpen\Platform\ApollolakeBoardPkg\CfgData folder.

Please note that you may find many DSC files. However, only CfgDataDef.dsc is the primary file used for the platform configuration, and other sub DSC files will be included by the primary DSC file to provide component specific configuration.

The main platform configuration file is specified in CfgDataDef.dsc.
The following screen shots will help explain. Once DSC file is loaded, all other grayed menu will be enabled.

.. image:: /images/Config3.jpg

_DLT File
^^^^^^^^^^^^^

* DLT (delta) file is used to provide overrides to DSC file to address board-level difference, including GPIO, boot policy, PCIE configuration, security settings etc.
* DLT file contains unique Platform ID, and build tools will apply the settings to firmware images based on the platform ID.

DLT file can be generated in different ways:

* Change any existing settings, and save it to DLT file with Configuration Editor Tool.
* Load values from an existing binary file, and then save the changes as DLT file. 
* Update existing DLT file with other text editor.

Platform is one area that we must take care of. Most of the times, we open the DSC file and DLT file, and then save changes back to DLT file.

To include the DLT file, open Platform/ApollolakeBoardPkg/BoardConfig.py, and add like this:
self._CFGDATA_EXT_FILE    = ['CfgData_Ext_Gpmrb.dlt']


.. _platform-id:


Platform ID
^^^^^^^^^^^^^

.. note:: Platform ID and board ID are used interchangeably in this section

|SPN| uses platform ID to select the associated configuration data. The platform ID can be specified at build time or dynamically detected from GPIO pins at runtime. At the beginning of Stage 1B (``GetBoardIdFromGpioPins()``), |SPN| attempts to load GPIO platform ID by tag ``CDATA_PID_GPIO_TAG``. If the tag is found, the actual platform ID value is read from the GPIO pins. Otherwise, |SPN| uses static platform ID.

|SPN| supports up to 32 platform IDs with 16 allocated for static IDs and 16 for dynamic IDs.

.. note:: Platform ID **0** is reserved value so cannot be used for real board.


Platform Configuration Files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. _static-platform-id:

Static Platform ID Configuration
"""""""""""""""""""""""""""""""""

1. Provide platform ID (1-15) value in board configuration file (``*.dlt``):

.. code::

  PLATFORMID_CFG_DATA.PlatformId                  | 0x7

2. Build |SPN| and stitch IFWI image



.. _dynamic-platform-id:

Dynamic Platform ID Detection
"""""""""""""""""""""""""""""""""

1. Configure designated **4** GPIO pins in board configuration file using |CFGTOOL|.

2. Provide platform ID value (0-15) in board configuration file (``*.dlt``):

.. code::

  PLATFORMID_CFG_DATA.PlatformId                  | 0x9

.. note:: Internally, |SPN| adds 16 to dynamic Platform ID in order not to conflict with static IDs.

3. Build |SPN| and stitch IFWI image


Common Configuration Categories
"""""""""""""""""""""""""""""""""
|SPN| comes with commonly used configurable options for a given platform [#f2]_. One can add new configurations (``Platform/<platform_foo>/CfgData/*.dsc``) and Stage 1B board specific code (``Platform/<platform_foo>/Library/Stage1BBoardInitLib/``)

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

.. rubric:: Footnotes

.. [#f2] |APL| code includes various validated configuration options supporting |UP2| board.
