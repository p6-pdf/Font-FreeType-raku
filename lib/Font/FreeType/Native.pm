unit module Font::FreeType::Native;

use NativeCall;
use NativeCall::Types;

our $ftlib;
BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        $ftlib = 'libfreetype';
    } else {
        $ftlib = ('freetype', v6);
    }
}

constant FT_Byte   = uint8;
constant FT_Error  is export = uint32;
constant FT_Encoding = uint32;
constant FT_Int    is export = int32;
constant FT_Int32  is export = int32;
constant FT_Fixed  = long;
constant FT_Long   = long;
constant FT_Pos    = long;
constant FT_Short  = int16;
constant FT_String = Str;
constant FT_UInt   is export = uint32;
constant FT_ULong  is export = ulong;
constant FT_UShort = uint16;
constant FT_F26Dot6 is export = long;
constant FT_Glyph_Format = int32; # enum

class FT_Face is repr('CStruct') {...}
class FT_Library is repr('CPointer') {...}

class FT_Bitmap_Size is repr('CStruct') is export {
    has FT_Short  $.height;
    has FT_Short  $.width;

    has FT_Pos    $.size;

    has FT_Pos    $.x-ppem;
    has FT_Pos    $.y-ppem;
}

sub ft-enc-tag(Str $s) {
    my uint32 $enc = 0;
    for $s.ords {
        $enc *= 256;
        $enc += $_;
    }
    $enc;
}

enum FT_ENCODING is export (
    FT_ENCODING_UNICODE => ft-enc-tag("unic"),
    );

class FT_CharMap is export is repr('CStruct') {
    has FT_Face      $.face;
    has FT_Encoding  $.encoding;
    has FT_UShort    $.platform-id;
    has FT_UShort    $.encoding-id;
}

class FT_Generic is repr('CStruct') {
    has Pointer       $.data;
    has Pointer       $.finalizer;
}

class FT_BBox is repr('CStruct') {
    has FT_Pos  ($.x-min, $.y-min);
    has FT_Pos  ($.x-max, $.y-max);
}

class FT_Glyph_Metrics  is repr('CStruct') {
    has FT_Pos  $.width;
    has FT_Pos  $.height;

    has FT_Pos  $.horiBearingX;
    has FT_Pos  $.horiBearingY;
    has FT_Pos  $.horiAdvance;

    has FT_Pos  $.vertBearingX;
    has FT_Pos  $.vertBearingY;
    has FT_Pos  $.vertAdvance;
}

class FT_Vector is repr('CStruct') is export {
    has FT_Pos  $.x;
    has FT_Pos  $.y;
 }

class FT_Bitmap is repr('CStruct') {
    has uint32  $.rows;
    has uint32  $.width;
    has int32   $.pitch;
    has Pointer[uint8]    $.buffer;
    has uint16  $.num-grays;
    has uint8   $.pixel-mode;
    has uint8   $.palette-mode;
    has Pointer $.palette;
}

class FT_Outline is repr('CStruct') {
    has uint16       $.n-contours;       #| number of contours in glyph
    has uint16       $.n-points;         #| number of points in the glyph

    has Pointer[FT_Vector]  $.points;    #| the outline's points
    has Pointer[uint8]      $.tags;      #| the points flags
    has Pointer[uint16]     $.contours;  #| the contour end points
    has int32               $.flags;     #| outline masks
}

class FT_SubGlyph is repr('CPointer') { }
class FT_Slot_Internal is repr('CPointer') { }
class FT_Size_Internal is repr('CPointer') { }

class FT_Size_Metrics is repr('CStruct') {
    has FT_UShort  $.x-ppem;      #| horizontal pixels per EM
    has FT_UShort  $.y-ppem;      #| vertical pixels per EM

    has FT_Fixed   $.x-scale;     #| scaling values used to convert font
    has FT_Fixed   $.y-scale;     #| units to 26.6 fractional pixels

    has FT_Pos     $.ascender;    #| ascender in 26.6 frac. pixels
    has FT_Pos     $.descender;   #| descender in 26.6 frac. pixels
    has FT_Pos     $.height;      #| text height in 26.6 frac. pixels
    has FT_Pos     $.max-advance; #| max horizontal advance, in 26.6 pixels
  }

class FT_Size is repr('CStruct') {
    has FT_Face           $.face;      #| parent face object
    has FT_Generic        $.generic;   #| generic pointer for client uses
    has FT_Size_Metrics   $.metrics;   #| size metrics
    has FT_Size_Internal  $.internal;
}

class FT_GlyphSlot is repr('CStruct') is export {
    has FT_Library        $.library;
    has FT_Face           $.face;
    has FT_GlyphSlot      $.next;
    has FT_UInt           $.reserved;       #| retained for binary compatibility
    HAS FT_Generic        $.generic;

    HAS FT_Glyph_Metrics  $.metrics;
    has FT_Fixed          $.linearHoriAdvance;
    has FT_Fixed          $.linearVertAdvance;
    HAS FT_Vector         $.advance;

    has FT_Glyph_Format   $.format;

    HAS FT_Bitmap         $.bitmap;
    has FT_Int            $.bitmap-left;
    has FT_Int            $.bitmap-top;

    HAS FT_Outline        $.outline;

    has FT_UInt           $.num_subglyphs;
    has FT_SubGlyph       $.subglyphs;

    has Pointer           $.control-data;
    has long              $.control-len;

    has FT_Pos            $.lsb-delta;
    has FT_Pos            $.rsb-delta;

    has Pointer           $.other;

    has FT_Slot_Internal  $.internal;

    submethod TWEAK {
    }
}

class FT_SfntName is repr('CStruct') is export {
    has FT_UShort  $.platform-id;
    has FT_UShort  $.encoding-id;
    has FT_UShort  $.language-id;
    has FT_UShort  $.name-id;

    has CArray[FT_Byte]   $.string;      #| this string is *not* null-terminated! */
    has FT_UInt   $.string-len;  #| in bytes                              */
}

enum FT_FACE_FLAG is export «
    :FT_FACE_FLAG_SCALABLE(1 +<  0)
    :FT_FACE_FLAG_FIXED_SIZES(1 +<  1)
    :FT_FACE_FLAG_FIXED_WIDTH(1 +<  2)
    :FT_FACE_FLAG_SFNT(1 +<  3)
    :FT_FACE_FLAG_HORIZONTAL(1 +<  4)
    :FT_FACE_FLAG_VERTICAL(1 +<  5)
    :FT_FACE_FLAG_KERNING(1 +<  6)
    :FT_FACE_FLAG_FAST_GLYPHS(1 +<  7)
    :FT_FACE_FLAG_MULTIPLE_MASTERS(1 +<  8)
    :FT_FACE_FLAG_GLYPH_NAMES(1 +<  9)
    :FT_FACE_FLAG_EXTERNAL_STREAM(1 +< 10)
    :FT_FACE_FLAG_HINTER(1 +< 11)
    :FT_FACE_FLAG_CID_KEYED(1 +< 12)
    :FT_FACE_FLAG_TRICKY(1 +< 13)
    :FT_FACE_FLAG_COLOR(1 +< 14)
    »;

enum FT_STYLE_FLAG is export «
    :FT_STYLE_FLAG_ITALIC( 1 +< 0 )
    :FT_STYLE_FLAG_BOLD( 1 +< 1 )
    »;

class FT_Face is export {
    has FT_Long           $.num-faces;
    has FT_Long           $.face-index;

    has FT_Long           $.face-flags;
    has FT_Long           $.style-flags;

    has FT_Long           $.num-glyphs;

    has FT_String         $.family-name;
    has FT_String         $.style-name;

    has FT_Int            $.num-fixed-sizes;
    has Pointer[FT_Bitmap_Size]   $.available-sizes;

    has FT_Int            $.num-charmaps;
    has Pointer[FT_CharMap]       $.charmaps;

    HAS FT_Generic        $.generic;
##
##    /*# The following member variables (down to `underline_thickness') */
##    /*# are only relevant to scalable outlines; cf. @FT_Bitmap_Size    */
##    /*# for bitmap fonts.                                              */
    HAS FT_BBox           $.bbox;

    has FT_UShort         $.units-per-EM;
    has FT_Short          $.ascender;
    has FT_Short          $.descender;
    has FT_Short          $.height;

    has FT_Short          $.max-advance-width;
    has FT_Short          $.max-advance-height;

    has FT_Short          $.underline-position;
    has FT_Short          $.underline-thickness;

    has FT_GlyphSlot      $.glyph;
    has FT_Size           $.size;
    has FT_CharMap        $.charmap;

    method FT_Has_PS_Glyph_Names(  )
        returns FT_Int is native($ftlib) {*};

    method FT_Get_Postscript_Name(  )
        returns Str is native($ftlib) {*};

    method FT_Get_Sfnt_Name_Count(  )
        returns FT_UInt is native($ftlib) {*};

    method FT_Get_Sfnt_Name(
        FT_UInt $index,
        FT_SfntName $sfnt)
    returns FT_Error is native($ftlib) {*};

    method FT_Get_Glyph_Name(
        FT_UInt $glyph-index,
        buf8    $buffer,
        FT_UInt $buffer-max )
    returns FT_Error is native($ftlib) {*};

    method FT_Get_Char_Index(
        FT_ULong  $charcode )
    returns FT_UInt is native($ftlib) {*};

    method FT_Load_Glyph(
        FT_UInt   $glyph-index,
        FT_Int32  $load-flags )
    returns FT_Error is native($ftlib) {*};

    method FT_Load_Char(
        FT_ULong  $char-code,
        FT_Int32  $load-flags )
    returns FT_Error is native($ftlib) {*};

    method FT_Get_First_Char(
        FT_UInt  $agindex is rw )
    returns FT_UInt is native($ftlib) {*};

    method FT_Get_Next_Char(
        FT_UInt  $char-code,
        FT_UInt  $agindex is rw )
    returns FT_UInt is native($ftlib) {*};

    method FT_Set_Char_Size(
        FT_F26Dot6  $char-width,
        FT_F26Dot6  $char-height,
        FT_UInt     $horz-resolution,
        FT_UInt     $vert-resolution )
    returns FT_Error is native($ftlib) {*};

    method FT_Get_Kerning(
        FT_UInt     $left-glyph,
        FT_UInt     $right-glyph,
        FT_UInt     $kern-mode,
        FT_Vector   $kerning)
    returns FT_Error is native($ftlib) {*};

    method FT_Done_Face
        returns FT_Error
        is export
        is native($ftlib) {*};
}

class FT_Library is export {
    method FT_New_Face(
        Str $file-path-name,
        FT_Long $face-index,
        Pointer[FT_Face] $aface is rw
        )
    returns FT_Error is native($ftlib) {*};

    method FT_New_Memory_Face(
        Blob[FT_Byte] $buffer,
        FT_Long $buffer-size,
        FT_Long $face-index,
        Pointer[FT_Face] $aface is rw
        )
     returns FT_Error is native($ftlib) {*};

    method FT_Library_Version(
        FT_Int $major is rw,
        FT_Int $minor is rw,
        FT_Int $patch is rw,
        )
    returns FT_Error is native($ftlib) {*};

    method FT_Done_FreeType
        returns FT_Error
        is export
        is native($ftlib) {*};
}

sub FT_Init_FreeType(FT_Library $library is rw)
    returns FT_Error
        is export
        is native($ftlib) {*};
