.. _firmware-update:

Firmware Update
------------------

|SPN| implements a secure and power fail-safe firmware update mechanism.

  * |SPN| image is designed to contain redundant boot components and depends on hardware assisted boot partition switch to support fail-safe update.

  * Firmware update code is implemented as |SPN| payload.

  * |SPN| detects firmware update signal and launches firmware udpate payload.

  * Firmware update code will authenticate the capsule image before proceeding with firmware update.

  * Firmware update code maintains a state machine to keep track of the update progress. State machine is persistent across power cycles.

  * |SPN| uses redundant boot partitions to recover and complete firmware update incase of a power failure.

|SPN| supports independent update of BIOS and CSME regions of IFWI. Update of external configuration data is also supported.

An overview of high level flow is provided below

  **Step 1:**  Firmware Update capsule will be copied to designated location. This location is configurable through |SPN| configuration options.

  **Step 2:**  Firmware update is triggered from |SPN| shell or from Operating system and followed by system reset.

  **Step 3:**  |SPN| detects firmware update signal and sets platform into firmware update mode.

  **Step 4:**  Stage 2 code identifies firmware update mode and loads firmware update payload to start update flow.

  **Step 5:**  Firmware Update payload gathers capsule image from selected media and verifies capsule data. If successful, continues with firmware update

  **Step 6:**  Firmware update payload initializes state machine and identifies the update images in the capsule.

  **Step 7:**  Loop through and update each firwmare identified in the capsule image.

     #. Record update status after each firmware update.
     #. If the firmware is requesting reset after update, reset the system to continue updating other firmwares in the capsule.
     #. Slimbootloader firmware update involves the following steps
          #. Update partition B
          #. Set partition B as 'active'
          #. Reboot
          #. Boot from partition B
          #. Set partition A as 'active'
          #. Reboot

    In case of a power failure, firmware update payload will use the state machine to continue from the interrupted state.

  **Step 8:**  Once all the firmwares in the capsule are updated.

         #. Set state machine to init state, which indicates firmware update is completed.
         #. Terminate firmware update
         #. Reset system to continue booting to operating system.

.. _generate-capsule:

Generating capsule
***********************************

After gathering required firmware binaries, capsule image can be generated using capsule generation tool. Please refer to :ref:`generate-binaries-for-capsule` for details about generating component binaries for capsule.

  Capsule tool (``GenCapsuleFirmware.py``) creates a capsule image that can be processed by |SPN| in firmware update flow.

  Capsule tool is capable of incorporating multiple firmware images into single capsule binary. Each firmware is identified and included in the capsule image using a 4 byte string. While using the tool for capsule generation, Unique string identifier and associated binary should be provided as input to the tool.

  For components inside the container region <4 byte id for component inside container : 4 byte id container id> along with associated component binary should be provided as input to the tool. This format is required for components inside container region because there can be multiple container inside BIOS region

    usage: GenCapsuleFirmware.py [-h] -p <4 byte comp id> < FW IMAGE BINARY > -p <4 byte container component string id:4 byte comp id> <FW IMAGE BINARY> -p <4 byte comp id> <FW IMAGE BINARY n> -k PRIVKEY -o NEWIMAGE [-q]

    optional arguments:
      -h, --help            show this help message and exit
      -p  <4 byte string> <Payload Image>, 
                            Payload image that goes into firmware update capsule
      -k PRIVKEY, --priv_key PRIVKEY
                            KEY_ID or RSA 2048/3072 private key path in PEM format to sign image.
                            Use 'KEY_ID_FIRMWAREUPDATE_RSA2048/KEY_ID_FIRMWAREUPDATE_RSA3072' for KEY_ID
      -o NEWIMAGE, --output NEWIMAGE
                            Output file for signed image
      -q, --quiet           without output messages or temp files

  For example, the following command generates a capsule image (``FwuImage.bin``) containing an IFWI image (``sbl.bios.bin``), CSME image (``csme.bin``), CSME Firmware Update Driver (``csme_fw_update_driver.bin``) and container component TSN MAC address inside container IPFW (``tsnmacaddr.bin``) signed by key ``FirmwareUpdateTestKey_Priv_RSA2048.pem``::

    $ python ./BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS sbl.bios.bin -p CSME  csme.bin -p CSMD csme_fw_update_driver.bin -p TMAC:IPFW tsnmacaddr.bin -k $SBL_KEY_DIR/FirmwareUpdateTestKey_Priv_RSA2048.pem -o FwuImage.bin
    Successfully signed Bootloader image!
    $

  SBL_KEY_DIR is path to SblKeys directory used on |SPN|.

Component ID String
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section explains how to determine 4 byte string identifier for each of updatable components used in |SPN|

If the updatable component is part of flash map, 4 byte string identifying the component should be the component id from flash map. During the runtime, firmware update payload will look for this 4 byte string in the flash map, if found, it will update the component.

As an example, following is a sample flash map

  +----------+------------------------+------------+-----------------------+
  |   SG1B   |  0x4e5000(0xFFCE5000)  |  0x0db000  |  Uncompressed, R_B    |
  +----------+------------------------+------------+-----------------------+
  |   KEYH   |  0x4e4000(0xFFCE4000)  |  0x001000  |  Uncompressed, R_B    |
  +----------+------------------------+------------+-----------------------+
  |   CNFG   |  0x4e0000(0xFFCE0000)  |  0x004000  |  Uncompressed, R_B    |
  +----------+------------------------+------------+-----------------------+
  |   FWUP   |  0x4c0000(0xFFCC0000)  |  0x020000  |  Compressed  , R_B    |
  +----------+------------------------+------------+-----------------------+
  |   SG02   |  0x440000(0xFFC40000)  |  0x080000  |  Compressed  , R_B    |
  +----------+------------------------+------------+-----------------------+
  |   UCOD   |  0x3c0000(0xFFBC0000)  |  0x080000  |  Uncompressed, R_B    |
  +----------+------------------------+------------+-----------------------+

if Configuration data component to be updated, 4 byte string "CNFG" should be passed to capsule generation tool along with configuration data binary.

BIOS, CSME binaries and CSME update driver are assigned 4 byte pre-defined string identifier and can be found in the table below.

        +-----------------------------+------------------------------------+
        |       **String ID**         |         **Firmware**               |
        +-----------------------------+------------------------------------+
        |         **BIOS**            |       Slim Bootloader              |
        +-----------------------------+------------------------------------+
        |         **CSME**            |       CSME update binary           |
        +-----------------------------+------------------------------------+
        |         **CSMD**            |       CSME update driver           |
        +-----------------------------+------------------------------------+

.. _generate-binaries-for-capsule:

Generating Component Binaries for Capsule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Generating SBL binary for capsule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Please refer to **Slimbootloader binary for capsule image** section of desired board page in **Supported Hardware** to understand how to generate Slimbootloader binary for capsule.

Generating Configuration data binary for capsule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Components inside the BIOS region are often padded to certain alignment and size.

  Configuration Data region inside SBL is padded and so for generating capsule image to update configuration data region, please use CFGDATA.pad file available after building Slim Bootloader. After building Slim Bootloader, CFGDATA.pad file is available at Build/BootloaderCorePkg/DEBUG_VS2015x86/FV/CFGDATA.pad

Generating Container Component binary for capsule
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  Slim Bootloader can update component regions inside container component in the BIOS region.
  GenContainer.py tool can help sign and create a component binary that can be used for updating a specific component region inside the container.

  Following is a sample command to create signed component for capsule
  GenContainer.py sign -f <name of the component> -o <output file name> -c lz4 -a RSA2048_PSS_SHA2_256 -k $SBL_KEY_DIR/ContainerTestKey_Priv_RSA2048.pem -td BaseTools/Bin/Win32

  The output file generated using above command can be used to create capsule.

..  note::  GenContainer.py tool is available at SblPlatform/BootloaderCorePkg/Tools folder.

Capsule Definition
*********************

|SPN| capsule starts with a |SPN| capsule header followed by |SPN| capsule data, SHA 256 signature and public key. 

For ease of use |SPN| capsule data contains capsule defined by UEFI specification, which starts with EFI_FIRMWARE_MANAGEMENT_CAPSULE_HEADER followed by capsule body.

|SPN| capsule layout is shown in this picture

.. image:: /images/capsule_layout.png
   :width: 600
   :alt: |SPN| Capsule layout
   :align: center

|SPN| capsule header is defined below

.. code-block:: c

    typedef struct {
      ///
      /// FileGuid is a GUID that identifies this image as a |SPN| capsule
      ///
      EFI_GUID                    FileGuid;
      ///
      /// The size, in bytes of this structure
      ///
      UINT32                      HeaderSize;
      ///
      /// Version of Firmware contained in the capsule, this field is not used today.
      ///
      UINT32                      FirmwreVersion;
      ///
      /// Attributes associated with the capsule, this field is not used today.
      ///
      UINT32                      CapsuleFlags;
      ///
      /// Offset to the public key in the capsule image.
      ///
      UINT32                      PubKeyOffset;
      ///
      /// Size of public key
      ///
      UINT32                      PubKeySize;
      ///
      /// Offset to the capsule data in the capsule image.
      ///
      UINT32                      ImageOffset;
      ///
      /// Size of capsule data
      ///
      UINT32                      ImageSize;
      ///
      /// Offset to the SHA 256 signature inside the capsule image.
      ///
      UINT32                      SignatureOffset;
      ///
      /// Size of signature data.
      ///
      UINT32                      SignatureSize;
      ///
      /// Reserved for future use.
      ///
      UINT32                      Reserved[3];
    } FIRMWARE_UPDATE_HEADER;

EFI_FIRMWARE_MANAGEMENT_CAPSULE_HEADER is defined in UEFI specification and is as follows

.. code-block:: c

     typedef struct {
       UINT32 Version;
    
       ///
       /// The number of drivers included in the capsule and the number of corresponding
       /// offsets stored in ItemOffsetList array.
       ///
       UINT16 EmbeddedDriverCount;
    
       ///
       /// The number of payload items included in the capsule and the number of
       /// corresponding offsets stored in the ItemOffsetList array.
       ///
       UINT16 PayloadItemCount;
    
       ///
       /// Variable length array of dimension [EmbeddedDriverCount + PayloadItemCount]
       /// containing offsets of each of the drivers and payload items contained within the capsule
       ///
       // UINT64 ItemOffsetList[];
     } EFI_FIRMWARE_MANAGEMENT_CAPSULE_HEADER;
    
      #define EFI_FIRMWARE_MANAGEMENT_CAPSULE_HEADER_INIT_VERSION       0x00000001

EFI_FIRMWARE_MANAGEMENT_CAPSULE_HEADER is followed by one or multiple update images each preceeded by EFI_FIRMWARE_MANAGEMENT_CAPSULE_IMAGE_HEADER header and is defined in UEFI specification as follows 

.. code-block:: c

     typedef struct {
       UINT32   Version;
    
       ///
       /// Used to identify device firmware targeted by this update. This guid is matched by
       /// system firmware against ImageTypeId field within a EFI_FIRMWARE_IMAGE_DESCRIPTOR
       ///
       EFI_GUID UpdateImageTypeId;
    
       ///
       /// Passed as ImageIndex in call to EFI_FIRMWARE_MANAGEMENT_PROTOCOL.SetImage ()
       ///
       UINT8    UpdateImageIndex;
    
       UINT8    reserved_bytes[3];
    
       ///
       /// Size of the binary update image which immediately follows this structure
       ///
       UINT32   UpdateImageSize;
    
       ///
       /// Size of the VendorCode bytes which optionally immediately follow binary update image in the capsule
       ///
       UINT32   UpdateVendorCodeSize;
    
       ///
       /// The HardwareInstance to target with this update. If value is zero it means match all
       /// HardwareInstances. This field allows update software to target only a single device in
       /// cases where there are more than one device with the same ImageTypeId GUID.
       /// This header is outside the signed data of the Authentication Info structure and
       /// therefore can be modified without changing the Auth data.
       ///
       UINT64   UpdateHardwareInstance;
     } EFI_FIRMWARE_MANAGEMENT_CAPSULE_IMAGE_HEADER;

     #define EFI_FIRMWARE_MANAGEMENT_CAPSULE_IMAGE_HEADER_INIT_VERSION 0x00000002

.. note:: Please refer to UEFI specification for more details about capsule header and data.

Triggering Firmware Update 
*****************************

|SPN| supports triggering firmware update from Linux, Windows, and |SPN| shell.

|SPN| provides a platform independent abstracted way of triggering firmware update from operating system. |SPN| provides two ACPI methods, \DWMI.WQ00 for read and \DWMI.WS00 for write to a platform specific chipset register that can survive a reset to signal firmware update. Please refer to **Triggering Firmware Update** section of desired board page in **Supported Hardware** to find Sample implementation.

Trigger Update From Linux Operating System
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If your Linux kernel includes the Kconfig option `INTEL_WMI_SBL_FW_UPDATE` you can trigger a firmware update with the command below followed by restarting the system

.. code-block:: bash

  echo 1 > /sys/bus/wmi/devices/44FADEB1-B204-40F2-8581-394BBDC1B651/firmware_update_request
  reboot

Trigger Update From Windows Operating System
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Users can use windows provided WMI service to call \DWMI.WQ00 and \DWMI.WS00 ACPI methods to trigger firmware update. Following the reset, Slim Bootloader boots into firmware update mode

A sample implementation of a VB script to call these methods from Windows operating system is provided below

.. code-block:: vbscript

    set Service = GetObject("winmgmts:root/wmi")
    set EnumSet = Service.InstancesOf ("AcpiFirmwareCommunication")
    for each Instance in EnumSet
      Wscript.Echo "Current  Val: " & Hex(instance.Command)
      instance.Command = 1
      instance.Put_()
      Wscript.Echo "Set New Val: " & Hex(instance.Command)
    next 'instance

Trigger Update From Shell
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

During development, one can use shell command to manually test firmware update without relying on support in OS.

1. Copy ``FwuImage.bin`` into root directory on FAT partition of a USB key

2. Boot and press any key to enter |SPN| shell

3. Type command ``fwupdate`` from shell

   Observe |SPN| resets the platform and performs update flow. It resets *multiple* times to complete the update process.

   A sample boot messages from console::

    Shell> fwupdate
    HECI SecMode 0
    ...
    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 0
    BoardID: 0E
    PlatformName: UP2
    BootPolicy : 0x00000010
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    Jump to payload
    ...
    Starting Firmware Update
    ...
    =================Read Capsule Image==============
    ...
    CapsuleImage: 0x787AF000, CapsuleSize: 0xEFE248
    HASH Verification Success! Component Type (5)
    RSA Verification Success!
    The new BOOTLOADER image passed verification
    ...
    HECI/CSE ready for update
    Updating 0x77F000, Size:0x10000
    ................  Finished     0%
    Updating 0x78F000, Size:0x10000
    ................  Finished     1%
    ...
    Updating 0xEDF000, Size:0x10000
    ................  Finished    99%
    Updating 0xEEF000, Size:0xE000
    ..............  Finished    99%
    .Reset required to proceed with the firmware update.

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP1
    MODE: 0
    BoardID: 0E
    PlatformName: UP2
    BootPolicy : 0x00000010
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    =================Read Capsule Image==============
    ...
    CapsuleImage: 0x787AE000, CapsuleSize: 0xEFE248
    HASH Verification Success! Component Type (5)
    RSA Verification Success!
    The new BOOTLOADER image passed verification
    ...
    HECI/CSE prepare for update failed
    Updating 0x0, Size:0x10000
    x...............  Finished     0%
    Updating 0x10000, Size:0x10000
    ................  Finished     1%
    Updating 0x20000, Size:0x10000
    ................  Finished    99%
    Updating 0x770000, Size:0xF000
    ...............  Finished    99%
    .Reset required to proceed with the firmware update.

    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 0
    BoardID: 0E
    PlatformName: UP2
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    Firmware update Done! clear CSE flag to normal boot mode.
    ...
    ============= Intel Slim Bootloader STAGE1A =============
    ...
    ============= Intel Slim Bootloader STAGE1B =============
    ...
    BOOT: BP0
    MODE: 0
    BoardID: 0E
    PlatformName: UP2
    ...
    ============= Intel Slim Bootloader STAGE2 =============
    ...
    ==================== OS Loader ====================

    Starting Kernel ...


Capsule Location
***********************

The location of the firmware update capsule image is passed to Firmware update payload through CAPSULE_INFO_CFG_DATA configuration data.

As an example, please refer to CAPSULE_INFO_CFG_DATA configuration data from ``Platform\ApollolakeBoardPkg\CfgData\CfgData_CapsuleInformation.yaml``.

.. note:: Capsule update defined by UEFI specification is different from |SPN| capsule format.


Firmware Update Status
************************

|SPN| reports firmware update status through custom defined Firmware Update status (FWST) ACPI table. FWST ACPI table will be available as part of RSDT and can be identified with a table signature "FWST".

FWST ACPI table makes use of EFI_SYSTEM_RESOURCE_TABLE defined in UEFI specification to report firmware update status.

.. note::  Please refer to UEFI specification for structure definition of EFI_SYSTEM_RESOURCE_TABLE and EFI_SYSTEM_RESOURCE_ENTRY.

FWST ACPI table will contain EFI_SYSTEM_RESOURCE_ENTRY entry for each of the component updated through capsule update, update status is part of EFI_SYSTEM_RESOURCE_ENTRY entry.





