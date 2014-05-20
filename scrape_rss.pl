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
use SWTFunctions;
use Params::Validate qw(:all);
use Data::Dumper;

use SWT::RSS;

my $feed_list = '';
my $start_scrape	= '';
my $stop_scrape	= '';

GetOptions ("feed_list=s" 			=> \$feed_list,
			"start_scrape=s"		=> \$start_scrape,
			"stop_scrape=s"			=> \$stop_scrape)
or die("Error in command line arguments\n");

SWT::RSS::scrape_feed($feed_list, $start_scrape, $stop_scrape);

exit;