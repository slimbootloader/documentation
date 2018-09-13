.. _boot-guard:

Boot Guard
-------------

Intel® Device Protection Technology with Boot Guard (a.k.a. Boot Guard), is a platform integrity protection technology. It’s rooted in a protected hardware infrastructure and prevents the execution of unauthorized initial boot block (IBB).

Verified Boot
  Cryptographically verifies IBB.

Measured Boot
  Measures firmware components and records them into a platform storage device such as Trusted Platform Module (TPM) or Intel® Platform Trust Technology (Intel® PTT).

One of the main differences between measured boot and verified boot is that measured boot does not halt on error as the verification is done once the entire system has booted up.


|SPN| supports boot guard technology.

.. note:: Enabling boot guard technology on a platform requires additional firmware components and tools.



