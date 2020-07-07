.. _enable-verified-boot:

Enable Verified Boot
---------------------

Verified boot can only be enabled or disabled at build time. 

In ``BoardConfig.py``, change the following entries::

  HAVE_VERIFIED_BOOT       = 0x1



