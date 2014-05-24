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

use SWT::Functions;
use SWT::SQL;

my $path = SWT::Functions::make_download_path();

GetOptions ("path=s" 			=> \$path,)
or die("Error in command line arguments\n");

my $dbh = SWT::SQL::mysql_connect();

my @xml_files = glob "$path/*parsed*.csv";

foreach my $file (@xml_files) {
	# print $file."\n";
	open (CONTENT, '<'.$file);
	my @content = <CONTENT>;
	close(CONTENT);
	my $line_i = 0;
	my $table_headers = '';
	my $title_column = '';
	foreach my $line (@content) {
		if($line_i == 0) {
			$table_headers = $line;
			$table_headers =~ s/\n//g;
			$table_headers =~ s/,$//;
			$line_i++;
			next;
		} else {
			$line =~ s/\n//g;
			$line =~ s/,$//;
			
			my $insert_sql_query = "INSERT INTO pm_abstracts (".$table_headers.") VALUES (".$line.");";
			# print $sql_query."\n";
			my $insert_sth = $dbh->prepare($insert_sql_query);
			eval { $insert_sth->execute() or warn $DBI::errstr; };
			# warn $@ if $@;
			$insert_sth->finish();
			
		}
		
		$line_i++;
	}
}

