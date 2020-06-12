Key Management
---------------

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


Cryptographic keys used for signing |SPN| binaries should be securely managed.
A leak of private key would allow a hacker to install/push compromised |SPN| or rootkits on platforms.
Here is a `link <https://csrc.nist.gov/CSRC/media/Publications/white-paper/2018/01/26/security-considerations-for-code-signing/final/documents/security-considerations-for-code-signing.pdf>`_ to NIST whitepaper which provides BKM's for Code signing and secure key management.

