#!/usr/bin/env perl

use strict;
use warnings;

use CSS::Struct::Output::Indent;
use Data::MARC::Validator::Report;
use Data::MARC::Validator::Report::Error;
use Data::MARC::Validator::Report::Plugin;
use Data::MARC::Validator::Report::Plugin::Errors;
use DateTime;
use Plack::App::Tags::HTML;
use Plack::Runner;
use Tags::Output::Indent;

# Report data.
my $report = Data::MARC::Validator::Report->new(
        'datetime' => DateTime->now,
        'plugins' => [
                Data::MARC::Validator::Report::Plugin->new(
                        'plugin_errors' => [
                                Data::MARC::Validator::Report::Plugin::Errors->new(
                                        'errors' => [
                                                Data::MARC::Validator::Report::Error->new(
                                                        'error' => 'Error #1',
                                                        'params' => {
                                                                'key' => 'value',
                                                        },
                                                ),
                                        ],
                                        'filters' => ['filter1'],
                                        'record_id' => 'id1',
                                ),
                        ],
                        'module_name' => 'MARC::Validator::Plugin::Foo',
                        'name' => 'foo',
                        'version' => '0.01',
                ),
        ],
);

# Run application.
my $app = Plack::App::Tags::HTML->new(
        'component' => 'Tags::HTML::MARC::Validator::Report',
        'css' => CSS::Struct::Output::Indent->new,
        'data_init' => [$report],
        'tags' => Tags::Output::Indent->new(
                'preserved' => ['style'],
                'xml' => 1,
        ),
        'title' => 'MARC validator report',
)->to_app;
Plack::Runner->new->run($app);

# Run with:
# plackup examples/plack_app_validator_report.pl
#
# The application is then available at http://localhost:5000/.