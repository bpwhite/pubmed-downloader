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


use HTML::LinkExtractor;
use Data::Dumper;

use Text::Levenshtein::XS qw/distance/;


# print distance('free complete genomes','costly partial genome');
# exit;

my $textfile = '';

GetOptions ("file=s" 			=> \$textfile,)
or die("Error in command line arguments\n");

### Ngram calculation
my $ngram = Lingua::EN::Ngram->new( file => $textfile );

my @exclusion_list = (	'was','and','the','such','as','of','for','th','this','in','is','on',
						'that', 'had', 'been');

# calculate t-score; t-score is only available for bigrams
my $tscore = $ngram->tscore;
my $num_tscore = 15;
my $min_tscore_length = 3;
my $cutoff_tscore_length = 2;
my $min_total_length = 6;

print "Processing bigrams...\n\n";
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
	if ((length($first_word) <= $cutoff_tscore_length) || (length($second_word) <= $cutoff_tscore_length)) {
		next;
	}
	next if ($total_length < $min_total_length);
	next if($first_word ~~ @exclusion_list);
	next if($second_word ~~ @exclusion_list);

	print $score." => ".$pair."\n";
	
	$tscore_i++;
}

# list other ngrams according to frequency
my $ngram_i = 0;
my $min_ngram_length = 3;
my $max_ngrams = 15;
print "\nProcessing ngrams...\n\n";
my $trigrams = $ngram->ngram( 4 );
foreach my $trigram ( sort { $$trigrams{ $b } <=> $$trigrams{ $a } } keys %$trigrams ) {
	last if $ngram_i == $max_ngrams;
	my $frequency = $$trigrams{ $trigram };
	
	my @split_gram = split(/ /,$trigram);
	my $gram_fail = 0;
	foreach my $gram (@split_gram) {
		$gram_fail++ if length($gram) < $min_ngram_length;
		$gram_fail++ if $gram ~~ @exclusion_list;
		$gram_fail++ if length($gram) == 1;
	}
	$gram_fail++ if $frequency < 3;
	next if $gram_fail > 1;
	
	print $frequency." => ".$trigram."\n";
	# print $$trigrams{ $trigram }, "\t$trigram\n";
	$ngram_i++;
}


exit;

# Subs
############# 
