package Tags::HTML::MARC::Validator::Report;

use base qw(Tags::HTML);
use strict;
use warnings;

use Class::Utils qw(set_params split_params);
use Error::Pure qw(err);
use Scalar::Util qw(blessed);
use Unicode::UTF8 qw(decode_utf8);

our $VERSION = 0.02;

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
		['d', 'flex-wrap', 'wrap'],
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

		['s', $class.' .param-empty'],
		['d', 'border-radius', '10px'],
		['d', 'background', '#f1f5f9'],
		['d', 'padding', '6px 8px'],
		['d', 'font-family', 'ui-monospace,SFMono-Regular,Menlo,Consolas,monospace'],
		['d', 'font-size', '12px'],
		['d', 'color', '#334155'],
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
	$self->{'tags'}->put(
		['a', 'open', 'open'],
	) if @plugin_errors;
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
		['b', 'article'], ['a', 'class', 'record'], ['a', 'id', 'record-'.$record_anchor],
		['b', 'div'], ['a', 'class', 'record-header'],
		['b', 'span'], ['a', 'class', 'record-id'], ['d', $record_id], ['e', 'span'],
		['b', 'span'], ['a', 'class', 'badge'],
		['d', scalar(@errors).decode_utf8('×')], ['e', 'span'],
		['e', 'div'],
		['b', 'div'], ['a', 'class', 'issues'],
	);

	foreach my $error (@errors) {
		$self->{'tags'}->put(
			['b', 'section'], ['a', 'class', 'issue'],
			['b', 'div'], ['a', 'class', 'issue-title'],
			['d', $error->error], ['e', 'div'],
			['b', 'div'], ['a', 'class', 'params'],
		);
		my $params = $error->params;
		if (keys %{$params}) {
			foreach my $key (sort keys %{$params}) {
				$self->{'tags'}->put(
					['b', 'span'], ['a', 'class', 'param'],
					['b', 'span'], ['a', 'class', 'param-key'],
					['b', 'b'], ['d', $key], ['e', 'b'],
					['e', 'span'],
					['b', 'span'], ['a', 'class', 'param-separator'],
					['d', ':'], ['e', 'span'],
					['b', 'code'], ['a', 'class', 'param-value'],
					['b', 'span'], ['a', 'class', 'param-value-text'],
					['r', $self->_html_param_value($params->{$key})],
					['e', 'span'], ['e', 'code'],
					['e', 'span'],
				);
			}
		} else {
			$self->{'tags'}->put(
				['b', 'div'], ['a', 'class', 'param-empty'],
				['d', decode_utf8('bez parametrů')], ['e', 'div'],
			);
		}
		$self->{'tags'}->put(
			['e', 'div'],
			['e', 'section'],
		);
	}

	$self->{'tags'}->put(
		['e', 'div'], ['e', 'article'],
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
