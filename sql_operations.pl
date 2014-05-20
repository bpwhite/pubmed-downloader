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

my $dbh = SWTSql::mysql_connect();
my $rebuild = 0;
my $purge = 0;
my $populate = 0;

$rebuild = 0;
if($rebuild == 1) {
	SWTSql::delete_pubmed_table($dbh);
	SWTSql::delete_web_news_table($dbh);
	SWTSql::create_pubmed_table($dbh);
	SWTSql::create_web_news_table($dbh);
}

if($purge == 1) {
	SWTSql::delete_pubmed_table($dbh);
	SWTSql::delete_web_news_table($dbh);
}

if($populate == 1) {

}
exit;
