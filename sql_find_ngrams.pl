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
my $max_ngrams = '50';
my $insert = 0;
my $daterange = '';
my $datefield = '';

GetOptions ("table=s" 			=> \$table_name,
			"field=s"			=> \$field_name,
			"nsize=s"			=> \$ngram_size,
			"max_ngrams=s"		=> \$max_ngrams,
			"insert=s"			=> \$insert,
			"range=s"			=> \$daterange,
			"datefield=s"		=> \$datefield)
or die("Error in command line arguments\n");


my $dbh = SWT::SQL::mysql_connect();

# build exclusion list from sql
my @exclusion_list = ();
my $exclusion_query = "SELECT * FROM ngi_ngram_ignore_list WHERE ngi_nsize = '".$ngram_size."';";
my $exclusion_sth = $dbh->prepare($exclusion_query);
eval { $exclusion_sth->execute() or warn $DBI::errstr; };
while (my $ref = $exclusion_sth->fetchrow_hashref()) {
	if(defined($ref->{'ngi_phrase'})) {
		push(@exclusion_list, $ref->{'ngi_phrase'});
	}
}
$exclusion_sth->finish();

my @articles_list = ('the','a','an','some');

# Check data table
my $sql_query = '';
if($daterange ne '') {
	my @split_range = split(/,/,$daterange);
	$sql_query = "SELECT * FROM ".$table_name." WHERE  ".$datefield." between '".$split_range[0]."' AND '".$split_range[1]."' ;";
} else {
	$sql_query = "SELECT * FROM ".$table_name." ;";
}

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

my $filename = 'ngrams.txt';
open (CONCAT, '>'.$filename);
print CONCAT $concat;
close (CONCAT);

my $ngram = Lingua::EN::Ngram->new( file => $filename );
# list other ngrams according to frequency
my $ngram_i = 0;
my $min_ngram_length = 3;
my $max_frequency = 0;
print "\nProcessing ngrams...\n\n";
my $trigrams = $ngram->ngram( $ngram_size );
foreach my $trigram ( sort { $$trigrams{ $b } <=> $$trigrams{ $a } } keys %$trigrams ) {
	last if $ngram_i == $max_ngrams;
	my $frequency = $$trigrams{ $trigram };

	

	my $gram_fail = 0;
	my @split_gram = split(/ /,$trigram);
	foreach my $split (@split_gram) {
		$gram_fail++ if length($split) < $min_ngram_length;
		$gram_fail++ if $split ~~ @articles_list;
	}
	$gram_fail++ if length($trigram) < $min_ngram_length;
	$gram_fail++ if $trigram ~~ @exclusion_list;
	$gram_fail++ if $frequency < 3;
	next if $gram_fail >= 1;
	
	if ($frequency > $max_frequency) {
		$max_frequency = $frequency;
	}
	my $relative_frequency = int($frequency/$max_frequency*100);
	
	if($insert == 1) {
		my $insert_sql_query = "INSERT INTO ng_ngrams (ng_phrase,ng_size,ng_freq,ng_table,ng_field) VALUES (\"".
								$trigram."\",\"".$ngram_size."\",\"".$relative_frequency."\",\"".$table_name."\",\"".$field_name."\");";

		my $insert_sth = $dbh->prepare($insert_sql_query);
		eval { $insert_sth->execute() or warn $DBI::errstr; };
		warn $@ if $@;
		$insert_sth->finish();
	}
	# print $frequency." => ".$max_frequency."\n";
	print $relative_frequency." => ".$trigram."\n";
	
	$ngram_i++;
}

