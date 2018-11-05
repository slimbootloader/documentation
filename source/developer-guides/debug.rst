.. _debug:

Source Level Debugging on Serial Port
--------------

This explains how to perform basic debugging operation with Intel UDK Debugger on SBL over serial port.

**Prerequisite**

Install Intel UDK Debugger on HOST::
Intel UDK Debugger can be downloaded here for Windows and Linux, and just install it with default configuration values.

https://firmware.intel.com/develop/intel-uefi-tools-and-utilities/intel-uefi-development-kit-debugger-tool#overlay-context=develop

https://firmware.intel.com/sites/default/files/UDK_Debugger_Tool_User_Manual_V1.11.pdf


**General steps**

1. Enable DebugAgent on SBL and flash the SBL image(or IFWI) on TARGET

2. Configure Intel UDK Debugger environment on HOST

3. Launch Intel UDK Debugger on HOST

4. Turn TARGET on

5. Start debugging


**Step 1 - Enable Debug Agent**

By default, DebugAgent is not enabled. It can be simply enabled with a single line change.

1. Open BoardConfig.py of specific platform, set **ENABLE_SOURCE_DEBUG** to **1**::

    self.ENABLE_SOURCE_DEBUG = 1
  
2. APL platform has a known issue on Stage1A debugging because of its size limitation. ONLY APL platform requires **SKIP_STAGE1A_SOURCE_DEBUG** to **1**::

    self.SKIP_STAGE1A_SOURCE_DEBUG = 1
  
3. Build as usable

4. Stitch IFWI and Flash it


**Step 2 - Configure Intel UDK Debugger environment**

1. Configuration file default location 

 - Windows:: 
 
    C:\Program Files (x86)\Intel\Intel(R) UEFI Development Kit Debugger Tool\SoftDebugger.ini 
 
 - Linux::
 
    /etc/udkdebugger.conf
    

2. [Debug Port] option::

    [Debug Port]
    Channel = Serial    <== Must be Serial
    Port = COM5         <== Change properly
    FlowControl = 0     <== 0 for now**
    BaudRate = 115200   <== Change properly
    Server =            <== Can be empty
    
3. [Target System] option::

    [Target System]
    FlashRange        = 0xFEF00000:0x1100000     <== This must be added for APL platform for code execution debugging in CAR

4. [Maintenance] option::

    [Maintenance]
    Trace=0x10          <== This is optional. 0x0: Disable trace output, 0x3f: Enable full trace output

**Step 3 - Launch Intel UDK Debugger**

* Windows
 - Launch "Start WinDbg with Intel UDK Debugger Tool"

* Linux
 - Launch::

    /opt/intel/udkdebugger/bin/udk-gdb-server


**Step 4 - Turn TARGET on**

* Windows
 - Just turn TARGET on. Connection of HOST and TARGET will be established immediately.

* Linux
 - Turn TARGET on
 - Launch GDB in a separate terminal
 - Make a connection with GDB target command::
    
    target remote :1234 
    
   (or target remote FULL_SERVER_URL:1234 from Intel UDK Debugger console)
  
  
 - Run Intel UDK Debugger scripts for GDB::

    source /opt/intel/udkdebugger/script/udk_gdb_script

**Step 5 - Start debugging**

Start debugging with WinDbg or GDB