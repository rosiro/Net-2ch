use strict;
use warnings;
use utf8;
use Net::2ch;
use Data::Printer;
use Encode;
{
    print "1____________________________________________________\n";
    my $bbs = Net::2ch->new(url => 'http://hanabi.2ch.net/bake/',
			    cache => '/tmp/net2ch-cache');
    $bbs->load_setting;
    $bbs->load_subject;
    foreach my $dat ($bbs->subject->threads) {
	$dat->load;
	my $one = $dat->res(1);
	print $dat->title . "\n";
	print '>>1: ' . $one->body;
	foreach my $res ($dat->reslist) {
	    print $res->resid . ':' . $res->date . "\n";
	    print $res->body_text . "\n";
	}
	last;
    }
}

{
    print "2____________________________________________________\n";
    my $bbs = Net::2ch->new(url => 'http://hanabi.2ch.net/test/read.cgi/bake/1449179159/',
			    cache => '/tmp/net2ch-cache');
    my $dat = $bbs->subject->thread('1449179159');
    $dat->load;
}


# dat in cash is taken out
{
    print "3____________________________________________________\n";
    my $bbs = Net::2ch->new(url => 'http://hanabi.2ch.net/bake/',
			    cache => '/tmp/net2ch-cache');
    my $dat = $bbs->recall_dat('1449179159');
}

{
    print "4____________________________________________________\n";
    # parse dose dat from file
    my $bbs = Net::2ch->new(url => 'http://hanabi.2ch.net/bake/',
			    cache => '/tmp/net2ch-cache');
    open my $fh, "test.dat" or return;
    my $data = join('', <$fh>);
    close($fh);
    my $dat = $bbs->parse_dat($data);
}
