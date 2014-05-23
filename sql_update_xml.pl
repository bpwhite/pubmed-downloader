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
	my $title_column = '';
	foreach my $line (@content) {
		if($line_i == 0) {
			$table_headers = $line;
			$table_headers =~ s/\n//g;
			$table_headers =~ s/,$//;
			# print $table_headers."\n";
			my @split_headers = split(/,/,$table_headers);
			my $title_i = 0;
			foreach my $split_header (@split_headers) {
				if($split_header =~ m/pm_pubtitle/) {
					$title_column = $title_i;
					last;
				}
				$title_i++;
			}
			$line_i++;
			next;
		} else {
			$line =~ s/\n//g;
			$line =~ s/,$//;
			my @split_line = split(/,/,$line);
			$split_line[$title_column] =~ s/'/\'/g; # escape single quotes for sql
			my $check_query = "SELECT pm_pubtitle FROM pm_abstracts WHERE pm_pubtitle = '".$split_line[$title_column]."';";
			my $check_sth = $dbh->prepare($check_query);
			$check_sth->execute();
			my $num_rows = $check_sth->rows;
			$check_sth->finish();
			if($num_rows > 0) {
				my $del_query = "DELETE FROM pm_abstracts WHERE pm_pubtitle = ".$split_line[$title_column].";";
				my $del_sth = prepare($del_query);
				$del_sth->execute();
				$del_sth->finish();
			}
			
			my $insert_sql_query = "INSERT INTO pm_abstracts (".$table_headers.") VALUES (".$line.");";
			# print $sql_query."\n";
			my $insert_sth = $dbh->prepare($insert_sql_query);
			eval { $insert_sth->execute() or warn $DBI::errstr; };
			warn $@ if $@;
			$insert_sth->finish();
			
		}
		
		$line_i++;
	}
}

