#!/home/ben/software/install/bin/perl
use Z;
use File::Copy 'copy';
use HTML::Make::Page 'make_page';
use lib "/home/ben/projects/image-svg-path/lib";
use lib "/home/ben/projects/image-cairosvg/lib";
use Image::CairoSVG;
use lib $Bin;
use STI;

my $ok = GetOptions (
    "single=s" => \my $single,
    "verbose" => \my $verbose,
);

if (! $ok) {
    print <<EOF;
--single <name>  - do just one SVG file of the collection
--verbose        - print debugging messages
EOF
}

binmode STDOUT, ":encoding(utf8)";
my $wwwdir = "$Bin";
my $dir = "$wwwdir/docs";
md ($dir, $verbose);

my $indir = "$Bin/docs/svg";
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
$li->push ('a', href => 'twemoji/index.html', text => 'Twitter Emoji');
$li->push ('a', href => 'sts.html', text => 'SVG Test Suite');
my $table = $body->push ('table');
my %attr = (width => 500, height => 500);
my $one;
for my $file (@svg) {
    if ($single && $file !~ /\Q$single\E/) {
	next;
    }
#    print "$file\n";
    $one = 1;
    # Make a new object each time because this is prone to crashing
    # and leaving the object in a state of disrepair.
    my $cairosvg = Image::CairoSVG->new (verbose => $verbose);
    my $base = $file;
    $base =~ s!.*/!!;
#    copy $file, "$svgdir/$base" or die $!;
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
	my $surface;
	if ($file =~ /linux_mint/) {
	    my $text = read_text ($file);
	    $text =~ s!MM!M!;
	    $surface = $cairosvg->render ($text);
	}
	else {
	    $surface = $cairosvg->render ($file);
	}
	$surface->write_to_png ($png);
    };
    if ($@) {
	warn "$png failed: $@";
    }
}

write_text ("$dir/index.html", $html->text ());
if ($single && ! $one) {
    print "$single not found.\n";
}
if ($verbose) {
    print "Finished.\n";
}
exit;

