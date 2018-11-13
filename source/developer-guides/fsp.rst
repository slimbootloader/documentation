Firmware Support Package
---------------------------

Intel® Firmware Support Package (Intel® FSP) provides key programming information for initializing Intel® silicon and can be easily integrated into a boot loader of the developer’s choice. In essense, |SPN| is a minimal boot loader that consumes
FSP as a binary package. FSP is widely used in many open source or commerial boot solutions on newer Intel silicons.

|SPN| supports |FSP Specification v2.0|

.. |FSP Specification v2.0| raw:: html

   <a href="https://www.intel.com/content/www/us/en/intelligent-systems/intel-firmware-support-package/intel-fsp-overview.html" target="_blank">FSP Specification v2.0</a>

FSP provides many configuration options called User Product Data (UPD). See FSP UPD header files (``Silicon/<platform_foo>/Include/Fsp*Upd.h``).

FSP UPD is exposed to |SPN| configuration data interface so FSP can be configured directly using |CFGTOOL| or at |SPN| runtime.

.. note:: 

  |SPN| includes FSP interfacing infrastructure including locating and loading FSP binary, configuring FSP UPDs and calling FSP APIs. 

  This infrastructure is implemented in |SPN| core code to allow ease of porting to a new silicon.


The latest FSP release can be downloaded from GitHub: |https://github.com/IntelFsp/FSP|

.. |https://github.com/IntelFsp/FSP| raw:: html

   <a href="https://github.com/IntelFsp/FSP" target="_blank">https://github.com/IntelFsp/FSP</a>


For more information on FSP, please visit |http://www.intel.com/fsp|

.. |http://www.intel.com/fsp| raw:: html

   <a href="http://www.intel.com/fsp" target="_blank">http://www.intel.com/fsp</a>