#!/usr/bin/env perl
# This script downloads abstracts from pubmed

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
my $num_articles = '100';
my $path = '';
my $query_list_file = '';
my $add_keywords = '';

GetOptions ("url=s" 			=> \$url,
			"num_articles=s"	=> \$num_articles,
			"path=s"			=> \$path,
			"list=s"			=> \$query_list_file,
			"add-keywords=s"	=> \$add_keywords,)
or die("Error in command line arguments\n");

my @query_list = ();
if($query_list_file eq '') {
	@query_list = ('nature[journal]');
} else {
	open QUERY, "< $query_list_file" or die "Can't open $query_list_file : $!";
	@query_list = <QUERY>;
	close QUERY;
}

my $base_query = '';
my $query_i = 0;
foreach my $query (@query_list) {
	chomp($query);
	my $root = $query;
	if($query_i == 0) {
		$base_query = $query;
		$query_i++;
		next;
	}
	$query .= ' '.$base_query;
	SWT::Functions::download_pubmed(query => $query, 
									num_results => $num_articles, 
									path => $path,
									root => $root,
									add_keywords => $add-keywords,
									);
	$query_i++;
}

exit;


