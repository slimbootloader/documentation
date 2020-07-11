.. _integrate-multiple-payloads:

Integrate Multiple Payloads
------------------------------

You can integrate more than one payload files using |SPN| build tool::

    python BuildLoader.py build <PLATFORM> -p <PAYLOAD_FILE>:<PAYLOAD_ID>:<COMPRESSION_ALGORITHM>;...

    Multi-payload build option format:

    <PAYLOAD_FILE>:<PAYLOAD_ID>:<COMPRESSION_ALGORITHM>;...

    <PAYLOAD_FILE>           : external payload file name. Required to be placed in ``PayloadPkg/PayloadBins`` directory
    <PAYLOAD_ID>             : 4-byte ASCII name for this payload
    <COMPRESSION_ALGORITHM>  : compression algorithm for this payload ('Lz4', 'Lzma' or 'Dummy'). 'Dummy' indicates no compression.
                               This parameter is optional, and default is 'Dummy' if not specified.

If only one payload is specified, this payload will be built into normal payload compoment (PYLD) in the SBL flash map.
If more then one payloads are specified, the first payload will be built into PLD and the remaining will be built into extended payload container (EPLD) in the SBL flash map.

The following procedure shows you how to integrate ``UefiPld.fd`` into |SPN| image. Adding other custom payloads is similar.


1. Copy ``UefiPld.fd`` into ``PayloadPkg/PayloadBins`` directory (create the directory if it is missing)

2. Specify ``PayloadId`` in |SPN| configuration file (``*.dlt``)

  ``PayloadId`` tells |SPN| which payload to load instead of default ``OsLoader``. For QEMU, open ``Platform/QemuBoardPkg/CfgData/CfgDataExt_Brd1.dlt`` and append the following configuration::

     GEN_CFG_DATA.PayloadId                     | 'UEFI'

  You may also use |CFGTOOL| to make file changes. See :ref:`configuration-tool` for more details.


3. Build ``UefiPld.fd`` into |SPN| image::

    python BuildLoader.py build qemu -p "OsLoader.efi:LLDR:Lz4;UefiPld.fd:UEFI:Lzma"

  ``UefiPld.fd`` image is located in the ``EPLD`` region according to |SPN| flash map.

  ``PayloadId`` is 4 bytes and should match the value used in the configuration. In this example, ``PayloadId`` is ``UEFI`` on the command line.


.. note:: ``PayloadId`` 0 is reserved for OsLoader payload.

.. note:: The payload footprint should be considered as whether it can be fit into the limited flash space. Smaller, single-purpose payload allows flexibility and easier to debug.
