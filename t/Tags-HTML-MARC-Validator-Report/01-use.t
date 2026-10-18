use strict;
use warnings;

use Test::More 'tests' => 3;
use Test::NoWarnings;

BEGIN {

	# Test.
	use_ok('Tags::HTML::MARC::Validator::Report');
}

# Test.
require_ok('Tags::HTML::MARC::Validator::Report');
