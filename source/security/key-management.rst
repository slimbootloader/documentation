SBL Build and Sign
------------------
SBL build process uses a signing interface. This signing method can access required keys from any accessible location based on an id.
A sample implementation of signing service is provided by *SingleSign.py* and is invoked during SBL build process.
Customers may use different signing infrastructure including use of secure signing servers, etc. and the SingleSign.py can be updated/replaced with customer’s signing infrastructure.


Key Management
---------------

Cryptographic keys used for signing SBL binaries should be securely managed. A leak of private key would allow a hacker to install/push compromised SBL or rootkits on platforms. Here is a link to `link <https://csrc.nist.gov/CSRC/media/Publications/white-paper/2018/01/26/security-considerations-for-code-signing/final/documents/security-considerations-for-code-signing.pdf>`_ to NIST  whitepaper which provides BKM’s for Code signing and secure key management.

Below is a list of Security keys and their function in securing |SPN|.

+-----------------+------------------+------------------------+------------------------+
| Key Name        | Owner            | Usage                  | Comment                |
+=================+==================+========================+========================+
| OEM Key         | Platform Owner   | To sign BootGuard Key  |                        |
|                 |                  | Manifest.              |                        |
+-----------------+------------------+------------------------+------------------------+
| BPM Key         | Firmware Owner   | To sign BootGuard Boot |                        |
|                 |                  | Policy Manifest.       |                        |
+-----------------+------------------+------------------------+------------------------+
| ConfigData Key  | Firmware Owner   | To sign Config Data    | Use CfgDataTool.py     |
|                 |                  | blob.                  |                        |
+-----------------+------------------+------------------------+------------------------+
| Master Key      | Firmware Owner   | To sign |SPN|          |                        |
|                 |                  | Key Manifest.          |                        |
+-----------------+------------------+------------------------+------------------------+
| Container Def   | Firmware Owner   | To sign container      | Use GenContainer.py    |
| Key             |                  | header.                | to package various     |
|                 |                  |                        | components             |
+-----------------+------------------+------------------------+------------------------+
| Container       | Container Owner  | To sign container      |                        |
| Component Key   |                  | components, such as,   |                        |
|                 |                  | UEFI Payload,PSE fw etc|                        |
+-----------------+------------------+------------------------+------------------------+
| OS Key          | OS Owner         | Hash of it's public key| Use GenContainer.py    |
|                 |                  | is stored in |SPN| Key | to package a OS binary.|
|                 |                  | Manifest.              |                        |
+-----------------+------------------+------------------------+------------------------+
| Firmware Update | Firmware Owner   | To sign capsule        | Use                    |
| Capsule Key     |                  | images.                | GenCapsuleFirmware.py  |
+-----------------+------------------+------------------------+------------------------+



KEY ID and configurations
*************************

A unique key id would be associated for each private key corresponding to a component to be signed.

Table below depicts key id’s defined for components and their associated test keys for various key types used for signing components.

+-----------------------------------+------------------------------------------+------------------------------------------+
| KEY ID                            |         KEY                              |  Usage                                   |
+=================+=================+========================+=================+==========================================+
| KEY_ID_MASTER_RSA2048             | MasterTestKey_Priv_RSA2048.pem           | Signing external key hash store          |
+-----------------------------------+------------------------------------------+------------------------------------------+
| KEY_ID_MASTER_RSA3072             | MasterTestKey_Priv_RSA3072.pem           | Signing external key hash store          |
+-----------------------------------+------------------------------------------+------------------------------------------+
| KEY_ID_CFGDATA_RSA2048            | ConfigTestKey_Priv_RSA2048.pem           | Signing CfgData                          |
+-----------------------------------+------------------------------------------+------------------------------------------+
| KEY_ID_CFGDATA_RSA3072            | ConfigTestKey_Priv_RSA3072.pem           | Signing CfgData                          |
+-----------------------------------+------------------------------------------+------------------------------------------+
| KEY_ID_FIRMWAREUPDATE_RSA2048     | FirmwareUpdateTestKey_Priv_RSA2048.pem   | Signing firmware capsule update          |
+-----------------------------------+------------------------------------------+------------------------------------------+
| KEY_ID_FIRMWAREUPDATE_RSA3072     | FirmwareUpdateTestKey_Priv_RSA3072.pem   | Signing firmware capsule update          |
+-----------------------------------+------------------------------------------+------------------------------------------+
| KEY_ID_CONTAINER_RSA2048          | ContainerTestKey_Priv_RSA2048.pem        | Signing Container header                 |
+-----------------------------------+------------------------------------------+------------------------------------------+
| KEY_ID_CONTAINER_RSA3072          | ContainerTestKey_Priv_RSA3072.pem        | Signing Container header                 |
+-----------------------------------+------------------------------------------+------------------------------------------+
| KEY_ID_CONTAINER_COMP_RSA2048     | ContainerCompTestKey_Priv_RSA2048.pem    | Signing Container component              |
+-----------------------------------+------------------------------------------+------------------------------------------+
| KEY_ID_CONTAINER_COMP_RSA3072     | ContainerCompTestKey_Priv_RSA3072.pem    | Signing Container componentm             |
+-----------------------------------+------------------------------------------+------------------------------------------+
| KEY_ID_OS1_PUBLIC_RSA2048         | OS1_TestKey_Pub_RSA3072.pem              | Public key used to sign Linux OS image   |
+-----------------------------------+------------------------------------------+------------------------------------------+
| KEY_ID_OS1_PUBLIC_RSA3072         | OS1_TestKey_Pub_RSA3072.pem              | Public key used to sign Linux OS image   |
+-----------------------------------+------------------------------------------+------------------------------------------+

One could use either key id or complete path to signing keys while configuring in build scripts.

.. note:: Signing tools support either KEY_ID corresponding to a component or complete path to private key.

Keys Generation
*********************

Keys required for |SPN| can be generated using GenerateKeys.py available
at BootloaderCorePkg/Tools/. The key generation process is a **one
time process** for specific project. Use same set of keys for signing
and verification operations for a specific project when generating
firmware capsule update image, cfgdata stitch, Container image and
others. Verification operations would fail incase different keys are used
which causes security violations.

Usage of GenerateKeys.py tool see :ref:`sbl-keys`


Build Environment Configuration for Key ID usage
************************************************

Key directory to be used can be specified using an environment variable.

Set env variable “SBL_KEY_DIR” to keys directory generated using
GenerateKeys.py or similar methods. This env variable need to be to set before running SBL
build command. Also, set environment variable before executing tools in standalone mode as
Capsule firmware update, container operations, cfgdata stitching and
others when KEY ID are used.

For environment setting see :ref:`build-sbl`

.. note::  Use respective component keys from SblKey directory while performing standalone operations as Capsule firmware update, container operations, cfgdata stitching.


