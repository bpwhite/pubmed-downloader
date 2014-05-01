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

my @rss_list = (
				'http://www.ncbi.nlm.nih.gov/entrez/eutils/erss.cgi?rss_guid=1zYrsILa0sOmmYyQyFZ-shJiy5elic75sxJABMB6Jm3DplqQv7', # nature[journal] 100 entries
				'http://www.ncbi.nlm.nih.gov/entrez/eutils/erss.cgi?rss_guid=1J__86CjOXsqvrviyWiygdOuThgZaqYd_LuF7SWd01J8kJYAP4', # "nature biotechnology"[journal] 100 entries
				'http://www.ncbi.nlm.nih.gov/entrez/eutils/erss.cgi?rss_guid=1vWAR2vnuIcrenrcelx0EZlv48tx_WfHEeHDdnkc8cX1CyzsP_', # science[journal] 100 entries
				'http://www.ncbi.nlm.nih.gov/entrez/eutils/erss.cgi?rss_guid=1BmJTbU5jL0jvbTMLiufayls_4Fd6JWA1OISCItwCDTZKYcolC', # cell[journal] 100 entries
				'http://www.ncbi.nlm.nih.gov/entrez/eutils/erss.cgi?rss_guid=1levKdK_NRD9DNeOLLED5DXayKo752i1khyuiayB_zrOS4kQsy', # "nature genetics"[journal] 100 entries
				'http://www.ncbi.nlm.nih.gov/entrez/eutils/erss.cgi?rss_guid=1FwYT_rsr_VmWWShW1EonPM_sIfUxFT92PHhANW86clDcDy97A', # "chemical reviews"[journal] 100 entries
				'http://www.ncbi.nlm.nih.gov/entrez/eutils/erss.cgi?rss_guid=12MSb85m6hHeGjP9REXHNLeIWOgyP-prlOwHD0l66FdOTLZso_', # "physical review letters"[journal] 100 entries
				'http://www.ncbi.nlm.nih.gov/entrez/eutils/erss.cgi?rss_guid=1Ts-QavLxpnzWtqL4iGcp6wO61Zd7Ql4BG7Hcf7QkhUWP7VYRn', # "journal of the american chemical society"[journal] 100 entries
				
				);

# SWTFunctions::parse_clean_doc($url, $output);
foreach my $feed (@rss_list) {
	SWTFunctions::scrape_rss($feed);
}
exit;


