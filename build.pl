#!/home/ben/software/install/bin/perl
use Z;

do_system ("./super-tiny-icons.pl");
do_system ("./twemoji.pl");
do_system ("git add .;git commit -a -m 'update';git push");
