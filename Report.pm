package Tags::HTML::MARC::Validator::Report;

use base qw(Tags::HTML);
use strict;
use warnings;

use Class::Utils qw(set_params split_params);
use Error::Pure qw(err);
use Scalar::Util qw(blessed);
use Unicode::UTF8 qw(decode_utf8);

our $VERSION = 0.04;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my ($object_params_ar, $other_params_ar) = split_params(
		['css_class'], @params);
	my $self = $class->SUPER::new(@{$other_params_ar});

	# CSS class for legend.
	$self->{'css_class'} = 'marc-validator-report';

	# Process params.
	set_params($self, @{$object_params_ar});

	# Object.
	return $self;
}

sub _cleanup {
	my $self = shift;

	delete $self->{'_report'};

	return;
}

sub _init {
	my ($self, $report) = @_;

	if (! defined $report
		|| ! blessed($report)
		|| ! $report->isa('Data::MARC::Validator::Report')) {

		err "Not valid 'Data::MARC::Validator::Report' object.";
	}

	$self->{'_report'} = $report;

	return;
}

# Process 'Tags'.
sub _process {
	my $self = shift;

	if (! exists $self->{'_report'}) {
		return;
	}

	$self->{'tags'}->put(
		['b', 'div'],
		['a', 'class', $self->{'css_class'}],
	);

	my $report = $self->{'_report'};
	my @plugins = @{$report->plugins};
	my @plugins_with_errors;
	my ($plugins_with_errors, $records, $error_count) = (0, {}, 0);
	foreach my $plugin (@plugins) {
		my $plugin_error_count = 0;
		foreach my $plugin_errors (@{$plugin->plugin_errors}) {
			$records->{$plugin_errors->record_id} = 1;
			$plugin_error_count += scalar @{$plugin_errors->errors};
			$error_count += scalar @{$plugin_errors->errors};
		}
		if ($plugin_error_count) {
			$plugins_with_errors++;
			push @plugins_with_errors, $plugin;
		}
	}

	$self->{'tags'}->put(
		['b', 'section'],
		['a', 'class', 'stats'],
	);
	$self->_tags_article(scalar @plugins, decode_utf8('validačních pluginů'));
	$self->_tags_article($plugins_with_errors, decode_utf8('pluginů s chybou'));
	$self->_tags_article(scalar keys %{$records}, decode_utf8('zasažených záznamů'));
	$self->_tags_article($error_count, decode_utf8('celkem chyb'));
	$self->{'tags'}->put(
		['e', 'section'],

		['b', 'section'],
		['a', 'class', 'content-grid'],
		['b', 'div'],
		['a', 'class', 'plugin-list'],
	);

	foreach my $plugin (@plugins_with_errors) {
		$self->_tags_plugin($plugin);
	}

	if (! @plugins_with_errors) {
		$self->{'tags'}->put(
			['b', 'div'],
			['a', 'class', 'panel empty'],
			['d', decode_utf8('Celý report je bez chyb.')],
			['e', 'div'],
		);
	}

	$self->{'tags'}->put(
		['e', 'div'],
		['e', 'section'],
	);

	$self->{'tags'}->put(
		['e', 'div'],
	);

	return;
}

sub _process_css {
	my $self = shift;

	my $class = '.'.$self->{'css_class'};
	$self->{'css'}->put(
		['s', $class],
		['d', '--bg', '#f6f7fb'],
		['d', '--panel', '#fff'],
		['d', '--text', '#172033'],
		['d', '--muted', '#64748b'],
		['d', '--line', '#e2e8f0'],
		['d', '--accent', '#2563eb'],
		['d', '--accent-soft', '#dbeafe'],
		['d', '--danger', '#dc2626'],
		['d', '--danger-soft', '#fee2e2'],
		['d', '--ok', '#16a34a'],
		['d', '--ok-soft', '#dcfce7'],
		['d', '--shadow', '0 18px 45px rgba(15,23,42,.08)'],
		['d', '--radius', '18px'],
		['d', 'font-family', 'Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif'],
		['d', 'display', 'grid'],
		['d', 'gap', '18px'],
		['d', 'color', 'var(--text)'],
		['e'],

		['s', $class.' *'],
		['d', 'box-sizing', 'border-box'],
		['e'],

		['s', $class.' .panel'],
		['d', 'background', 'rgba(255,255,255,.88)'],
		['d', 'border', '1px solid rgba(226,232,240,.85)'],
		['d', 'border-radius', 'var(--radius)'],
		['d', 'box-shadow', 'var(--shadow)'],
		['d', 'backdrop-filter', 'blur(10px)'],
		['e'],

		['s', $class.' .stats'],
		['d', 'display', 'grid'],
		['d', 'grid-template-columns', 'repeat(auto-fit,minmax(180px,1fr))'],
		['d', 'gap', '14px'],
		['e'],

		['s', $class.' .stat'],
		['d', 'padding', '18px'],
		['e'],

		['s', $class.' .stat strong'],
		['d', 'display', 'block'],
		['d', 'font-size', '30px'],
		['d', 'letter-spacing', '-.04em'],
		['e'],

		['s', $class.' .stat span'],
		['d', 'color', 'var(--muted)'],
		['d', 'font-size', '14px'],
		['e'],

		['s', $class.' .content-grid'],
		['d', 'display', 'grid'],
		['d', 'gap', '18px'],
		['e'],

		['s', $class.' .plugin-list'],
		['d', 'display', 'grid'],
		['d', 'gap', '14px'],
		['e'],

		['s', $class.' details.plugin'],
		['d', 'overflow', 'hidden'],
		['d', 'scroll-margin-top', '16px'],
		['e'],

		['s', $class.' details.plugin summary'],
		['d', 'list-style', 'none'],
		['d', 'display', 'grid'],
		['d', 'grid-template-columns', '1fr auto'],
		['d', 'gap', '12px'],
		['d', 'align-items', 'center'],
		['d', 'padding', '18px'],
		['d', 'cursor', 'pointer'],
		['e'],

		['s', $class.' details.plugin summary::-webkit-details-marker'],
		['d', 'display', 'none'],
		['e'],

		['s', $class.' .plugin-title'],
		['d', 'display', 'flex'],
		['d', 'flex-wrap', 'wrap'],
		['d', 'gap', '8px'],
		['d', 'align-items', 'baseline'],
		['e'],

		['s', $class.' .plugin-title h2'],
		['d', 'margin', '0'],
		['d', 'font-size', '20px'],
		['d', 'letter-spacing', '-.02em'],
		['e'],

		['s', $class.' .module'],
		['d', 'color', 'var(--muted)'],
		['d', 'font-size', '13px'],
		['d', 'font-family', 'ui-monospace,SFMono-Regular,Menlo,Consolas,monospace'],
		['e'],

		['s', $class.' .badge'],
		['d', 'display', 'inline-flex'],
		['d', 'align-items', 'center'],
		['d', 'justify-content', 'center'],
		['d', 'gap', '6px'],
		['d', 'min-width', '34px'],
		['d', 'padding', '5px 9px'],
		['d', 'border-radius', '999px'],
		['d', 'font-size', '12px'],
		['d', 'font-weight', '800'],
		['d', 'background', 'var(--danger-soft)'],
		['d', 'color', '#991b1b'],
		['e'],

		['s', $class.' .badge.ok'],
		['d', 'background', 'var(--ok-soft)'],
		['d', 'color', '#166534'],
		['e'],

		['s', $class.' .records'],
		['d', 'border-top', '1px solid var(--line)'],
		['d', 'padding', '0 18px 18px'],
		['d', 'display', 'grid'],
		['d', 'gap', '10px'],
		['e'],

		['s', $class.' .record'],
		['d', 'border', '1px solid var(--line)'],
		['d', 'border-radius', '14px'],
		['d', 'overflow', 'hidden'],
		['d', 'background', '#fff'],
		['d', 'scroll-margin-top', '16px'],
		['e'],

		['s', $class.' .record-header'],
		['d', 'padding', '12px 14px'],
		['d', 'display', 'flex'],
		['d', 'flex-wrap', 'wrap'],
		['d', 'gap', '10px'],
		['d', 'align-items', 'center'],
		['d', 'justify-content', 'space-between'],
		['d', 'background', '#f8fafc'],
		['d', 'border-bottom', '1px solid var(--line)'],
		['e'],

		['s', $class.' .record-id'],
		['d', 'font-family', 'ui-monospace,SFMono-Regular,Menlo,Consolas,monospace'],
		['d', 'font-weight', '800'],
		['e'],

		['s', $class.' .issues'],
		['d', 'display', 'grid'],
		['d', 'gap', '10px'],
		['d', 'padding', '12px'],
		['e'],

		['s', $class.' .issue'],
		['d', 'display', 'grid'],
		['d', 'gap', '7px'],
		['d', 'padding', '12px'],
		['d', 'border-radius', '12px'],
		['d', 'background', '#fff'],
		['d', 'border', '1px solid #eef2f7'],
		['e'],

		['s', $class.' .issue-title'],
		['d', 'font-weight', '750'],
		['e'],

		['s', $class.' .params'],
		['d', 'display', 'flex'],
		['d', 'flex-direction', 'column'],
		['d', 'align-items', 'flex-start'],
		['d', 'gap', '7px'],
		['e'],

		['s', $class.' .param'],
		['d', 'max-width', '100%'],
		['d', 'display', 'inline-flex'],
		['d', 'align-items', 'center'],
		['d', 'gap', '4px'],
		['d', 'font-family', 'ui-monospace,SFMono-Regular,Menlo,Consolas,monospace'],
		['d', 'font-size', '12px'],
		['d', 'color', '#334155'],
		['d', 'overflow-wrap', 'anywhere'],
		['e'],

		['s', $class.' .param-key'],
		['d', 'border-radius', '10px'],
		['d', 'background', '#f1f5f9'],
		['d', 'padding', '6px 8px'],
		['e'],

		['s', $class.' .param-separator'],
		['d', 'padding', '0 1px'],
		['e'],

		['s', $class.' .param-value'],
		['d', 'font-size', '0'],
		['d', 'display', 'inline-block'],
		['d', 'border-radius', '10px'],
		['d', 'background', '#f1f5f9'],
		['d', 'padding', '6px 8px'],
		['e'],

		['s', $class.' .param-value-text'],
		['d', 'font-family', 'inherit'],
		['d', 'font-size', '12px'],
		['d', 'white-space', 'nowrap'],
		['e'],

		['s', $class.' .empty'],
		['d', 'padding', '26px'],
		['d', 'text-align', 'center'],
		['d', 'color', 'var(--muted)'],
		['e'],

	);

	return;
}

sub _tags_article {
	my ($self, $number, $title) = @_;

	$self->{'tags'}->put(
		['b', 'article'],
		['a', 'class', 'panel stat'],
		['b', 'strong'],
		['d', $number],
		['e', 'strong'],
		['b', 'span'],
		['d', $title],
		['e', 'span'],
		['e', 'article'],
	);

	return;
}

sub _tags_plugin {
	my ($self, $plugin) = @_;

	my $id = $plugin->name;
	$id =~ s/[^A-Za-z0-9_-]+/_/g;
	my @plugin_errors = @{$plugin->plugin_errors};
	my ($error_count, $record_count) = (0, scalar @plugin_errors);
	$error_count += scalar @{$_->errors} for @plugin_errors;

	$self->{'tags'}->put(
		['b', 'details'],
		['a', 'class', 'panel plugin'],
		['a', 'id', $id],
	);
	if (@plugin_errors) {
		$self->{'tags'}->put(
			['a', 'open', 'open'],
		);
	}
	$self->{'tags'}->put(
		['b', 'summary'],
		['b', 'div'],
		['b', 'div'],
		['a', 'class', 'plugin-title'],
		['b', 'h2'],
		['d', $plugin->name],
		['e', 'h2'],
		['b', 'span'],
		['a', 'class', 'badge'],
		['d', $error_count.' '.decode_utf8('chyb')],
		['e', 'span'],
		['b', 'span'],
		['a', 'class', 'badge'],
		['d', $record_count.' '.decode_utf8('záznamů')],
		['e', 'span'],
		['e', 'div'],
		['b', 'div'],
		['a', 'class', 'module'],
		['d', $plugin->module_name.' '.decode_utf8('·').' v'.$plugin->version
			.' '.decode_utf8('·').' '.$self->{'_report'}->datetime],
		['e', 'div'],
		['e', 'div'],
		['b', 'span'],
		['a', 'aria-hidden', 'true'],
		['d', decode_utf8('▾')],
		['e', 'span'],
		['e', 'summary'],
		['b', 'div'],
		['a', 'class', 'records'],
	);

	foreach my $plugin_errors (@plugin_errors) {
		$self->_tags_record($plugin_errors);
	}

	if (! @plugin_errors) {
		$self->{'tags'}->put(
			['b', 'div'],
			['a', 'class', 'empty'],
			['d', decode_utf8('Bez chyb.')],
			['e', 'div'],
		);
	}

	$self->{'tags'}->put(
		['e', 'div'],
		['e', 'details'],
	);

	return;
}

sub _tags_record {
	my ($self, $plugin_errors) = @_;
	my $record_id = $plugin_errors->record_id;
	my @errors = @{$plugin_errors->errors};

	my $record_anchor = $record_id;
	$record_anchor =~ s/[^A-Za-z0-9_-]+/_/g;
	$self->{'tags'}->put(
		['b', 'article'],
		['a', 'class', 'record'],
		['a', 'id', 'record-'.$record_anchor],
		['b', 'div'],
		['a', 'class', 'record-header'],
		['b', 'span'],
		['a', 'class', 'record-id'],
		['d', $record_id],
		['e', 'span'],
		['b', 'span'],
		['a', 'class', 'badge'],
		['d', scalar(@errors).decode_utf8('×')],
		['e', 'span'],
		['e', 'div'],
		['b', 'div'],
		['a', 'class', 'issues'],
	);

	foreach my $error (@errors) {
		$self->{'tags'}->put(
			['b', 'section'],
			['a', 'class', 'issue'],
			['b', 'div'],
			['a', 'class', 'issue-title'],
			['d', $error->error],
			['e', 'div'],
			['b', 'div'],
			['a', 'class', 'params'],
		);
		my $params = $error->params;
		if (keys %{$params}) {
			foreach my $key (sort keys %{$params}) {
				$self->{'tags'}->put(
					['b', 'span'],
					['a', 'class', 'param'],
					['b', 'span'],
					['a', 'class', 'param-key'],
					['b', 'b'],
					['d', $key],
					['e', 'b'],
					['e', 'span'],
					['b', 'span'],
					['a', 'class', 'param-separator'],
					['d', ':'],
					['e', 'span'],
					['b', 'code'],
					['a', 'class', 'param-value'],
					['b', 'span'],
					['a', 'class', 'param-value-text'],
					['r', $self->_html_param_value($params->{$key})],
					['e', 'span'],
					['e', 'code'],
					['e', 'span'],
				);
			}
		}
		$self->{'tags'}->put(
			['e', 'div'],
			['e', 'section'],
		);
	}

	$self->{'tags'}->put(
		['e', 'div'],
		['e', 'article'],
	);

	return;
}

sub _html_param_value {
	my ($self, $value) = @_;

	$value = '' if ! defined $value;
	$value =~ s/&/&amp;/g;
	$value =~ s/</&lt;/g;
	$value =~ s/>/&gt;/g;
	$value =~ s/ /&nbsp;/g;
	$value =~ s/\t/&#9;/g;
	$value =~ s/\r/&#13;/g;
	$value =~ s/\n/&#10;/g;

	return $value;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

Tags::HTML::MARC::Validator::Report - Tags helper class for MARC validator report presentation.

=head1 SYNOPSIS

 use Tags::HTML::MARC::Validator::Report;

 my $obj = Tags::HTML::MARC::Validator::Report->new(%params);
 $obj->cleanup;
 $obj->init($report);
 $obj->prepare;
 $obj->process;
 $obj->process_css;

=head1 METHODS

=head2 C<new>

 my $obj = Tags::HTML::MARC::Validator::Report->new(%params);

Constructor.

=over 8

=item * C<css_class>

CSS class for the report root element.

Default value is 'marc-validator-report'.

=item * C<css>

L<CSS::Struct::Output> object.

Default value is undef.

=item * C<tags>

L<Tags::Output> object.

Default value is undef.

=back

Returns instance of object.

=head2 C<cleanup>

 $obj->cleanup;

Process cleanup after page run and remove the initialized report object.

Returns undef.

=head2 C<init>

 $obj->init($report);

Initialize the component for a page run. Takes a
L<Data::MARC::Validator::Report> object as C<$report>.

Returns undef.

=head2 C<prepare>

 $obj->prepare;

Process initialization before page run.

It is not used in this module.

Returns undef.

=head2 C<process>

 $obj->process;

Process the initialized MARC validator report into a Tags structure. The
output is rooted in a C<div> with the configured CSS class and contains report
statistics, plugin sections, records, and validation issues.

Returns undef.

=head2 C<process_css>

 $obj->process_css;

Process the component CSS into a CSS::Struct structure. Selectors are scoped
below the configured report CSS class.

Returns undef.

=head1 ERRORS

 new():
         From Class::Utils::set_params():
                 Unknown parameter '%s'.
         From Tags::HTML::new():
                 Parameter 'css' must be a 'CSS::Struct::Output::*' class.
                 Parameter 'tags' must be a 'Tags::Output::*' class.

 init():
         Not valid 'Data::MARC::Validator::Report' object.

 process():
         From Tags::HTML::process():
                 Parameter 'tags' isn't defined.

 process_css():
         From Tags::HTML::process_css():
                 Parameter 'css' isn't defined.

=head1 EXAMPLE1

=for comment filename=create_validator_report_html.pl

 use strict;
 use warnings;

 use CSS::Struct::Output::Indent;
 use Data::MARC::Validator::Report;
 use Data::MARC::Validator::Report::Error;
 use Data::MARC::Validator::Report::Plugin;
 use Data::MARC::Validator::Report::Plugin::Errors;
 use DateTime;
 use Tags::HTML::MARC::Validator::Report;
 use Tags::Output::Indent;

 # Output objects.
 my $css = CSS::Struct::Output::Indent->new;
 my $tags = Tags::Output::Indent->new;
 my $obj = Tags::HTML::MARC::Validator::Report->new(
         'css' => $css,
         'tags' => $tags,
 );

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
                                                 Data::MARC::Validator::Report::Error->new(
                                                         'error' => 'Error #2',
                                                         'params' => {
                                                                 'key' => 'value',
                                                         },
                                                 ),
                                         ],
                                         'filters' => ['filter1', 'filter2'],
                                         'record_id' => 'id1',
                                 ),
                         ],
                         'module_name' => 'MARC::Validator::Plugin::Foo',
                         'name' => 'foo',
                         'version' => '0.01',
                 ),
         ],
 );

 # Process HTML and CSS.
 $obj->init($report);
 $obj->process;
 $obj->process_css;

 print "HTML:\n";
 print $tags->flush;
 print "\n\n";
 print "CSS:\n";
 print $css->flush;

 # Output:
 # HTML:
 # <div class="marc-validator-report">
 #   <section class="stats">
 #     <article class="panel stat">
 #       <strong>
 #         1
 #       </strong>
 #       <span>
 #         validačních pluginů
 #       </span>
 #     </article>
 #     <article class="panel stat">
 #       <strong>
 #         1
 #       </strong>
 #       <span>
 #         pluginů s chybou
 #       </span>
 #     </article>
 #     <article class="panel stat">
 #       <strong>
 #         1
 #       </strong>
 #       <span>
 #         zasažených záznamů
 #       </span>
 #     </article>
 #     <article class="panel stat">
 #       <strong>
 #         2
 #       </strong>
 #       <span>
 #         celkem chyb
 #       </span>
 #     </article>
 #   </section>
 #   <section class="content-grid">
 #     <div class="plugin-list">
 #       <details class="panel plugin" id="foo" open="open">
 #         <summary>
 #           <div>
 #             <div class="plugin-title">
 #               <h2>
 #                 foo
 #               </h2>
 #               <span class="badge">
 #                 2 chyb
 #               </span>
 #               <span class="badge">
 #                 1 záznamů
 #               </span>
 #             </div>
 #             <div class="module">
 #               MARC::Validator::Plugin::Foo · v0.01 · 2026-10-23T17:10:26
 #             </div>
 #           </div>
 #           <span aria-hidden="true">
 #             ▾
 #           </span>
 #         </summary>
 #         <div class="records">
 #           <article class="record" id="record-id1">
 #             <div class="record-header">
 #               <span class="record-id">
 #                 id1
 #               </span>
 #               <span class="badge">
 #                 2×
 #               </span>
 #             </div>
 #             <div class="issues">
 #               <section class="issue">
 #                 <div class="issue-title">
 #                   Error #1
 #                 </div>
 #                 <div class="params">
 #                   <span class="param">
 #                     <span class="param-key">
 #                       <b>
 #                         key
 #                       </b>
 #                     </span>
 #                     <span class="param-separator">
 #                       :
 #                     </span>
 #                     <code class="param-value">
 #                       <span class="param-value-text">value                      </span>
 #                     </code>
 #                   </span>
 #                 </div>
 #               </section>
 #               <section class="issue">
 #                 <div class="issue-title">
 #                   Error #2
 #                 </div>
 #                 <div class="params">
 #                   <span class="param">
 #                     <span class="param-key">
 #                       <b>
 #                         key
 #                       </b>
 #                     </span>
 #                     <span class="param-separator">
 #                       :
 #                     </span>
 #                     <code class="param-value">
 #                       <span class="param-value-text">value                      </span>
 #                     </code>
 #                   </span>
 #                 </div>
 #               </section>
 #             </div>
 #           </article>
 #         </div>
 #       </details>
 #     </div>
 #   </section>
 # </div>
 #
 # CSS:
 # .marc-validator-report {
 # 	--bg: #f6f7fb;
 # 	--panel: #fff;
 # 	--text: #172033;
 # 	--muted: #64748b;
 # 	--line: #e2e8f0;
 # 	--accent: #2563eb;
 # 	--accent-soft: #dbeafe;
 # 	--danger: #dc2626;
 # 	--danger-soft: #fee2e2;
 # 	--ok: #16a34a;
 # 	--ok-soft: #dcfce7;
 # 	--shadow: 0 18px 45px rgba(15,23,42,.08);
 # 	--radius: 18px;
 # 	font-family: Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
 # 	display: grid;
 # 	gap: 18px;
 # 	color: var(--text);
 # }
 # .marc-validator-report * {
 # 	box-sizing: border-box;
 # }
 # .marc-validator-report .panel {
 # 	background: rgba(255,255,255,.88);
 # 	border: 1px solid rgba(226,232,240,.85);
 # 	border-radius: var(--radius);
 # 	box-shadow: var(--shadow);
 # 	backdrop-filter: blur(10px);
 # }
 # .marc-validator-report .stats {
 # 	display: grid;
 # 	grid-template-columns: repeat(auto-fit,minmax(180px,1fr));
 # 	gap: 14px;
 # }
 # .marc-validator-report .stat {
 # 	padding: 18px;
 # }
 # .marc-validator-report .stat strong {
 # 	display: block;
 # 	font-size: 30px;
 # 	letter-spacing: -.04em;
 # }
 # .marc-validator-report .stat span {
 # 	color: var(--muted);
 # 	font-size: 14px;
 # }
 # .marc-validator-report .content-grid {
 # 	display: grid;
 # 	gap: 18px;
 # }
 # .marc-validator-report .plugin-list {
 # 	display: grid;
 # 	gap: 14px;
 # }
 # .marc-validator-report details.plugin {
 # 	overflow: hidden;
 # 	scroll-margin-top: 16px;
 # }
 # .marc-validator-report details.plugin summary {
 # 	list-style: none;
 # 	display: grid;
 # 	grid-template-columns: 1fr auto;
 # 	gap: 12px;
 # 	align-items: center;
 # 	padding: 18px;
 # 	cursor: pointer;
 # }
 # .marc-validator-report details.plugin summary::-webkit-details-marker {
 # 	display: none;
 # }
 # .marc-validator-report .plugin-title {
 # 	display: flex;
 # 	flex-wrap: wrap;
 # 	gap: 8px;
 # 	align-items: baseline;
 # }
 # .marc-validator-report .plugin-title h2 {
 # 	margin: 0;
 # 	font-size: 20px;
 # 	letter-spacing: -.02em;
 # }
 # .marc-validator-report .module {
 # 	color: var(--muted);
 # 	font-size: 13px;
 # 	font-family: ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;
 # }
 # .marc-validator-report .badge {
 # 	display: inline-flex;
 # 	align-items: center;
 # 	justify-content: center;
 # 	gap: 6px;
 # 	min-width: 34px;
 # 	padding: 5px 9px;
 # 	border-radius: 999px;
 # 	font-size: 12px;
 # 	font-weight: 800;
 # 	background: var(--danger-soft);
 # 	color: #991b1b;
 # }
 # .marc-validator-report .badge.ok {
 # 	background: var(--ok-soft);
 # 	color: #166534;
 # }
 # .marc-validator-report .records {
 # 	border-top: 1px solid var(--line);
 # 	padding: 0 18px 18px;
 # 	display: grid;
 # 	gap: 10px;
 # }
 # .marc-validator-report .record {
 # 	border: 1px solid var(--line);
 # 	border-radius: 14px;
 # 	overflow: hidden;
 # 	background: #fff;
 # 	scroll-margin-top: 16px;
 # }
 # .marc-validator-report .record-header {
 # 	padding: 12px 14px;
 # 	display: flex;
 # 	flex-wrap: wrap;
 # 	gap: 10px;
 # 	align-items: center;
 # 	justify-content: space-between;
 # 	background: #f8fafc;
 # 	border-bottom: 1px solid var(--line);
 # }
 # .marc-validator-report .record-id {
 # 	font-family: ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;
 # 	font-weight: 800;
 # }
 # .marc-validator-report .issues {
 # 	display: grid;
 # 	gap: 10px;
 # 	padding: 12px;
 # }
 # .marc-validator-report .issue {
 # 	display: grid;
 # 	gap: 7px;
 # 	padding: 12px;
 # 	border-radius: 12px;
 # 	background: #fff;
 # 	border: 1px solid #eef2f7;
 # }
 # .marc-validator-report .issue-title {
 # 	font-weight: 750;
 # }
 # .marc-validator-report .params {
 # 	display: flex;
 # 	flex-direction: column;
 # 	align-items: flex-start;
 # 	gap: 7px;
 # }
 # .marc-validator-report .param {
 # 	max-width: 100%;
 # 	display: inline-flex;
 # 	align-items: center;
 # 	gap: 4px;
 # 	font-family: ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;
 # 	font-size: 12px;
 # 	color: #334155;
 # 	overflow-wrap: anywhere;
 # }
 # .marc-validator-report .param-key {
 # 	border-radius: 10px;
 # 	background: #f1f5f9;
 # 	padding: 6px 8px;
 # }
 # .marc-validator-report .param-separator {
 # 	padding: 0 1px;
 # }
 # .marc-validator-report .param-value {
 # 	font-size: 0;
 # 	display: inline-block;
 # 	border-radius: 10px;
 # 	background: #f1f5f9;
 # 	padding: 6px 8px;
 # }
 # .marc-validator-report .param-value-text {
 # 	font-family: inherit;
 # 	font-size: 12px;
 # 	white-space: nowrap;
 # }
 # .marc-validator-report .empty {
 # 	padding: 26px;
 # 	text-align: center;
 # 	color: var(--muted);
 # }

=head1 EXAMPLE2

=for comment filename=plack_app_validator_report.pl

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

=head1 DEPENDENCIES

L<Class::Utils>,
L<Error::Pure>,
L<Scalar::Util>,
L<Tags::HTML>,
L<Unicode::UTF8>.

=head1 SEE ALSO

=over

=item L<Data::MARC::Validator::Report>

Data object consumed by this component.

=item L<Tags::HTML::Image>

Reusable Tags::HTML component with the same rendering lifecycle.

=back

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/Tags-HTML-MARC-Validator-Report>

=head1 AUTHOR

Michal Josef Špaček L<mailto:michal.josef.spacek@gmail.com>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2025-2026 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.04

=cut
