#!/usr/bin/env perl
# This script enumerates keywords in a webpage

# Copyright (c) 2013, 2014 Bryan White, bpcwhite@gmail.com

use strict;
use warnings;
use utf8;
use Lingua::EN::Ngram;
use LWP::Simple;
use HTML::Entities;
use Text::Unidecode qw(unidecode);
use HTML::Scrubber;
use String::Util 'trim';
use Getopt::Long;
use Params::Validate qw(:all);
use Data::Dumper;
use Digest::SHA qw(sha1_hex);

use SWT::Functions;
use SWT::SQL;

my $table_name = '';
my $id_name	= '';
my $order = '';

GetOptions ("table_name=s" 			=> \$table_name,
			"id_name=s"				=> \$id_name,
			"order=s"				=> \$order)
or die("Error in command line arguments\n");

my $dbh = SWT::SQL::mysql_connect();

# Check pm_abstracts
my $sql_query = "SELECT * FROM ".$table_name.";";
if($order ne '') {
	"SELECT * FROM ".$table_name." ORDER BY ".$order." DESC;";
}

# print $sql_query."\n";
my $sth = $dbh->prepare($sql_query);
$sth->execute();
my %unique_items = ();
my @remove_list = ();
while (my @row= $sth->fetchrow_array())  {
	my $concat = '';
	foreach my $field (1..$#row) {
		if(!defined($row[$field])) {
			next;
		} else {
			$concat .= $row[$field];
		}
	}
	my $digest = sha1_hex($concat);
	if(exists($unique_items{$digest})) {
		push(@remove_list, $row[0]);
	} else {
		$unique_items{$digest} = 1;
	}
}
$sth->finish();
my $delete_ids = join(',',@remove_list);

my $del_query = "DELETE FROM ".$table_name." WHERE ".$id_name." in ( ".$delete_ids." )";
if($delete_ids eq '') {
	exit;
}
print $del_query."\n";
my $del_sth = $dbh->prepare($del_query);
$del_sth->execute();
$del_sth->finish();