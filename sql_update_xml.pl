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

my $dbh = SWT::SQL::mysql_connect();

my $path = SWT::Functions::make_download_path();

my @xml_files = glob "$path/*parsed*.csv";

foreach my $file (@xml_files) {
	# print $file."\n";
	open (CONTENT, '<'.$file);
	my @content = <CONTENT>;
	close(CONTENT);
	my $line_i = 0;
	my $table_headers = '';
	foreach my $line (@content) {
		if($line_i == 0) {
			$table_headers = $line;
			$table_headers =~ s/\n//g;
			$table_headers =~ s/,$//;
			# print $table_headers."\n";
			$line_i++;
			next;
		} else {
			$line =~ s/\n//g;
			$line =~ s/,$//;
			my $sql_query = "INSERT INTO pm_abstracts (".$table_headers.") VALUES (".$line.");";
			# print $sql_query."\n";
			my $sth = $dbh->prepare($sql_query);
			eval { $sth->execute() or warn $DBI::errstr; };
			warn $@ if $@;
			$sth->finish();
		}
		
		$line_i++;
	}
}

