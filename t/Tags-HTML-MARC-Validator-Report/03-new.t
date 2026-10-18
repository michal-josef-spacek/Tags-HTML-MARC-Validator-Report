use strict;
use warnings;

use Tags::HTML::MARC::Validator::Report;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
my $obj = Tags::HTML::MARC::Validator::Report->new;
isa_ok($obj, 'Tags::HTML::MARC::Validator::Report');
