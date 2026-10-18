use strict;
use warnings;

use Test::NoWarnings;
use Test::Pod::Coverage 'tests' => 2;

# Test.
pod_coverage_ok('Tags::HTML::MARC::Validator::Report', 'Tags::HTML::MARC::Validator::Report is covered.');
