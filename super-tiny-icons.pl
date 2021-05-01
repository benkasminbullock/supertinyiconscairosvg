#!/home/ben/software/install/bin/perl
use Z;
use File::Copy 'copy';
use HTML::Make::Page 'make_page';
use lib "/home/ben/projects/image-svg-path/lib";
use lib "/home/ben/projects/image-cairosvg/lib";
use Image::CairoSVG;

my $verbose;
#my $verbose = 1;
binmode STDOUT, ":encoding(utf8)";
my $wwwdir = "$Bin";
my $dir = "$wwwdir/docs";
md ($dir, $verbose);

my $indir = "/home/ben/software/SuperTinyIcons/images/svg";
if (! -d $indir) {
    die "No $indir";
}
my @svg = <$indir/*.svg>;
die "$indir is empty" unless @svg > 0;
# Make output directories
my $svgdir = "$dir/svg";
md ($svgdir, $verbose);
md ("$dir/png", $verbose);
my ($html, $body) = make_page (title => 'Super Tiny Icons');
my $stiorigin = '';
my $links = $body->push ('ul');
my $li = $links->push ('li');
$li->push ('a', href => 'https://github.com/edent/SuperTinyIcons', text => 'Super Tiny Icons repository');
my $table = $body->push ('table');
my %attr = (width => 500, height => 500);
for my $file (@svg) {
    if ($file !~ /\/youtube/) {
#	next;
    }
    # Make a new object each time because this is prone to crashing
    # and leaving the object in a state of disrepair.
    my $cairosvg = Image::CairoSVG->new (verbose => $verbose);
    my $base = $file;
    $base =~ s!.*/!!;
    copy $file, "$svgdir/$base" or die $!;
    my $hrow = $table->push ('tr');
    $hrow->push ('th', text => $base, class => 'svgfilename',
		 attr => {colspan => 2});
    my $row = $table->push ('tr');
    my $svgtd = $row->push ('td');
    $svgtd->push ('img', attr => {src => "svg/$base", %attr});
    my $pngtd = $row->push ('td');
    my $png = $base;
    $png =~ s!\.svg$!.png!;
    $pngtd->push ('img', attr => {src => "png/$png", %attr});
    eval {
	my $png = "$dir/png/$png";
	if (-f $png) {
	    unlink ($png) or die $!;
	}
	my $surface = $cairosvg->render ($file);
	$surface->write_to_png ($png);
    };
    if ($@) {
	warn "$png failed: $@";
    }
}
write_text ("$dir/index.html", $html->text ());
if ($verbose) {
    print "Finished.\n";
}
exit;

sub md ($dir, $verbose)
{
    if (! -d $dir) {
	do_system ("mkdir -p $dir;chmod 0755 $dir", $verbose);
    }
}