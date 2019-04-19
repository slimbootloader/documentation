.. _versioning:

Versioning
------------

|SPN| implements a simple versioning structure with many features:

* Image identification (e.g. supported platforms)
* Core major and minor revision (See |Semantic Versioning|)
* Project major and minor revision
* Traceability to release process and build environment (e.g. git SHA1, dirty bit, build number)
* Security version (SVN) to provide Anti-Rollback protection during firmware update

.. |Semantic Versioning| raw:: html

   <a href="https://semver.org/" target="_blank">Semantic Versioning</a>

Version Information data structure (``BootlLoaderVersionGuid.h``)::

    typedef struct {
      UINT16             BuildNumber;        /* A hour-granularity time stamp     */
      UINT8              ProjMinorVersion;   /* Project or platform major version */
      UINT8              ProjMajorVersion;   /* Project or platform minor version */
      UINT8              CoreMinorVersion;   /* Core code major version           */
      UINT8              CoreMajorVersion;   /* Core code minor version           */
      UINT8              SecureVerNum;       /* Security version number (SVN)     */
      UINT8              Reserved : 5;
      UINT8              BldDebug : 1;       /* Bootloader debug build if 1       */
      UINT8              FspDebug : 1;       /* FSP debug build if 1              */
      UINT8              Dirty    : 1;       /* Dirty flag from git               */
    } IMAGE_BUILD_INFO;

    typedef struct {
      UINT32             Signature;          /* '$SBH'                            */
      UINT16             HeaderLength;
      UINT8              HeaderRevision;
      UINT8              Reserved;
      UINT64             ImageId;            /* Unique ASCII string per platform */
      IMAGE_BUILD_INFO   ImageVersion;
      UINT64             SourceVersion;      /* First 8 bytes of git SHA1        */
    } BOOT_LOADER_VERSION;

Image build data ``IMAGE_BUILD_INFO`` can be configured in board configuration file ``BoardConfig.py``. One can specify ``BUILD_NUMBER`` in environment variables to provide references in an automated build and release setup (e.g. Jenkins)

During build process, version data is generated and embedded in |SPN| image with signature ``$SBH``.

During boot, |SPN| passes version data to OS via HOB data list with GUID ``gBootLoaderVersionGuid`` and also prints it to the serial console. For example::

    SBID: SB_APLI
    ISVN: 001
    IVER: 000.005.001.000.02490
    SVER: 77F65EAF257FD5DE-dirty
    FDBG: BLD(D) FSP(R)
    FSPV: ID($APLFSP$) REV(01040301)

For build reproducibility required by certain strict development process, one can provide a *hard-coded* version information in a file during the build process. See :ref:`build-tool` for more details.
