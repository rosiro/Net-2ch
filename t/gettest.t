use strict;
use warnings;
use utf8;
use Net::2ch;
use Data::Printer;
use Encode;
{
    #http://anago.2ch.sc/test/read.cgi/gline/1447007337/l50
    print "1____________________________________________________\n";
    my $bbs = Net::2ch->new(url => 'http://anago.2ch.sc/gline/',
			    cache => '/tmp/net2ch-cache',
			    plugin => '2chSC');
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
    }
}

{
    print "2____________________________________________________\n";
    my $bbs = Net::2ch->new(url => 'http://anago.2ch.sc/test/read.cgi/gline/1447007337/',
			    cache => '/tmp/net2ch-cache',
			    plugin => '2chSC');
    my $dat = $bbs->subject->thread('1449179159');
    $dat->load;
}


# dat in cash is taken out
{
    print "3____________________________________________________\n";
    my $bbs = Net::2ch->new(url => 'http://anago.2ch.scnet/bake/',
			    cache => '/tmp/net2ch-cache',
			    plugin => '2chSC');
    my $dat = $bbs->recall_dat('1447007337');
}

{
    print "4____________________________________________________\n";
    # parse dose dat from file
    my $bbs = Net::2ch->new(url => 'http://hanabi.2ch.net/bake/',
			    cache => '/tmp/net2ch-cache',
			    plugin => '2chSC');
    open my $fh, "test.dat" or return;
    my $data = join('', <$fh>);
    close($fh);
    my $dat = $bbs->parse_dat($data);
}
