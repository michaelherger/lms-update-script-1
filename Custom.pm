package Slim::Utils::OS::Custom;

# Custom OS file for piCore 8.x   http://www.tinycore.net
#
# This version only downloads the update link to
# /tmp/slimupdate/update_url
#
# Revision 1.1
# 2017-04-16	Removed /proc from a music path
#

use strict;
use warnings;

use base qw(Slim::Utils::OS::Linux);

use constant MAX_LOGSIZE => 1024*1024*1; # maximum log size: 1 MB
use constant UPDATE_DIR  => '/tmp/slimupdate';

sub initDetails {
	my $class = shift;

	$class->{osDetails} = $class->SUPER::initDetails();
	$class->{osDetails}->{osName} = 'piCore';

	return $class->{osDetails};
}

sub getSystemLanguage { 'EN' }

sub localeDetails {
	my $lc_ctype = 'utf8';
	my $lc_time = 'C';
       
	return ($lc_ctype, $lc_time);
}

=head2 dirsFor( $dir )

Return OS Specific directories.

Argument $dir is a string to indicate which of the server directories we
need information for.

=cut

sub dirsFor {
	my ($class, $dir) = @_;

	my @dirs;
	
	if ($dir eq 'updates') {

        mkdir UPDATE_DIR unless -d UPDATE_DIR;
        	
		@dirs = (UPDATE_DIR);
	}
	else {
		@dirs = $class->SUPER::dirsFor($dir);
	}

	return wantarray() ? @dirs : $dirs[0];
}

# don't download/cache firmware for other players, but have them download directly
sub directFirmwareDownload { 1 };

sub canAutoUpdate { 1 }
sub installerExtension { 'tgz' }
sub installerOS { 'nocpan' }

sub getUpdateParams {
	my ($class, $url) = @_;
	
	if ($url) {
		my ($version, $revision) = $url =~ /(\d+\.\d+\.\d+)(?:.*(\d{5,}))?/;
		$revision ||= '';
		$::newVersion = Slim::Utils::Strings::string('PICORE_UPDATE_AVAILABLE', "$version - $revision", $url);
		
		require File::Slurp;
			
		if ( File::Slurp::write_file(UPDATE_DIR . '/update_url', $url) ) {
			main::INFOLOG && Slim::Utils::Log::logger('server.update')->info("Setting update url file to: $url"); 
		}
		else {
			Slim::Utils::Log::logger('server.update')->warn("Unable to update version file: $updateFile");
		}
	}
	
	return;
}                                                                                               

sub logRotate {
	# only keep small log files (1MB) because they are in RAM
	Slim::Utils::OS->logRotate($_[1], MAX_LOGSIZE);
}       

sub ignoredItems {
	return (
		'bin'	=> '/',
		'dev'	=> '/',
		'etc'	=> '/',
		'opt'	=> '/',
		'init'	=> '/',
		'root'	=> '/',
		'sbin'	=> '/',
		'tmp'	=> '/',
		'var'	=> '/',
		'lib'	=> '/',
		'run'	=> '/',
		'sys'	=> '/',
		'usr'	=> '/',
		'proc'  => '/',
		'lost+found'=> 1,
	);
}

1;

