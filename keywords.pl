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

use SWT::Functions;
my $url = '';
my $num_articles = '50';
my $path = '';
GetOptions ("url=s" 			=> \$url,
			"num_articles=s"	=> \$num_articles,
			"path=s"			=> \$path)
or die("Error in command line arguments\n");

my @query_list = (	'nature[journal]',
					'science[journal]',
					'cell[journal]',
					'"Nature Genetics"[journal]',
					'"Physical Review Letters"[journal]',
					'"Journal of the American Chemical Society"[journal]',
					'Circulation[journal]',
					'"Nano Letters"[journal]',
					'"Journal of the American College of Cardiology"[journal]',
					'"Chemical Society reviews"[journal]',
					'"Nucleic Acids Research"[journal]',
					'Blood[journal]',
					'"Nature Materials"[journal]',
					'"Nature Medicine"[journal]',
					'"Nature Medicine"[journal]',
					'"Nature Reviews Molecular Cell Biology"[journal]',
					'"Nature Reviews Cancer"[journal]',
					'"Cancer Research"[journal]',
					'"Nature Immunology"[journal]',
					'"The Journal of Clinical Investigation"[journal]',
					'"PLoS One"[journal]',
					'"Nature Reviews Immunology"[journal]',
					'"British Medical Journal"[journal]',
					'"Accounts of Chemical Research"[journal]',
					'"Nature Reviews Genetics"[journal]',
					'"Gastroenterology"[journal]',
					'"The Journal of Experimental Medicine"[journal]',
					'"Immunity"[journal]',
					'"Neuron"[journal]',
					'"ACS Nano"[journal]',
					'"Nature Biotechnology"[journal]',
					'"The American Economic Review"[journal]',
					'"Nature Reviews Neuroscience"[journal]',
					'"Hepatology"[journal]',
					'"Applied Physics Letters"[journal]',
					'"Nature Nanotechnology"[journal]',
					'"Cell Stem Cell"[journal]',
					'"Molecular Cell"[journal]',
					'"Nature Cell Biology"[journal]',
					'"Nature Methods"[journal]',
					'"The Lancet Oncology"[journal]',
					'"Annals of Internal Medicine"[journal]',
					'"Genes & Development"[journal]',
					'"Nature Photonics"[journal]',
					'"European Heart Journal"[journal]',
					'"Nature Neuroscience"[journal]',
					'"Cancer Cell"[journal]',
					'"Pediatrics"[journal]',
					'"Biomaterials"[journal]',
					'"Archives of Internal Medicine"[journal]',
					'"PLOS Genetics"[journal]',
					'"Arthritis and Rheumatism"[journal]',
					'"Neurology"[journal]',
					'"Nature Reviews Microbiology"[journal]',
					'"American Journal of Respiratory and Critical Care Medicine"[journal]',
					'"The Journal of Cell Biology"[journal]',
					'"Nature Reviews Drug Discovery"[journal]',
					'"Bioinformatics"[journal]',
					'"Diabetes Care"[journal]',
					'"Oncogene"[journal]',
					'"NeuroImage"[journal]',
					'"Bioresource Technology"[journal]',
					'"Genome Research"[journal]'
					);

# SWTFunctions::parse_clean_doc($url, $output);
foreach my $query (@query_list) {
	SWT::Functions::scrape_rss(query => $query, num_results => $num_articles, path => $path);
}
# SWTFunctions::scrape_rss_eutil();

exit;


