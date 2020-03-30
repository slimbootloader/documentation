.. _collect-time-logs:

Capture Boot Time Data
-----------------------

Boot time data should be collected using |SPN| release build. Upon reset, press any key to enter shell interface:: 

    Shell> perf

Alternatively, to capture the boot time data the platform can be booted to the desired OS and just before
the release build of |SPN| completes handing off control to the OS the boot time data will be displayed via
debug serial output.

An example of boot time data printed via debug serial output before handing off to an OS is given below:

.. image:: /images/sbl_sample_boot_time_data.png
   :alt: A sample of the boot time data printed before handing off to an OS