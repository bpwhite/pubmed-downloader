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
use Params::Validate qw(:all);
use HTML::LinkExtractor;

require Exporter;
my @ISA = qw(Exporter);
my @EXPORT_OK = qw(parse_clean_doc find_tag fetch_sub_docs) ;


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
	
	my $line_num = 0;
	foreach my $line (@$doc_ref) {
	
		if ($line =~ m/$tag/) {
			return $line_num;
		}
		$line_num++;
	}
	
	if ($line_num == 0) {
		return undef;
	}
}

sub find_all_tags {
	my $tag 	= shift;
	my $doc_ref = shift;
	
	my @line_nums = ();
	
	my $line_num = 0;
	foreach my $line (@$doc_ref) {
	
		if ($line =~ m/$tag/) {
			push(@line_nums,$line_num);
		}
		$line_num++;
	}
	
	if ($line_num == 0) {
		return undef;
	}
	return \@line_nums;
}

sub fetch_sub_docs {
	my %p = validate(
				@_, {
					sub_docs 		=> 1, # optional string of urls; comma separator
					target_keys 	=> 1, # optional string of target keys
					num_keys		=> 1, # number of target keys
					num_cur_key		=> 1, # current key to search for
				}
			);

	my $sub_docs 		= $p{'sub_docs'};
	my $target_keys 	= $p{'target_keys'};
	my $num_keys		= $p{'num_keys'};
	my $num_cur_key 	= $p{'num_cur_key'};
	
	# split url and key strings on comma
	my @split_target_keys = split(/,/,$target_keys);
	my @split_sub_docs =  split(/,/,$sub_docs);
	
	my $cur_key = $split_target_keys[$num_cur_key];
	my $cur_doc = $split_sub_docs[$num_cur_key];
	
	print $cur_key."\n";
	print $cur_doc."\n";
	
	# num keys must match url search depth
	# if (scalar(@split_target_keys) != scalar(@split_sub_docs)) {
		# return 0;
	# }
	# print "A";
	# search doc for keyword and extract target url
	my $doc = get $cur_doc;
	my @split_doc = split(/\n/,$doc);
	
	# find key line
	my $keyword_LNS = find_all_tags($cur_key, \@split_doc);

	foreach my $keyword_LN (@$keyword_LNS) {
		my $line_text =  get_line($keyword_LN, \@split_doc);
		get_url_loc($line_text);
	}
	exit;
	# print 
	
	# parse url from line
	# go to next url
	# foreach my $line (@split_doc) {
		# print $line."\n";
	# }
	
}

sub count_keys {
	my $target_keys = shift;
	
	my @split_target_keys = split(/,/,$target_keys);
	
	return scalar(@split_target_keys);
}

sub get_line {
	my $line 	= shift;
	my $doc_ref = shift;
	
	return $doc_ref->[$line];
	
}

sub get_url_loc {
	my $line = shift;
	# print $line."\n";
	my $url_start_key = '"http';
	my $url_end_key = '"/>';
	my $url_end_key2 = '">';
	my $arr_ref = convert_string_array($line);
	my $num_chars = length($line);

	my $url_start = 0;
	my $url_end = 0;
	
	
	for (my $i = 1; $i <= $num_chars; $i++) {
		my $ngram_start = substr($line, $i, 5);
		my $ngram_end = substr($line, $i, 2);
		print $ngram_end."\n";
		
		$url_start = $i if $ngram_start eq $url_start_key;
		$url_end = $i-3 if $ngram_end eq $url_end_key;
		
		# last if $url_end != 0;
	}
	
	print $url_start." => ".$url_end."\n";
	exit;
	for (my $i = $url_start; $i <= $url_end; $i++) {
		print $arr_ref->[$i];
	}
	print "\n";
}

sub get_end_url {

}


sub convert_string_array {
	my $string = shift;
	my @split_string = split(//,$string);
	return \@split_string;
}
