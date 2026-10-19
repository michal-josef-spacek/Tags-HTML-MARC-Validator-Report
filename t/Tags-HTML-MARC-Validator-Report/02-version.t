use strict;
use warnings;

use Tags::HTML::MARC::Validator::Report;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Tags::HTML::MARC::Validator::Report::VERSION, 0.04, 'Version.');
