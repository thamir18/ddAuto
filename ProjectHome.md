## About ##

ddAuto is an open-source front-end GUI cross-platform imaging tool written in Perl to automate dd utility process. The purpose of this tool is to provide the user with the power of the dd utility as well as providing the user with an intuitive interface. ddAuto provides the option for the user to image attached drives (e.g. HD, Flash Drive) locally or remotely via TCP protocol using netcat/cryptcat.
Image integrity functionality is also provided by the tool. The user may choose to use MD5, SHA1, SHA2 or any other degist algorithm for hash verification. Most importantly, ddAuto allows the user to view the imaging completion percent as dd in the background as well as the estimated remaining time.
 


## Features ##
  * GUI for dd
  * Easy to change options and to switch between windows.
  * Automatically devices detection (HD, USB Flash Drive, SD Memory).
  * Progress bar for imaging time.
  * Elapsed / Estimated time calculations.
  * Support for a number of hashing algorithms.
  * Netcat and Cryptcat support.
  * Multi-OS support (Windows, Linux, OSX).
  * Exported HTML summary report.



## Minimum Requirements ##
The following list of requirements must be installed before running the tool
  * Linux
    * Perl (Installed by default)
    * Tk Module ([Tk Installation](http://www.tkdocs.com/tutorial/install.html))
  * Mac
    * X Server ([XQuartz](http://xquartz.macosforge.org))
    * Perl ([ActiveState](http://www.activestate.com))
    * Tk Module ([Tk Installation](http://www.tkdocs.com/tutorial/install.html))
  * Window
    * Cygwin ([Cygwin Project](http://www.cygwin.com))
    * Perl ([ActiveState](http://www.activestate.com))
    * Tk Module ([Tk Installation](http://www.tkdocs.com/tutorial/install.html))



## Optional Requirements ##
The following list of requirements are required if used by the user:
  * Linux
    * Netcat (Installed by default)
    * Cryptcat, installed by default in some Linux distros ([CryptCat Project](http://cryptcat.sourceforge.net/))
    * Perl Modules:
      * Digest::MD5
      * Digest::SHA
      * Digest::Tiger
      * Digest::Whirlpool
      * Digest::Adler32
      * Digest::CRC
  * Mac
    * Netcat (Installed by default)
    * Cryptcat([CryptCat Project](http://cryptcat.sourceforge.net/))
    * Perl Modules:
      * Digest::MD5
      * Digest::SHA
      * Digest::Tiger
      * Digest::Whirlpool
      * Digest::Adler32
      * Digest::CRC

  * Window
    * Netcat (Supported by Cygwin)
    * Cryptcat ([CryptCat Project](http://cryptcat.sourceforge.net/))
    * Perl Modules:
      * Win32::Process
      * Win32::Process::List
      * Digest::MD5
      * Digest::SHA
      * Digest::Tiger
      * Digest::Whirlpool
      * Digest::Adler32
      * Digest::CRC

## Windows Users Instructions ##
Before the tool is launched from the command line in Windows machine, the user must provide the script file with valid path to Cygwin binary directory. The following lines in the script file must reflect the exact path for Cygwin bin directory as well as Netcat and Cryptcat exe files:
```
 my $cygwinPath='C:\cygwin\bin\\' 	   if ($^O eq 'MSWin32');
 my $ncPath='C:\nc-exe-path\\' 		   if ($^O eq 'MSWin32');
 my $cryptcatPath='C:\cryptcat-exe-path\\' if ($^O eq 'MSWin32');
```

## Remote Imaging ##
For remote imaging, ddAuto opens dual TCP connections. One via Netcat/Cryptcat to tunnel dd stream, and the other is a TCP connection on port '9090' for data control initiated by the Sender to exchange control data, like how many bytes have been transferred so far and what hash calculation requested by the receiver. In case of firewall protection, the user should allow for port '9090' (hardcoded) and the Netcat/Cryptcat listing port selected by the user. The following table summarizes the remote imaging on different OSs.
| **Receiver** | **Sender** | **Notes** |
|:-------------|:-----------|:----------|
| Windows 7 | Backtrack 5 | <ul><li>File Imaging</li> <li>Flash drive imaging</li> <li>Netcat/Cryptcat</li>
<tr><td> Backtrack 5 </td><td> Windows 7 </td><td> <ul><li>File Imaging</li> <li>Flash drive imaging</li> <li>Netcat/Cryptcat</li></td></tr>
<tr><td> Backtrack 5 </td><td> Backtrack 5 </td><td> <ul><li>File Imaging</li> <li>Flash drive imaging</li> <li>Netcat/Cryptcat</li></td></tr>
<tr><td> Windows 7 </td><td> Mac OS </td><td> <ul><li>File Imaging</li> <li>Flash drive imaging</li> <li>Netcat</li></td></tr></tbody></table>



<h2>Feature Development</h2>
<ul><li>Integrate with other forks of dd (Dc3dd, dcfldd, sdd, dd_rescue, ddrescue, dccidd)<br>
</li><li>Support memory imaging<br>
</li><li>Logging<br>
</li><li>Support multi-imaging<br>
</li><li>Support dd over SSH<br>
</li><li>Pause/Continue<br>
</li><li>Error Handling</li></ul>

<h2>Release Track</h2>
<table><thead><th> <b>Version</b> </th><th> <b>Release Date</b> </th><th> <b>Applied Changes</b> </th></thead><tbody>
<tr><td> ddAuto-1.0 </td><td> May 14, 2014 </td><td> <ul><li>Initial Version</li> <li>Local/Remote Imaging</li> <li>Netcat/Cryptcat Support</li> <li>Hashing Support</li> <li>HTML Format Report</li></ul> </td></tr></tbody></table>


<h2>Screenshots</h2>

<h3>Welcome Window</h3>
1- Utility body area.<br />
2- Utility control area.<br />
<img src='https://dl.dropboxusercontent.com/s/77bislzgxo2dq9l/1.jpg' />


<h3>Imaging Mode Window</h3>
3- <b>Local</b>: allows the user to image attached devices locally.<br />
4- <b>Remote</b>: allows the user to image attached devices remotely over TCP connection.<br />
<img src='https://dl.dropbox.com/s/yo07r3cv2qprtzi/2.jpg' />


<h3>I/O Path Window</h3>
5- <b>Input Device/File</b>: it can be a valid device or file path to pass for dd as input (if=).<br />
6- <b>Output File</b>: it can be a valid file path to pass for dd as output (of=).<br />
7- The button with the black arrow on the right opens a list with detected devices. In the the example below, 'Device1' refers to the hard drive while 'Device2' refers to a USB flash drive. <br />
<img src='https://dl.dropbox.com/s/82lcohbzptbpq5p/3.jpg' />
<img src='https://dl.dropbox.com/s/38onesvyecrdf07/4.jpg' />

<h3>Connection Mode Window</h3>
This window appears only if 'Remote Mode' option is selected.<br />
8- <b>Sender Mode</b>: allows the user to send the input of dd to a remote receiver over TCP connection.<br />
9- <b>Receiver Mode</b>: allows the user to accept the output of dd from a remote sender over TCP connection.<br />
<img src='https://dl.dropbox.com/s/3bjk11zyyp2a808/5.jpg' />


<h3>Tunneling Mode Window</h3>
This window appears only if 'Remote Mode' option is selected.<br />
10- <b>Netcat</b>: allows the user to send the dd stream over unencrypted TCP connection.<br />
11- <b>Cryptcat</b>: allows the user to send the dd stream over encrypted TCP connection.<br />
12- <b>Network Settings</b>: a parameters must be passed to Netcat/Cryptcat:<br>
<ul><li><b>Remote IP</b>: valid remote host IP address in the format: #.#.#.#<br>
</li><li><b>Port</b>: valid remote host listing port.<br>
</li><li><b>key</b>: optional encryption key for Cryptcat only.<br>
<img src='https://dl.dropbox.com/s/icqylvq6fs8uyxu/6.jpg' /></li></ul>


<h3>dd Options Window</h3>
This windows allows the user to pass options in graphic mode to dd utility. It should be noticed that dd options for Windows versions are limited. For more information about dd options, visit <a href='http://linux.die.net/man/1/dd'>dd options</a> or type <i>man dd</i> in the command line.<br>
<img src='https://dl.dropbox.com/s/vgzxruty7pb8hn1/7.jpg' />


<h3>Checksum & Report Options Window</h3>
13- A list of optional checksum algorithms.<br />
14- User's HTML report options.<br />
<img src='https://dl.dropbox.com/s/wbw4xicg9mufr4u/8.jpg' />

<h3>Confirmation Window</h3>
This windows allows the user to confirm his selected options before imaging starts up. The user can smoothly moves back and forth between windows and change options.<br>
<img src='https://dl.dropbox.com/s/8si45c323xdxsjt/9.jpg' />


<h3>Status Window</h3>
This windows updates the user with the progress of dd as well as the estimated time.<br>
15- Time estimation.<br />
16- Progress bar.<br />
17- Messages area to keep the user updated about the process.<br />
18- Exit button.<br />
19- Open an HTML summary report in a browser.<br />
20- Takes the user to the first step.<br />
<img src='https://dl.dropbox.com/s/omj3ewzg8f9kqzq/10.jpg' />

<h3>HTML Summary Report</h3>
The HTML summary report confirms wither the imaging processed successful or not by showing the checksum test results. It also can be printed or exported as a record.<br>
<img src='https://dl.dropbox.com/s/qescr7wppk7psq4/11.jpg' />
