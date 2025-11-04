
.. _tcc_enable:

Intel® TCC enable
~~~~~~~~~~~~~~~~~

Intel® TCC (Time Coordinated Computing) is a set of capabilities that improve compute efficiency for real-time applications by solving jitter and latency issues inside the compute node. This creates fast connections that keep IP blocks within the system in sync. To learn more about Intel® TCC, see |TCC_Overview| for details.
For a platform supporting TCC, there is a build configuration file BoardConfig.py. User could check this build configuration  file to make sure self.ENABLE_TCC is set to 1 to enable TCC.
The other Intel® TCC related configuration data might also be enabled when self.ENABLE_TCC is set. User could check the platform configuration  BoardConfig.py for details.

.. |TCC_Overview| raw:: html

   <a href="https://www.intel.com/content/www/us/en/developer/topic-technology/edge-5g/real-time/overview.html" target="_blank"> Intel® TCC Overview</a>

**NOTE:** 

Some platform might put all the Intel® TCC related SBL configuration data into a separate delta file (e.g. https://github.com/slimbootloader/slimbootloader/blob/master/Platform/TigerlakeBoardPkg/CfgData/CfgData_Tcc_Feature.dlt).
And this delta file could be automatically applied when self.ENABLE_TCC is set in BoardConfig.py based on BoardConfig.py implementation. In this case, user could directly update this TCC delta file for the detail TCC configuration.


