.. _enable-verified-boot:

Enable Verified Boot
---------------------

Verified boot can only be enabled or disabled at build time. 

In ``BoardConfig.py``, change the following entries::

  HAVE_VERIFIED_BOOT       = 0x1
  # OS_PK | FWU_PK | CFG_PK | FWU_PLD | PLD | Stage2 | Stage1B
  # Stage1B is verified by CSE
  self.VERIFIED_BOOT_HASH_MASK  = 0x00000056

When the bit for a component is 1 in ``VERIFIED_BOOT_HASH_MASK``, |SPN| verifies the digest for the corresponding component.

One can replace a new key in ``BootloaderCorePkg/Tools/Keys``.


