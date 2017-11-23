# prints an ascii banner, using the supplied font
use Font::FreeType;
use Font::FreeType::Native::Types;

enum Mode «
    :normal(0)
    :light(1)
    :mono(2)
    :lcd(3)
    :lcd-v(4)
   »; 

sub MAIN(Str $font-file,
         Str $text is copy,
         Int  :$resolution=60,
         Bool :$kern = True,
         Bool :$hint,
         UInt :$ascend,
         UInt :$descend,
         UInt :$char-spacing is copy,
         UInt :$word-spacing is copy,
         UInt :$bold = 0,
         Mode :$mode = normal,
    ) {

    if $text eq '' {
        # handle empty string as a zero width space
        $text = ' ';
        $word-spacing //= 0;
    }

    my $load-flags = $hint
        ?? FT_LOAD_DEFAULT
        !! FT_LOAD_NO_HINTING;
    my $face = Font::FreeType.new.face($font-file, :$load-flags);

    try $face.set-char-size(24, 0, $resolution, $resolution);
    $char-spacing //= $resolution > 40
        ?? ($resolution + 20) div 40
        !! 1;
    $word-spacing //= $char-spacing * 4;
    my @bitmaps = $face.glyph-images($text).map: {
        .bold($bold) if $bold;
        .bitmap(:render-mode($mode));
    }

    my @pix-bufs = @bitmaps.map: { .defined && .width ?? .pixels !! Any };
    my $top = $ascend // @bitmaps.map({.defined ?? .top !! 0}).max;
    my $bottom = - ($descend // @bitmaps.map({.defined ?? .rows - .top !! 0}).max);
    for $top ...^ $bottom -> $row {
        my Str @line;
        my int16 $pos = 0;
        for 0 ..^ +@bitmaps -> $col {
            with @bitmaps[$col] {
                $pos += do-horiz-kern($face, @bitmaps[$col-1], $_, $mode)
                    if $col && $kern && $face.has-kerning;
                my @chars = scan-line($_, @pix-bufs[$col], $row);
                @line[$pos..($pos += +@chars)] = @chars;
                $pos += $char-spacing;
            }
            else {
                @line = ' ' xx $word-spacing;
            }
        }
        $_ //= ' ' for @line;
        say @line.join;
    }
}

sub scan-line($bitmap, $pix-buf, $row) {
    my Str @chars;
    my int $y = $bitmap.top - $row;
    if $bitmap.rows > $y >= 0 {
        for ^$bitmap.width -> int $x {
            @chars.push: $pix-buf[$y;$x] ?? '#' !! ' ';
        }
    }
    else {
        @chars = ' ' xx $bitmap.width;
    }
    @chars;
}

sub do-horiz-kern($face, $bm1, $bm2, $mode ) {
    my $vec = $face.kerning($bm1.char-code.chr, $bm2.char-code.chr);
    my $x = $vec.x;
    $x *= 3 if $mode == lcd;
    round($x).Int;
}
