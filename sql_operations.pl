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
my $rebuild = 0;
my $purge = 0;
my $populate = 0;
my $build = 0;
my $rebuild_web_news = 0;

$rebuild = 0;
$build = 0;
$rebuild_web_news = 1;

if($rebuild_web_news == 1) {
	SWT::SQL::delete_web_news_table($dbh);
	SWT::SQL::create_web_news_table($dbh);
}
if($rebuild == 1) {
	SWT::SQL::delete_pubmed_table($dbh);
	SWT::SQL::delete_web_news_table($dbh);
	SWT::SQL::create_pubmed_table($dbh);
	SWT::SQL::create_web_news_table($dbh);
}

if($purge == 1) {
	SWT::SQL::delete_pubmed_table($dbh);
	SWT::SQL::delete_web_news_table($dbh);
}

if($build == 1) {
	SWT::SQL::create_pubmed_table($dbh);
	SWT::SQL::create_web_news_table($dbh);
}

if($populate == 1) {
	
}
exit;
