.. _change-gpio-options:

GPIO config data
----------------------

**Step1**. In the console launch the "ConfigEditor" from
"slimbootloader" folder.

**Command** : python Sblopen/BootloaderCorePkg/Tools/ConfigEditor.py

.. image:: /images/Gpio_config_1.jpg

**Step2.** Open the "Config DSC" file, then select the description file
according to your platform( eg.
/Platform/CoffeelakeBoardPkg/CfgData/CfgDataDef.dsc")

.. image:: /images/Gpio_config_2.jpg


.. image:: /images/Gpio_config_3.jpg

**Step 3.**  Load the "Config Delta" file from the same folder of the
description file by selecting "Load Config Changes from Delta File"
menu.

.. image:: /images/Gpio_config_4.jpg

.. image:: /images/Gpio_config_5.jpg

**Step 4**. At the menu panel in left, select the "GPIO Settings", and
Select GPIO number which needs to be updated.

.. image:: /images/Gpio_config_6.jpg

-  Refer to https://slimbootloader.github.io/tools/index.html#cfgtool
   for description regarding these pins .

-  | GPIO pins are grouped into different Community (e.g. Community 0,
     Community 1,
   | etc.). Each Community consists of one or more GPIO groups. Refer to
     Corresponding EDS document for more details.

**Step 5.** Save the changes with "**save config changes to Delta
File**\ ” to the required board specific dlt file

.. image:: /images/Gpio_config_7.jpg

.. image:: /images/Gpio_config_8.jpg

Changes shall be reflected into the dlt file. Open the corresponding dlt
file in notepad and check if the value is updated accordingly.

GenGpioData Tool
^^^^^^^^^^^^^^^^

GenGpioData.py is a utility that converts the GPIO pin data from one
format to other. The formats currently supported are [h, csv, txt, dsc,
dlt]. h, csv, txt formats are external to SBL and dsc, dlt formats are
known to SBL. So, this tool provides a way to convert one of the h, csv,
txt to dsc, dlt and vice-versa.

https://slimbootloader.github.io/tools/index.html#cfgtool

GpioTool is used by developers for porting GPIO configuration from BIOS
to SBL

Command to run GenGpioData Tool

*Input is .h and output .dsc*

1. GenGpioData.py -if GpioTableXxx.h -of dsc

   *Input is .h and output .dlt*

2. GenGpioData.py -if GpioTableXxx.h -of dlt

   *Input is .csv and output .dsc*

3. GenGpioData.py -if GpioTablexx.csv -of dsc

   *Input is .csv and output .dlt*

4. GenGpioData.py -if GpioTablexx.csv -of dlt

Refer to https://slimbootloader.github.io/tools/index.html#cfgtool for
description regarding GPIO tool supported formats .

GpioTablexxx.h file shall be imported from BIOS source. Depending upon
requirement this table can be updated.

Input format is .h and output generated is .dsc file

Using Config editor the generated Dsc file can be loaded and modified

Generated Dsc file looks like

.. image:: /images/Gpio_config_9.jpg

.. |image0| image:: media/image1.png
   :width: 6.51469in
   :height: 4.61806in
.. |image1| image:: media/image2.png
   :width: 6.50000in
   :height: 4.53264in
.. |image2| image:: media/image3.png
   :width: 5.86538in
   :height: 4.02847in
.. |image3| image:: media/image4.png
   :width: 6.50000in
   :height: 4.49861in
.. |image4| image:: media/image5.png
   :width: 6.07292in
   :height: 3.80985in
.. |image5| image:: media/image6.png
   :width: 6.50000in
   :height: 3.92083in
.. |image6| image:: media/image7.png
   :width: 6.50000in
   :height: 3.75139in
.. |image7| image:: media/image8.png
   :width: 6.50000in
   :height: 4.07778in
.. |image8| image:: media/image9.png
   :width: 5.71875in
   :height: 4.54167in
