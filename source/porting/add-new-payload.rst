.. _create-new-payload:

Creating New Payload
---------------------------

.. note:: Before you decide to suport a new payload in |SPN|, it is recommended to check whether the existng payloads can be updated to support the new requirement.


For **tightly-coupled** payload, two steps are required to integrate a new payload:

#. Create a new payload starts with adding a new module in ``PayloadPkg/<payload_bar>`` with entry point function ``PayloadMain()``.

   See :ref:`package-dependency` when you are implementing payload code.


#. Build and integrate the new payload

    The image size and memory location of the new payload can be configured in ``BoardConfig.py``. The following values are used in |APL| payload configurations::

        PAYLOAD_SIZE         = 0x0001F000
        EPAYLOAD_SIZE        = 0x00120000
        LOADER_RSVD_MEM_SIZE = 0x00B8C000
        PLD_RSVD_MEM_SIZE    = 0x00500000
        PAYLOAD_LOAD_HIGH    = 1


    See :ref:`board-config-script` for details.


For **loosely-coupled** payload, you are full control of payload design and implementation.

UEFI Payload is loosely-coupled payload. 

.. todo:: split into new page

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


