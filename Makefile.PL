use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'WWW::Deutschepost::Detail',
    'VERSION_FROM'	=> 'Detail.pm', # finds $VERSION
    'PREREQ_PM'		=> {LWP::Simple => 1.00,LWP::UserAgent => 1.00,MIME::Base64 => 3.00},
    ($] >= 5.005 ? (
      ABSTRACT_FROM => 'Detail.pm', 
      AUTHOR     => '-',
    ) : ()),
);
