#!/usr/bin/env perl
# Functions for science web tools

# Copyright (c) 2013, 2014 Bryan White, bpcwhite@gmail.com
package SWT::SQL;

use DBI;
use strict;
use strict;
use warnings;

require Exporter;
my @ISA = qw(Exporter);
my @EXPORT_OK = qw(scrape_rss) ;

sub mysql_connect {
	my $driver = "mysql"; 
	my $database = "test";
	my $hostname = "localhost";
	my $userid = "root";
	my $password = "";
	my $dsn = "DBI:$driver:database=$database;host=$hostname";
	
	my $dbh = DBI->connect($dsn, $userid, $password ) or die $DBI::errstr;
	return $dbh;
	
}

sub create_pubmed_table {
	my $dbh = shift;
	my $sth = $dbh->prepare("CREATE TABLE pm_abstracts (
							pm_abstract_id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
							pm_abstract TEXT,
							pm_author_list_abbrv VARCHAR(255),
							pm_author_list_full VARCHAR(255),
							pm_ISSNType VARCHAR(255),
							pm_journal_abbrv VARCHAR(255),
							pm_journal_pub_day VARCHAR(255),
							pm_journal_pub_month VARCHAR(255),
							pm_journal_pub_year VARCHAR(255),
							pm_journal_title VARCHAR(255),
							pm_language VARCHAR(255),
							pm_pub_day VARCHAR(255),
							pm_pub_hour VARCHAR(255),
							pm_pub_minute VARCHAR(255),
							pm_pub_month VARCHAR(255),
							pm_pub_status VARCHAR(255),
							pm_pub_status_access VARCHAR(255),
							pm_pub_year VARCHAR(255),
							pm_pubmed_doi VARCHAR(255),
							pm_pubmed_doi_type VARCHAR(255),
							pm_pubmed_id VARCHAR(255),
							pm_pubmodel VARCHAR(255),
							pm_pubtitle VARCHAR(255),
							pm_pubtype VARCHAR(255),
							pm_pagination VARCHAR(255),
							pm_journal_issue VARCHAR(255),
							pm_journal_volume VARCHAR(255)
            ) ENGINE=InnoDB;");
	eval { $sth->execute() or warn $DBI::errstr; };
	warn $@ if $@;
	$sth->finish();
}

sub delete_pubmed_table {
	my $dbh = shift;
	my $sth = $dbh->prepare("DROP TABLE pm_abstracts");
	eval { $sth->execute() or warn $DBI::errstr; };
	warn $@ if $@;
	$sth->finish();
}

sub insert_pubmed {
	# my $sth = $dbh->prepare("INSERT INTO TEST_TABLE
                       # (FIRST_NAME, LAST_NAME, SEX, AGE, INCOME )
                        # values
                       # ('john', 'poul', 'M', 30, 13000)");
	# $sth->execute() or die $DBI::errstr;
	# $sth->finish();
	# $dbh->commit or die $DBI::errstr;
}

sub create_web_news_table {
	my $dbh = shift;
	my $sth = $dbh->prepare("CREATE TABLE web_news (
		web_news_id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
		web_news_feed_title VARCHAR(255),
		web_news_feed_link VARCHAR(255),
		web_news_link VARCHAR(255),
		web_news_article_title VARCHAR(255),
		web_news_description TEXT
		) ENGINE=InnoDB;");
	eval { $sth->execute() or warn $DBI::errstr; };
	warn $@ if $@;
	$sth->finish();
}

sub delete_web_news_table {
	my $dbh = shift;
	my $sth = $dbh->prepare("DROP TABLE web_news");
	eval { $sth->execute() or warn $DBI::errstr; };
	warn $@ if $@;
	$sth->finish();
}

sub create_user_table {
	my $dbh = shift;
	my $sth = $dbh->prepare("CREATE TABLE IF NOT EXISTS users (
	  userID int(11) NOT NULL AUTO_INCREMENT,
	  username varchar(50) NOT NULL,
	  password varbinary(250) NOT NULL,
	  email varchar(50) NOT NULL,
	  PRIMARY KEY (userID,username)
	) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;");
}

sub create_ngrams_table {
	my $dbh = shift;
	my $sth = $dbh->prepare("CREATE TABLE ng_ngrams (
							ng_id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
							ng_phrase VARCHAR(255),
							ng_size int(3),
							ng_date 
            ) ENGINE=InnoDB;");
	eval { $sth->execute() or warn $DBI::errstr; };
	warn $@ if $@;
	$sth->finish();
}
1;