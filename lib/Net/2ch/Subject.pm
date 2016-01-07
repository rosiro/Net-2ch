package Net::2ch::Subject;
use strict;

use base qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors( qw( c url title noname image) );

use HTTP::Date;

use Net::2ch::Dat;

sub new {
    my $class = shift;
    my $c = shift;
    my $url = shift;

    my $self = bless {
	c => $c,
	url => $url,
	threads => [],
	thread_by_key => {},
    }, $class;

    $self->title($c->setting->{title});
    $self->noname($c->setting->{noname});
    $self->image($c->setting->{image});

    $self;
}

sub load {
    my ($self) = @_;

    $self->{threads} = [];
    $self->{thread_by_key} = {};
    return 0 unless $self->c && $self->url;

    my $cache = $self->c->cache->get($self->file);
    my $time = $cache->{time} || 0;
    my $res = $self->c->ua->diff_request($self->url, time => $time);

    my $data;
    if (!$res->is_success) {
	return 0 unless $res->code eq '304';
	$data = $cache->{data};
    } elsif ($res->content eq $cache->{data}) {
	$data = $cache->{data};
    } else {
	my $lasttime =  HTTP::Date::str2time($res->header('Last-Modified'));
	$self->c->cache->set($self->file, {
	    data => $res->content,
	    time => $lasttime,
	    fetch_time => time,
	    url => $self->url,
	    title => $self->title,
	    noname => $self->noname,
	    image => $self->image,
	});
	$data = $res->content;
    }
    my $subject = $self->c->worker->parse_subject($data);
    foreach (@{ $subject }) {
	$_->{url} = $self->url;
	$_->{bbstitle} = $self->title;
	$_->{noname} = $self->noname;
	$_->{image} = $self->image;
	$self->add_thread( Net::2ch::Dat->new($self->c, $_) );
    }
    return 1;
}

sub add_thread {
    my($self, $dat) = @_;
    push @{ $self->{threads} }, $dat;
    $self->{thread_by_key}->{$dat->key} = $dat;
}

sub threads {
    my $self = shift;
    wantarray ? @{ $self->{threads} } : $self->{threads};
}

sub thread {
    my ($self, $key) = @_;
    $self->{thread_by_key}->{$key};
}

sub file {
    my ($self) = @_;
    $self->c->conf->{local_path} . 'subject.txt';
}

sub permalink {
    my ($self) = @_;
    $self->c->worker->permalink;
}

1;
