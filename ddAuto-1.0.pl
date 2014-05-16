#!/usr/bin/perl

# Script: ddAuto.pl
# Authors: Thamir Alshammari
# Organization: Rochester Institute of Technology
#
# This script is designed to automate the function of DD command line tool in a simple graphic user interface.
##########


use Net::hostent; 
use IO::Socket;
use Tk;												# require install for Windows via PPM, open the Command Prompt and type (ppm install Tk)
use Tk::ProgressBar;
use Tk::ROText;
use Tk::LabFrame;
use Tk::BrowseEntry;
use threads;
use threads 'exit' => 'threads_only';
use strict;
no strict "vars";
use Cwd;

require Win32::Process if ($^O eq 'MSWin32');		# required if the OS is Windows
require Win32::Process::List if ($^O eq 'MSWin32');	# require install via PPM in ActiveState (>ppm install Win32-Process-List)
	

########### Required only for Windows Platforms, you have to specify the wright path for Cygwin, Netcat, Cryptcat 	
my $cygwinPath='C:\cygwin\bin\\' 	if ($^O eq 'MSWin32');
my $ncPath='C:\cygwin\bin\\' 		if ($^O eq 'MSWin32');
my $cryptcatPath='C:\cygwin\bin\nt\\' 	if ($^O eq 'MSWin32');
#########################################################


my $defaultPort = 9090;
	
	

# Generl Variables
my $src_file_size=0;
my $dst_file_size=0; 
my $cmd_title = 'Start';
my $path = getcwd();
my $t;
my $src_file_path;
my $dst_file_path; 
my $status;
my $browse_src;
my $browse_dst;
my $mode;
my %defs;
my $network;
my $transfer;
my $dd_cmd;
my $ipaddress;
my $port;
my $connStatus;
my $key;


#Widgets Variables
my $mw;
my $summaryTxt;
my $mbar;
my $percent_done = 0;
my $file_m;
my $edit_m;
my $help_m;
my $srcLabel;
my $srcTxt;
my $dstLabel;
my $dstTxt;
my $progress;
my $img_openFolder;
my $LoadDialog;
my $cmd_next;
my $cmd_back;
my $cmd_start;
my $cmd_stop;
my $cmd_viewreport;
my $cmd_go;
my $level;
my $cmd_local;
my $cmd_remote;
my $ratePerSec;
my $dd_all_options;
my $reportTitle;
my $reportAuthor;
my $reportOrg;
my $ddThread;
my $remoteImagingControl;
my $percentage;
my $connection;

my %devicesListNames;
my %devicesListHardware;
my @hashList;
my @hashValues;
my @hashValues_remote;
@colors = (	0, '#FF4545',  1, '#FF4845',  2, '#FF5145',  3, '#FF5B45',  4, '#FF6D45',
			5, '#FF7345',  6, '#FF7D45',  7, '#FF8345',  8, '#FF9945',  9, '#FF9C45',
			10, '#FFA245', 11, '#FFA545', 12, '#FFA845', 13, '#FFAE45', 14, '#FFB245',
			15, '#FFB845', 16, '#FFBB45', 17, '#FFC445', 18, '#FFC745', 19, '#FFCD45',
			20, '#FFD145', 21, '#FFD445', 22, '#FFDA45', 23, '#FFDD45', 24, '#FFE645',
			25, '#FFF045', 26, '#FFF345', 27, '#FFFC45', 28, '#F9FF45', 29, '#F0FF45',
			30, '#E6FF45', 31, '#E0FF45', 32, '#D7FF45', 33, '#D1FF45', 34, '#CAFF45',
			35, '#C4FF45', 36, '#C1FF45', 37, '#BBFF45', 38, '#B8FF45', 39, '#B5FF45',
			40, '#AEFF45', 41, '#A5FF45', 42, '#A2FF45', 43, '#99FF45', 44, '#96FF45',
			45, '#8FFF45', 46, '#8CFF45', 47, '#89FF45', 48, '#83FF45', 49, '#80FF45',
			50, '#7AFF45');
		
&determainOS;
&build_main_gui;
&build_welcome_win;
&build_imageMode_win;
&build_connection_win;
&build_transfer_win;
&build_io_win;
&build_ddOptions_win;
&build_checksum_win;
&build_confirmation_win; 
&build_status_win;
&definitions; 

MainLoop();

sub build_main_gui{
$maxStep = 5;


$mw = MainWindow->new(-title => 'ddAuto v 1.0');
$mw->geometry('625x450');
$mw->geometry (sprintf "+%d+%d", ($mw->screenwidth() - 625) / 2,($mw->screenheight() - 450) / 2);
$mw->resizable( 0, 0 );
$icon = $mw->Photo(-file=>$path.'/src/img/logo.gif');
$mw->Icon(-image=> $icon);
$mw->fontCreate('courier',
     -family=>'courier',
     -size=> 15
    );
	
	
	

$bottom = $mw->Frame->pack (-side => 'bottom', -fill => 'x', -pady => 5, -padx => 2);
$main   = $mw->Frame->pack (-side => 'bottom', -fill => 'both', -expand => 1);
$levels = $main->Frame->pack (-fill => 'both', -expand => 1);
$level_1 = $levels->Frame ()->pack (-fill => 'both', -expand => 1);
$level_2 = $levels->Frame ();
$level_3 = $levels->Frame ();
$level_4 = $levels->Frame ();
$level_5 = $levels->Frame ();
$level_6 = $levels->Frame ();
$level_7 = $levels->Frame ();
$level_8 = $levels->Frame ();
$level_9 = $levels->Frame ();

$cmd_start = $bottom->Button(-text => "Start", -width => 10, -command => \&next, -relief => 'groove', -takefocus => 1)->pack();
$cmd_next = $bottom->Button(-text => "Next >", -width => 10, -command => \&next, -takefocus => 1,-relief => 'groove');
$cmd_back = $bottom->Button(-text => "< Back", -width => 10, -command => \&back, -relief => 'groove');
$cmd_go= $bottom->Button(-text => "Go >", -width => 10, -command => \&go, -takefocus => 1,  -relief => 'groove');
$center_frame= $bottom->Frame()->pack(-anchor=>'center');
$cmd_stop= $bottom->Button(-text => "Stop", -width => 10, -command => \&stop, -relief => 'groove');
$cmd_exit= $center_frame->Button(-text => "Exit", -width => 10, -command => \&exit_, -relief => 'groove');
$cmd_startover= $center_frame->Button(-text => "Start Over", -width => 10, -command => \&startover, -relief => 'groove');
$cmd_viewreport= $center_frame->Button(-text => "View Report", -width => 10, -command => \&viewReport, -relief => 'groove');

$steps = $bottom->Label (
    -textvariable  => \$step
);
$level = 1;
$currentStep= 1;
$step = "Step: $currentStep | $maxStep";
}
     
sub next {

	if ($level == 1) { # imaging mode win
		
		$level_1->packForget();
		$level_2->pack(-fill => "both",  -expand => 1);
		$cmd_start->packForget();
		$cmd_next->pack(-side => 'right', -anchor => 'se');
		$cmd_back->pack(-side => 'left', -anchor => 'sw');
		$steps->pack(-fill => "x",  -expand => 1);
		$level = 2;
		
	}elsif ($level == 2) { #  connection mode win
		if ($mode eq 'Remote') {
			$level_2->packForget();
			$level_3->pack(-fill => "both",  -expand => 1);
			$mw->update();
			$level = 3;
			$maxStep = 7; 
			$currentStep++;
			$step = "Step: $currentStep | $maxStep";
		}else{
			$level_2->packForget();
			$level_5->pack(-fill => "both",  -expand => 1);
			$mw->update();
			$level = 5;
			$currentStep++;
			$step = "Step: $currentStep | $maxStep";
		}
	}elsif ($level == 3) { # transfer mode win
		$level_3->packForget();
		$level_4->pack(-fill => "both",  -expand => 1);
		$level = 4;
		$currentStep++;
		$step = "Step: $currentStep | $maxStep";
		if ($connection eq 'Sender'){		
				$portFrame->packForget();
				$ipaddressFrame->pack(-fill => 'x');
				$portFrame->pack(-fill => 'x');
			}		
			if ($connection eq 'Receiver'){
				$ipaddressFrame->packForget();				
			}		
		if ($mode eq 'Remote'){
			if ($connection eq 'Sender'){		
				$portFrame->packForget();
				$ipaddressFrame->pack(-fill => 'x');
				$portFrame->pack(-fill => 'x');
			}		
			if ($connection eq 'Receiver'){
				$ipaddressFrame->packForget();
			}		
		}	
	}elsif ($level == 4) { # paths win
		$isIPvalid = validateIP();
		 if ($isIPvalid eq 'false' && $connection eq 'Sender'){
			$mw -> messageBox(-message=>"You entered invalid IP!",-type=>'ok',-icon=>'error');
			return;
		 }		 
		 $isPortValid = validatePort();
		 if ($isPortValid eq 'false'){
			$mw -> messageBox(-message=>"You entered invalid Port!",-type=>'ok',-icon=>'error');
			return;
		 }
		if ($mode eq 'Remote'){
			if ($connection eq 'Sender'){		
				$paths_win_src->pack(-fill =>  'x');
				$paths_win_dst->packForget();
				$portFrame->packForget();
				$ipaddressFrame->pack(-fill => 'x');
				$portFrame->pack(-fill => 'x');
			}		
			if ($connection eq 'Receiver'){
				$paths_win_src->packForget();
				$paths_win_dst->pack(-fill =>  'x');
				$ipaddressFrame->packForget();				
			}		
		}	
		$level_4->packForget();
		$level_5->pack(-fill => "both",  -expand => 1);
		$level = 5;
		$currentStep++;
		$step = "Step: $currentStep | $maxStep";
	}elsif ($level == 5) { # dd options win
		if ($mode eq 'Local'){
			if (!$src_file_path){
				$mw -> messageBox(-message=>"You must provide an input device/file!",-type=>'ok',-icon=>'error');
				return;
			}		
			if (!$dst_file_path){
				$mw -> messageBox(-message=>"You must provide an output device/file!",-type=>'ok',-icon=>'error');
				return;
			}		
		}else{
			if ($connection eq 'Sender'){
				if (!$src_file_path){
					$mw -> messageBox(-message=>"You must provide an output device/file!",-type=>'ok',-icon=>'error');
					return;
				}
			}		
			if ($connection eq 'Receiver'){
				if (!$dst_file_path){
					$mw -> messageBox(-message=>"You must provide an output file!",-type=>'ok',-icon=>'error');
					return;
				}
			}		
			
		}		
	
		$level_5->packForget();
		if (($mode eq 'Remote') and ($connection eq 'Sender')) {
			&disableChecksums;
		
		}else{
			&enableChecksums;
		}
		$level_6->pack(-fill => "both",  -expand => 1);
		$level = 6;
		$currentStep++;
		$step = "Step: $currentStep | $maxStep";
	}elsif ($level == 6) { # checksum options win
		$level_7->pack(-fill => "both",  -expand => 1);
		$level_6->packForget();
		$level = 7;
		$currentStep++;
		$step = "Step: $currentStep | $maxStep";
	}elsif ($level == 7) { # confirmation win
		&updateConfirmationText;
		$level_7->packForget();
		$level_8->pack(-fill => "both",  -expand => 1);
		$cmd_next->packForget();
		$steps->packForget();
		$cmd_go->pack(-side => 'right', -anchor => 'se');
		$cmd_back->pack(-side => 'left', -anchor => 'sw');
		$steps->pack(-fill => "x",  -expand => 1);
		$level = 8;
		$currentStep++;
		$step = "Step: $currentStep | $maxStep";
	}
}	
sub back {
	if ($level == 2) {
		$currentStep= 1;
		$level_2->packForget();
		$level_1->pack(-fill => "both",  -expand => 1);
		$cmd_start->pack();
		$cmd_next->packForget();
		$cmd_back->packForget();
		$steps->packForget();
		$level = 1;
		$step = "Step: $currentStep | $maxStep";		
	}elsif ($level == 3) {
		$level_3->packForget();
		$level_2->pack(-fill => "both",  -expand => 1);
		$level = 2;
		$currentStep--;
		$step = "Step: $currentStep | $maxStep";
	}elsif ($level == 4) {
		$level_4->packForget();
		$level_3->pack(-fill => "both",  -expand => 1);
		$level = 3;
		$currentStep--;
		$step = "Step: $currentStep | $maxStep";
	}elsif ($level == 5) {
		$paths_win_src->packForget(-fill =>  'x');
		$paths_win_dst->packForget(-fill =>  'x');
		$paths_win_src->pack(-fill =>  'x');
		$paths_win_dst->pack(-fill =>  'x');
		if ($mode eq 'Remote') {
			$level_5->packForget();
			$level_4->pack(-fill => "both",  -expand => 1);
			$level = 4; 
		}else{
			$level_5->packForget();
			$level_2->pack(-fill => "both",  -expand => 1);
			$level = 2;
		}
		$currentStep--;
		$step = "Step: $currentStep | $maxStep";
	}elsif ($level == 6) {
		$level_6->packForget();
		$level_5->pack(-fill => "both",  -expand => 1);
		$level = 5;
		$currentStep--;
		$step = "Step: $currentStep | $maxStep";
	}elsif ($level == 7) {
		$level_7->packForget();
		$level_6->pack(-fill => "both",  -expand => 1);
		$level = 6;
		$currentStep--;
		$step = "Step: $currentStep | $maxStep";
	}elsif ($level == 8) {
		$level_8->packForget();
		$level_7->pack(-fill => "both",  -expand => 1);
		$level = 7;
		$cmd_go->packForget();
		$steps->packForget();
		$cmd_next->pack(-side => 'right');
		$cmd_back->pack(-side => 'left', -anchor => 'sw');
		$steps->pack(-fill => "x",  -expand => 1);
		$currentStep--;
		$step = "Step: $currentStep | $maxStep";
	}
}
sub go {
	if ($level == 8) {
		$process='Active';
		$level_8->packForget();
		$level_9->pack(-fill => "both",  -expand => 1);
		$cmd_stop->pack();
		$cmd_go->packForget();
		$steps->packForget();
		$cmd_back->packForget();
		$level = 8;
		if ($mode eq 'Local'){
			&startImaging_local;
		}else{
			&startImaging_remote;
		}
		
		
	}
}
sub startover{
	$level_9->packForget();
	$level_1->pack(-fill => "both",  -expand => 1);
	$cmd_start->pack();
	$cmd_startover->packForget();
	$cmd_exit->packForget();
	$cmd_viewreport->packForget();
	$steps->packForget();
	$level = 1;
	$maxStep = 5;
	$currentStep = 1;
	$step = "Step: $currentStep | $maxStep";	
	$process='Active';
	$percent_done=0;
}
sub stop {
	
if ($system eq 'Windows') {
	
	$remoteImagingControl->kill('KILL')->detach() if $mode eq 'Remote';
	$ddThread->kill('KILL')->detach();
	my $P = Win32::Process::List->new();
	
	my %list = $P->GetProcesses();
	foreach my $pid ( keys %list ) {
		my $name = $list{$pid};
		if ($name =~ /dd.exe/) {
			my $exitcode;
			Win32::Process::KillProcess ($pid, \$exitcode);
		}
	}
	unlink($dst_file_path);
}elsif ($system eq 'Linux' or $system eq 'Mac' ){
	
	$remoteImagingControl->kill('KILL')->detach() if $mode eq 'Remote';
	$ddThread->kill('KILL')->detach();
}

$cmd_startover->pack(-side=>'left',-anchor=>'center', -padx=>20);
$cmd_exit->pack(-side=>'left', -anchor=>'center', -padx=>20);
$cmd_stop->packForget();
$process = 'Aborted';

}
sub exit_{
exit(0);
} 
sub build_welcome_win{
$welcome_win = $level_1->LabFrame(-borderwidth => '2',-label => " Welcome ",-labelside => "acrosstop",)->pack(-fill => "both",  -expand => 1);
$welcome_win->Label (-textvariable  => \$defs{'welcome'},-anchor=> 'nw', -justify => 'left', -wraplength => 600)->pack(-fill => 'x', -anchor=> 'w');
}
sub build_imageMode_win{
$mode = 'Local';
		
$img_local = $mw->Photo(-file=>$path.'/src/img/local.gif');
$img_remote = $mw->Photo(-file=>$path.'/src/img/remote.gif');

$imagingMode_win = $level_2->LabFrame(-borderwidth => '2',-label => " Imaging Mode ",-labelside => "acrosstop")->pack(-fill => "both",  -expand => 1);
$imagingMode_win->Label (-textvariable  => \$defs{'imagingMode'},-anchor=> 'nw', -height => 6, -justify => 'left', -wraplength => 480)->pack(-fill => 'x', -anchor=> 'w');

$imagingMode_win_local =  $imagingMode_win->Frame(-relief => 'groove',-borderwidth => 2)->pack(-fill =>  'x');

$cmd_local = $imagingMode_win_local->Button(-image => $img_local, -command=> sub{$mode = 'Local';$maxStep = 5;$cmd_local->configure(-relief => 'solid');$cmd_remote->configure(-relief => 'raised');}, -width => 50, -height => 45, -relief => 'solid')->pack(-side=> 'left', -padx=>5, -pady=>5);
$imagingMode_win_local->Label (-text  => 'Local:', -justify  => 'left', -anchor => 'nw', -font => 'bold, 9')->pack(-side => 'top', -fill => 'x');
$imagingMode_win_local->Label (-textvariable  => \$defs{'Local'}, -justify  => 'left', -anchor => 'nw', -wraplength => 440)->pack(-side => 'top', -fill => 'x');

$imagingMode_win_remote =  $imagingMode_win->Frame(-relief => 'groove',-borderwidth => 2)->pack(-fill =>  'x');

$cmd_remote = $imagingMode_win_remote->Button(-image => $img_remote, -command=> sub{$mode = 'Remote';$maxStep = 7; $cmd_local->configure(-relief => 'raised');$cmd_remote->configure(-relief => 'solid');}, -width => 50, -height => 45)->pack(-anchor=> 'w', -padx=>5, -pady=>5)->pack(-side=> 'left', -padx=>5, -pady=>5);
$imagingMode_win_remote->Label (-text  => 'Remote:', -justify  => 'left', -anchor => 'nw', -font => 'bold, 9')->pack(-side => 'top', -fill => 'x');
$imagingMode_win_remote->Label (-textvariable  => \$defs{'Remote'}, -justify  => 'left', -anchor => 'nw', -wraplength => 440)->pack(-side => 'top', -fill => 'x');
}
sub build_connection_win{
$connection = 'Sender';
$ipaddressTxt;


$img_sender = $mw->Photo(-file=>$path.'/src/img/sender.gif');
$img_receiver = $mw->Photo(-file=>$path.'/src/img/receiver.gif');

$connection_win = $level_3->LabFrame(-borderwidth => '2',-label => " Connection Mode ",-labelside => "acrosstop")->pack(-fill => "both",  -expand => 1);

$connection_win->Label (-textvariable  => \$defs{'connection'},-anchor=> 'nw', -height => 6, -justify => 'left', -wraplength => 480)->pack(-fill => 'x', -anchor=> 'w');
$connection_win_sender =  $connection_win->Frame(-relief => 'groove',-borderwidth => 2)->pack(-fill =>  'x');

$cmd_sender = $connection_win_sender->Button(-image => $img_sender, -command=> sub{$connection = 'Sender'; $cmd_sender->configure(-relief => 'solid');$cmd_receiver->configure(-relief => 'raised');}, -width => 50, -height => 45, -relief => 'solid')->pack(-side=> 'left', -padx=>5, -pady=>5);
$connection_win_sender->Label (-text  => 'Sender Mode:', -justify  => 'left', -anchor => 'nw', -font => 'bold, 9')->pack(-side => 'top', -fill => 'x');
$connection_win_sender->Label (-textvariable  => \$defs{'Sender'}, -justify  => 'left', -anchor => 'nw', -wraplength => 440)->pack(-side => 'top', -fill => 'x');

$connection_win_receiver =  $connection_win->Frame(-relief => 'groove',-borderwidth => 2)->pack(-fill =>  'x');

$cmd_receiver = $connection_win_receiver->Button(-image => $img_receiver, -command=> sub{$connection = 'Receiver'; $cmd_sender->configure(-relief => 'raised');$cmd_receiver->configure(-relief => 'solid');}, -width => 50, -height => 45)->pack(-anchor=> 'w', -padx=>5, -pady=>5)->pack(-side=> 'left', -padx=>5, -pady=>5);
$connection_win_receiver->Label (-text  => 'Receiver Mode:', -justify  => 'left', -anchor => 'nw', -font => 'bold, 9')->pack(-side => 'top', -fill => 'x');
$connection_win_receiver->Label (-textvariable  => \$defs{'Receiver'}, -justify  => 'left', -anchor => 'nw', -wraplength => 440)->pack(-side => 'top', -fill => 'x');


}
sub build_transfer_win{
$transfer_mode = 'Netcat';
$transfer_mode_cmd = 'nc';
$port = 3333;

$img_netcat = $mw->Photo(-file=>$path.'/src/img/netcat.gif');
$img_cryptcat = $mw->Photo(-file=>$path.'/src/img/cryptcat.gif');
$transfer_win = $level_4->LabFrame(-borderwidth => '2',-label => " Tunneling  Mode ",-labelside => "acrosstop")->pack(-fill => "both",  -expand => 1);

$transfer_win->Label (-textvariable  => \$defs{'transfer'},-anchor=> 'nw', -height => 4, -justify => 'left', -wraplength => 480)->pack(-fill => 'x');

$transfer_win_netcat =  $transfer_win->Frame(-relief => 'groove',-borderwidth => 2)->pack(-fill =>  'both', -side=>'top', -anchor=> 'e');

$cmd_netcat = $transfer_win_netcat->Button(-image => $img_netcat, -command=> sub{$transfer_mode = 'Netcat';$transfer_mode_cmd = 'nc'; $cmd_netcat->configure(-relief => 'solid');$cmd_cryptcat->configure(-relief => 'raised');$keyFrame->packForget();}, -width => 50, -height => 45, -relief => 'solid')->pack(-side=> 'left', -padx=>5, -pady=>5);
$transfer_win_netcat->Label (-text  => 'Netcat:', -justify  => 'left', -anchor => 'nw', -font => 'bold, 9')->pack(-side => 'top', -fill => 'x');
$transfer_win_netcat->Label (-textvariable  => \$defs{'netcat'}, -justify  => 'left', -anchor => 'nw', -wraplength => 450)->pack(-side => 'top', -fill => 'x');

$transfer_win_cryptcat =  $transfer_win->Frame(-relief => 'groove',-borderwidth => 2)->pack(-fill =>  'x');

$cmd_cryptcat = $transfer_win_cryptcat->Button(-image => $img_cryptcat, -command=> sub{$transfer_mode = 'Cryptcat';$transfer_mode_cmd = 'cryptcat'; $cmd_netcat->configure(-relief => 'raised');$cmd_cryptcat->configure(-relief => 'solid');$keyFrame->pack(-fill =>  'x');}, -width => 50, -height => 45)->pack(-side=> 'left', -padx=>5, -pady=>5);
$transfer_win_cryptcat->Label (-text  => 'Cryptcat:', -justify  => 'left', -anchor => 'nw', -font => 'bold, 9')->pack(-side => 'top', -fill => 'x');
$transfer_win_cryptcat->Label (-textvariable  => \$defs{'cryptcat'}, -justify  => 'left', -anchor => 'nw', -wraplength => 450)->pack(-side => 'top', -fill => 'x');

############## Network Settings Frame
$connection_win_netOption = $transfer_win->LabFrame(-label => " Netcat/Cryptcat Network Settings ", -labelside => "acrosstop")->pack(-fill => "x");
$ipaddressFrame = $connection_win_netOption->Frame()->pack(-fill =>  'x');

$ipaddressFrame->Label (-text => 'Remote IP: ', -justify  => 'right', -anchor => 'e', -width => 10)->pack(-side => 'left');
$ipaddressTxt = $ipaddressFrame->Entry(-textvariable  => \$ipaddress, -background=>'white', -relief => 'groove' )->pack(-side=>'left', -anchor => 'w');
	
$portFrame = $connection_win_netOption->Frame()->pack(-fill =>  'x');
$portFrame->Label (-text => 'Port: ', -justify  => 'right', -anchor => 'e', -width => 10)->pack(-side => 'left');
$portTxt = $portFrame->Entry(-textvariable  => \$port, -background=>'white', -relief => 'groove', -width => 10 )->pack(-side=>'left', -anchor => 'w');

$keyFrame = $connection_win_netOption->Frame();
$keyFrame->Label (-text => 'Key: ', -justify  => 'right', -anchor => 'e', -width => 10)->pack(-side => 'left');
$keyTxt = $keyFrame->Entry(-textvariable  => \$key, -background=>'white', -relief => 'groove', -width => 10 )->pack(-side=>'left', -anchor => 'w');





}
sub build_io_win{
$src_file_path = '';
$dst_file_path = '';

$img_openFolder = $mw->Photo(-file=>$path.'/src/img/openFile.gif');
$paths_win = $level_5->LabFrame(-borderwidth => '2',-label => " IO Paths ",-labelside => "acrosstop")->pack(-fill => "both",  -expand => 1);

$paths_win->Label (-textvariable  => \$defs{'paths'},-anchor=> 'nw', -height => 6, -justify => 'left', -wraplength => 600)->pack(-fill => 'x', -anchor=> 'w');

$paths_win_src =  $paths_win->LabFrame(-label => "Input Device/File ",-relief => 'groove',-borderwidth => 2)->pack(-fill =>  'x');
$srcTxt = $paths_win_src->BrowseEntry(-textvariable=> \$src_file_path ,-borderwidth=>0, -style=> 'MSWin32', -background=>'white', -relief => 'flat',-font=>[-family=>'Courier', -size=> 12]  )->pack(-side=>'left', -anchor => 'w', -expand=>1, -fill=>'both', -ipadx=>7, -ipady=>5);
$paths_win_src->Button(-image => $img_openFolder, -command=> \&srcOpenFile)->pack(-side=>'top', -anchor => 'w', -ipadx=> 7, -ipady=> 7);
$srcTxt->insert('end', '');
if ($system eq 'Linux'){
	@getinfo = `cat /proc/partitions`;
	my $xx=0;
	foreach (@getinfo){
		chomp;	
		if ($_ =~ m/^.*\s+(\d+)\s+(sd[a-z]|hd[a-z])$/){
			$xx++; 
			$sizeReadable = scaleIt($1*1024);
			$srcTxt->insert('end', "Device$xx ($sizeReadable)");
			$devicesListNames{'/dev/'.$2} = ($1*1024); 
			$devicesListHardware{"Device$xx ($sizeReadable)"} = $2; 
		}
	}
	
}elsif ($system eq 'Mac'){
	@getinfo = `diskutil list | grep /dev/`;
	my $xx=0;
	foreach (@getinfo){
		chomp;	
		$line = `diskutil info $_ | grep 'Total Size:'`;
		if ($line =~ m/^.*\s+\((\d+)\s+Bytes\).*$/){
			$xx++;
			$sizeReadable = scaleIt($1);
			$srcTxt->insert('end', "Device$xx ($sizeReadable)");
			$devicesListNames{$_} = ($1); 
			$devicesListHardware{"Device$xx ($sizeReadable)"} = $_; 
		}
	}
	
}elsif ($system eq 'Windows'){
	@getinfo = `$cygwinPath/cat /proc/partitions`;

	my $xx=0;
	foreach (@getinfo){
		chomp;	
		
		if ($_ =~ m/^.*\s+(\d+)\s+(sd[a-z]|hd[a-z])$/){
			$xx++;
			$sizeReadable = scaleIt($1*1024);
			$srcTxt->insert('end', "Device$xx ($sizeReadable)");
			$devicesListNames{'/dev/'.$2} = ($1*1024); 
			$devicesListHardware{"Device$xx ($sizeReadable)"} = $2; 
		}
	}
}


$paths_win_dst =  $paths_win->LabFrame(-label => "Output File ",-relief => 'groove',-borderwidth => 2)->pack(-fill =>  'x');
$dstTxt = $paths_win_dst->Entry(-textvariable=> \$dst_file_path ,-background=>'white', -relief => 'flat',-font=>[-family=>'Courier', -size=> 12]  )->pack(-side=>'left', -anchor => 'w', -expand=>1, -fill=>'both', -ipadx=>5, -ipady=>5);
$paths_win_dst->Button(-image => $img_openFolder, -command=> \&dstSaveFile)->pack(-side=>'top', -anchor => 'w', -ipadx=> 7, -ipady=> 7);



}
 
sub build_ddOptions_win{
$dd_bs=512;

$ddOptions_win = $level_6->LabFrame(-borderwidth => '2',-label => " dd Options ",-labelside => "acrosstop")->pack(-fill => "both",  -expand => 1);
$ddOptions_win_top =  $ddOptions_win->Frame()->pack(-side =>  'top', -fill =>  'both');

############ left side of DD options frame
$ddOptions_win_left =  $ddOptions_win_top->Frame()->pack(-side =>  'left', -fill =>  'y');

$ddOptions_win_bs =  $ddOptions_win_left->Frame()->pack(-fill =>  'x');
$ddOptions_win_bs->Label (-width => 7, -text => 'BS', -anchor => 'w')->pack(-side=>'top', -expand=>1, -fill=>'both');
$ddOptions_win_bs_f =  $ddOptions_win_bs->Frame(-relief => 'groove',-borderwidth => 2)->pack(-fill =>  'x');
$bsTxt = $ddOptions_win_bs_f->BrowseEntry(-textvariable=> \$dd_bs ,-background=>'white', -relief => 'flat',-font=>[-family=>'Courier', -size=> 12]  )->pack(-side=>'top',-expand=>1, -fill=>'both', -ipadx=>5, -ipady=>5);
$bsTxt->insert('end', '');
$bsTxt->insert('end', '512');
$bsTxt->insert('end', '1024');
$bsTxt->insert('end', '2048');
$bsTxt->insert('end', '4096');
$bsTxt->insert('end', '8192');
$bsTxt->insert('end', '10240');
$bsTxt->insert('end', '16384');
$bsTxt->insert('end', '32768');
$bsTxt->insert('end', '65536');
$bsTxt->insert('end', '131072');



$ddOptions_win_ibs =  $ddOptions_win_left->Frame()->pack(-fill =>  'x');
$ddOptions_win_ibs->Label (-width => 7,-text => 'iBS',-anchor=> 'w')->pack(-side=>'top', -expand=>1, -fill=>'both');
$ibsTxt = $ddOptions_win_ibs->Entry(-textvariable=> \$dd_ibs, -relief => 'groove',-font=>[-family=>'Courier', -size=> 12] ,-background=>'white', -relief => 'flat')->pack(-side=>'top',-expand=>1, -fill=>'both', -ipadx=>5, -ipady=>5);

$ddOptions_win_obs =  $ddOptions_win_left->Frame()->pack(-fill =>  'x');
$ddOptions_win_obs->Label (-width => 7,-text => 'oBS',-anchor=> 'w')->pack(-side=>'top', -expand=>1, -fill=>'both');
$obsTxt = $ddOptions_win_obs->Entry(-textvariable=> \$dd_obs , -relief => 'groove',-font=>[-family=>'Courier', -size=> 12] ,-background=>'white', -relief => 'flat')->pack(-side=>'top',-expand=>1, -fill=>'both', -ipadx=>5, -ipady=>5);

$ddOptions_win_cbs =  $ddOptions_win_left->Frame()->pack(-fill =>  'x');
$ddOptions_win_cbs->Label (-width => 7,-text => 'CBS',-anchor=> 'w')->pack(-side=>'top', -expand=>1, -fill=>'both');
$cbsTxt = $ddOptions_win_cbs->Entry(-textvariable=> \$dd_cbs,  -relief => 'groove',-font=>[-family=>'Courier', -size=> 12] ,-background=>'white', -relief => 'flat')->pack(-side=>'top',-expand=>1, -fill=>'both', -ipadx=>5, -ipady=>5);

############ right side of DD options
$ddOptions_win_right =  $ddOptions_win_top->Frame()->pack(-side =>  'right', , -fill =>  'y');

$ddOptions_win_count =  $ddOptions_win_right->Frame()->pack(-fill =>  'x');
$ddOptions_win_count->Label (-width => 7, -text => 'COUNT',-anchor=> 'w')->pack(-side=>'top', -expand=>1, -fill=>'both');
$countTxt = $ddOptions_win_count->Entry(-textvariable=> \$dd_count ,-relief => 'groove',-font=>[-family=>'Courier', -size=> 12] ,-background=>'white', -relief => 'flat')->pack(-side=>'top',-expand=>1, -fill=>'both', -ipadx=>5, -ipady=>5);

$ddOptions_win_seek =  $ddOptions_win_right->Frame()->pack(-fill =>  'x');
$ddOptions_win_seek->Label (-width => 7,-text => 'SEEK',-anchor=> 'w')->pack(-side=>'top', -expand=>1, -fill=>'both');
$seekTxt = $ddOptions_win_seek->Entry(-textvariable=> \$dd_seek ,-relief => 'groove',-font=>[-family=>'Courier', -size=> 12] ,-background=>'white', -relief => 'flat')->pack(-side=>'top',-expand=>1, -fill=>'both', -ipadx=>5, -ipady=>5);

$ddOptions_win_skip =  $ddOptions_win_right->Frame()->pack(-fill =>  'x');
$ddOptions_win_skip->Label (-width => 7,-text => 'SKIP',-anchor=> 'w')->pack(-side=>'top', -expand=>1, -fill=>'both');
$skipTxt = $ddOptions_win_skip->Entry(-textvariable=> \$dd_skip ,-relief => 'groove',-font=>[-family=>'Courier', -size=> 12] ,-background=>'white', -relief => 'flat')->pack(-side=>'top',-expand=>1, -fill=>'both', -ipadx=>5, -ipady=>5);

$ddOptions_win_status =  $ddOptions_win_right->Frame()->pack(-fill =>  'x');
$ddOptions_win_status->Label (-width => 7,-text => 'STATUS',-anchor=> 'w')->pack(-side=>'top', -expand=>1, -fill=>'both');
$status = $ddOptions_win_status->Entry(-textvariable=> \$dd_status ,-relief => 'groove',-font=>[-family=>'Courier', -size=> 12] ,-background=>'white', -relief => 'flat')->pack(-side=>'top',-expand=>1, -fill=>'both', -ipadx=>5, -ipady=>5);

################## CONV Options
$ddOptions_win_otherOptions =  $ddOptions_win->Frame()->pack(-side=> 'left', -expand => 1, -fill=>'x');
$ddOptions_win_conv_frame =  $ddOptions_win_otherOptions->LabFrame(-label=> 'CONV Options ', -borderwidth => 2, -relief => 'groove')->pack(-side=>'left', -fill => 'x', -expand => 1);

$ddOptions_win_conv_c1 =  $ddOptions_win_conv_frame->Frame()->pack(-side => 'left', -expand => 1);
$ddOptions_win_conv_c1->Checkbutton(-variable=> \$ascii ,-text => "ascii")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_conv_c1->Checkbutton(-variable=> \$ebcdic, -text => "ebcdic")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_conv_c1->Checkbutton(-variable=> \$ibm, -text => "ibm")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_conv_c1->Checkbutton(-variable=> \$block, -text => "block")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_conv_c1->Checkbutton(-variable=> \$unblock, -text => "unblock")->pack(-side=> 'top', -anchor=> 'w');

$ddOptions_win_conv_c2 =  $ddOptions_win_conv_frame->Frame()->pack(-side => 'left', -expand => 1);
$ddOptions_win_conv_c2->Checkbutton(-variable=> \$lcase, -text => "lcase")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_conv_c2->Checkbutton(-variable=> \$ucase, -text => "ucase")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_conv_c2->Checkbutton(-variable=> \$nocreat, -text => "nocreat")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_conv_c2->Checkbutton(-variable=> \$excl, -text => "excl")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_conv_c2->Checkbutton(-variable=> \$notrunc, -text => "conv")->pack(-side=> 'top', -anchor=> 'w');

$ddOptions_win_conv_c3 =  $ddOptions_win_conv_frame->Frame()->pack(-side => 'left', -expand => 1);
$ddOptions_win_conv_c3->Checkbutton(-variable=> \$swab, -text => "notrunc")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_conv_c3->Checkbutton(-variable=> \$noerror, -text => "noerror")->pack(-side=> 'top', -anchor=> 'w')->select();

$ddOptions_win_conv_c3->Checkbutton(-variable=> \$sync, -text => "sync")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_conv_c3->Checkbutton(-variable=> \$fdatasync, -text => "fdatasync")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_conv_c3->Checkbutton(-variable=> \$fsync, -text => "fsync")->pack(-side=> 'top', -anchor=> 'w');

################## iFLAG Options
$ddOptions_win_iflag_frame =  $ddOptions_win_otherOptions->LabFrame(-label=> 'iFLAG Options ', -borderwidth => 2, -relief => 'groove')->pack(-side=>'right', -fill => 'x', -expand => 1);
$ddOptions_win_iflag_c1 =  $ddOptions_win_iflag_frame->Frame()->pack(-side => 'left', -expand => 1, -fill=>'x');

$ddOptions_win_iflag_c1->Checkbutton(-variable=> \$i_append, -text => "append")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_iflag_c1->Checkbutton(-variable=> \$i_direct, -text => "direct")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_iflag_c1->Checkbutton(-variable=> \$i_dsync, -text => "dsync")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_iflag_c1->Checkbutton(-variable=> \$i_sync, -text => "sync")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_iflag_c1->Checkbutton(-variable=> \$i_fullblock, -text => "fullblock")->pack(-side=> 'top', -anchor=> 'w');

$ddOptions_win_iflag_c2 =  $ddOptions_win_iflag_frame->Frame()->pack(-side => 'left', -fill => 'both');
$ddOptions_win_iflag_c2->Checkbutton(-variable=> \$i_nonblock, -text => "nonblock")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_iflag_c2->Checkbutton(-variable=> \$i_noatime, -text => "noatime")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_iflag_c2->Checkbutton(-variable=> \$i_noctty, -text => "noctty")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_iflag_c2->Checkbutton(-variable=> \$i_nofollow, -text => "nofollow")->pack(-side=> 'top', -anchor=> 'w');

################## oFLAG Options
$ddOptions_win_oflag_frame =  $ddOptions_win_otherOptions->LabFrame(-label=> 'oFLAG Options ', -borderwidth => 2, -relief => 'groove')->pack(-side=>'right', -fill => 'both', -expand => 1);
$ddOptions_win_oflag_c1 =  $ddOptions_win_oflag_frame->Frame()->pack(-side => 'left', -expand => 1, -fill=>'x');

$ddOptions_win_oflag_c1->Checkbutton(-variable=> \$o_append, -text => "append")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_oflag_c1->Checkbutton(-variable=> \$o_direct, -text => "direct")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_oflag_c1->Checkbutton(-variable=> \$o_dsync, -text => "dsync")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_oflag_c1->Checkbutton(-variable=> \$o_sync, -text => "sync")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_oflag_c1->Checkbutton(-variable=> \$o_fullblock, -text => "fullblock")->pack(-side=> 'top', -anchor=> 'w');

$ddOptions_win_oflag_c2 =  $ddOptions_win_oflag_frame->Frame()->pack(-side => 'left', -fill => 'both');
$ddOptions_win_oflag_c2->Checkbutton(-variable=> \$o_nonblock, -text => "nonblock")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_oflag_c2->Checkbutton(-variable=> \$o_noatime, -text => "noatime")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_oflag_c2->Checkbutton(-variable=> \$o_noctty, -text => "noctty")->pack(-side=> 'top', -anchor=> 'w');
$ddOptions_win_oflag_c2->Checkbutton(-variable=> \$o_nofollow, -text => "nofollow")->pack(-side=> 'top', -anchor=> 'w');

}
sub build_checksum_win{
#Container Frame
$Options_win = $level_7->Frame(-relief => 'groove', -borderwidth => '2')->pack(-fill => "both",  -expand => 1);

#Checksum Options Frame
$checksumOptions_win_frame =  $Options_win->LabFrame(-label=> 'Checksum Options ', -borderwidth => 2, -relief => 'groove')->pack(-anchor=> 'e', -side=>'top', -fill => 'both');
$checksumOptions_win_frame_c1 =  $checksumOptions_win_frame->Frame()->pack(-side => 'left', -expand => 1, -fill=>'x');
$checksumOptions_win_frame_c1->Checkbutton(-variable=> \$checksum_md5, -text => "MD5")->pack(-side=> 'top', -anchor=> 'w');
$checksumOptions_win_frame_c1->Checkbutton(-variable=> \$checksum_sha1, -text => "SHA-1")->pack(-side=> 'top', -anchor=> 'w');
$checksumOptions_win_frame_c1->Checkbutton(-variable=> \$checksum_sha256, -text => "SHA-256")->pack(-side=> 'top', -anchor=> 'w');
$checksumOptions_win_frame_c2 =  $checksumOptions_win_frame->Frame()->pack(-side => 'left', -expand => 1);
$checksumOptions_win_frame_c2->Checkbutton(-variable=> \$checksum_sha384, -text => "SHA-384")->pack(-side=> 'top', -anchor=> 'w');
$checksumOptions_win_frame_c2->Checkbutton(-variable=> \$checksum_sha512, -text => "SHA-512")->pack(-side=> 'top', -anchor=> 'w');
$checksumOptions_win_frame_c2->Checkbutton(-variable=> \$checksum_tiger, -text => "Tiger")->pack(-side=> 'top', -anchor=> 'w');
$checksumOptions_win_frame_c3 =  $checksumOptions_win_frame->Frame()->pack(-side => 'left', -expand => 1);
$checksumOptions_win_frame_c3->Checkbutton(-variable=> \$checksum_whirlpool, -text => "Whirlpool")->pack(-side=> 'top', -anchor=> 'w');
$checksumOptions_win_frame_c3->Checkbutton(-variable=> \$checksum_crc, -text => "CRC")->pack(-side=> 'top', -anchor=> 'w');
$checksumOptions_win_frame_c3->Checkbutton(-variable=> \$checksum_adler32, -text => "Adler32")->pack(-side=> 'top', -anchor=> 'w');

#Report Options Frame
$ReportOptions_win =  $Options_win->LabFrame(-label=> 'Report Options ', -borderwidth => 2, -relief => 'groove')->pack(-anchor=> 'e', -side=>'top', -fill => 'x');

$ReportOptions_win->Label (-text=> 'Title:')->pack(-side=>'top',-anchor=> 'w');
$reportTitle_txt = $ReportOptions_win->Entry(-textvariable=> \$reportTitle ,-width=> 30, -background=>'white', -relief => 'groove', -font=>[-family=>'Courier', -size=> 14] )->pack(-side=>'top', -anchor => 'w', -expand=>1, -fill=>'x', -ipadx=> 5, -ipady=> 5);

$ReportOptions_win->Label (-text=> 'Name:')->pack(-side=>'top',-anchor=> 'w');
$reportAuthor_txt = $ReportOptions_win->Entry(-textvariable=> \$reportAuthor ,-width=> 30, -background=>'white', -relief => 'groove', -font=>[-family=>'Courier', -size=> 14] )->pack(-side=>'top', -anchor => 'w', -expand=>1, -fill=>'x', -ipadx=> 5, -ipady=> 5);

$ReportOptions_win->Label (-text=> 'Organization:')->pack(-side=>'top',-anchor=> 'w');
$reportOrg_txt = $ReportOptions_win->Entry(-textvariable=> \$reportOrg ,-width=> 30, -background=>'white', -relief => 'groove', -font=>[-family=>'Courier', -size=> 14] )->pack(-side=>'top', -anchor => 'w', -expand=>1, -fill=>'x', -ipadx=> 5, -ipady=> 5);

}
sub build_confirmation_win{

$confirmation_win = $level_8->LabFrame(-borderwidth => '2',-label => " Confirmation ",-labelside => "acrosstop")->pack(-fill => "both",  -expand => 1);
$confirmTxt = $confirmation_win->Scrolled("ROText", -scrollbars => "se", -width => 50, -height => 12 )->pack();
$confirmTxt->pack(-side => 'bottom', -fill => 'both', -expand => 1);

  
}
sub build_status_win{
$status_win = $level_9->LabFrame(-borderwidth => '2',-label => " Status ",-labelside => "acrosstop")->pack(-fill => "both",  -expand => 1);

$status_frame = $status_win->Frame()->pack(-side=> 'top', -fill => 'x', -expand => 1);

$remainedTime = '00:00:00';
$status_frame_r = $status_frame->Frame()->pack(-side=> 'left', -fill => 'x', -expand => 1);
$status_frame_r->Label (-text=> 'Remaining Time:', -anchor => 'w')->pack( -side=>'top', -fill => 'x');
$status_frame_r->Entry (-textvariable=> \$remainedTime, -relief=>'groove', -state=> 'disabled', -font=>'courier')->pack(-side=>'top',-fill => 'none');

$elapsedTime = '00:00:00';
$status_frame_l = $status_frame->Frame()->pack(-side=> 'right', -fill => 'x', -expand => 1);
$status_frame_l->Label (-text=> 'Elapsed Time:', -anchor => 'e')->pack(-side=>'top',-fill=>'x');
$status_frame_l->Entry (-textvariable=> \$elapsedTime, -relief=>'groove', -state=> 'disabled', -font=>'courier',-justify => 'right')->pack(-side=>'top',-fill=>'none');

$percentage = '0%';
$status_frame_m = $status_frame->Frame()->pack(-side=> 'left', -fill => 'both', -expand => 1);
$status_frame_m->Label (-text=> 'Progress:', -anchor => 'w')->pack(-side=>'top',-fill=>'x');
$status_frame_m->Entry (-textvariable=> \$percentage,-relief=>'groove', -state=> 'disabled', -font=>'courier', -justify => 'center')->pack(-side=>'bottom', -fill => 'x');

$progress = $status_win->ProgressBar(-borderwidth=>1, -width => 20,-from => 0,-gap=>0,-to => 100,-blocks => 50,-colors => \@colors,-variable => \$percent_done)->pack(-fill => "x",  -expand => 1,  -pady=>0);
$summaryTxt = $status_win->Scrolled("ROText",-background => 'gray', -scrollbars => "se", -width => 50, -height => 12 )->pack();
$summaryTxt->pack(-side => 'bottom', -fill => 'both', -expand => 1);


}
sub setMode {
if ($_ eq 'Local'){
	$mode = 'Local'; $cmd_local->configure(-relief => 'solid');$cmd_remote->configure(-relief => 'raised');
	$mw->update();
}elsif ($_ eq 'Remote'){
	$mode = 'Remote'; 
	$cmd_remote->configure(-relief => 'solid');
	$cmd_local->configure(-relief => 'raised');
	$mw->update();
}
}
sub validateIP{
	$ipaddress_ = $ipaddressTxt->get;
	if( $ipaddress_ eq '' ){
			return 'false';
	}else{
		return 'true';
	}
}
sub validatePort{	
	$port_ = $portTxt->get;
	if( $port_ eq '' ){
			return 'false';
	}else{
		return 'true';
	}
}
sub srcOpenFile{
$src_file_path = $mw->getOpenFile();
if (!defined($src_file_path)){
	$src_file_path = "Error to open path";
}
$mw->update;
$src_path = $src_file_path;
$process = 'Active';

}
sub dstSaveFile{
$dst_file_path = $mw->getSaveFile();
if (!defined($dst_file_path)){
	$dst_file_path = "Error to open path";
}
$mw->update;
$dst_path = $dst_file_path;
}
sub updateConfirmationText{
$confirmMsg="";

$confirmMsg .= "Imaging Mode: $mode";
$confirmMsg .= "\nConnection Mode: $connection" if ($mode eq 'remote');
$confirmMsg .= "\nRemote IP: $ipaddress" if (($mode eq 'remote') and ($connection eq 'Sender' ));
$confirmMsg .= "\nPort: $port" if ($mode eq 'remote');
$confirmMsg .= "\nTunneling  Mode: $transfer_mode" if ($mode eq 'remote');

 
	
if ($src_file_path =~ m/^Device\d+\s+/){
	$src_file_path = '/dev/'.$devicesListHardware{$src_file_path};
}
$confirmMsg .= "\n\nInput Device/File: $src_file_path";
$confirmMsg .= "\nOutput File: $dst_file_path";

$confirmMsg .= "\n\nDD Options:";
$confirmMsg .= "\n     BS: $dd_bs K" if $dd_bs;
$confirmMsg .= "\n    iBS: $dd_ibs K" if $dd_ibs;
$confirmMsg .= "\n    oBS: $dd_obs K" if $dd_obs;
$confirmMsg .= "\n    CBS: $dd_cbs K" if $dd_cbs;
$confirmMsg .= "\n  COUNT: $dd_count K" if $dd_count;
$confirmMsg .= "\n   SEEK: $dd_seek K" if $dd_seek;
$confirmMsg .= "\n   SKIP: $dd_skip K" if $dd_skip;
$confirmMsg .= "\n STATUS: $dd_status" if $dd_status;

$confirmMsg .= "\n   CONV:" if ($ascii or $ebcdic or $ibm or $block or $unblock or $lcase or $ucase or $nocreat or $excl);
$confirmMsg .= " ascii," if $ascii;
$confirmMsg .= " ebcdic," if $ebcdic;
$confirmMsg .= " ibm," if $ibm;
$confirmMsg .= " block," if $block;
$confirmMsg .= " unblock," if $unblock;
$confirmMsg .= " lcase," if $lcase;
$confirmMsg .= " ucase," if $ucase;
$confirmMsg .= " nocreat," if $nocreat;
$confirmMsg .= " excl," if $excl;

$confirmMsg .= "\n  iFLAG:" if ($i_append or $i_direct or $i_dsync or $i_sync or $i_fullblock or $i_nonblock or $i_noatime or $i_noctty or $i_nofollow); 
$confirmMsg .= " append," if $i_append;
$confirmMsg .= " direct," if $i_direct;
$confirmMsg .= " dsync," if $i_dsync;
$confirmMsg .= " sync," if $i_sync;
$confirmMsg .= " fullblock," if $i_fullblock;
$confirmMsg .= " nonblock," if $i_nonblock;
$confirmMsg .= " noatime," if $i_noatime;
$confirmMsg .= " noctty," if $i_noctty;
$confirmMsg .= " nofollow," if $i_nofollow;

$confirmMsg .= "\n  oFLAG:" if ($o_append or $o_direct or $o_dsync or $o_sync or $o_fullblock or $o_nonblock or $o_noatime or $o_noctty or $o_nofollow);
$confirmMsg .= " append," if $o_append;
$confirmMsg .= " direct," if $o_direct;
$confirmMsg .= " dsync," if $o_dsync;
$confirmMsg .= " sync," if $o_sync;
$confirmMsg .= " fullblock," if $o_fullblock;
$confirmMsg .= " nonblock," if $o_nonblock;
$confirmMsg .= " noatime," if $o_noatime;
$confirmMsg .= " noctty," if $o_noctty;
$confirmMsg .= " nofollow," if $o_nofollow;


$confirmMsg .= "\n\nHash Options:\n" if ($checksum_md5 or $checksum_sha1 or $checksum_sha256 or $checksum_sha384 or $checksum_sha512 or $checksum_tiger or $checksum_whirlpool or $checksum_crc or $checksum_adler32);
$confirmMsg .= " MD5," if $checksum_md5;
$confirmMsg .= " SHA1," if $checksum_sha1;
$confirmMsg .= " SHA256," if $checksum_sha256;
$confirmMsg .= " SHA384," if $checksum_sha384;
$confirmMsg .= " SHA512," if $checksum_sha512;
$confirmMsg .= " Tiger," if $checksum_tiger;
$confirmMsg .= " Whirlpool," if $checksum_whirlpool;
$confirmMsg .= " crc," if $checksum_crc;
$confirmMsg .= " Adler32," if $checksum_adler32;

&ddUpdatOptions;
$confirmMsg .= "\n\ndd Full Command:\n".' '.$dd_cmd;


$confirmMsg .= "\n\nReport Options:\n" if ($reportTitle or $reportAuther or $reportOrg);
$confirmMsg .= " Title: $reportTitle" if $reportTitle;
$confirmMsg .= "\n Author: $reportAuthor" if $reportAuthor;
$confirmMsg .= "\n Organization: $reportOrg" if $reportOrg;


$confirmTxt->configure(-state => 'normal');
$confirmTxt->delete('0.0','end');
$confirmTxt->insert('end',$confirmMsg);

 
$mw->update();


}
sub ddCall{
	# Thread termination signal
    $SIG{'KILL'} = sub { threads->exit(); };
	system($dd_cmd);
	return'';
}
sub enableChecksums{
	for($checksumOptions_win_frame_c1->children){
      $_->configure(-state=>'normal');
	}
	for($checksumOptions_win_frame_c2->children){
		$childName = $_->cget('-text');
		if (($src_file_path =~ m/^Device\d+\s+/) and ($childName eq 'Tiger') and ($system eq 'Windows')  ){
			$_->configure(-state=>'disabled');
		}else{
			$_->configure(-state=>'normal');
		}	  
	}
   
	for($checksumOptions_win_frame_c3->children){
		if ( ($src_file_path =~ m/^Device\d+\s+/) and ($system eq 'Windows') ){
			$_->configure(-state=>'disabled');
		}else{
			$_->configure(-state=>'normal');
		}
	}
}

sub disableChecksums{
for($checksumOptions_win_frame_c1->children){
      $_->configure(-state=>'disabled');
   }
   for($checksumOptions_win_frame_c2->children){
      $_->configure(-state=>'disabled');
   }
   for($checksumOptions_win_frame_c3->children){
      $_->configure(-state=>'disabled');
   }
}
 
sub verifyIntegrity_local{

	$hashing_start_sec = time();
	$hash_verify_msg='';
	$report_msg='';
	
	 
	
	if ($checksum_md5 ){
		require Digest::MD5;
		if (($src_file_path =~ m/^\/dev\//) and ($system eq 'Windows')){
			$src_md5_msg = `$cygwinPath/md5sum $src_file_path`;
			chomp $src_md5_msg;
			($src_md5_msg, $_) = split /\s+/, $src_md5_msg;
		}else{
			$src_md5 = Digest::MD5->new;
			open(my $MD5S,'<',"$src_file_path") or die "Error to open the input media"; 
			binmode($MD5S);
			$src_md5->addfile($MD5S);
			$src_md5_msg = $src_md5->hexdigest;	
			close $MD5S;
		}
		
		$dst_md5 = Digest::MD5->new;
		open(my $MD5D,'<',"$dst_file_path") or die "Error to open the output image file"; 
		binmode($MD5D);
		$dst_md5->addfile($MD5D);
		$dst_md5_msg = $dst_md5->hexdigest;
		if ($src_md5_msg == $dst_md5_msg){
			$hash_verify_msg = $hash_verify_msg."MD5 Test: Match\n  Input: ".$src_md5_msg."\n Output: ".$dst_md5_msg."\n\n";
		}else{
			$hash_verify_msg = $hash_verify_msg."MD5 Test: Mismatch\n  Input: ".$src_md5_msg."\n Output: ".$dst_md5_msg."\n\n";
		}
	}
	if ($checksum_sha1 ){
	
		require Digest::SHA1;
		if (($src_file_path =~ m/^\/dev\//) and ($system eq 'Windows')){
			$src_sha1_msg = `$cygwinPath/sha1sum $src_file_path`;
			chomp $src_sha1_msg;
			($src_sha1_msg, $_) = split /\s+/, $src_sha1_msg;
		}else{
			$src_sha1 = Digest::SHA1->new;
			open(my $SHA1S,'<',"$src_file_path") or die "Error to open the input media"; 
			binmode($SHA1S);
			$src_sha1->addfile($SHA1S);
			$src_sha1_msg = $src_sha1->hexdigest;
			close $SHA1S;
		}
		
		$dst_sha1 = Digest::SHA1->new;
		open(my $SHA1D,'<',"$dst_file_path") or die "Error to open the output image file"; 
		binmode($SHA1D);
		$dst_sha1->addfile(*$SHA1D);
		$dst_sha1_msg = $dst_sha1->hexdigest;
		close $SHA1D;
		
		if ($src_sha1_msg == $dst_sha1_msg){
			$hash_verify_msg = $hash_verify_msg."SHA1 Test: Match\n  Input: ".$src_sha1_msg."\n Output: ".$dst_sha1_msg."\n\n";
		}else{
			$hash_verify_msg = $hash_verify_msg."SHA1 Test: Mismatch\n  Input: ".$src_sha1_msg."\n Output: ".$dst_sha1_msg."\n\n";
		}
	}
	if ($checksum_sha256 ){
		require Digest::SHA;
		if (($src_file_path =~ m/^\/dev\//) and ($system eq 'Windows')){
			$src_sha256_msg = `$cygwinPath/sha256sum $src_file_path`;
			chomp $src_sha256_msg;
			($src_sha256_msg, $_) = split /\s+/, $src_sha256_msg;
		}else{
			$src_sha256 = new Digest::SHA 256;
			open(my $SHA256S,'<',"$src_file_path") or die "Error to open the input media"; 
			binmode($SHA256S);
			$src_sha256->addfile($SHA256S);
			$src_sha256_msg = $src_sha256->hexdigest;
			close $SHA256S;
		}
		
		$dst_sha256 = new Digest::SHA 256;	 
		open(my $SHA256D,'<',"$dst_file_path") or die "Error to open the output image file"; 
		binmode($SHA256D);
		$dst_sha256->addfile($SHA256D);
		$dst_sha256_msg = $dst_sha256->hexdigest;
		close $SHA256D;
		
		if ($src_sha256_msg == $dst_sha256_msg){
			$hash_verify_msg = $hash_verify_msg."SHA256 Test: Match\n  Input: ".$src_sha256_msg."\n Output: ".$dst_sha256_msg."\n\n";
		}else{
			$hash_verify_msg = $hash_verify_msg."SHA256 Test: Mismatch\n  Input: ".$src_sha256_msg."\n Output: ".$dst_sha256_msg."\n\n";
		}
	}
	if ($checksum_sha384 ){
		require Digest::SHA;
		if (($src_file_path =~ m/^\/dev\//) and ($system eq 'Windows')){
			$src_sha384_msg = `$cygwinPath/sha384sum $src_file_path`;
			chomp $src_sha384_msg;
			($src_sha384_msg, $_) = split /\s+/, $src_sha384_msg;
		}else{
			$src_sha384 = new Digest::SHA 384;
			open(my $SHA384S,'<',"$src_file_path") or die "Error to open the input media"; 
			binmode($SHA384S);
			$src_sha384->addfile($SHA384S);
			$src_sha384_msg = $src_sha384->hexdigest;
			close $SHA384S;
		}
		
		$dst_sha384 = new Digest::SHA 384;
		open(my $SHA384D,'<',"$dst_file_path") or die "Error to open the output image file"; 
		binmode($SHA384D);
		$dst_sha384->addfile($SHA384D);
		$dst_sha384_msg = $dst_sha384->hexdigest;
		close $SHA384D;
		
		if ($src_sha384_msg == $dst_sha384_msg){
			$hash_verify_msg = $hash_verify_msg."SHA384 Test: Match\n  Input: ".$src_sha384_msg."\n Output: ".$dst_sha384_msg."\n\n";
		}else{
			$hash_verify_msg = $hash_verify_msg."SHA384 Test: Mismatch\n  Input: ".$src_sha384_msg."\n Output: ".$dst_sha384_msg."\n\n";
		}
	}
	if ($checksum_sha512 ){
		require Digest::SHA;
		if (($src_file_path =~ m/^\/dev\//) and ($system eq 'Windows')){
			$src_sha512_msg = `$cygwinPath/sha512sum $src_file_path`;
			chomp $src_sha512_msg;
			($src_sha512_msg, $_) = split /\s+/, $src_sha512_msg;
		}else{
			$src_sha512 = new Digest::SHA 512;
			open(my $SHA512S,'<',"$src_file_path") or die "Error to open the input media"; 
			binmode($SHA512S);
			$src_sha512->addfile($SHA512S);
			$src_sha512_msg = $src_sha512->hexdigest;
			close $SHA512S;
		}
		
		$dst_sha512 = new Digest::SHA 512;	 
		open(my $SHA512D,'<',"$dst_file_path") or die "Error to open the output image file"; 
		binmode($SHA512D);
		$dst_sha512->addfile($SHA512D);
		$dst_sha512_msg = $dst_sha512->hexdigest;
		close $SHA512D;
		
		if ($src_sha512_msg == $dst_sha512_msg){
			$hash_verify_msg = $hash_verify_msg."SHA512 Test: Match\n  Input: ".$src_sha512_msg."\n Output: ".$dst_sha512_msg."\n\n";
		}else{
			$hash_verify_msg = $hash_verify_msg."SHA512 Test: Mismatch\n  Input: ".$src_sha512_msg."\n Output: ".$dst_sha512_msg."\n\n";
		}
	}
	
	if ($checksum_tiger ){
		require Digest::Tiger; 
		open(my $TigerS,'<',"$src_file_path") or die "Error to open the input media"; 
		binmode($TigerS);
		$src_tiger_msg = Digest::Tiger::hexhash(<$TigerS>);
		close $TigerS;
	
		open(my $TigerD,'<',"$dst_file_path") or die "Error to open the output image file"; 
		binmode($TigerD);
		$dst_tiger_msg = Digest::Tiger::hexhash(<$TigerD>);
		close $TigerS;
		
		
		if ($src_tiger_msg == $dst_tiger_msg){
			$hash_verify_msg = $hash_verify_msg."Tiger Test: Match\n  Input: ".$src_tiger_msg."\n Output: ".$dst_tiger_msg."\n\n";
		}else{
			$hash_verify_msg = $hash_verify_msg."Tiger Test: Mismatch\n  Input: ".$src_tiger_msg."\n Output: ".$dst_tiger_msg."\n\n";
		}
	}
	if ($checksum_whirlpool ){
		require Digest::Whirlpool;
		$src_whirlpool = Digest::Whirlpool->new();
		open(my $WhirlpoolS,'<',"$src_file_path") or die "Error to open the input media"; 
		binmode($WhirlpoolS);
		$src_whirlpool->addfile($WhirlpoolS);
		$src_whirlpool_msg = $src_whirlpool->hexdigest;
		close $WhirlpoolS;

		$dst_whirlpool = Digest::Whirlpool->new();
		open(my $WhirlpoolD,'<',"$dst_file_path") or die "Error to open the input media"; 
		binmode($WhirlpoolD);
		$dst_whirlpool->addfile($WhirlpoolD);
		$dst_whirlpool_msg = $dst_whirlpool->hexdigest;
		close $WhirlpoolD;
	
		if ($src_whirlpool_msg == $dst_whirlpool_msg){
			$hash_verify_msg = $hash_verify_msg."Whirlpool Test: Match\n  Input: ".$src_whirlpool_msg."\n Output: ".$dst_whirlpool_msg."\n\n";
		}else{
			$hash_verify_msg = $hash_verify_msg."Whirlpool Test: Mismatch\n  Input: ".$src_whirlpool_msg."\n Output: ".$dst_whirlpool_msg."\n\n";
		}
	}
	if ($checksum_adler32 ){
		require Digest::Adler32;
		$src_adler32 = Digest::Adler32->new;
		open(my $Adler32S,'<',"$src_file_path") or die "Error to open the input media"; 
		binmode($Adler32S);
		$src_adler32->addfile($Adler32S);
		$src_adler32_msg = $src_adler32->hexdigest;	
		close $Adler32S;
		
		$dst_adler32 = Digest::Adler32->new;
		open(my $Adler32D,'<',"$dst_file_path") or die "Error to open the output image file"; 
		binmode($Adler32D);
		$dst_adler32->addfile($Adler32D);
		$dst_adler32_msg = $dst_adler32->hexdigest;
		close $Adler32D;
		
		if ($src_adler32_msg == $dst_adler32_msg){
			$hash_verify_msg = $hash_verify_msg."Adler32 Test: Match\n  Input: ".$src_adler32_msg."\n Output: ".$dst_adler32_msg."\n\n";
		}else{
			$hash_verify_msg = $hash_verify_msg."Adler32 Test: Mismatch\n  Input: ".$src_adler32_msg."\n Output: ".$dst_adler32_msg."\n\n";
		}
	}	
	if ($checksum_crc ){
		require Digest::CRC;
		$src_crc = Digest::CRC->new;		
		open(my $CRCS,'<',"$src_file_path") or die "Error to open the input media"; 
		binmode($CRCS);
		$src_crc->addfile($CRCS);
		$src_crc_msg = $src_crc->hexdigest;	
		close $CRCS;
		
		$dst_crc = Digest::CRC->new;
		open(my $CRCD,'<',"$dst_file_path") or die "Error to open the output image file"; 
		binmode($CRCD);
		$dst_crc->addfile($CRCD);
		$dst_crc_msg = $dst_crc->hexdigest;
		close $CRCD;
		
		if ($src_crc_msg == $dst_crc_msg){
			$hash_verify_msg = $hash_verify_msg."CRC Test: Match\n  Input: ".$src_crc_msg."\n Output: ".$dst_crc_msg."\n\n";
		}else{
			$hash_verify_msg = $hash_verify_msg."CRC Test: Mismatch\n  Input: ".$src_crc_msg."\n Output: ".$dst_crc_msg."\n\n";
		}
	}	
	$hashing_end_sec = time();
 	
	$hashing_duration = $hashing_end_sec - $hashing_start_sec;
	$report_msg .= 'Imaging Duration: '.$elapsedTime."\n";
	$report_msg .= 'Total Bytes Imaged: '.$total_Bytes."\n\n";		
	$report_msg .= "$hash_verify_msg\n";
	
	return "Done!\n\n$report_msg";
}
sub verifyIntegrity_remote{
	$hash_verify_msg='';
	$report_msg='';
	 
	 
	for my $i (0 .. $#hashList) {
		if ($hashValues[$i] == $hashValues_remote[$i]){
			if ($S_[0] eq 'Receiver'){
				$hash_verify_msg .= $hashList[$i]." Test: Matched\n  Input: ".$hashValues_remote[$i]."\n Output: ".$hashValues[$i]."\n\n";
			}else{
				$hash_verify_msg .= $hashList[$i]." Test: Matched\n  Input: ".$hashValues[$i]."\n Output: ".$hashValues_remote[$i]."\n\n";
			}
		}else{
			if ($S_[0] eq 'Receiver'){
				$hash_verify_msg .= $hashList[$i]." Test: Mismatched\n  Input: ".$hashValues_remote[$i]."\n Output: ".$hashValues[$i]."\n\n";
			}else{
				$hash_verify_msg .= $hashList[$i]." Test: Mismatched\n  Input: ".$hashValues[$i]."\n Output: ".$hashValues_remote[$i]."\n\n";
			}
		}
	}
	
	$report_msg .= 'Imaging Duration: '.$elapsedTime."\n";
	$report_msg .= 'Total Bytes Imaged: '.$total_Bytes."\n\n";		
	$report_msg .= "$hash_verify_msg\n";
	
	return "Done!\n\n$report_msg";
	
}
sub calcIntegrity_remote{
	$local_filePath = $_[0];
	$hashList = $_[1];
	$hashing_start_sec = time();
	
	$hashValues='';
	$report_msg='';
	
	if (index($hashList, 'MD5') != -1){
		if (($src_file_path =~ m/^\/dev\//) and ($system eq 'Windows')){
			$src_md5_msg = `$cygwinPath/md5sum $src_file_path`;
			chomp $src_md5_msg;
			($src_md5_msg, $_) = split /\s+/, $src_md5_msg;
			push(@hashValues,$src_md5_msg);	
		}else{
			require Digest::MD5;
			$src_md5 = Digest::MD5->new;
			open(my $MD5S,'<',"$local_filePath") or die "Error to open the input media"; 
			binmode($MD5S);
			$src_md5->addfile($MD5S);
			$src_md5_msg = `$cygwinPath/md5sum $local_filePath`;
			push(@hashValues,$src_md5->hexdigest);	
			close $MD5S;
		}
	}
	
	if (index($hashList, 'SHA1') != -1){
		if (($src_file_path =~ m/^\/dev\//) and ($system eq 'Windows')){
			$src_sha1_msg = `$cygwinPath/sha1sum $src_file_path`;
			chomp $src_sha1_msg;
			($src_sha1_msg, $_) = split /\s+/, $src_sha1_msg;
			push(@hashValues,$src_sha1_msg);	
		}else{
			require Digest::SHA1;
			$src_sha1 = Digest::SHA1->new;
			open(my $SHA1S,'<',"$local_filePath") or die "Error to open the input media"; 
			binmode($SHA1S);
			$src_sha1->addfile($SHA1S);
			push(@hashValues,$src_sha1->hexdigest);	
			close $SHA1S;
		}
	 
	}
	if (index($hashList, 'SHA256') != -1){
		if (($src_file_path =~ m/^\/dev\//) and ($system eq 'Windows')){
			$src_sha256_msg = `$cygwinPath/sha256sum $src_file_path`;
			chomp $src_sha256_msg;
			($src_sha256_msg, $_) = split /\s+/, $src_sha256_msg;
			push(@hashValues,$src_sha256_msg);	
		}else{
			require Digest::SHA;
			$src_sha256 = new Digest::SHA 256;
			open(my $SHA256S,'<',"$local_filePath") or die "Error to open the input media"; 
			binmode($SHA256S);
			$src_sha256->addfile($SHA256S);
			push(@hashValues,$src_sha256->hexdigest);			
			close $SHA256S;
		}
	}
	if (index($hashList, 'SHA384') != -1){
		if (($src_file_path =~ m/^\/dev\//) and ($system eq 'Windows')){
			$src_sha384_msg = `$cygwinPath/sha384sum $src_file_path`;
			chomp $src_sha384_msg;
			($src_sha384_msg, $_) = split /\s+/, $src_sha384_msg;
			push(@hashValues,$src_sha384_msg);	
		}else{
			require Digest::SHA;
			$src_sha384 = new Digest::SHA 384;
			open(my $SHA384S,'<',"$local_filePath") or die "Error to open the input media"; 
			binmode($SHA384S);
			$src_sha384->addfile($SHA384S);
			push(@hashValues,$src_sha384->hexdigest);	
			close $SHA384S;
		}
	}
	if (index($hashList, 'SHA512') != -1){
		if (($src_file_path =~ m/^\/dev\//) and ($system eq 'Windows')){
			$src_sha512_msg = `$cygwinPath/sha512sum $src_file_path`;
			chomp $src_sha512_msg;
			($src_sha512_msg, $_) = split /\s+/, $src_sha512_msg;
			push(@hashValues,$src_sha512_msg);	
		}else{
			require Digest::SHA;
			$src_sha512 = new Digest::SHA 512;
			open(my $SHA512S,'<',"$local_filePath") or die "Error to open the input media"; 
			binmode($SHA512S);
			$src_sha512->addfile($SHA512S);
			push(@hashValues,$src_sha512->hexdigest);	
			close $SHA512S;
		}
		
	}
	if (index($hashList, 'Tiger') != -1){		 
		if (not ($src_file_path =~ m/^\/dev\//)){
			require Digest::Tiger; 
			open(my $TigerS,'<',"$src_file_path") or die "Error to open the input media"; 
			binmode($TigerS);
			$src_tiger_msg = Digest::Tiger::hexhash(<$TigerS>);
			push(@hashValues,$src_tiger_msg->hexdigest);	
			close $TigerS;
		}
	}
	if (index($hashList, 'Whirlpool') != -1){
		if (not ($src_file_path =~ m/^\/dev\//)){
			require Digest::Whirlpool;
			open(my $WhirlpoolS,'<',"$local_filePath") or die "Error to open the input media"; 
			binmode($WhirlpoolS);
			$src_whirlpool->addfile($WhirlpoolS);
			push(@hashValues,$src_whirlpool->hexdigest);	
			close $WhirlpoolS;
		}
	}
	if (index($hashList, 'Adler32') != -1){
		if (not ($src_file_path =~ m/^\/dev\//)){
			$src_adler32 = Digest::Adler32->new;
			open(my $Adler32S,'<',"$local_filePath") or die "Error to open the input media"; 
			binmode($Adler32S);
			$src_adler32->addfile($Adler32S);
			push(@hashValues,$src_adler32->hexdigest);	
			lcose $Adler32S;
		}
	}	
	if (index($hashList, 'CRC') != -1){
		if (not ($src_file_path =~ m/^\/dev\//)){
			$src_crc = Digest::CRC->new;
			open(my $CRCS,'<',"$local_filePath") or die "Error to open the input media"; 
			binmode($CRCS);
			$src_crc->addfile($CRCS);
			push(@hashValues,$src_crc->hexdigest);	
			close $CRCS;
		}
	}	
	
	$hashing_end_sec = time();
 	
	$hashing_duration = $hashing_end_sec - $hashing_start_sec;
	$report_msg .= 'Imaging Duration: '.$elapsedTime."\n";
	$report_msg .= 'Total Bytes Imaged: '.$total_Bytes."\n\n";		
	$report_msg .= "$hash_verify_msg\n";
	
	return "Done!\n\n$report_msg";
}

sub getRemoteHashingList{
	@hashList = ();
	
	if ($checksum_md5 ){
		push(@hashList, 'MD5');	
	}
	if ($checksum_sha1 ){
		push(@hashList, 'SHA1');	
		 
	}
	if ($checksum_sha256 ){
		push(@hashList, 'SHA256');	
	}
	if ($checksum_sha384 ){
		push(@hashList, 'SHA384');	 
	}
	if ($checksum_sha512 ){
		push(@hashList, 'SHA512');	
	}
	if ($checksum_tiger ){
		push(@hashList, 'Tiger');	
	}
	if ($checksum_whirlpool ){
		push(@hashList, 'Whirlpool');	
	}
	if ($checksum_adler32 ){
		push(@hashList, 'Adler32');	 
	}	
	if ($checksum_crc ){
		push(@hashList, 'CRC');	
	}

	$hashList_ = join(":", @hashList);	
	return $hashList_;
	
}
sub startImaging_remote{

$remained_bytes;
$percentage='';
$time_min = 0;
$time_hr = 0;


if ($connection eq 'Sender'){
	
	if ($src_file_path =~ m/^\/dev\//){
		$src_file_size = $devicesListNames{$src_file_path};
		$total_Bytes = scaleIt($devicesListNames{$src_file_path});
	}else{
		$src_file_size = -s "$src_file_path";
		$total_Bytes = scaleIt($src_file_size);
	}
	

    # create a tcp connection to the specified host and port
	$summaryTxt->delete('0.0','end');
	$summaryTxt->insert('end',"Connecting to $ipaddress ....");
	$mw->update();
	sleep(5);
	
    my $receiver = IO::Socket::INET->new(Proto     => "tcp",
                                    PeerAddr  => $ipaddress,
                                    PeerPort  => $defaultPort);
    
	unless ($receiver){
		$summaryTxt->delete('0.0','end');
		$summaryTxt->insert('end',"Unable to connect to remote host at $ipaddress: $defaultPort");
		return '';
	 }

    $receiver->autoflush(1);              # so output gets there right away
	
	$summaryTxt->delete('0.0','end');
	$summaryTxt->insert('end',"Connected to $ipaddress");
	$mw->update();
	
		
	while (<$receiver>) {
		chomp;
		last if /Disconnected/;
		if (/Connected/){ print $receiver "RTS\n";}
		if (/CTS/) {print $receiver "Size=$src_file_size\n";}
		if (/SizeReceived/){print $receiver "Calldd\n";}
		if (/ddCalled/) {
			$ddThread = threads->create(\&ddCall);
			print $receiver "Start\n";  
			$summaryTxt->delete('0.0','end');
			$summaryTxt->insert('end','Imaging, please wait....');
			$time_start = time(); 		 
			$start_time = timeDate(); 	 
			$mw->update();
		}
		if (/BytesReceived=(.*)$/){
			if ($process eq 'Aborted'){
				$summaryTxt->delete('0.0','end');
				$summaryTxt->insert('end','Process aborted!');
				$percent_done = 0;
				$mw->update(); 
				return '';	
			}
			$dst_file_size_remote = int $1;
			
			$remained_bytes =  $src_file_size - $dst_file_size_remote;	
			$percent_done = ($dst_file_size_remote/$src_file_size)*100;
 
		
			$time_sec_temp = time()- $time_start;
			$elapsed_s_m_h = timeDiff($time_sec_temp);
			
			 
			if ($time_sec_temp > 1){ 
				$byte_copied_per_sec = ($dst_file_size_remote/$time_sec_temp);
				$remained_sec = int ($remained_bytes / $byte_copied_per_sec) + 1  if ($byte_copied_per_sec != 0);
				$remaining_s_m_h = timeDiff($remained_sec);
			}else{
				$remaining_s_m_h = '00:00:00';
			}
			
			if ($dst_file_size_remote==$src_file_size){
				$percentage ='100%';
				$elapsedTime = $elapsed_s_m_h;
				$remainedTime = '00:00:00';
				$summaryTxt->delete('0.0','end');
				$summaryTxt->insert('end','Verifing......'); 		
			}else{
				$ptmp = int($percent_done);
				$percentage=  $ptmp.'%';
				$elapsedTime = $elapsed_s_m_h;
				$remainedTime = $remaining_s_m_h;
			}
			$mw->update(); 
			
		 
			
			
		 
		}
		
		
		if (/HashRequest=(.*)$/){
		
			calcIntegrity_remote($src_file_path, $1);
			@hashList = split(/:/, $1);
			$hashValues_ = join(":", @hashValues);
			print $receiver "HashResponse=".$hashValues_."\n";
		}
		if (/HashResponse=(.*)$/){
			@hashValues_remote = split(/:/, $1);
			print $receiver "HashReceived\n";
		}
		
		if (/Finish/){
 
			$ddThread->detach();			
			print $receiver "Disconnect\n";
			$end_time = timeDate();
			if ($time_sec_temp != 0){
				$ratePerSec = scaleIt(int ($src_file_size / $time_sec_temp));
			}
			
			my $verify_msg = verifyIntegrity_remote("Sender");
			$summaryTxt->delete('0.0','end');
			$verify_msg .= "Full Report Path:\n$path/src/html/home.html";
			$summaryTxt->insert('end',$verify_msg);
			$cmd_startover->pack(-side=>'left',-anchor=>'center', -padx=>20);
			$cmd_viewreport->pack(-side=>'left',-anchor=>'center', -padx=>20);
			$cmd_exit->pack(-side=>'left', -anchor=>'center', -padx=>20);
			$cmd_stop->packForget();
			&generateReport;
			$process = 'over';
			last;
		
		}
    
	}
	
	
	
	
	shutdown($receiver,2);
	close $receiver;

}else{ # Receiver Mode

	
		
	$conn = IO::Socket::INET->new( Proto     => 'tcp',
									  LocalPort => $defaultPort,
									  Listen    => SOMAXCONN,
									  Reuse     => 1);

	unless ($conn){
		$summaryTxt->delete('0.0','end');
		$summaryTxt->insert('end',"Error to open a local port: $defaultPort");
		return '';
	 }

	$summaryTxt->delete('0.0','end');
	$summaryTxt->insert('end','Waiting for connection....');
	$mw->update(); 

	 while ($sender = $conn->accept()) {
		$sender->autoflush(1);
		
		$ipaddress = $sender->peerhost; 
		$summaryTxt->delete('0.0','end');
		$summaryTxt->insert('end','Connected to '.$ipaddress);
		$mw->update();
		
		sleep(5);
		
		print $sender "Connected\n";
		
		$src_file_size_remote;
		while ( <$sender>) {
		     chomp;
			 next unless /\S/;       	# blank line
			 if    (/Disconnect/i)    	{ print $sender "Disconnected\n";last;}
			 elsif (/^RTS/)    		{ print $sender "CTS\n";}
			 elsif (/^Size=(.*)$/ )     {print $sender "SizeReceived=$1\n"; $src_file_size_remote = $1;}
			 elsif (/^Calldd/ )      { $ddThread = threads->create(\&ddCall); print  $sender "ddCalled\n";}
			 elsif (/^Start/ )        { 
			
			$summaryTxt->delete('0.0','end');
			$summaryTxt->insert('end','Imaging, please wait....');
			$mw->update();
			$time_start = time(); 		 
			$start_time = timeDate(); 	 
			 

			$dst_file_size = 0;
			 
			while ($dst_file_size == $src_file_size_remote or $dst_file_size == 0){
					$dst_file_size = -s "$dst_file_path" if -e "$dst_file_path";
			}
			
			
			
			while ($dst_file_size <= $src_file_size_remote){
				$dst_file_size = -s "$dst_file_path";
				
				
				if ($process eq 'Aborted'){
					$summaryTxt->delete('0.0','end');
					$summaryTxt->insert('end','Process aborted!');
					$percent_done = 0;
					$mw->update(); 
					return '';	
				}
				 
				$remained_bytes =  $src_file_size_remote - $dst_file_size;	
				$percent_done = ($dst_file_size/$src_file_size_remote)*100;
				if (int($percent_done)<100){
					$ptmp = int($percent_done);
					$percentage=  $ptmp.'%';
					
				}else{
					$summaryTxt->delete('0.0','end');
					$summaryTxt->insert('end','Verifing......'); 		
				}
			
				$time_sec_temp = time()- $time_start;
				$elapsed_s_m_h = timeDiff($time_sec_temp);
				
				 
				if ($time_sec_temp > 1){ 
					$byte_copied_per_sec = ($dst_file_size/$time_sec_temp);
					$remained_sec = int ($remained_bytes / $byte_copied_per_sec) + 1  if ($byte_copied_per_sec != 0);
					$remaining_s_m_h = timeDiff($remained_sec);
				}else{
					$remaining_s_m_h = '00:00:00';
				}
				
				if ($dst_file_size==$src_file_size_remote){
					$percentage ='100%';
					$elapsedTime = $elapsed_s_m_h;
					$remainedTime = '00:00:00';
					print  $sender "BytesReceived=$dst_file_size\n";
					$mw->update(); 
					last;
					
				}
				
				
				$elapsedTime = $elapsed_s_m_h;
				$remainedTime = $remaining_s_m_h;
				
				$mw->update(); 
				print  $sender "BytesReceived=$dst_file_size\n";
				sleep(0.5);
				
				
			}
			
			
			$hashListTemp = getRemoteHashingList();
			print $sender "HashRequest=".$hashListTemp."\n";
			
			
			 
			 
			 
			 
		} elsif (/^HashResponse=(.*)$/){
				
			    $ddThread->detach();
				@hashValues_remote = split(/:/, $1);
				$hashListTemp = getRemoteHashingList();
				calcIntegrity_remote($dst_file_path, $hashListTemp);
				$hashValues_ = join(":", @hashValues);
				print $sender "HashResponse=".$hashValues_."\n";
			 
		} elsif (/^HashReceived/){
				
				print $sender "Finish\n";
				$end_time = timeDate();
				$time_sec_temp = 1 if $time_sec_temp == 0;
				$ratePerSec = scaleIt(int ($dst_file_size / $time_sec_temp));
				$total_Bytes = scaleIt($dst_file_size);
				my $verify_msg = verifyIntegrity_remote("Receiver");
				$summaryTxt->delete('0.0','end');
				$verify_msg .= "Full Report Path:\n$path/src/html/home.html";
				$summaryTxt->insert('end',$verify_msg);
				$cmd_startover->pack(-side=>'left',-anchor=>'center', -padx=>20);
				$cmd_viewreport->pack(-side=>'left',-anchor=>'center', -padx=>20);
				$cmd_exit->pack(-side=>'left', -anchor=>'center', -padx=>20);
				$cmd_stop->packForget();
				&generateReport;
				$process = 'over';
		} 
		
		} 
	shutdown( $sender, 2 );
	close $sender;
	last;
	}
} 
 
 
	return'';

}
sub startImaging_local{
	$remained_bytes;
	$percentage='';
	$time_start = time();
	$time_min = 0;
	$time_hr = 0;
	
	
	$summaryTxt->delete('0.0','end');
	$summaryTxt->insert('end','Imaging, please wait....');
	$mw->update();
	$start_time = timeDate();
	$ddThread = threads->create(\&ddCall);
	if ($src_file_path =~ m/^\/dev\//){
		$src_file_size = $devicesListNames{$src_file_path};
	}else{
		$src_file_size = -s "$src_file_path";
	}
	
	$dst_file_size = 0;
	# wait until to see any transfer progress
	while ($dst_file_size == $src_file_size or $dst_file_size == 0){
			$dst_file_size = -s "$dst_file_path" if -e "$dst_file_path";
	}
	
	
   	while ($dst_file_size <= $src_file_size) { 
		$dst_file_size = -s "$dst_file_path" if -e "$dst_file_path";
		if ($process eq 'Aborted'){
			$summaryTxt->delete('0.0','end');
			$summaryTxt->insert('end','Process aborted!');
			$percent_done = 0;
			$mw->update(); 
			return '';	
		}
		
		$remained_bytes =  $src_file_size - $dst_file_size;	
		$percent_done = ($dst_file_size/$src_file_size)*100;
		if (int($percent_done)<100){
			$ptmp = int($percent_done);
			$percentage=  $ptmp.'%';
		}else{
			$percentage=  '100%';
			$remainedTime = '00:00:00';
			$summaryTxt->delete('0.0','end');
			$summaryTxt->insert('end','Verifing......'); 		
			$mw->update();  
			last;
		}
		
		
		$time_sec_temp = time()- $time_start;
		
		#calculating the elabsed time
		$elapsed_s_m_h = timeDiff($time_sec_temp);
		
		
		
		#calculating the estimated remaining time
		if ($time_sec_temp > 1){ 
			$byte_copied_per_sec = ($dst_file_size/$time_sec_temp);
			$remained_sec = int ($remained_bytes / $byte_copied_per_sec) + 1  if ($byte_copied_per_sec != 0);
			$remaining_s_m_h = timeDiff($remained_sec);
		}else{
			$remaining_s_m_h = '00:00:00';
		}
		
		if ($dst_file_size==$src_file_size){
			$percentage ='100%';
			$remaining_s_m_h = '00:00:00';
		}
		
		#Format the L Time and ER Time
		$elapsedTime = $elapsed_s_m_h;
		$remainedTime = $remaining_s_m_h;
		
		$mw->update(); 
		sleep(0.5);
		 
	} # End of While
	
	$end_time = timeDate();
	$ddThread->detach();
	$ratePerSec = scaleIt(int ($src_file_size / $time_sec_temp));
	$total_Bytes = scaleIt($src_file_size);
	my $verify_msg = verifyIntegrity_local();
	$summaryTxt->delete('0.0','end');
	$verify_msg .= "Full Report Path:\n$path/src/html/home.html";
	$summaryTxt->insert('end',$verify_msg);
	
	$cmd_startover->pack(-side=>'left',-anchor=>'center', -padx=>20);
	$cmd_viewreport->pack(-side=>'left',-anchor=>'center', -padx=>20);
	$cmd_exit->pack(-side=>'left', -anchor=>'center', -padx=>20);
	$cmd_stop->packForget();
	&generateReport;
	$process = 'Over';
	
	
	
	
 }

sub changeState{
   my ($frame_,$state_)=@_;
   for($frame_->children){
      $_->configure(-state=>$state_);
   }
}
sub viewReport{
	if ($system eq 'Windows'){
		system("$path/src/html/home.html");
	}elsif($system eq 'Linux' or $system eq 'Mac'){
		system("firefox $path/src/html/home.html");
	}
} 
sub generateReport {
	open(my $REPORT,'>', "$path/src/html/home.html") or die "Error to open home page";
	open(my $REPORT_Template,'<', "$path/src/html/temp.html") or die "Error to open template page";
	$reportHeader = prepareReportHeader();
	$preChecks = prepareChecksums();
	$dd_options = prepareDDoptions();
	
	while (<$REPORT_Template>){
		$_ =~ s/\@Report_Header\@/$reportHeader/;
		$_ =~ s/\@Start_Time\@/$start_time/;
		$_ =~ s/\@End_Time\@/$end_time/;
		$_ =~ s/\@Total_Duration\@/$elapsedTime/;
		$_ =~ s/\@Imaging_Rate\@/$ratePerSec/;
		$_ =~ s/\@Total_Bytes\@/$total_Bytes/;
		$_ =~ s/\@Imaging_Mode\@/$mode/;
		
		if (($mode eq 'Local') or ($connection eq 'Sender')){
			$_ =~ s/\@SRC_Input\@/$src_file_path/;
		}else{
				$_ =~ s/\@SRC_Input\@/\\$ipaddress\\\*/;
		}
		if (($mode eq 'Local') or ($connection eq 'Receiver')){
			$_ =~ s/\@DST_Output\@/$dst_file_path/;
		}else{
			$_ =~ s/\@DST_Output\@/\\$ipaddress\\\*/;
		}
		$preChecks = 'None' if $preChecks eq '';
		$_ =~ s/\@Checksums\@/$preChecks/;
		$_ =~ s/\@dd_All_Options\@/$dd_options/;
		$_ =~ s/\@OS\@/$system/;
		print $REPORT $_;
	}
	close $REPORT;
	close $REPORT_Template;
} 
sub timeDate {
	@months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
	@weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
	($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
	$year = 1900 + $yearOffset;
	$timeDate = "$hour:$minute:$second, $weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
	return $timeDate; 
} 
sub determainOS{
	if ($^O eq 'MSWin32'){
		$system = 'Windows';
	}elsif ($^O eq 'darwin' or $^O eq 'MacOS'){
		$system = 'Mac';
	}elsif ($^O eq 'linux'){
		$system = 'Linux';
	}else{
		$system = 'Other';
	}
}
sub getTime {
	($second, $minute, $hour) = @_;
	$timeShort = "$hour:$minute:$second";
	return $timeShort; 
} 
sub timeDiff {

$tmpTimeCalc = $_[0];

$seconds = $tmpTimeCalc % 60;
$tmpTimeCalc = ($tmpTimeCalc - $seconds) / 60;
$minutes = $tmpTimeCalc % 60;
$tmpTimeCalc = ($tmpTimeCalc - $minutes) / 60;
$hours = $tmpTimeCalc % 24;

return sprintf ("%02d:%02d:%02d\n",$hours,$minutes,$seconds);
}
sub scaleIt{
    my( $size, $n ) =( shift, 0 );
    ++$n and $size /= (1024) until $size < (1024);
    return sprintf "%.2f %s", $size, ( qw[ bytes KB MB GB ] )[ $n ];
}
sub ddUpdatOptions{
$dd_all_options='';
	$dd_all_options .= ' bs='.$dd_bs if ($dd_bs);
	$dd_all_options .= ' ibs='.$dd_ibs if ($dd_ibs);
	$dd_all_options .= ' obs='.$dd_obs if ($dd_obs);
	$dd_all_options .= ' cbs='.$dd_cbs if ($dd_cbs);
	$dd_all_options .= ' count='.$dd_count if ($dd_count);
	$dd_all_options .= ' seek='.$dd_seek if ($dd_seek);
	$dd_all_options .= ' skip='.$dd_skip if ($dd_skip);
	$dd_all_options .= ' status='.$dd_status if ($dd_status);
	
	@dd_convOptions;
	$dd_convOptions_str =(' conv=') if ($ascii or $ebcdic or $ibm or $block or $unblock or $lcase or $ucase or $nocreat or $excl);
	push(@dd_convOptions,'ascii') if ($ascii);
	push(@dd_convOptions,'ebcdic') if ($ebcdic);
	push(@dd_convOptions,'ibm') if ($ibm);
	push(@dd_convOptions,'block') if ($block);
	push(@dd_convOptions,'unblock') if ($unblock);
	push(@dd_convOptions,'lcase') if ($lcase);
	push(@dd_convOptions,'ucase') if ($ucase);
	push(@dd_convOptions,'nocreat') if ($nocreat);
	push(@dd_convOptions,'excl') if ($excl);
	
	$dd_convOptions_str.= join(',',@dd_convOptions);
	
	@dd_iflagOptions;
	$dd_iflagOptions_str =(' iflag=') if ($i_append or $i_direct or $i_dsync or $i_sync or $i_fullblock or $i_nonblock or $i_noatime or $i_noctty or $i_nofollow);
	push(@dd_iflagOptions,'append') if ($i_append);
	push(@dd_iflagOptions,'direct') if ($i_direct);
	push(@dd_iflagOptions,'dsync') if ($i_dsync);
	push(@dd_iflagOptions,'sync') if ($i_sync);
	push(@dd_iflagOptions,'fullblock') if ($i_fullblock);
	push(@dd_iflagOptions,'nonblock') if ($i_nonblock);
	push(@dd_iflagOptions,'noatime') if ($i_noatime);
	push(@dd_iflagOptions,'noctty') if ($i_noctty);
	push(@dd_iflagOptions,'nofollow') if ($i_nofollow);
	
	$dd_iflagOptions_str.= join(',', @dd_iflagOptions);
	
	@dd_oflagOptions;
	$dd_oflagOptions_str =(' oflag=') if ($o_append or $o_direct or $o_dsync or $o_sync or $o_fullblock or $o_nonblock or $o_noatime or $o_noctty or $o_nofollow);
	push(@dd_oflagOptions,'append') if ($o_append);
	push(@dd_oflagOptions,'direct') if ($o_direct);
	push(@dd_oflagOptions,'dsync') if ($o_dsync);
	push(@dd_oflagOptions,'sync') if ($o_sync);
	push(@dd_oflagOptions,'fullblock') if ($o_fullblock);
	push(@dd_oflagOptions,'nonblock') if ($o_nonblock);
	push(@dd_oflagOptions,'noatime') if ($o_noatime);
	push(@dd_oflagOptions,'noctty') if ($o_noctty);
	push(@dd_oflagOptions,'nofollow') if ($o_nofollow);
	
	$dd_oflagOptions_str.= join(',', @dd_oflagOptions);
	
	$dd_all_options .= $dd_convOptions_str if ($dd_convOptions_str);
	$dd_all_options .= $dd_iflagOptions_str if ($dd_iflagOptions_str);
	$dd_all_options .= $dd_oflagOptions_str if ($dd_oflagOptions_str);

	if ($mode eq 'Local'){
			$dd_cmd = 'dd if="'.$src_file_path.'" of="'.$dst_file_path.'" '.$dd_all_options;
	}else{ # Remote
			$transfer_cmd_path;
			if ($transfer_mode eq 'Netcat'){
				$transfer_cmd_path = $ncPath.$transfer_mode_cmd; 
			}else{
				if( $key eq '' ) {
					$transfer_cmd_path = $cryptcatPath.$transfer_mode_cmd; 
				}else{
					$transfer_cmd_path = $cryptcatPath.$transfer_mode_cmd.' -k '.$key; 
				}
			}
			
			if ($connection eq 'Sender'){
				$dd_cmd = $cygwinPath.'dd if="'.$src_file_path.'" '.$dd_all_options .' | '.$transfer_cmd_path.' '.$ipaddress.' '.$port.' ';
			}else{ # Receiver
				$dd_cmd = $transfer_cmd_path.' -w3 -l -p '.$port.' | '.$cygwinPath.'dd of="'.$dst_file_path.'" '.$dd_all_options;				
			}
	
	}
}
sub definitions {

$defs{'welcome'} = 
'Welcome to ddAuto. The purpose of this tool is to provide the user with the power of the dd utility as well as providing the user with an intuitive interface. ddAuto provides the option for the user to output created images locally or to a remote computer using netcat/cryptcat.
Image integrity functionality is also provided by the tool. The user may choose to use MD5, SHA1, SHA2 or any other degist algorithm for hash verification. Most importantly, ddAuto allows the user to view the imaging completion percent as dd in the background as well as the estimated remaining time. 

For more details about the tool, please visit the following site:
https://code.google.com/p/ddauto';


$defs{'imagingMode'} = 
'The user have the option either to image devices/files on the same hard dirve or over the network';

$defs{'Local'} = 
'Local imaging will allow you to save your dd images to a local hard drive on your computer.';

$defs{'Remote'} = 
'Remote imaging will allow you to save your images to a remote system running netcat or cryptcat. Additional setup action is required of the user in order for this functionality to work.';

$defs{'connection'} = 
'Choose your connection mode from the following options';

$defs{'transfer'} = 
'Choose how you need the tool to transfer your image over the network';

$defs{'paths'} = 
'Input media can either point directly to a file, directory, or device that you wish to image. The user which runs this script must have read access to the specified directory. Output media points to the directory which you wish to save your image to. This is only applicable for local imaging.';

$defs{'confirm'} = 
'type some text here';

$defs{'Sender'} = 
'It allows the user to send a local device/file to a remote computer as the input for dd tool';

$defs{'Receiver'} = 
'It allows the user to receive a remote device/file to the local computer as the output for dd tool';

$defs{'ddOptions'} = 
'type some text here';

$defs{'netcat'} = 
'Netcat is an unencrypted way to transfer your image to a remote system. This option can be used for transfering an image over a trusted network.';

$defs{'cryptcat'} = 
'Cryptcat is an encrypted way to transfer your image to a remote system. This option should be used for transfering an image over an untrusted network.';

}

sub prepareChecksums{
	$checksumsStr = '';
	$checksum_icon = '';
	$match_icon = '<img width="18" height="18" title="Verified" style="cursor: pointer;" src="../img/check.gif"/>';
	$unmatch_icon = '<img width="18" height="18" title="Verified" style="cursor: pointer;" src="../img/x.gif"/>';

	if ($mode eq 'Local'){
		if ($checksum_md5){
			if ($src_md5_msg == $dst_md5_msg){
				$checksum_icon = $match_icon;
			}else{
				$checksum_icon = $unmatch_icon
			}
		$checksumsStr .= '	<p  style="padding:0;margin: 0;"><b>MD5:</b> '.$checksum_icon.'</p>'.
							'<table>'.
								'<tr>'.
									'<td class="formatLineR">Input:</td>'.
									'<td class="formatLineL">'.$src_md5_msg.'</td>'.
								'</tr>'.
								'<tr>'.
									'<td class="formatLineR">Output:</td>'.
									'<td class="formatLineL">'.$dst_md5_msg.'</td>'.
								'</tr>'.
							'</table>'.
							'<br/>';

		}

		if ($checksum_sha1){

			if ($src_sha1_msg == $dst_sha1_msg){
				$checksum_icon = $match_icon;
			}else{
				$checksum_icon = $unmatch_icon
			}
				
		$checksumsStr .= '	<p  style="padding:0;margin: 0;"><b>SHA1:</b> '.$checksum_icon.'</p>'.
							'<table>'.
								'<tr>'.
									'<td class="formatLineR">Input:</td>'.
									'<td class="formatLineL">'.$src_sha1_msg.'</td>'.
								'</tr>'.
								'<tr>'.
									'<td class="formatLineR">Output:</td>'.
									'<td class="formatLineL">'.$dst_sha1_msg.'</td>'.
								'</tr>'.
							'</table>'.
							'<br/>';
		}

		if ($checksum_sha256){

			if ($src_sha256_msg == $dst_sha256_msg){
				$checksum_icon = $match_icon;
			}else{
				$checksum_icon = $unmatch_icon
			}
				
		$checksumsStr .= '	<p  style="padding:0;margin: 0;"><b>SHA256:</b> '.$checksum_icon.'</p>'.
							'<table>'.
								'<tr>'.
									'<td class="formatLineR">Input:</td>'.
									'<td class="formatLineL">'.$src_sha256_msg.'</td>'.
								'</tr>'.
								'<tr>'.
									'<td class="formatLineR">Output:</td>'.
									'<td class="formatLineL">'.$dst_sha256_msg.'</td>'.
								'</tr>'.
							'</table>'.
							'<br/>';

		}

		if ($checksum_sha384){

			if ($src_sha384_msg == $dst_sha384_msg){
				$checksum_icon = $match_icon;
			}else{
				$checksum_icon = $unmatch_icon
			}	
				
		$checksumsStr .= '	<p  style="padding:0;margin: 0;"><b>SHA384:</b> '.$checksum_icon.'</p>'.
							'<table>'.
								'<tr>'.
									'<td class="formatLineR">Input:</td>'.
									'<td class="formatLineL">'.$src_sha384_msg.'</td>'.
								'</tr>'.
								'<tr>'.
									'<td class="formatLineR">Output:</td>'.
									'<td class="formatLineL">'.$dst_sha384_msg.'</td>'.
								'</tr>'.
							'</table>'.
							'<br/>';

		}

		if ($checksum_sha512){

			if ($src_sha512_msg == $dst_sha512_msg){
				$checksum_icon = $match_icon;
			}else{
				$checksum_icon = $unmatch_icon
			}
				
		$checksumsStr .= '	<p  style="padding:0;margin: 0;"><b>SHA512:</b> '.$checksum_icon.'</p>'.
							'<table>'.
								'<tr>'.
									'<td class="formatLineR">Input:</td>'.
									'<td class="formatLineL">'.$src_sha512_msg.'</td>'.
								'</tr>'.
								'<tr>'.
									'<td class="formatLineR">Output:</td>'.
									'<td class="formatLineL">'.$dst_sha512_msg.'</td>'.
								'</tr>'.
							'</table>'.
							'<br/>';

		}

		if ($checksum_tiger){

			if ($src_tiger_msg == $dst_tiger_msg){
				$checksum_icon = $match_icon;
			}else{
				$checksum_icon = $unmatch_icon
			}
				
		$checksumsStr .= '	<p  style="padding:0;margin: 0;"><b>Tiger:</b> '.$checksum_icon.'</p>'.
							'<table>'.
								'<tr>'.
									'<td class="formatLineR">Input:</td>'.
									'<td class="formatLineL">'.$src_tiger_msg.'</td>'.
								'</tr>'.
								'<tr>'.
									'<td class="formatLineR">Output:</td>'.
									'<td class="formatLineL">'.$dst_tiger_msg.'</td>'.
								'</tr>'.
							'</table>'.
							'<br/>';

		}


		if ($checksum_whirlpool){

			if ($src_whirlpool_msg == $dst_whirlpool_msg){
				$checksum_icon = $match_icon;
			}else{
				$checksum_icon = $unmatch_icon
			}
				
		$checksumsStr .= '	<p  style="padding:0;margin: 0;"><b>Whirlpool:</b> '.$checksum_icon.'</p>'.
							'<table>'.
								'<tr>'.
									'<td class="formatLineR">Input:</td>'.
									'<td class="formatLineL">'.$src_whirlpool_msg.'</td>'.
								'</tr>'.
								'<tr>'.
									'<td class="formatLineR">Output:</td>'.
									'<td class="formatLineL">'.$dst_whirlpool_msg.'</td>'.
								'</tr>'.
							'</table>'.
							'<br/>';

		}


		if ($checksum_adler32){

			if ($src_adler32_msg == $dst_adler32_msg){
				$checksum_icon = $match_icon;
			}else{
				$checksum_icon = $unmatch_icon
			}
				
		$checksumsStr .= '	<p  style="padding:0;margin: 0;"><b>Adler32:</b> '.$checksum_icon.'</p>'.
							'<table>'.
								'<tr>'.
									'<td class="formatLineR">Input:</td>'.
									'<td class="formatLineL">'.$src_adler32_msg.'</td>'.
								'</tr>'.
								'<tr>'.
									'<td class="formatLineR">Output:</td>'.
									'<td class="formatLineL">'.$dst_adler32_msg.'</td>'.
								'</tr>'.
							'</table>'.
							'<br/>';

		}


		if ($checksum_crc){

			if ($src_crc_msg == $dst_crc_msg){
				$checksum_icon = $match_icon;
			}else{
				$checksum_icon = $unmatch_icon
			}
				
		$checksumsStr .= '	<p  style="padding:0;margin: 0;"><b>CRC:</b> '.$checksum_icon.'</p>'.
							'<table>'.
								'<tr>'.
									'<td class="formatLineR">Input:</td>'.
									'<td class="formatLineL">'.$src_crc_msg.'</td>'.
								'</tr>'.
								'<tr>'.
									'<td class="formatLineR">Output:</td>'.
									'<td class="formatLineL">'.$dst_crc_msg.'</td>'.
								'</tr>'.
							'</table>'.
							'<br/>';

		}
	}else{
		for my $i (0 .. $#hashList) {
			if ($hashValues[$i] == $hashValues_remote[$i]){
				$checksum_icon = $match_icon;
			}else{
				$checksum_icon = $unmatch_icon
			}
			if ($S_[0] eq 'Receiver'){
			$checksumsStr .= '	<p  style="padding:0;margin: 0;"><b>CRC:</b> '.$checksum_icon.'</p>'.
							'<table>'.
								'<tr>'.
									'<td class="formatLineR">Input:</td>'.
									'<td class="formatLineL">'.$hashValues_remote[$i].'</td>'.
								'</tr>'.
								'<tr>'.
									'<td class="formatLineR">Output:</td>'.
									'<td class="formatLineL">'.$hashValues[$i].'</td>'.
								'</tr>'.
							'</table>'.
							'<br/>';
			
			}else{
			$checksumsStr .= '	<p  style="padding:0;margin: 0;"><b>CRC:</b> '.$checksum_icon.'</p>'.
							'<table>'.
								'<tr>'.
									'<td class="formatLineR">Input:</td>'.
									'<td class="formatLineL">'.$hashValues[$i].'</td>'.
								'</tr>'.
								'<tr>'.
									'<td class="formatLineR">Output:</td>'.
									'<td class="formatLineL">'.$hashValues_remote[$i].'</td>'.
								'</tr>'.
							'</table>'.
							'<br/>';
			
			}
		}
	}

	return $checksumsStr;
}

sub prepareDDoptions{

$dd_options='';

$dd_options .= "<tr><td><b>BS:</b></td><td>$dd_bs K</td>" if $dd_bs;
$dd_options .= "<tr><td><b>iBS:</b></td><td>$dd_ibs K</td></tr>" if $dd_ibs;
$dd_options .= "<tr><td><b>oBS:</b></td><td>$dd_obs K</td></tr>" if $dd_obs;
$dd_options .= "<tr><td><b>CBS:</b></td><td>$dd_cbs K</td></tr>" if $dd_cbs;
$dd_options .= "<tr><td><b>COUNT:</b></td><td>$dd_count K</td></tr>" if $dd_count;
$dd_options .= "<tr><td><b>SEEK:</b></td><td>$dd_seek K</td></tr>" if $dd_seek;
$dd_options .= "<tr><td><b>SKIP:</b></td><td>$dd_skip K</td></tr>" if $dd_skip;
$dd_options .= "<tr><td><b>STATUS:</b></td><td>$dd_status</td></tr>" if $dd_status;

 
$dd_options .= '<tr><td><b>CONV:</b></td><td>' if (	$ascii or $ebcdic or $ibm or $block or $unblock or $lcase or $ucase or $nocreat or $excl or 
										$notrunc or $swab or $noerror or $sync or $fdatasync or $fsync  );
$dd_options .= ' ascii,' if $ascii;
$dd_options .= ' ebcdic,' if $ebcdic;
$dd_options .= ' ibm,' if $ibm;
$dd_options .= ' block,' if $block;
$dd_options .= ' unblock,' if $unblock;
$dd_options .= ' lcase,' if $lcase;
$dd_options .= ' ucase,' if $ucase;
$dd_options .= ' nocreat,' if $nocreat;
$dd_options .= ' excl,' if $excl;
$dd_options .= ' notrunc,' if $notrunc;
$dd_options .= ' swab,' if $swab;
$dd_options .= ' noerror,' if $noerror;
$dd_options .= ' sync,' if $sync;
$dd_options .= ' fdatasync,' if $fdatasync;
$dd_options .= ' fsync,' if $fsync;
$dd_options .= '</td></tr>';



$dd_options .= '<tr><td><b>iFLAG:</b></td><td>' if ($i_append or $i_direct or $i_dsync or $i_sync or $i_fullblock or $i_nonblock or $i_noatime or $i_noctty or $i_nofollow); 
$dd_options .= ' append,' if $i_append;
$dd_options .= ' direct,' if $i_direct;
$dd_options .= ' dsync,' if $i_dsync;
$dd_options .= ' sync,' if $i_sync;
$dd_options .= ' fullblock,' if $i_fullblock;
$dd_options .= ' nonblock,' if $i_nonblock;
$dd_options .= ' noatime,' if $i_noatime;
$dd_options .= ' noctty,' if $i_noctty;
$dd_options .= ' nofollow,' if $i_nofollow;
$dd_options .= '</td></tr>';
 

$dd_options .= '<tr><td><b>oFLAG:</b></td><td>' if ($o_append or $o_direct or $o_dsync or $o_sync or $o_fullblock or $o_nonblock or $o_noatime or $o_noctty or $o_nofollow);
$dd_options .= ' append,' if $o_append;
$dd_options .= ' direct,' if $o_direct;
$dd_options .= ' dsync,' if $o_dsync;
$dd_options .= ' sync,' if $o_sync;
$dd_options .= ' fullblock,' if $o_fullblock;
$dd_options .= ' nonblock,' if $o_nonblock;
$dd_options .= ' noatime,' if $o_noatime;
$dd_options .= ' noctty,' if $o_noctty;
$dd_options .= ' nofollow,' if $o_nofollow;
$dd_options .= '</td></tr>';

return $dd_options;
 

}

sub prepareReportHeader{

$reportHader='';

if ($reportTitle ne '' or $reportAuthor ne '' or $reportOrg ne '' ){
	$reportHader = '<table class="table" style="border-collapse: separate;border-spacing: 2px  2px;" >';
}

if ($reportTitle ne '') {

$reportHader .= '<tr>
				<td class="heads"><h4>Title</h4></td>
				<td><h4>'.$reportTitle.'</h4></td>
				</tr>';
}

if ($reportAuthor ne '') {

$reportHader .= '<tr>
				<td class="heads"><h4>Author</h4></td>
				<td><h4>'.$reportAuthor.'</h4></td>
				</tr>';
}

if ($reportOrg ne '') {

$reportHader .= '<tr>
				<td class="heads"><h4>Organization</h4></td>
				<td><h4>'.$reportOrg.'</h4></td>
				</tr>';
}


return $reportHader;


}