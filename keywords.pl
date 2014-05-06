#!/usr/bin/env perl
# This script enumerates keywords in a webpage

# Copyright (c) 2013, 2014 Bryan White, bpcwhite@gmail.com

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

my $url = '';

GetOptions ("url=s" 			=> \$url,)
or die("Error in command line arguments\n");

my @query_list = ('nature[journal','science[journal]');

# SWTFunctions::parse_clean_doc($url, $output);
foreach my $query (@query_list) {
	SWTFunctions::scrape_rss(query => $query, num_results => 10);
}
# SWTFunctions::scrape_rss_eutil();

exit;


