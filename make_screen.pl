#!/usr/bin/env perl

use strict;
use warnings;

use File::Spec;
use File::Basename;
use lib File::Spec->catdir( dirname(__FILE__), 'local', 'lib', 'perl5' );

use Text::Xslate;
use Time::Piece ();

my $time = Time::Piece::localtime();
my $day;
my $hour;
$day  = $time->strftime('%y.%m.%d');
$hour = $time->strftime('%H.%m');

my $tx = Text::Xslate->new();

$tx->load_file('./make_screen.tx');
my $in_file = './make_screen.csv';

my $host_data;
my @datas;

my $srnm;
my $out_file;

my $x = 0;
my $y = 0;
my $z = 0;

my $hsize = 0;
my $vsize = 0;

open my $ifh, '<', $in_file
  or die "Can't open file \"$in_file\": $!";

while ( my $line = <$ifh> ) {

    next if $line =~ /^#/ || $line =~ /^$/;

    my ( $file, $host, $name, $screenname, ) = split( /,/, $line );

    chomp($screenname);
    $out_file = "$file.xml";
    $srnm     = $screenname;

    $host_data = {
        host => $host,
        name => $name,
        x    => $x,
        y    => $y,
    };

    push( @datas, $host_data );

    if ( $x == 1 ) {
        $x = 0;
    }
    else {
        $x = 1;
    }

    if ( $z == 0 ) {
        $z++;
    }
    else {
        $z = 0;
        $y++;
    }

}

$hsize = 2;
$vsize = $y;

my $content = $tx->render(
    "./make_screen.tx",
    {
        day   => $day,
        hour  => $hour,
        srnm  => $srnm,
        hsize => $hsize,
        vsize => $vsize,
        data  => \@datas,
    }
);

if ( -e $out_file ) {

    print "allow overrite => $out_file ok? [y/n] : ";

    while ( my $ans = <> ) {
        chomp($ans);
        if ( $ans eq "y" ) {
            open my $ofh, '>', $out_file;
            print $ofh $content;
            close($ofh);
            exit;
        }
        elsif ( $ans eq "n" ) {
            print "goodbye.\n";
            exit;
        }
        elsif ( $ans ne "y" && $ans ne "n" ) {
            print "allow overrite => $out_file ok? [y/n] : ";
        }
    }
}

open my $ofh, '>', $out_file;
print $ofh $content;
close($ofh);

__END__

=head1 HOW TO USE

Please refer to "make_screen.csv" file.
