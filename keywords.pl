#!/usr/bin/env perl
# This script enumerates keywords in a webpage

# Copyright (c) 2013, Bryan White, bpcwhite@gmail.com

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
use Regexp::Keywords;
use LWP::Simple;
use HTML::Entities;
use Text::Unidecode qw(unidecode);
use HTML::Scrubber;
use String::Util 'trim';

my $doc = get 'http://en.wikipedia.org/wiki/Bill_Russell';

# print $doc;
my @split_doc = split(/\n/,$doc);

my $head_LN		 	= find_tag('<\/head',	\@split_doc);
my $body_LN 		= find_tag('<body',		\@split_doc);
my $body_end_LN		= find_tag('<\/body',	\@split_doc);

print $head_LN."\n";
print $body_LN."\n";
print $body_end_LN."\n";

my $scrubber = HTML::Scrubber->new( allow => [ qw[] ] );

open (WEBDL, '>data.txt');
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

### Ngram calculation
my $ngram = Lingua::EN::Ngram->new( file => 'data.txt' );

my $exclude_being_verbs = Regexp::Keywords->new();

my $being_verbs = 'was';
$exclude_being_verbs->prepare($being_verbs);

# calculate t-score; t-score is only available for bigrams
my $tscore = $ngram->tscore;
my $num_tscore = 5;
my $min_tscore_length = 3;
my $cutoff_tscore_length = 2;
my $min_total_length = 6;

my $tscore_i = 0;
foreach ( sort { $$tscore{ $b } <=> $$tscore{ $a } } keys %$tscore ) {
	last if $tscore_i == $num_tscore;
	my $score = $$tscore{ $_ };
	my $pair = $_;
	my @split_pair = split(/ /,$pair);
	my $first_word = $split_pair[0];
	my $second_word = $split_pair[1];
	my $total_length = length($first_word)+length($second_word);
	
	if ((length($first_word) < $min_tscore_length) && (length($second_word) < $min_tscore_length)) {
		next;
	}
	if ((length($first_word) < $cutoff_tscore_length) || (length($second_word) < $cutoff_tscore_length)) {
		next;
	}
	next if ($total_length < $min_total_length);
	next if $exclude_being_verbs->test($first_word);
	next if $exclude_being_verbs->test($second_word);

	print $score." => ".$pair."\n";
	
	$tscore_i++;
}

exit;
# list trigrams according to frequency
my $trigrams = $ngram->ngram( 3 );
foreach my $trigram ( sort { $$trigrams{ $b } <=> $$trigrams{ $a } } keys %$trigrams ) {
  print $$trigrams{ $trigram }, "\t$trigram\n";
}


exit;
# Keyword calculations
my $kw = Regexp::Keywords->new();

my $wanted = 'comedy + ( action , romance ) - thriller';
$kw->prepare($wanted);

my $movie_tags = 'action,comedy,crime,fantasy,adventure';
print "Buy ticket!\n" if $kw->test($movie_tags);

# Subs
############# 

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
