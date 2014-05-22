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

use SWT::RSS;
use SWT::Functions;

my $feed_list = '';

GetOptions ("feed_list=s" 			=> \$feed_list,)
or die("Error in command line arguments\n");

my $file = SWT::RSS::scrape_feed($feed_list);

# SWT::RSS::fix_lines($file);

exit;