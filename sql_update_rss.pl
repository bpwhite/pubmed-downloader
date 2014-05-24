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

GetOptions ("path=s" 			=> \$path,)
or die("Error in command line arguments\n");


my @rss_files = glob "$path/*rss*.csv";
# for (0..$#rss_files){
  # $rss_files[$_] =~ s/\.csv$//;
# }
foreach my $file (@rss_files) {
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
			$line =~ s/\n//g; # remove newlines
			$line =~ s/,$//; # remove trailing commas
			# $line =~ s/\"//g; # strip quotes
			# $line =~ s/,/\",\"/g; # add quotes back in
			# $line = "\"".$line."\"";
			# print $line."\n";
			# exit;
			my $sql_query = "INSERT INTO web_news (".$table_headers.") VALUES (".$line.");";
			# print $sql_query."\n";
			my $sth = $dbh->prepare($sql_query);
			eval { $sth->execute() or warn $DBI::errstr; };
			$sth->finish();
		}
		
		$line_i++;
	}
}