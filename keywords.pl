#!/usr/bin/env perl
# This script enumerates keywords in a webpage

# Copyright (c) 2013-2015 Bryan White, bpcwhite@gmail.com

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
my $url = '';
my $num_articles = '50';
my $path = '';
GetOptions ("url=s" 			=> \$url,
			"num_articles=s"	=> \$num_articles,
			"path=s"			=> \$path)
or die("Error in command line arguments\n");

my @query_list = (	'nature[journal]',
					);

# SWTFunctions::parse_clean_doc($url, $output);
foreach my $query (@query_list) {
	SWT::Functions::download_pubmed(query => $query, num_results => $num_articles, path => $path);
}
# SWTFunctions::scrape_rss_eutil();

exit;


