package WWW::Deutschepost::Detail;
use strict;
#use warnings;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/deutschepostcheck/;
our $VERSION = '0.1';
use LWP::Simple;
use LWP::UserAgent;
use MIME::Base64;

sub deutschepostcheck {
	my $paketnummer = shift;
	my $tag = shift;
	my $monat = shift;
	my $jahr = shift;

	my %post;
	$post{'form.sendungsnummer'} = $paketnummer;
	$post{'form.einlieferungsdatum_tag'} = $tag;
	$post{'form.einlieferungsdatum_monat'} = $monat;
	$post{'form.einlieferungsdatum_jahr'} = $jahr;
	my $ua = LWP::UserAgent->new;
	my $response = $ua->post('https://www.deutschepost.de/sendung/simpleQueryResult.html', \%post );
	my $data1 = $response->content;

	my($detail) = ($data1 =~ /<div class="pk-result-element-one">(.*)<div id="buttons">/i);
	my($laststatus) = ($data1 =~ /<div class="pk-result-element-one">([^<]*)<div class="pk-result-links">/si);
	my($signature) = ($data1 =~ /<div class="pk-result-link"><a href="javascript: callPopUpReceipt\('Belegzugriffspfad=([^']*)'\)" class="link">Auslieferungsbeleg anzeigen<\/a><\/div>/i);
	$laststatus =~ s/[\n\r]//g;
	$laststatus =~ s/^\s*//g;
	$laststatus =~ s/\s\s*/ /g;
	$laststatus =~ s/,\s*/, /g;
	$signature =~ s/&amp;/\%26/g;
	$signature =~ s/=/\%3D/g;

	my $pictureurl;
	my $picturedata;
	my $signaturedata;
	if($signature){
		$signaturedata = get('https://www.deutschepost.de/sendung/receipt.html?receiptUrl=Belegzugriffspfad%3D'.$signature);
		($pictureurl) = ($signaturedata =~ /<img src="([^"]*)"/);
		($picturedata) = get('https://www.deutschepost.de'.$pictureurl);
	}

	return(({
		'shipnumber' => $paketnummer,
		'laststatus' => $laststatus,
		'signature' => 'https://www.deutschepost.de/sendung/receipt.html?receiptUrl=Belegzugriffspfad%3D'.$signature,
		'pictureurl' => 'https://www.deutschepost.de'.$pictureurl,
		'picture' => encode_base64($picturedata, ''),
		})
	);
}


=pod

=head1 NAME

WWW::Deutschepost::Detail - Perl module for the Deutschepost online tracking service with details.

=head1 SYNOPSIS

	use WWW::Deutschepost::Detail;
	my($other) = deutschepostcheck('paketnumber','day','month','year');

	foreach my $key (keys %$other){# shipnumber, laststatus, signature (as url), pictureurl (as url), picture (as base64)
		print $key . ": " . ${$other}{$key} . "\n";
	}

	#
	#save as picturefile
	#
	#open(F,">picture.gif");
	#binmode(F);
	#print F decode_base64(${$other}{'picture'});
	#close(F);

=head1 DESCRIPTION

WWW::Deutschepost::Detail - Perl module for the Deutschepost online tracking service with details.

=head1 AUTHOR

    Stefan Gipper <stefanos@cpan.org>, http://www.coder-world.de/

=head1 COPYRIGHT

	WWW::Deutschepost::Detail is Copyright (c) 2010 Stefan Gipper
	All rights reserved.

	This program is free software; you can redistribute
	it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO



=cut
