#!/usr/bin/env perl
# Functions for science web tools

# Copyright (c) 2013, 2014 Bryan White, bpcwhite@gmail.com
package SWT::RSS;
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
use XML::FeedPP;
use Class::Date qw(:errors date localdate gmdate now -DateParse -EnvC);
use Digest::SHA qw(sha1_hex);
use Data::Dumper;
use XML::Simple;

require Exporter;
my @ISA = qw(Exporter);
my @EXPORT_OK = qw() ;

sub scrape_feed {
	my $feed_list 		= shift;
	my $start_scrape 	= shift;
	my $stop_scrape 	= shift;
	
	open (FEED_LIST, '<'.$feed_list);
	my @feed_list = <FEED_LIST>;
	close(FEED_LIST);
	foreach my $feed_source (@feed_list) {
		my $feed = XML::FeedPP->new( $feed_source );
		print "Feed Title: ", $feed->title(), "\n";
		print "Date: ", $feed->pubDate(), "\n";
		foreach my $item ( $feed->get_item() ) {
			print "Scraping: ", $item->title(), "\n";
			# print Dumper($item);
			# exit;
			print "URL: ", $item->link(), "\n";
			my $content = get $item->link();
			# print Dumper($content);
			# print $content;
			
			my @content_lines = split(/\n/,$content);
			my $scrubber = HTML::Scrubber->new( allow => [ qw[ ] ] );
			my $found_start = 0;
			my $summary = '';
			foreach my $line (@content_lines) {
				if ($line =~ m/$start_scrape/) {
					$found_start = 1;
					print $line;
				}
				if($found_start == 1) {
					last if $line =~ m/$stop_scrape/;
					$line = $scrubber->scrub($line);
					#trim whitespace
					$line =~ s/^\s+//;
					$line =~ s/\s+$//;
					$line =~ s/&nbsp;/ /g; # html blank
					$line =~ s/\n//g;
					$line =~ s/\r\n//g;
					$line =~ s/\r//g;
					$line =~ s/&quot;/\"/g; # html quote
					$line =~ s/&mdash;/\-/g;
					$line =~ s/&hellip;/\.\.\./g;
					# scrub html
					# chomp($line);
					$summary .= $line;
					# split on whitespace, words.
					# my @words = split(/\s+/, $line);
					# print scalar(@words)."\n";
					# if(scalar(@words) > 5) {
					# print $line."\n";
					# }
					
				}
			}
			print $summary."\n";
			# exit;
			
		}
		exit;
	}
	
}

1;