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
use XML::FeedPP;
use Class::Date qw(:errors date localdate gmdate now -DateParse -EnvC);
use Digest::SHA qw(sha1_hex);
use Data::Dumper;
use XML::Simple;


require Exporter;
my @ISA = qw(Exporter);
my @EXPORT_OK = qw(parse_clean_doc find_tag fetch_sub_docs) ;

sub scrape_rss {
	my %p = validate(
				@_, {
					query	 	=> 1, # optional string of urls; comma separator
					num_results	=> 1, # optional string of target keys
				}
			);
	my $query = $p{'query'};
	my $num_results = $p{'num_results'};
	
	use DateTime;

	my %months = (	'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'June' => 6, 
					'July' => 7, 'Aug' => 8, 'Sept' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12);
	my $dt = DateTime->now;
	$dt->set_time_zone('America/Los_Angeles');
	
	my $year = $dt->year;
	my $month = $dt->month;
	my $day = $dt->day;
	
	my $digest = sha1_hex($query);
	my $final_path = $year.'/'.$month.'/'.$day;
	my $final_file = $final_path.'/'.$digest.'.xml';
	my $parsed_file = $final_path.'/'.$digest.'_parsed.csv';

	# Only scrape once a day.
	unless (-d $year) {
		mkdir $year;
	}
	unless (-d $year.'/'.$month) {
		mkdir $year.'/'.$month;
	}
	unless (-d $final_path) {
		mkdir $final_path;
	}
	
	unless (-e $final_file) {
		my $db = 'pubmed';

		#assemble the esearch URL
		my $base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
		my $url = $base . "esearch.fcgi?db=$db&term=$query&usehistory=y&retmax=$num_results";
		
		#post the esearch URL
		my $output = get($url);
		# print $output."\n";
		
		#parse WebEnv and QueryKey
		my $web = $1 if ($output =~ /<WebEnv>(\S+)<\/WebEnv>/);
		my $key = $1 if ($output =~ /<QueryKey>(\d+)<\/QueryKey>/);
		# print $web."\n";
		# print $key."\n";
		
		### include this code for ESearch-ESummary
		#assemble the esummary URL
		# $url = $base . "esummary.fcgi?db=$db&query_key=$key&WebEnv=$web";

		#post the esummary URL
		# my $docsums = get($url);
		# print "$docsums";

		### include this code for ESearch-EFetch
		#assemble the efetch URL
		$url = $base . "efetch.fcgi?db=$db&query_key=$key&WebEnv=$web";
		$url .= "&rettype=abstract&retmode=xml&retmax=$num_results";
		print $url."\n";

		#post the efetch URL
		my $data = get($url);
		# print "$data";
		$data =~ s/[^[:ascii:]]+//g;
		print "Scraping to: ".$final_file."\n";
		open (SCRAPED, '>'.$final_file);
		print SCRAPED $data;
		close (SCRAPED);
	}

	# Scraping done.
	
	my $source = $final_file;
	my $xml = new XML::Simple;
	my $xml_data = $xml->XMLin($source);
	# my $scrubber = HTML::Scrubber->new( allow => [ qw[] ] );
	
	my $parsed_ref = parse_xml($query, $xml_data);
	my %parsed = %$parsed_ref;

	open (PARSED, '>'.$parsed_file);
	my $line_i = 0;
	foreach my $article_key (keys %parsed) {
		# print "Parsing... ".$article_key."\n";
		if ($line_i == 0) {
			foreach my $key2 (keys $parsed{$article_key}) {
				print PARSED $key2.",";
			}
		}
		if ($line_i > 0) {
			foreach my $key2 (keys $parsed{$article_key}) {
				if (defined($parsed{$article_key}->{$key2})) {
					$parsed{$article_key}->{$key2} =~ s/\"//g;
					$parsed{$article_key}->{$key2} =~ s/\n//g;
					print PARSED "\"".$parsed{$article_key}->{$key2}."\",";
				} else {
					print PARSED "\"NA\",";
				}
			}
		}
		$line_i++;
		print PARSED "\n";
	}
	close(PARSED);
}

# my $source = $url;
# my $feed = XML::FeedPP->new( $source );
# print "Title: ", $feed->title(), "\n";
# print "Date: ", $feed->pubDate(), "\n";
# foreach my $item ( $feed->get_item() ) {
	# print "Title: ", $item->title(), "\n";
	# print "URL: ", $item->link(), "\n";
	
	
	# print $doc."\n";
	# exit;
	# print "Description: ", $item->description(), "\n";
# }

sub parse_xml{
	my $query = shift;
	my $xml_data = shift;
	my %parsed = ();
	
	foreach my $e (@{$xml_data->{PubmedArticle}}) {
		# print Dumper($e);
		
		# check and process abstract
		my $pubmed_id			= $e->{MedlineCitation}->{PMID}->{content};
		next if !defined($pubmed_id);
		
		my $abstract = '';			
		if(ref($e->{MedlineCitation}->{Article}->{Abstract}->{'AbstractText'}) eq 'HASH') {
			$abstract = $e->{MedlineCitation}->{Article}->{Abstract}->{'AbstractText'}->{'content'};
		} elsif(ref($e->{MedlineCitation}->{Article}->{Abstract}->{'AbstractText'}) eq 'ARRAY') {
			# print ref($e->{MedlineCitation}->{Article}->{Abstract}->{'AbstractText'})."\n";
			foreach my $content (@{$e->{MedlineCitation}->{Article}->{Abstract}->{'AbstractText'}}) {
				# print Dumper($content)."\n";
				$abstract .= " ".$content->{'content'};
			}
			# print Dumper($abstract = $e->{MedlineCitation}->{Article}->{Abstract}->{'AbstractText'})."\n";
			# print $abstract."\n";
			# exit;
		}
		else {
			$abstract = $e->{MedlineCitation}->{Article}->{Abstract}->{'AbstractText'};
		}
		next if !defined($abstract);
		next if $abstract eq '';
		
		$abstract				=~ s/\n//g;
		$parsed{$pubmed_id}->{'abstract'} 		= $abstract;
		# edit here for science
		# $parsed{$pubmed_id}->{'EIdType'}		= $e->{MedlineCitation}->{Article}->{ELocationID}->{EIdType}; # type of electronic archive e.g. doi
		# $parsed{$pubmed_id}->{'EIdAccess'}		= $e->{MedlineCitation}->{Article}->{ELocationID}->{content}; # typically doi access point
		$parsed{$pubmed_id}->{'language'}		= $e->{MedlineCitation}->{Article}->{Language}; # article primary language
		# $parsed{$pubmed_id}->{'owner'}			= $e->{MedlineCitation}->{Article}->{Owner}; # copyright owner?
		$parsed{$pubmed_id}->{'pubmodel'}		= $e->{MedlineCitation}->{Article}->{PubModel}; # print, electronic, or both?
		$parsed{$pubmed_id}->{'pubtitle'}		= $e->{MedlineCitation}->{Article}->{ArticleTitle};
		$parsed{$pubmed_id}->{'pubtitle'}		=~ s/\"//g;
		
		$parsed{$pubmed_id}->{'pubtype'}		= '';
		if(ref($e->{MedlineCitation}->{Article}->{PublicationTypeList}->{PublicationType}) eq 'ARRAY') {
			$parsed{$pubmed_id}->{'pubtype'}	= $e->{MedlineCitation}->{Article}->{PublicationTypeList}->{PublicationType}[0];
		} else {
			$parsed{$pubmed_id}->{'pubtype'}	= $e->{MedlineCitation}->{Article}->{PublicationTypeList}->{PublicationType};
		}
		$parsed{$pubmed_id}->{'journal_abbrv'}	= $e->{MedlineCitation}->{Article}->{Journal}->{ISOAbbreviation};
		$parsed{$pubmed_id}->{'ISSNType'}		= $e->{MedlineCitation}->{Article}->{Journal}->{ISSN}->{content};
		$parsed{$pubmed_id}->{'journal_pub_year'}		= $e->{MedlineCitation}->{Article}->{Journal}->{JournalIssue}->{PubDate}->{Year};
		$parsed{$pubmed_id}->{'journal_pub_month'}		= $e->{MedlineCitation}->{Article}->{Journal}->{JournalIssue}->{PubDate}->{Month};
		$parsed{$pubmed_id}->{'journal_pub_day'}		= $e->{MedlineCitation}->{Article}->{Journal}->{JournalIssue}->{PubDate}->{Day};
		$parsed{$pubmed_id}->{'journal_title'}			= $e->{MedlineCitation}->{Article}->{Journal}->{Title};
		my $author_list_array							= $e->{MedlineCitation}->{Article}->{AuthorList}->{Author};
		my $author_list_full = '';
		my $author_list_abbrv = '';
		# print Dumper($author_list_array);
		if (ref($author_list_array) eq 'ARRAY') {
			foreach my $author (@$author_list_array) {
				# print Dumper($author);
				if(defined($author->{'Affiliation'})) {
					$author_list_full .= $author->{'LastName'}.";".$author->{'ForeName'}.";".$author->{'Initials'}.";".$author->{'Affiliation'}."|";
				}
				if(defined($author->{'LastName'})) {
					$author_list_abbrv .= $author->{'LastName'}.", ".$author->{'Initials'}.". ";
				}
			}
		} else {
				# print Dumper($author_list_array);			
				if(defined($author_list_array->{'Affiliation'})) {
					$author_list_full .= $author_list_array->{'LastName'}.";".$author_list_array->{'ForeName'}.";".$author_list_array->{'Initials'}.";".$author_list_array->{'Affiliation'}."|";
				}
				if(defined($author_list_array->{'LastName'})) {
					$author_list_abbrv .= $author_list_array->{'LastName'}.", ".$author_list_array->{'Initials'}.". ";
				}
		}
		if($author_list_abbrv eq '') {
			$author_list_abbrv = $author_list_array->{'CollectiveName'};
			$author_list_full = $author_list_array->{'CollectiveName'};
		}
		
		$parsed{$pubmed_id}->{'author_list_full'}			= $author_list_full;
		$parsed{$pubmed_id}->{'author_list_abbrv'}			= $author_list_abbrv;
		$parsed{$pubmed_id}->{'pub_status_access'}		= $e->{PubmedData}->{PublicationStatus};
		my $pub_date									= $e->{PubmedData}->{History}->{PubMedPubDate};
		$parsed{$pubmed_id}->{'pub_year'}				= @$pub_date[-1]->{Year};
		$parsed{$pubmed_id}->{'pub_month'}				= @$pub_date[-1]->{Month};
		$parsed{$pubmed_id}->{'pub_day'}				= @$pub_date[-1]->{Day};
		$parsed{$pubmed_id}->{'pub_status'}				= @$pub_date[-1]->{PubStatus};
		$parsed{$pubmed_id}->{'pub_hour'}				= @$pub_date[-1]->{Hour};
		$parsed{$pubmed_id}->{'pub_minute'}				= @$pub_date[-1]->{Minute};
	}
	
	return \%parsed;
}


sub convert_string_array {
	my $string = shift;
	my @split_string = split(//,$string);
	return \@split_string;
}
