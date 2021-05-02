#!/home/ben/software/install/bin/perl
use Z;
use HTML::Make::Page 'make_page';
use HTML::Make;
use lib '/home/ben/projects/image-cairosvg/lib';
use Image::CairoSVG;
use File::Copy;
use Math::Trig;
use lib $Bin;
use STI;
my $dir = '/home/ben/software/twemoji/assets/svg';
if (! -d $dir) {
    die "$dir invalid";
}
my @emoji = <$dir/*.svg>;
my $odir = "$Bin/docs/twemoji";
my $verbose = 1;
md ($odir, $verbose);
# Count of emoji
my $count = 0;
# Emojis for one page
my $perpage = 100;
my $page = 1;
my $cols = 5;
my $size = 100;
my $twsize = 36;
my ($mainhtml, $mainbody) = make_page (
    title => "Twitter Emoji Collection via Image::CairoSVG"
);
$mainhtml->push ('h1', text => 'Twitter emoji via Image::CairoSVG');
$mainhtml->push ('p', text => <<EOF);
This page is a demonstration of constructing the Twitter Emoji using
Image::CairoSVG to render the SVG icons from SVG into PNG. The icons
on the left are the original SVG icons, and the icons on the right are
the renderings.
EOF
my $ul = $mainbody->push ('ul');
my ($html, $body, $table) = start_page ($page);
my $tr = $table->push ('tr');
for my $emoji (@emoji) {
    my $podir = "$odir/$page";
    md ($podir, $verbose);
    eval {
	my $trunk = $emoji;
	$trunk =~ s!.*/!!;
	my $png = $trunk;
	$png =~ s!\.svg!.png!;
	copy ($emoji, "$podir/$trunk");
#	copy ($emoji, "$odir/$trunk");
	my $tdsvg = $tr->push ('td');
	$tdsvg->push ('img', src => $trunk, attr => {width => 100, height => 100});
	my $tdpng = $tr->push ('td');
	$tdpng->push ('img', src => $png, attr => {width => 100, height => 100});
	my $surface = Cairo::ImageSurface->create ('argb32', $size, $size);
	my $cr = Cairo::Context->create ($surface);
	my $cairosvg = Image::CairoSVG->new (context => $cr);
	$cr->save ();
	
	$cr->scale ($size/$twsize, $size/$twsize);
	$cairosvg->render ($emoji);
	$cr->restore ();
	$surface->write_to_png ("$podir/$png");
    };
    if ($@) {
	warn "$@ with $emoji";
    }
    $count++;
    if ($count % $perpage == 0) {
	print "Ending page $page\n";
	end_page ($page, $html, $ul);
	$page++;
	print "Starting page $page\n";
	($html, $body, $table) = start_page ($page);
    }
    if ($count % $cols == 0) {
	$tr = $table->push ('tr');
    }
#    last;
}
if ($count % $perpage != 0) {
    end_page ($page, $html, $ul);
}
write_text ("$odir/index.html", $mainhtml->text ());
exit;

sub start_page ($page)
{
    my ($html, $body) = make_page (title => "Twemoji page $page");
    my $table = $body->push ('table');
    return ($html, $body, $table);
}

sub end_page ($page, $html, $ul)
{
    my $podir = "$odir/$page";
    write_text ("$podir/index.html", $html->text ());
    my $li = $ul->push ('li');
    $li->push ('a', href => "$page/index.html", text => "Page $page");
}
