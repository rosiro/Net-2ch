package Net::2ch::Res;
use strict;

use base qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors( qw( c key resid num name mail date time id be body ) );

sub new {
    my $class = shift;
    my $c = shift;
    my $opt = shift;
    my $self = bless $opt, $class;
    $self->c($c);
    $self;
}

sub body_text {
    my $self = shift;
    my $body = $self->body;
    $body =~ s/<br>/\n/ig;
    $body =~ s/<[^>]*>//g;
    $body =~ s/&lt;/</g;
    $body =~ s/&gt;/>/g;
    $body;
}

sub permalink {
    my ($self) = @_;
    $self->c->worker->permalink($self->key, $self->resid);
}

1;
