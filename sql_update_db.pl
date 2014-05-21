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

my @rss_files = glob "$path/*rss*.csv";
for (0..$#rss_files){
  $rss_files[$_] =~ s/\.csv$//;
}
foreach my $file (@rss_files) {
	print $file."\n";
}

my @xml_files = glob "$path/*parsed*.csv";
for (0..$#xml_files){
  $xml_files[$_] =~ s/\.csv$//;
}
foreach my $file (@xml_files) {
	print $file."\n";
	open (CONTENT, '<'.$feed_list);
	my @feed_list = <CONTENT>;
	close(CONTENT);
}

# SWT::Sql::insert_web_news();