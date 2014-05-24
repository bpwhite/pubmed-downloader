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

GetOptions ("table=s" 			=> \$table_name,)
or die("Error in command line arguments\n");


my $dbh = SWT::SQL::mysql_connect();

my $truncate_query = "TRUNCATE ".$table_name.";";

my $truncate_sth = $dbh->prepare($truncate_query);
eval { $truncate_sth->execute() or warn $DBI::errstr; };
warn $@ if $@;
$truncate_sth->finish();