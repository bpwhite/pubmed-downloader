#!/usr/bin/env perl
# Functions for science web tools

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
package SWTFunctions;
use strict;
use warnings;
use LWP::Simple;
use utf8;
use Lingua::EN::Ngram;
use HTML::Entities;
use Text::Unidecode qw(unidecode);
use HTML::Scrubber;
use String::Util 'trim';
use Getopt::Long;

require Exporter;
my @ISA = qw(Exporter);
my @EXPORT_OK = qw(parse_clean_doc find_tag);


sub parse_clean_doc {
	my $url 	= shift;
	my $output 	= shift;
	
	my $doc = get $url;

	my @split_doc = split(/\n/,$doc);

	my $head_LN		 	= find_tag('<\/head',	\@split_doc);
	my $body_LN 		= find_tag('<body',		\@split_doc);
	my $body_end_LN		= find_tag('<\/body',	\@split_doc);

	print $head_LN."\n";
	print $body_LN."\n";
	print $body_end_LN."\n";

	my $scrubber = HTML::Scrubber->new( allow => [ qw[] ] );

	open (WEBDL, '>'.$output);
	for (my $line_i = $body_LN; $line_i < $body_end_LN; $line_i++) {
		# clean line of html tags and attempt to decode utf8 into unicode
		my $cleaned_line =
			unidecode(
				decode_entities(
					$scrubber->scrub(
						$split_doc[$line_i])));
		print WEBDL trim($cleaned_line).' ' if $cleaned_line ne '';
	}
	close (WEBDL);
}

sub find_tag {
	my $tag 	= shift;
	my $doc_ref = shift;
	
	my $line_num = 1;
	foreach my $line (@$doc_ref) {
	
		if ($line =~ m/$tag/) {
			return $line_num;
		}
		$line_num++;
	}
	
	if ($line_num == 1) {
		return undef;
	}
}

sub fetch_sub_docs {

	my $url_doc1 = shift;
	my $url_doc2 = shift;
	my $url_doc3 = shift;
	my $url_doc4 = shift;
	
	my $doc1 = get $url_doc1;

	my @split_doc = split(/\n/,$doc1);

	foreach my $line (@split_doc) {
		print $line."\n";
	}
}


