package Net::2ch::Dat;
use strict;
use Encode;
use Data::Printer;
use base qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors( qw( c subject key title resnum dat ) );

use Net::2ch::Res;

sub new {
    my $class = shift;
    my $c = shift;
    my $subject = shift;

    my $self = bless {
	c => $c,
	reslist => [],
	res_by_num => {},
	subject => $subject,
    }, $class;

    $self->set_subjects;
    $self;
}

sub set_subjects {
    my ($self) = @_;
    $self->key($self->subject->{key});
    $self->title($self->subject->{title});
    $self->resnum($self->subject->{resnum});
}

sub get_cache {
    my ($self) = @_;

    my $cache = $self->c->cache->get($self->file);
    return unless $cache->{data};
    $self->subject($cache->{subject});
    $self->set_subjects;
    $self->dat($cache->{data});
    $cache;
}

sub set_cache {
    my ($self, $data, $res) = @_;
    $self->c->cache->set($self->file, {
	subject => $self->subject,
	data => $data,
	time => HTTP::Date::str2time($res->header('Last-Modified')),
	fetch_time => time,
    });
}

sub load {
    my ($self) = @_;

    $self->{reslist} = [];
    $self->{res_by_num} ={};
    return 0 unless $self->c && $self->key;
    $self->dat($self->c->worker->get_dat($self));
    $self->parse;
}

sub parse {
    my ($self, $dat) = @_;

    return 0 unless $self->dat;
    my $dat = $self->c->worker->parse_dat(decode("cp932",$self->dat));
    my $i = 1;
    foreach (@{ $dat }) {
	$_->{num} = $i++;
	$_->{key} = $self->key;
	$_->{resid} = $_->{num} if $_->{resid} eq '';
	$self->add_res( Net::2ch::Res->new($self->c, $_) );
    }
    $i;
}

sub add_res {
    my($self, $dat) = @_;
    push(@{ $self->{reslist} }, $dat);
    $self->{res_by_num}->{$dat->num} = $dat;
}

sub reslist {
    my $self = shift;
    wantarray ? @{ $self->{reslist} } : $self->{reslist};
}

sub res {
    my ($self, $num) = @_;
    $self->{res_by_num}->{$num};
}

sub url {
    my ($self) = @_;
    $self->c->worker->daturl($self->key);
}

sub file {
    my ($self) = @_;
    $self->c->conf->{local_path} . $self->key . '.dat';
}

sub permalink {
    my ($self) = @_;
    $self->c->worker->permalink($self->key);
}

1;
