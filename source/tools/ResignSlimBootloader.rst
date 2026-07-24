ResignSlimBootloader Tool
=========================

Introduction
------------

The ``ResignSlimBootloader.py`` tool updates the Slim Bootloader signing
artifacts in an existing ``SlimBootloader.bin`` image without rebuilding the
full firmware from source, using only tools that already ship in the SBL
tree. It is intended for release, security, and manufacturing workflows that
need to rotate SBL-owned keys, regenerate KEYH, re-sign dependent artifacts,
and preserve the image layout already produced by the build flow.

.. note::

  The default operating model is post-build re-signing. SBL is not expected
  to be rebuilt as part of this flow, and the existing image signing layout,
  key configuration, compression algorithm, source-image SVN values, and
  on-flash HashStore slot count remain unchanged.

  To turn the re-signed ``SlimBootloader.bin`` into a shipping IFWI, re-run
  your platform's normal stitch flow
  (typically ``Platform/<BoardPkg>/Script/StitchIfwi.py``). Boot Guard signing is
  outside the scope of this tool.

The tool updates the following image content:

* ``KEYH``: rebuilds the key-hash container from the replacement key set.
* Master key: updates the master-key hash in Stage1A's
  ``HashStoreTable``.
* Container: re-generates hash and signature data according to the existing
  signing strategy while preserving each component's compressed payload
  bytes.
* ``CFGDATA``: re-signs and re-stitches ``CFGDATA`` in the image.


Prerequisites
-------------

* An input ``SlimBootloader.bin`` with a standard redundant SBL layout that
  already carries the signing layout and key configuration for this flow.
  The tool discovers the required flash layout, key usage, and signing
  inputs directly from the binary.
* A replacement SBL key directory compatible with the image's existing
  signing layout and key configuration. Using
  ``BootloaderCorePkg/Tools/GenerateKeys.py`` to prepare that directory is
  recommended.


.. _resign-sbl-automated-path:

Usage
-----

.. code-block:: powershell

  python BootloaderCorePkg/Tools/ResignSlimBootloader.py -i ./SlimBootloader.bin -o ./SlimBootloader_resigned.bin -k ./NewSblKeys --hash-log ./resign_hash.txt -v

Command-line options:

.. code-block:: text

  -i, --input-image   Path to the input SlimBootloader.bin to be re-signed.
  -o, --output-image  Path to write the re-signed SlimBootloader.bin.
  -k, --key-dir       Directory containing the replacement SBL keys
                      (GenerateKeys.py naming convention).
  -w, --work-dir      Working directory for intermediates. If supplied, the
                      directory is kept after the run so you can inspect
                      intermediate artifacts. If omitted, a temporary
                      directory is created and auto-deleted.
  --hash-log          Path to write a BEFORE/AFTER SHA-256 hash log.
  -v, --verbose       Enable verbose logging.


Existing tools leveraged by this script
---------------------------------------

.. list-table::
   :header-rows: 1

   * - Tool
     - How this script uses it
   * - ``BootloaderCorePkg/Tools/IfwiUtility.py``
     - Parses the input image layout and locates Stage1A, ``KEYH``,
       containers, and ``CFGDATA`` leaves.
   * - ``BootloaderCorePkg/Tools/BuildUtility.py``
     - Provides ``HashStoreTable`` / ``HASH_USAGE`` definitions and rebuilds
       the ``KEYH`` key-hash container.
   * - ``BootloaderCorePkg/Tools/SingleSign.py``
     - Resolves SBL key IDs and generates the Master public-key hash used
       for the Stage1A update.
   * - ``BootloaderCorePkg/Tools/GenContainer.py``
     - Loads existing containers and re-generates container hash and
       signature data according to the existing signing strategy.
   * - ``BootloaderCorePkg/Tools/CfgDataTool.py``
     - Re-signs ``CFGDATA`` and stitches the updated blob back into the
       image.
   * - ``BootloaderCorePkg/Tools/GenerateKeys.py``
     - Recommended for preparing a replacement SBL key directory compatible
       with the image's existing signing layout and key configuration.
