package STI;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw/md/;
use warnings;
use strict;
use utf8;
use Carp;
use Z;

sub md ($dir, $verbose)
{
    if (! -d $dir) {
	do_system ("mkdir -p $dir;chmod 0755 $dir", $verbose);
    }
}

1;
