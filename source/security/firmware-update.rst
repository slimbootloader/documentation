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
^^^^^^^^^^^^^^^^^^

Please refer to **Slimbootloader binary for capsule image** section of desired board page in **Supported Hardware** to understand how to generate Slimbootloader binary for capsule.

After gathering required firmware binaries, capsule image can be generated using capsule generation tool

  Capsule tool (``GenCapsuleFirmware.py``) creates a capsule image that can be processed by |SPN| in firmware update flow.

  Capsule tool is capable of incorporating multiple firmware images into single capsule binary. Each firmware is identified and included in the capsule image using a GUID.
  Known GUIDs are included in the capsule generation tool, please refer to the note below for more details.

    usage: GenCapsuleFirmware.py [-h] -p BIOS <BIOS_IMAGE> -p <GUID> <FW IMAGE BINARY 1>.....-p <GUID> <FW IMAGE BINARY n> -k PRIVKEY -o NEWIMAGE [-q]

    optional arguments:
      -h, --help            show this help message and exit
      -p  <GUID> <Payload Image>, 
                            Payload image that goes into firmware update capsule
      -k PRIVKEY, --priv_key PRIVKEY
                            Private RSA 2048 key in PEM format to sign image
      -o NEWIMAGE, --output NEWIMAGE
                            Output file for signed image
      -q, --quiet           without output messages or temp files

  For example, the following command generates a capsule image (``FwuImage.bin``) containing an IFWI image (``sbl.bios.bin``), CSME image (``csme.bin``), CSME Firmware Update Driver (``csme_fw_update_driver.bin``) and firmware image (``fwimage.bin``) signed by key ``TestSigningPrivateKey.pem``::

    $ python ./BootloaderCorePkg/Tools/GenCapsuleFirmware.py -p BIOS sbl.bios.bin -p CSME  csme.bin -p CSMD csme_fw_update_driver.bin -p fwimage.bin -k ./BootloaderCorePkg/Tools/Keys/TestSigningPrivateKey.pem -o FwuImage.bin
    Successfully signed Bootloader image!
    $

.. note:: For user convenience GUID's for following firmwares are included in the capsule generation tool and these firmwares can be included in the capsule image by using known string in place of GUID in the command line.

        +-----------------------------+------------------------------------+
        | **String for Known Guid**   |         **Firmware**               |
        +-----------------------------+------------------------------------+
        |         **BIOS**            |       Slim Bootloader              |
        +-----------------------------+------------------------------------+
        |         **CSME**            |       CSME update binary           |
        +-----------------------------+------------------------------------+
        |         **CSMD**            |       CSME update driver           |
        +-----------------------------+------------------------------------+
        |         **CFGD**            |       Configuration data binary    |
        +-----------------------------+------------------------------------+

Capsule Definition
^^^^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Triggering firmware update is a platform specific mechanism.

|SPN| uses platform specific register that can survive a reset to signal firmware update. Please refer to **Triggering Firmware Update** section of desired board page in **Supported Hardware** to find Sample implementation.

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The location of the firmware update capsule image is passed to Firmware update payload through CAPSULE_INFO_CFG_DATA configuration data.

As an example, please refer to CAPSULE_INFO_CFG_DATA configuration data from ``Platform\ApollolakeBoardPkg\CfgData\CfgData_CapsuleInformation.dsc``.

.. note:: Capsule update defined by UEFI specification is different from |SPN| capsule format.


Firmware Update Status
^^^^^^^^^^^^^^^^^^^^^^^^

|SPN| reports firmware update status through custom defined Firmware Update status (FWST) ACPI table. FWST ACPI table will be available as part of RSDT and can be identified with a table signature "FWST".

FWST ACPI table makes use of EFI_SYSTEM_RESOURCE_TABLE defined in UEFI specification to report firmware update status.

.. note::  Please refer to UEFI specification for structure definition of EFI_SYSTEM_RESOURCE_TABLE and EFI_SYSTEM_RESOURCE_ENTRY.

FWST ACPI table will contain EFI_SYSTEM_RESOURCE_ENTRY entry for each of the component updated through capsule update, update status is part of EFI_SYSTEM_RESOURCE_ENTRY entry.





