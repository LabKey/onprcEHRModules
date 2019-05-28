#!/usr/bin/perl
#
# Script to execute various DB SQL statements to monitor SQLServer status
#
# * Install and configure FreeTDS and DBD::Sybase.  Instructions can be found here: http://www.perlmonks.org/?node_id=392385
# - DBD::Sybase is prefered over ODBC because of strange TEXT field handling in DBD::ODBC
#
# Example
# /etc/freetds/freetds.conf:
# [MyHost]
#        host = MyHost.domain.com
#        port = 1433
#        tds version = 7.0
#

use strict;
use Data::Dumper;
use Text::Trim;
use DBI;
use DBD::Sybase;
use MIME::Base64;

my $host = undef;
my $err_file = '/var/log/sqlserver-monitor-error';
my $status_file = '/var/log/sqlserver-monitor-status';

# note: eventually we will want these in the environment, so we dont see to store password in the file, but for debugging/writing
#it should be easier to hard code them here
my $dsn    = $ENV{dsn}    || $host;
my $dbuser = $ENV{dbuser} || undef;
my $dbpass = $ENV{dbpass} || undef;

my $dbh = DBI->connect("DBI:Sybase:$dsn", $dbuser, $dbpass, { PrintError => 1, AutoCommit => 1 });

# evaluate each query.  each item has SQL to return a numeric column called 'metric'.  it should typically return a single row;
# however if more than 1 row it returned the code will iterate each row
# if 'metric' is above the provided threshold, the supplied error is written to the error log
my $queries = {
    longrunning => {
        sql => q(SELECT DATEDIFF(MINUTE, er.start_time, GETDATE()) as metric, qt.text, sp.hostname, sp.hostprocess, sp.blocked, sp.loginame,sp.status, sp.cmd
                 FROM sys.dm_exec_requests er INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
                 CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)as qt
                 WHERE session_Id > 50 AND session_Id NOT IN (@@SPID) AND DATEDIFF(MINUTE, er.start_time, GETDATE()) > 10),
        message => 'Query running longer than 10 minutes, execute stored procedure master.dbo.dba_WhatSQLIsExecuting for further information.',
    }
};

#reset error log
`echo "" > $err_file`;
my $has_error = 0;

foreach my $key (keys %$queries) {
    my $sql = $$queries{$key}{'sql'};
    my $messageStr = $$queries{$key}{'message'} || '';
    my $threshold = $$queries{$key}{'threshold'} + 0;
    my $sth = run_query($sql);
    while(my @row = $sth->fetchrow_array) {
        my $message = $messageStr . "  Row values were: \n";
        foreach (@row) {
            $message .= trim($_) . ", ";
        }
        $message =~ s/, $//;
        $message =~ s/\'/\\\'/g;
        $message .= "\n";

        `echo \$'$message' >> $err_file`;
        $has_error = 1;
    }
}

if (!-e $err_file || $has_error){
   `/bin/cat $err_file | mail -s 'PRIMe long running query' yourEmail\@server.edu`;
   `touch $err_file`;
}

#always touch status file, which indicates script ran
`touch $status_file`;

sub run_query {
    my $sql = shift;
    my $sth = $dbh->prepare($sql, {odbc_exec_direct => 1});
    $sth->execute();
    return $sth;
}
