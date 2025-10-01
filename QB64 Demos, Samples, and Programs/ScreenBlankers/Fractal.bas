'+---------------+---------------------------------------------------+
'| ###### ###### |     .--. .         .-.                            |
'| ##  ## ##   # |     |   )|        (   ) o                         |
'| ##  ##  ##    |     |--' |--. .-.  `-.  .  .-...--.--. .-.        |
'| ######   ##   |     |  \ |  |(   )(   ) | (   ||  |  |(   )       |
'| ##      ##    |     '   `'  `-`-'  `-'-' `-`-`|'  '  `-`-'`-      |
'| ##     ##   # |                            ._.'                   |
'| ##     ###### |  Sources & Documents placed in the Public Domain. |
'+---------------+---------------------------------------------------+
'|                                                                   |
'| === Fractal.bas ===                                               |
'|                                                                   |
'| == Draws Mandelbrot fractals, displays each for 3 seconds.        |
'| == Be patient, some fractals may start with black areas before    |
'| == the good stuff shows up.                                       |
'| == Press "s" once during calculation to save the picture after    |
'| == calculation is completed.                                      |
'| == Press "i" once will also save the current fractal, but prints  |
'| == the x/y range info into it before doing so.                    |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

di& = _SCREENIMAGE
scrX% = _WIDTH(di&)
scrY% = _HEIGHT(di&)
_FREEIMAGE di&
si& = _NEWIMAGE(scrX%, scrY%, 256)
SCREEN si&
_DELAY 0.2: _SCREENMOVE _MIDDLE
_DELAY 0.2: _FULLSCREEN

nc% = 128
RESTORE ColorTab
FOR k% = 0 TO (nc% - 1)
    READ r%, g%, b%
    _PALETTECOLOR k%, (r% * 65536) + (g% * 256) + b%
NEXT k%

RANDOMIZE TIMER
DIM StdFrac%(scrX% - 1, scrY% - 1)
sd% = 0
pn% = 0
sp% = 0

_MOUSEHIDE
DO
    CLS

    IF sd% = 0 THEN
        x1# = -2.1
        x2# = 0.7
        y1# = -1.18
        y2# = 1.18
    ELSE
        x% = RangeRand%(0, scrX% - 1)
        y% = RangeRand%(0, scrY% - 1)
        lc% = RangeRand%(32, 48)
        WHILE StdFrac%(x%, y%) < lc%
            x% = RangeRand%(0, scrX% - 1)
            y% = RangeRand%(0, scrY% - 1)
        WEND
        fd% = RangeRand%(1, 10)
        x1# = (2.8 / scrX% * (x% - fd%)) + (-2.1)
        x2# = (2.8 / scrX% * (x% + fd%)) + (-2.1)
        y1# = (2.36 / scrY% * (y% - fd%)) + (-1.18)
        y2# = (2.36 / scrY% * (y% + fd%)) + (-1.18)
    END IF

    dx# = (x2# - x1#)
    dy# = (y2# - y1#)

    FOR y% = 0 TO (scrY% - 1)
        b# = y1# + (dy# * (y% / scrY%))
        FOR x% = 0 TO (scrX% - 1)
            a# = x1# + (dx# * (x% / scrX%))
            v# = 0
            c1# = 0.001 'play with it 0.1...0.001
            c2# = 0.005 'play with it 0.5...0.005
            f% = 1
            k% = 0
            WHILE v# < nc% AND f% = 1
                tc1# = c1#
                tc2# = c2#
                c1# = (tc1# * tc1#) - (tc2# * tc2#) + a#
                c2# = (2 * tc1# * tc2#) + b#
                v# = (c1# * c1#) + (c2# * c2#)
                k% = k% + 1
                IF k% = nc% THEN f% = 0
                i$ = INKEY$
                DO WHILE _MOUSEINPUT
                    mx% = mx% + _MOUSEMOVEMENTX
                    my% = my% + _MOUSEMOVEMENTY
                LOOP
                IF i$ <> "" OR mx% <> 0 OR my% <> 0 THEN
                    IF i$ = "s" THEN
                        sp% = 1
                    ELSEIF i$ = "i" THEN
                        sp% = 2
                    ELSE
                        sp% = 0
                        GOTO exitProgram
                    END IF
                END IF
            WEND
            IF k% = nc% THEN
                PSET (x%, y%), 0
                IF sd% = 0 THEN StdFrac%(x%, y%) = 0
            ELSE
                PSET (x%, y%), k%
                IF sd% = 0 THEN StdFrac%(x%, y%) = k%
            END IF
        NEXT x%
        IF (y% MOD 10) = 0 THEN _DISPLAY
    NEXT y%
    _DISPLAY
    IF sp% > 0 THEN
        IF sp% > 1 THEN
            COLOR 32
            LOCATE 3, 5
            PRINT USING "X1 = +#.##########"; x1#
            LOCATE 4, 5
            PRINT USING "X2 = +#.##########"; x2#
            LOCATE 5, 5
            PRINT USING "Y1 = +#.##########"; y1#
            LOCATE 6, 5
            PRINT USING "Y2 = +#.##########"; y2#
        END IF
        WriteBMP si&, "Fractal-" + RIGHT$("0000" + LTRIM$(STR$(pn%)), 4)
        pn% = pn% + 1
        sp% = 0
    END IF

    sd% = 1
    _DELAY 3
    exitProgram:
LOOP WHILE i$ = "" AND mx% = 0 AND my% = 0

_FULLSCREEN _OFF
_DELAY 0.2: SCREEN 0
_DELAY 0.2: _FREEIMAGE si&
SYSTEM

ColorTab:
DATA &H00,&H00,&H00,&H08,&H00,&H10,&H10,&H00,&H20,&H18,&H00,&H30
DATA &H20,&H00,&H40,&H28,&H00,&H50,&H30,&H00,&H60,&H38,&H00,&H70
DATA &H40,&H00,&H80,&H48,&H00,&H90,&H50,&H00,&HA0,&H58,&H00,&HB0
DATA &H60,&H00,&HC0,&H68,&H00,&HD0,&H70,&H00,&HE0,&H78,&H00,&HF0
DATA &H80,&H00,&HFF,&H78,&H00,&HFF,&H70,&H00,&HFF,&H68,&H00,&HFF
DATA &H60,&H00,&HFF,&H58,&H00,&HFF,&H50,&H00,&HFF,&H48,&H00,&HFF
DATA &H40,&H00,&HFF,&H38,&H00,&HFF,&H30,&H00,&HFF,&H28,&H00,&HFF
DATA &H20,&H00,&HFF,&H18,&H00,&HFF,&H10,&H00,&HFF,&H08,&H00,&HFF
DATA &H00,&H00,&HFF,&H00,&H10,&HFF,&H00,&H20,&HFF,&H00,&H30,&HFF
DATA &H00,&H40,&HFF,&H00,&H50,&HFF,&H00,&H60,&HFF,&H00,&H70,&HFF
DATA &H00,&H80,&HFF,&H00,&H90,&HFF,&H00,&HA0,&HFF,&H00,&HB0,&HFF
DATA &H00,&HC0,&HFF,&H00,&HD0,&HFF,&H00,&HE0,&HFF,&H00,&HF0,&HFF
DATA &H00,&HFF,&HFF,&H00,&HFF,&HF0,&H00,&HFF,&HE0,&H00,&HFF,&HD0
DATA &H00,&HFF,&HC0,&H00,&HFF,&HB0,&H00,&HFF,&HA0,&H00,&HFF,&H90
DATA &H00,&HFF,&H80,&H00,&HFF,&H70,&H00,&HFF,&H60,&H00,&HFF,&H50
DATA &H00,&HFF,&H40,&H00,&HFF,&H30,&H00,&HFF,&H20,&H00,&HFF,&H10
DATA &H00,&HFF,&H00,&H10,&HFF,&H00,&H20,&HFF,&H00,&H30,&HFF,&H00
DATA &H40,&HFF,&H00,&H50,&HFF,&H00,&H60,&HFF,&H00,&H70,&HFF,&H00
DATA &H80,&HFF,&H00,&H90,&HFF,&H00,&HA0,&HFF,&H00,&HB0,&HFF,&H00
DATA &HC0,&HFF,&H00,&HD0,&HFF,&H00,&HE0,&HFF,&H00,&HF0,&HFF,&H00
DATA &HFF,&HFF,&H00,&HFF,&HF0,&H00,&HFF,&HE0,&H00,&HFF,&HD0,&H00
DATA &HFF,&HC0,&H00,&HFF,&HB0,&H00,&HFF,&HA0,&H00,&HFF,&H90,&H00
DATA &HFF,&H80,&H00,&HFF,&H70,&H00,&HFF,&H60,&H00,&HFF,&H50,&H00
DATA &HFF,&H40,&H00,&HFF,&H30,&H00,&HFF,&H20,&H00,&HFF,&H10,&H00
DATA &HFF,&H00,&H00,&HFF,&H00,&H08,&HFF,&H00,&H10,&HFF,&H00,&H18
DATA &HFF,&H00,&H20,&HFF,&H00,&H28,&HFF,&H00,&H30,&HFF,&H00,&H38
DATA &HFF,&H00,&H40,&HFF,&H00,&H48,&HFF,&H00,&H50,&HFF,&H00,&H58
DATA &HFF,&H00,&H60,&HFF,&H00,&H68,&HFF,&H00,&H70,&HFF,&H00,&H78
DATA &HFF,&H00,&H80,&HF0,&H00,&H78,&HE0,&H00,&H70,&HD0,&H00,&H68
DATA &HC0,&H00,&H60,&HB0,&H00,&H58,&HA0,&H00,&H50,&H90,&H00,&H48
DATA &H80,&H00,&H40,&H70,&H00,&H38,&H60,&H00,&H30,&H50,&H00,&H28
DATA &H40,&H00,&H20,&H30,&H00,&H18,&H20,&H00,&H10,&H10,&H00,&H08

'======================================================================
FUNCTION RangeRand% (low%, high%)
RangeRand% = INT(RND(1) * (high% - low% + 1)) + low%
END FUNCTION

'======================================================================
SUB WriteBMP (image AS LONG, filename AS STRING)
bytesperpixel& = _PIXELSIZE(image&)
IF bytesperpixel& = 0 THEN PRINT "Text modes unsupported!": END
IF bytesperpixel& = 1 THEN bpp& = 8 ELSE bpp& = 24
x& = _WIDTH(image&)
y& = _HEIGHT(image&)
b$ = "BM????QB64????" + MKL$(40) + MKL$(x&) + MKL$(y&) + MKI$(1) + MKI$(bpp&) + MKL$(0) + "????" + MKL$(0) + MKL$(0) + MKL$(0) + MKL$(0) 'partial BMP header info(???? to be filled later)
IF bytesperpixel& = 1 THEN
    FOR c& = 0 TO 255 ' read BGR color settings from JPG image + 1 byte spacer(CHR$(0))
        cv& = _PALETTECOLOR(c&, image&) ' color attribute to read.
        b$ = b$ + CHR$(_BLUE32(cv&)) + CHR$(_GREEN32(cv&)) + CHR$(_RED32(cv&)) + CHR$(0) 'spacer byte
    NEXT
END IF
MID$(b$, 11, 4) = MKL$(LEN(b$)) ' image pixel data offset(BMP header)
lastsource& = _SOURCE
_SOURCE image&
IF ((x& * 3) MOD 4) THEN padder$ = SPACE$(4 - ((x& * 3) MOD 4))
FOR py& = y& - 1 TO 0 STEP -1 ' read JPG image pixel color data
    r$ = ""
    FOR px& = 0 TO x& - 1
        c& = POINT(px&, py&)
        IF bytesperpixel& = 1 THEN r$ = r$ + CHR$(c&) ELSE r$ = r$ + LEFT$(MKL$(c&), 3)
    NEXT px&
    d$ = d$ + r$ + padder$
NEXT py&
_SOURCE lastsource&
MID$(b$, 35, 4) = MKL$(LEN(d$)) ' image size(BMP header)
b$ = b$ + d$ ' total file data bytes to create file
MID$(b$, 3, 4) = MKL$(LEN(b$)) ' size of data file(BMP header)
IF LCASE$(RIGHT$(filename$, 4)) <> ".bmp" THEN ext$ = ".bmp"
f& = FREEFILE
OPEN filename$ + ext$ FOR OUTPUT AS #f&: CLOSE #f& ' erases an existing file
OPEN filename$ + ext$ FOR BINARY AS #f&
PUT #f&, , b$
CLOSE #f&
END SUB

'=====================================================================
FUNCTION VersionFractal$
VersionFractal$ = MID$("$VER: Fractal blanker 1.0 (07-Oct-2011) by RhoSigma :END$", 7, 45)
END FUNCTION

