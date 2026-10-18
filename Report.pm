package Tags::HTML::MARC::Validator::Report;

use base qw(Tags::HTML);
use strict;
use warnings;

use Class::Utils qw(set_params split_params);
use Error::Pure qw(err);
use Scalar::Util qw(blessed);

our $VERSION = 0.01;

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

	$self->{'tags'}->put(
		['b', 'section'],
	);
	$self->_tags_article(12, decode_utf8('validovaných pluginů'));
	$self->_tags_article(8, decode_utf8('pluginů s chybou'));
	$self->_tags_article(36, decode_utf8('zasažených záznamů'));
	$self->_tags_article(72, decode_utf8('celkem chyb'));
	$self->{'tags'}->put(
		['e', 'section'],
	);

	# TODO

	$self->{'tags'}->put(
		# TODO Div with plugin checkboxes on the right page.
	);

	# TODO

	$self->{'tags'}->put(
		['e', 'div'],
	);

	return;
}

sub _process_css {
	my $self = shift;

	$self->{'css'}->put(
		['s', ':root'],
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
		['e'],

		['s', '*'],
		['d', 'box-sizing', 'border-box'],
		['e'],

		['s', 'html'],
		['d', 'scroll-behavior', 'smooth'],
		['e'],

		['s', 'body'],
		['d', 'margin', '0'],
		['d', 'background', 'radial-gradient(circle at top left,rgba(37,99,235,.12),transparent 28rem),var(--bg)'],
		['d', 'color', 'var(--text)'],
		['e'],

		['s', 'header'],
		['d', 'padding', '32px clamp(16px,4vw,56px) 20px'],
		['e'],

		['s', 'h1'],
		['d', 'margin', '0 0 8px'],
		['d', 'font-size', 'clamp(28px,4vw,46px)'],
		['d', 'letter-spacing', '-.04em'],
		['e'],

		['s', '.lead'],
		['d', 'margin', '0'],
		['d', 'color', 'var(--muted)'],
		['d', 'max-width', '820px'],
		['d', 'line-height', '1.6'],
		['e'],

		['s', 'main'],
		['d', 'padding', '0 clamp(16px,4vw,56px) 48px'],
		['d', 'display', 'grid'],
		['d', 'gap', '18px'],
		['e'],

		['s', '.panel'],
		['d', 'background', 'rgba(255,255,255,.88)'],
		['d', 'border', '1px solid rgba(226,232,240,.85)'],
		['d', 'border-radius', 'var(--radius)'],
		['d', 'box-shadow', 'var(--shadow)'],
		['d', 'backdrop-filter', 'blur(10px)'],
		['e'],

		['s', '.stats'],
		['d', 'display', 'grid'],
		['d', 'grid-template-columns', 'repeat(4,minmax(0,1fr))'],
		['d', 'gap', '14px'],
		['e'],

		['s', '.stat'],
		['d', 'padding', '18px'],
		['e'],

		['s', '.stat strong'],
		['d', 'display', 'block'],
		['d', 'font-size', '30px'],
		['d', 'letter-spacing', '-.04em'],
		['e'],

		['s', '.stat span'],
		['d', 'color', 'var(--muted)'],
		['d', 'font-size', '14px'],
		['e'],

		['s', '.controls'],
		['d', 'padding', '14px'],
		['d', 'display', 'grid'],
		['d', 'grid-template-columns', '1.2fr .8fr .8fr'],
		['d', 'gap', '10px'],
		['d', 'align-items', 'center'],
		['e'],

		['s', 'select,input[type=search]'],
		['d', 'width', '100%'],
		['d', 'border', '1px solid var(--line)'],
		['d', 'border-radius', '999px'],
		['d', 'padding', '11px 14px'],
		['d', 'background', '#fff'],
		['d', 'color', 'var(--text)'],
		['d', 'outline', 'none'],
		['e'],

		['s', 'input[disabled]'],
		['d', 'color', '#94a3b8'],
		['d', 'background', '#f8fafc'],
		['e'],

		['s', '.hint'],
		['d', 'grid-column', '1/-1'],
		['d', 'color', 'var(--muted)'],
		['d', 'font-size', '13px'],
		['d', 'line-height', '1.5'],
		['e'],

		['s', '.content-grid'],
		['d', 'display', 'grid'],
		['d', 'grid-template-columns', '1fr 360px'],
		['d', 'gap', '18px'],
		['d', 'align-items', 'start'],
		['e'],

		['s', '.plugin-list'],
		['d', 'display', 'grid'],
		['d', 'gap', '14px'],
		['e'],

		['s', 'details.plugin'],
		['d', 'overflow', 'hidden'],
		['d', 'scroll-margin-top', '16px'],
		['e'],

		['s', 'details.plugin summary'],
		['d', 'list-style', 'none'],
		['d', 'display', 'grid'],
		['d', 'grid-template-columns', '1fr auto'],
		['d', 'gap', '12px'],
		['d', 'align-items', 'center'],
		['d', 'padding', '18px'],
		['d', 'cursor', 'pointer'],
		['e'],

		['s', 'details.plugin summary::-webkit-details-marker'],
		['d', 'display', 'none'],
		['e'],

		['s', '.plugin-title'],
		['d', 'display', 'flex'],
		['d', 'flex-wrap', 'wrap'],
		['d', 'gap', '8px'],
		['d', 'align-items', 'baseline'],
		['e'],

		['s', '.plugin-title h2'],
		['d', 'margin', '0'],
		['d', 'font-size', '20px'],
		['d', 'letter-spacing', '-.02em'],
		['e'],

		['s', '.module'],
		['d', 'color', 'var(--muted)'],
		['d', 'font-size', '13px'],
		['d', 'font-family', 'ui-monospace,SFMono-Regular,Menlo,Consolas,monospace'],
		['e'],

		['s', '.badge'],
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

		['s', '.badge.ok'],
		['d', 'background', 'var(--ok-soft)'],
		['d', 'color', '#166534'],
		['e'],

		['s', '.records'],
		['d', 'border-top', '1px solid var(--line)'],
		['d', 'padding', '0 18px 18px'],
		['d', 'display', 'grid'],
		['d', 'gap', '10px'],
		['e'],

		['s', '.record'],
		['d', 'border', '1px solid var(--line)'],
		['d', 'border-radius', '14px'],
		['d', 'overflow', 'hidden'],
		['d', 'background', '#fff'],
		['d', 'scroll-margin-top', '16px'],
		['e'],

		['s', '.record-header'],
		['d', 'padding', '12px 14px'],
		['d', 'display', 'flex'],
		['d', 'flex-wrap', 'wrap'],
		['d', 'gap', '10px'],
		['d', 'align-items', 'center'],
		['d', 'justify-content', 'space-between'],
		['d', 'background', '#f8fafc'],
		['d', 'border-bottom', '1px solid var(--line)'],
		['e'],

		['s', '.record-id'],
		['d', 'font-family', 'ui-monospace,SFMono-Regular,Menlo,Consolas,monospace'],
		['d', 'font-weight', '800'],
		['e'],

		['s', '.issues'],
		['d', 'display', 'grid'],
		['d', 'gap', '10px'],
		['d', 'padding', '12px'],
		['e'],

		['s', '.issue'],
		['d', 'display', 'grid'],
		['d', 'gap', '7px'],
		['d', 'padding', '12px'],
		['d', 'border-radius', '12px'],
		['d', 'background', '#fff'],
		['d', 'border', '1px solid #eef2f7'],
		['e'],

		['s', '.issue-title'],
		['d', 'font-weight', '750'],
		['e'],

		['s', '.params'],
		['d', 'display', 'flex'],
		['d', 'flex-wrap', 'wrap'],
		['d', 'gap', '7px'],
		['e'],

		['s', '.param'],
		['d', 'max-width', '100%'],
		['d', 'border-radius', '10px'],
		['d', 'background', '#f1f5f9'],
		['d', 'padding', '6px 8px'],
		['d', 'font-family', 'ui-monospace,SFMono-Regular,Menlo,Consolas,monospace'],
		['d', 'font-size', '12px'],
		['d', 'color', '#334155'],
		['d', 'overflow-wrap', 'anywhere'],
		['e'],

		['s', 'aside'],
		['d', 'position', 'sticky'],
		['d', 'top', '18px'],
		['d', 'display', 'grid'],
		['d', 'gap', '14px'],
		['e'],

		['s', '.side-section'],
		['d', 'padding', '16px'],
		['e'],

		['s', '.side-section h3'],
		['d', 'margin', '0 0 12px'],
		['d', 'font-size', '16px'],
		['e'],

		['s', '.mini-list'],
		['d', 'display', 'grid'],
		['d', 'gap', '8px'],
		['e'],

		['s', '.mini-row'],
		['d', 'display', 'grid'],
		['d', 'grid-template-columns', '1fr auto'],
		['d', 'gap', '10px'],
		['d', 'align-items', 'center'],
		['d', 'font-size', '13px'],
		['d', 'color', 'var(--muted)'],
		['e'],

		['s', '.mini-row b'],
		['d', 'color', 'var(--text)'],
		['d', 'overflow', 'hidden'],
		['d', 'text-overflow', 'ellipsis'],
		['d', 'white-space', 'nowrap'],
		['e'],

		['s', '.bar'],
		['d', 'height', '8px'],
		['d', 'border-radius', '999px'],
		['d', 'background', '#e2e8f0'],
		['d', 'overflow', 'hidden'],
		['d', 'grid-column', '1/-1'],
		['e'],

		['s', '.bar>i'],
		['d', 'display', 'block'],
		['d', 'height', '100%'],
		['d', 'background', 'var(--accent)'],
		['d', 'border-radius', 'inherit'],
		['e'],

		['s', '.empty'],
		['d', 'padding', '26px'],
		['d', 'text-align', 'center'],
		['d', 'color', 'var(--muted)'],
		['e'],

		['s', '.jump-list'],
		['d', 'display', 'grid'],
		['d', 'gap', '6px'],
		['d', 'max-height', '320px'],
		['d', 'overflow', 'auto'],
		['d', 'padding-right', '4px'],
		['e'],

		['s', '.jump-list a'],
		['d', 'display', 'grid'],
		['d', 'grid-template-columns', '1fr auto'],
		['d', 'gap', '8px'],
		['d', 'text-decoration', 'none'],
		['d', 'color', 'var(--text)'],
		['d', 'font-size', '13px'],
		['d', 'padding', '7px 9px'],
		['d', 'border-radius', '10px'],
		['e'],

		['s', '.jump-list a:hover'],
		['d', 'background', '#f1f5f9'],
		['e'],

		['s', '@media (max-width:980px)'],
		['d', '.stats{grid-template-columns:repeat(2,minmax(0,1fr))}.controls{grid-template-columns:1fr}.content-grid{grid-template-columns:1fr}aside{position:static}'],
		['e'],

		['s', '@media print'],
		['d', 'body{background:#fff}.panel{box-shadow:none;break-inside:avoid}.controls,aside{display:none}main,header{padding-left:0;padding-right:0}'],
		['e'],
	);

	return;
}

sub _tags_article {
	my ($self, $number, $title) = @_;

	$self->{'tags'}->put(
		['b', 'section'],
		['b', 'article'],
		['a', 'class', 'panel stat'],
		['b', 'strong'],
		['d', $number],
		['e', 'strong'],
		['b', 'span'],
		['d', $title],
		['e', 'span'],
		['e', 'article'],
		['e', 'section'],
	);

	return;
}

1;
