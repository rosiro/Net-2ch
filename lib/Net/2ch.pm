package Net::2ch;

use strict;
use warnings;
our $VERSION = '0.00';

use UNIVERSAL::require;

use base qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors( qw( conf worker cache ua setting subject) );

use Net::2ch::Setting;
use Net::2ch::Subject;
use Net::2ch::Dat;
use Net::2ch::UserAgent;
use Net::2ch::Cache;

sub new {
    my ($class, %conf) = @_;

    my $self = bless {}, $class;

    $self->{plugin} = $conf{plugin} || 'Base';
    $self->load_plugin;
    $self->conf($self->worker->gen_conf(\%conf));
    $self->ua( Net::2ch::UserAgent->new($conf{ua}) );
    $self->cache( Net::2ch::Cache->new($conf{cache}) );
    use Data::Printer;
    p $self;
    $self;
}

sub load_plugin {
    my ($self, $conf) = shift;

    my $module;
    if (-f $self->{plugin}) {
	open my $fh, $self->{plugin} or return;
	while (<$fh>) {
	    if (/^package (Net::2ch::Plugin::.*?);/) {
		eval { require $self->{plugin} } or die $@;
		$module = $1;
		last;
	    }
	}
    } else {
	$module = $self->{plugin};
	$module =~ s/^Net::2ch::Plugin:://;;
	$module = "Net::2ch::Plugin::$module";
	$module->require or die $@;
    }
    $self->worker($module->new($self->conf));
}

sub encoding { $_[0]->worker->encoding }

sub load_setting {
    my $self = shift;

    return unless $self->conf->{setting};
    $self->setting( Net::2ch::Setting->new($self, $self->conf->{setting}) )->load;
}

sub load_subject {
    my $self = shift;

    return unless $self->conf->{subject};
    $self->subject( Net::2ch::Subject->new($self, $self->conf->{subject}) )->load;
}

sub parse_dat {
    my ($self, $data, $subject) = @_;

    $subject = { $subject } unless ref($subject);
    my $dat = Net::2ch::Dat->new($self, $subject);
    $dat->dat($data);
    $dat->parse;
    $dat;
}

sub recall_dat {
    my ($self, $key) = @_;

    my $dat = Net::2ch::Dat->new($self, {});
    $dat->key($key);
    $dat->get_cache;
    $dat->parse;
    $dat;
}

1;
