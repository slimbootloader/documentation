Shell Interface
----------------

|SPN| comes with a built-in shell interface for diagnosis and debugging purpose. It allows one to examine platform state (e.g., dump memory content, PCI configuration registers, etc.), change boot configuration and trouble shoot before launching OS.

Developers can also add their own shell commands for unit testing.

To enter shell interface, press any key after reboot and before OS is launched.

Built-in shell commands::

  Shell> help
  boot     - Print or modify the OS boot option list
  cdata    - Display configuration data.
  cls      - Clear console
  cpuid    - Read CPU specific information
  dmesg    - Print messages stored in boot log buffer
  exit     - Exit the shell
  fs       - filesystem access command
  fwupdate - Initiate Firmware Update
  help     - List supported commands
  hob      - List HOBs
  mm       - Read or write memory, PCI config space, or IO ports
  mmap     - Display memory map
  mmcdll   - Tune or print MMC DLL data
  msr      - Read or write model specific registers
  mtrr     - Display current MTRR configuration
  pappend  - Append extra parameters to the boot option's command line
  pci      - Display PCI devices
  perf     - Display performance data
  reset    - Reset the system
  ucode    - Display microcode version
  usbdev   - Display USB Devices

Use '-h' to get help message for a command.

Apart from the above commands, developers may also implement platform specific shell commands within ``Platform/<*BoardPkg>/Library/ShellExtensionLib/``.
An example being shell command ``gpio`` for Alder Lake platform (refer ``Platform/AlderlakeBoardPkg/Library/ShellExtensionLib/CmdGpio.c``) to read and write the required GPIO pin.

.. note:: For small image footprint or security reasons, one can exclude shell module from |SPN| in release builds.
   The OsLoader shell can be enabled/disabled for release builds through ``Config Editor tool -> OS Boot Options -> Boot to OsLoader Shell``.

