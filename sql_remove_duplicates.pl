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

GetOptions ("table_name=s" 			=> \$table_name,
			"id_name=s"				=> \$id_name)
or die("Error in command line arguments\n");

my $dbh = SWT::SQL::mysql_connect();

# Check pm_abstracts
my $sql_query = "SELECT * FROM ".$table_name." ;";
# print $sql_query."\n";
my $sth = $dbh->prepare($sql_query);
$sth->execute();
my %unique_items = ();
my @remove_list = ();
while (my @row= $sth->fetchrow_array())  {
	my $concat = '';
	foreach my $field (1..$#row) {
		$concat .= $row[$field];
	}
	my $digest = sha1_hex($concat);
	if(exists($unique_items{$digest})) {
		push(@remove_list, $row[0]);
	} else {
		$unique_items{$digest} = 1;
	}
}
$sth->finish();
 
foreach my $remove_id (@remove_list) {
	print $remove_id."\n";
	my $del_query = "DELETE FROM ".$table_name." WHERE ".$id_name." = ".$remove_id;
	my $del_sth = $dbh->prepare($del_query);
	$del_sth->execute();
	$del_sth->finish();
}