[About]

ddAuto is an open-source front-end GUI cross-platform imaging tool written in Perl to automate dd utility process. The purpose 
of this tool is to provide the user with the power of the dd utility as well as providing the user with an intuitive 
interface. ddAuto provides the option for the user to image attached drives (e.g. HD, Flash Drive) locally or remotely via TCP
protocol using netcat/cryptcat. Image integrity functionality is also provided by the tool. The user may choose to use MD5, 
SHA1, SHA2 or any other degist algorithm for hash verification. Most importantly, ddAuto allows the user to view the imaging 
completion percent as dd in the background as well as the estimated remaining time. 

[Features]
•GUI for dd
•Easy to change options and to switch between windows. 
•Automatically devices detection (HD, USB Flash Drive, SD Memory). 
•Progress bar for imaging time. 
•Elapsed / Estimated time calculations. 
•Support for a number of hashing algorithms. 
•Netcat and Cryptcat support. 
•Multi-OS support (Windows, Linux, OSX). 
•Exported HTML summary report. 



[Minimum Requirements]
The following list of requirements must be installed before running the tool 
•Linux 
◦Perl (Installed by default) 
◦Tk Module (Tk Installation) 
•Mac 
◦X Server (XQuartz) 
◦Perl (ActiveState) 
◦Tk Module (Tk Installation) 
•Window 
◦Cygwin (Cygwin Project) 
◦Perl (ActiveState) 
◦Tk Module (Tk Installation) 




[Optional Requirements]
The following list of requirements are required if used by the user: 
  *Linux 
    ◦Netcat (Installed by default) 
    ◦Cryptcat, installed by default in some Linux distros (CryptCat Project) 
    ◦Perl Modules: 
      ◾Digest::MD5 
      ◾Digest::SHA 
      ◾Digest::Tiger 
      ◾Digest::Whirlpool 
      ◾Digest::Adler32 
      ◾Digest::CRC 
  *Mac 
    ◦Netcat (Installed by default) 
    ◦Cryptcat(CryptCat Project) 
    ◦Perl Modules: 
      ◾Digest::MD5 
      ◾Digest::SHA 
      ◾Digest::Tiger 
      ◾Digest::Whirlpool 
      ◾Digest::Adler32 
      ◾Digest::CRC 

  *Window 
    ◦Netcat (Supported by Cygwin) 
    ◦Cryptcat (CryptCat Project) 
    ◦Perl Modules: 
      ◾Win32::Process 
      ◾Win32::Process::List 
      ◾Digest::MD5 
      ◾Digest::SHA 
      ◾Digest::Tiger 
      ◾Digest::Whirlpool 
      ◾Digest::Adler32 
      ◾Digest::CRC 

[Windows Users Instructions]
Before the tool is launched from the command line in Windows machine, the user must provide the script file with valid path to Cygwin binary directory. The following lines in the script file must reflect the exact path for Cygwin bin directory as well as Netcat and Cryptcat exe files: 
  my $cygwinPath='C:\cygwin\bin\\'          if ($^O eq 'MSWin32');
  my $ncPath='C:\nc-exe-path\\'             if ($^O eq 'MSWin32');
  my $cryptcatPath='C:\cryptcat-exe-path\\' if ($^O eq 'MSWin32');

