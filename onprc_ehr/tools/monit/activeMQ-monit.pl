#!/usr/bin/perl
#
# This script can be used for monitoring an ActiveMQ JMS Broker. 
# The script will connect to the broker, place a message in the monitTestQueue 
# and then pull the message back off the queue.  
# 
# If the test is a success, it will
#   1. check if the $statusFile exists, if not, then it will create it. 
# 
# If any portion of the test is a failure, the script will 
#   1. delete the $statusFile
#   2. write the error message(s) to the $errorFile
#
# This script was modified from the script found at 
# http://it.toolbox.com/blogs/unix-sysadmin/monitoring-activemq-from-nagios-27743
#
# NOTE: you must enable stomp in activemq.xml by adding the following to the <transportConnectors> tag:
# <transportConnector name="stomp" uri="stomp://localhost:61613"/>
#
# B.Connolly @ LabKey
# B.Bimber @ 
#
 
use strict;
use Net::Stomp;

my $time = time;
my $host = "prc-labkey1.ohsu.edu";
my $hostname = `hostname`;
my $queue = "/queue/monitTestQueue." . $hostname;
my %error = ('ok'=>0,'warning'=>1,'critical'=>2);
my $statusFile = "/var/log/activeMQ-monit-check.status";
my $errorFile = "/var/log/activeMQ-monit-check.lasterror";
my ($exitcode, $evalcount);

# Test if the ActiveMQ broker is running 
my $stomp = Net::Stomp->new({ 
    hostname => "$host",
    port     => "61613"
});

$stomp->connect( );

# Send test message containing $time timestamp.
$stomp->send({
    destination => "$queue",
    body        => "$time"
});

# Subscribe to messages from the $queue.
$stomp->subscribe({
    destination             => "$queue",
    'ack'                   => 'client',
    'activemq.prefetchSize' => 1
});

# Wait max 5 seconds for message to appear.
my $can_read = $stomp->can_read({ timeout => "10" });
if (!$can_read){
    logError("Unable to receive message");
    exit;
}	
	
my $success;
while ($can_read){
    # There is a message to collect.
    my $frame = $stomp->receive_frame;
    $stomp->ack( { frame => $frame } );
    my $framebody=$frame->body;

    if ( $framebody eq $time ) {
        `touch $statusFile`;
        $success = 1;
    }
    else {
    	logError("Incorrect message body; Message body should be \"$time\", but was \"$framebody\"");
    }
    
    #try the next message.  this would only occur if the previous cron job timed out
    $can_read = $stomp->can_read({ timeout => "5" });
}

if (!$success){
    logError("Unable to read the proper message body");
}	

sub logError(){
    my $msg = shift;

    # There was an error. We received the incorrect message text. Delete the $statusFile (indicating an error to monitoring system)
    # and write the error message to the $errFile
    #unlink($statusFile);
    open (ERRFILE, ">> $errorFile");
    print ERRFILE time."\tWARNING: $msg\n";
    close (ERRFILE);
}
	
