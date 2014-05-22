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
use Time::HiRes;

use SWT::Functions;

require Exporter;
my @ISA = qw(Exporter);
my @EXPORT_OK = qw() ;

sub scrape_feed {
	my $feed_list 		= shift;
	
	open (FEED_LIST, '<'.$feed_list);
	my @feed_list = <FEED_LIST>;
	close(FEED_LIST);
	
	my $digest = sha1_hex($feed_list);
	my $scrape_path = SWT::Functions::make_download_path($digest);
	# print "Scraping too: ".$scrape_path."\n";
	my $parsed_file = $scrape_path.'/'.$digest.'_parsed.csv';
	my $final_file = $scrape_path.'/'.$digest.'_rss.csv';
	
	unless (-e $final_file) {
	
		my %parsed = ();
		my $feed_line_i = 0;
		foreach my $feed_line (@feed_list) {
			if($feed_line_i == 0) {
				$feed_line_i++;
				next;
			}
			my @split_feed = split(/,/,$feed_line);
			my $feed_source = $split_feed[1];
			
			
			
			my $feed = '';
			eval { $feed = XML::FeedPP->new( $feed_source ); };
			Time::HiRes::usleep (1000);
			if($@) {
				print "Feed failed: \n";
				print $@."\n";
				next;
			}
			# print "Feed Title: ", $feed->title(), "\n";
			
			# print "Date: ", $feed->pubDate(), "\n";
			my $item_i = 0;
			my $max_items = 100;
			foreach my $item ( $feed->get_item() ) {
				last if $item_i > $max_items;
				# print "Scraping: ", $item->title(), "\n";
				# print Dumper($item);
				# exit;
				# print "URL: ", $item->link(), "\n";
				# my $article = 'NA';
				# eval { $article = get $item->link(); };
				# $article = $scrubber->scrub($article);
				# $parsed{$title}->{'article'} = $article;
				
				my $title = $item->title();
				$parsed{$title}->{'web_news_feed_title'} = $feed->title();
				$parsed{$title}->{'web_news_article_title'} = $title;
				$parsed{$title}->{'web_news_feed_link'} = $feed_source;
				my $description = 'NA';
				my $scrubber = HTML::Scrubber->new( allow => [ qw[ ] ] );
				if (defined($item->description())) {
					$description = $item->description();
				}
				$description =~ s/\n//g;
				$description =~ s/\r\n//g;
				$description =~ s/\r//g;
				$description = $scrubber->scrub($description);
				$description =~ s/&quot;/\"/g; # html quote
				$description =~ s/&mdash;/\-/g; # html dash
				$description =~ s/&hellip;/\.\.\./g; # ellipses
				$description =~ s/&#39;/'/g; # apostrophe/single quote
				$description =~ s/\s+$//;
				$parsed{$title}->{'web_news_description'} = $description;
				$parsed{$title}->{'web_news_link'}	= $item->link();
				# $parsed{$title}->{'article'} = $article;
				# if($article eq '') {
					# print "No article. ".$feed_source."\n";
				# }
				$item_i++;
			}
			

		}
		open (SCRAPED, '>'.$final_file);
		my $line_i = 0;
		foreach my $article_key (keys %parsed) {
			# print "Parsing... ".$article_key."\n";
			if ($line_i == 0) {
				foreach my $key2 (keys $parsed{$article_key}) {
					print SCRAPED $key2.",";
				}
			}
			if ($line_i > 0) {
				foreach my $key2 (keys $parsed{$article_key}) {
					if (defined($parsed{$article_key}->{$key2})) {
						# $parsed{$article_key}->{$key2} =~ s/;//g;
						$parsed{$article_key}->{$key2} =~ s/\"//g;
						$parsed{$article_key}->{$key2} =~ s/\n//g;
						# print Dumper($parsed{$article_key}->{$key2})."\n";
						# $parsed{$article_key}->{$key2} =~ s/,/_/g;
						print SCRAPED "\"".$parsed{$article_key}->{$key2}."\",";
					} else {
						print SCRAPED "\"NA\",";
					}
				}
			}
			$line_i++;
			print SCRAPED "\n";
		}
		close (SCRAPED);
		
	} else {
		print "Already scraped $final_file today.\n";
	}
	return $final_file;
}

sub fix_lines {
	my $file = shift;
	open (SCRAPED, '<'.$file);
	my @scraped = <SCRAPED>;
	close(SCRAPED);
	foreach my $line (@scraped) {
		# $line =~ s/\|/\n/g;
		print $line;
	}
	
}

1;