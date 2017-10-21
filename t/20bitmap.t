# Extract bitmaps from a some bitmap fonts and check that they match the
# images in the 'bdf_bitmaps.txt' file, which were extracted by hand.

constant TESTS_PER_BITMAP_FONT = 4 * 3;
use Test;
plan 2 * TESTS_PER_BITMAP_FONT - 3;

use Font::FreeType;
use Font::FreeType::Native;

my Font::FreeType $ft .= new;
my $bitmap_file = 't/fonts/bdf_bitmaps.txt';

constant Width = 5;
constant Height = 7;

for  <bdf fnt> -> $fmt {
    # Load the bitmap font file file.
    my $face = $ft.face("t/fonts/5x7.$fmt");
    my @lines =  $bitmap_file.IO.lines ;

    # Load bitmaps from a file and compare them against ones from the font.
    while @lines {
        with (@lines.shift) {
            /^(<xdigit>+)$/
                or die "badly formated bitmap test file";
            my $unicode = $0.Str;
            my $charcode = :16($unicode);
            my $desc = "$fmt format font, glyph $unicode";

            # Read test bitmap.
            my @expected;
            while @lines {
                my $line = @lines.shift;
                my uint @bit-map = $line.comb.map: { $_ eq '#' ?? 0xFF !! 0x00 };
                push @expected, $line;
                last if @expected == Height;
            }

            # FNT doesn't do Unicode, it seems, and in older versions of FreeType
            # char 255 is inaccessible for some reason.
            next if $fmt eq 'fnt' && $charcode > 254;

            my $glyph = $face.load-glyph($charcode);
            my $bitmap = $glyph.bitmap;
            is $bitmap.left, 0, "$desc: bitmap starts 0 pixels to left of origin";
            is $bitmap.top, 6, "$desc: bitmap starts 6 pixels above origin";
            is $bitmap.Str, @expected.join("\n"), "{$desc} Str";
        }
    }
}

# vim:ft=perl ts=4 sw=4 expandtab:
