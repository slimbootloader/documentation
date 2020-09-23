Firmware Support Package
---------------------------

Intel(R) Firmware Support Package (Intel(R) FSP) provides key programming information for initializing Intel(R) silicon and can be easily integrated into a boot loader of the 
developer's choice. In essence, |SPN| is a minimal boot loader that consumes FSP as a binary package. FSP is widely used in many open source or commercial boot solutions on 
newer Intel silicons.

|SPN| supports |FSP Specification v2.x|

.. |FSP Specification v2.x| raw:: html

   <a href="https://www.intel.com/content/www/us/en/intelligent-systems/intel-firmware-support-package/intel-fsp-overview.html" target="_blank">FSP Specification  v2.x</a>

FSP provides many configuration options called User Product Data (UPD). See FSP UPD header files (``Silicon/<platform_foo>/Include/Fsp*Upd.h``).

FSP UPD is exposed to |SPN| configuration data interface so FSP can be configured directly using |CFGTOOL| or at |SPN| runtime.

.. note:: 

  |SPN| includes FSP interfacing infrastructure including locating and loading FSP binary, configuring FSP UPDs and calling FSP APIs. 

  This infrastructure is implemented in |SPN| core code to allow ease of porting to a new silicon.


The latest FSP release can be downloaded from GitHub: |https://github.com/intel/fsp|

.. |https://github.com/intel/fsp| raw:: html

   <a href="https://github.com/intel/fsp" target="_blank">https://github.com/intel/fsp</a>


For more information on FSP, please visit |http://www.intel.com/fsp|

.. |http://www.intel.com/fsp| raw:: html

   <a href="http://www.intel.com/fsp" target="_blank">http://www.intel.com/fsp</a>