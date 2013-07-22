#!/usr/bin/perl

my $data_dir = '/var/lib/munin/ohsu.edu';
my $err_file = '/var/log/munin-error';
my $status_file = '/var/log/munin-check-status';

########################

use strict;
use warnings;
use File::Spec;

my $oldest;
my $oldest_time;
my $file_spec = File::Spec->catfile($data_dir, '*.rrd');
my $min_time = (time - (60 * 60));  #1 hour

`echo "" > $err_file`;

foreach (glob $file_spec) {
   my $time = (stat $_)[9];
   if (!$oldest_time || $time < $oldest_time) {
      $oldest      = $_;
      $oldest_time = $time;
   }

   if ($time < $min_time){
      `echo $_ >> $err_file`;
   }
}

#print "Oldest file was: " . (time - $oldest_time) . " seconds\n";

if (!-e $err_file || $oldest_time < $min_time){
   `touch $err_file`;
}
else {
   `touch $status_file`;
}
