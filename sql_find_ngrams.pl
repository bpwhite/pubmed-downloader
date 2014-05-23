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
use Digest::SHA qw(sha1_hex);

use SWT::Functions;
use SWT::SQL;

my $table_name = '';
my $field_name	= '';
my $ngram_size = '3';

GetOptions ("table=s" 			=> \$table_name,
			"field=s"			=> \$field_name,
			"nsize=s"			=> \$ngram_size)
or die("Error in command line arguments\n");


my $dbh = SWT::SQL::mysql_connect();
my $filename = 'ngrams.txt';

# Check pm_abstracts
my $sql_query = "SELECT * FROM ".$table_name." ;";
# print $sql_query."\n";
my $sth = $dbh->prepare($sql_query);
$sth->execute();
my $concat = '';
my $num_queries = 0;
while (my $ref = $sth->fetchrow_hashref()) {
	# print $ref->{$field_name}."\n";
	if(defined($ref->{$field_name})) {
		$concat .= $ref->{$field_name};
	}
	$num_queries++;
}

print "Concatenated ".$num_queries." queries\n";
$sth->finish();

# my @exclusion_list = (	'was','and','the','such','as','of','for','th','this','in','is','on',
						# 'that', 'had', 'been',
						# 'here we show',
						# 'here we report',
						# 'was associated with',
						# 'results suggest that',
						# 'can be used',
						# 'oncogene advance online',
						# 'advance online publication',
						# 'here we demonstrate',
						# 'associated with the',
						# 'were associated with',
						# 'our results suggest',
						# 'are associated with',
						# 'findings suggest that',
						# 'an important role',
						# 'insight into the',
						# 'publication',
						# 'results',
						# 'findings',
						# 'suggest',
						# 'factors associated with',
						# 'recent studies have',
						# 'taken together our',
						# 'not associated with',
						# 'were randomly assigned',
						# 'when compared with',
						# 'independently associated with',
						# 'associated with increased',
						# 'significantly associated with',
						# 'with type diabetes',
						# 'from patients with',
						# 'patients with chronic',
						# 'not well understood',
						# 'new insights into',
						# 'patients were randomly',
						# 'patients with liver',
						# 'reports'
						# );
open (CONCAT, '>'.$filename);
print CONCAT $concat;
close (CONCAT);

my $ngram = Lingua::EN::Ngram->new( file => $filename );
# list other ngrams according to frequency
my $ngram_i = 0;
my $min_ngram_length = 3;
my $max_ngrams = 20;
print "\nProcessing ngrams...\n\n";
my $trigrams = $ngram->ngram( $ngram_size );
foreach my $trigram ( sort { $$trigrams{ $b } <=> $$trigrams{ $a } } keys %$trigrams ) {
	# last if $ngram_i == $max_ngrams;
	my $frequency = $$trigrams{ $trigram };
	
	my @split_gram = split(/ /,$trigram);
	my $gram_fail = 0;
	foreach my $gram (@split_gram) {
		$gram_fail++ if length($gram) < $min_ngram_length;
		# $gram_fail++ if $gram ~~ @exclusion_list;
		$gram_fail++ if length($gram) == 1;
	}
	# $gram_fail++ if $trigram ~~ @exclusion_list;
	$gram_fail++ if $frequency < 3;
	next if $gram_fail >= 1;
	
	my $insert_sql_query = "INSERT INTO ng_ngrams (ng_phrase,ng_size,ng_freq,ng_table,ng_field) VALUES (\"".
							$trigram."\",\"".$ngram_size."\",\"".$frequency."\",\"".$table_name."\",\"".$field_name."\");";
	# print $insert_sql_query."\n";
	# exit;
	my $insert_sth = $dbh->prepare($insert_sql_query);
	eval { $insert_sth->execute() or warn $DBI::errstr; };
	warn $@ if $@;
	$insert_sth->finish();
	print $frequency." => ".$trigram."\n";
	# print $$trigrams{ $trigram }, "\t$trigram\n";
	$ngram_i++;
}

