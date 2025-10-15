Customizing SMBIOS Production Data Using YAML
=============================================

Overview
--------

SBL now supports a flexible method for customizing SMBIOS production data (board name, serial numbers, etc.) for each platform.

Instead of modifying source code, users can simply edit a YAML file (`SmbiosStrings.yaml`) to define all SMBIOS strings for their product.

This YAML file is converted to a binary blob during the build process and automatically loaded by the firmware at runtime.

YAML file location: 

.. code-block:: text

  Platform/<Platform>BoardPkg/SmbiosStrings.yaml

How to Customize Production Data
--------------------------------

1. **Locate the platform `SmbiosStrings.yaml` file**
   - Example: `Platform/ArrowlakeBoardPkg/SmbiosStrings.yaml`

2. **Modify or add entries for the SMBIOS types and string indices you want to customize.**
   - Example:

     .. code-block:: yaml

        # Each entry has exactly 3 lines: - type:, idx:, string
        # Entry Strings are always quoted with double quotes

        smbios_strings:
          # Type 0: BIOS Information
          - type: 0    # BIOS Vendor
            idx: 1
            string: "Intel Corporation"
            # type 0, Idx 2 and 3 are optional

          # Type 1: System Information
          - type: 1    # Manufacturer
            idx: 1
            string: "Intel Corporation"
          - type: 1    # Product Name
            idx: 2
          - type: 1
            idx: 2
            string: "My Custom Product Name"
          - type: 1
            idx: 3
            string: "My Custom Version"
          - type: 1
            idx: 4
            string: "SN1234567890"

3. **Build SBL**
   - The YAML will be converted to `smbios.bin` and automatically loaded by SBL at runtime.

