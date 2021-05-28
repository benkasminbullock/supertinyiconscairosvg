#!/home/ben/software/install/bin/perl
use Z;
# use Trav::Dir;
# my $td = Trav::Dir->new (
#     only => qr!.*\.svg$!,
# );
# my @files;
# $td->find_files ('/home/ben/software/svg-test-suite', \@files);
# for my $file (@files) {
#     print "$file\n";
# }
use HTML::Make::Page 'make_page';
use lib '/home/ben/projects/image-cairosvg/lib';
use Image::CairoSVG;
my ($html, $body) = make_page (title => 'SVG Test Suite');
my @svg = <$Bin/docs/sts/svg/*.svg>;
my $table = $body->push ('table');
my $skip = qr!
struct-use
|
animate
!x;
for my $file (@svg) {
#    if ($file !~ /wank/) {
    if ($file !~ /color-prop-03/) {
#	next;
    }
    print "$file:\n";
    if ($file =~ $skip) {
	next;
    }
    my $png = $file;
    $png =~ s!svg!png!g;
    if ($png eq $file) {
	die;
    }
    if (-f $png) {
	unlink $png or die $!;
    }
    my $cairosvg = Image::CairoSVG->new (verbose => undef);
    my $surface;
    eval {
	$surface = $cairosvg->render ($file);
    };
    if ($@) {
	next;
    }
    $surface->write_to_png ($png);
    my $furl = furl ($file);
    my $purl = furl ($png);
    my $trh = $table->push ('tr');
    $trh->push ('th', attr => {colspan => 2}, text => $file);
    my $tr = $table->push ('tr');
    my $std = $tr->push ('td');
    $std->push ('img', attr => {width => 480}, src => $furl);
    my $ptd = $tr->push ('td');
    $ptd->push ('img', src => $purl);
}
write_text ("docs/sts.html", $html->text ());
exit;

sub furl ($file) {
    my $url = $file;
    $url =~ s!$Bin/docs/!!;
    return $url;
}
