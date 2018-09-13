.. _integrate-multiple-payloads:

Integrating Multiple Payloads into |SPN|
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can integrate more than one payload files using |SPN| build tool::

    python BuildLoader.py build <PLATFORM> -p <PAYLOAD_FILE>:<PAYLOAD_ID>:<COMPRESSION_ALGORITHM>;...

    Multi-payload build option format:

    <PAYLOAD_FILE>:<PAYLOAD_ID>:<COMPRESSION_ALGORITHM>;...

    <PAYLOAD_FILE>           : external payload file name. Required to be placed in ``PayloadPkg/PayloadBins`` directory
    <PAYLOAD_ID>             : 4-byte ASCII name for this payload
    <COMPRESSION_ALGORITHM>  : compression algorithm for this payload ('Lz4' or 'Lzma')


For example, to add ``OSLoader.efi`` and ``UefiPld.fd`` into |SPN| image, run::

    python BuildLoader.py build apl -p OsLoader.efi:LLDR:Lz4;UefiPld.fd:UEFI:Lzma

Then specify ``PayloadId`` in |SPN| configuration data::

  # !BSF HELP:{Specify payload ID string. Empty will boot default payload. Otherwise, boot specified payload ID in multi-payload binary.}
  gCfgData.PayloadId             |      * | 0x04 | 'UEFI'


.. note:: ``PayloadId`` 0 is reserved for OsLoader payload.

.. note:: The payload footprint should be considered as whether it can be fit into the limited flash space. Smaller, single-purpose payload allows flexibility and easier to debug.
