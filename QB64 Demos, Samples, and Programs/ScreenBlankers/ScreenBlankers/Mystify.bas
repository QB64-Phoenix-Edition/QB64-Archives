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
'| === Mystify.bas ===                                               |
'|                                                                   |
'| == The QB64 remake of the widely known Mystify screen blanker.    |
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

DIM SHARED x11(4), y11(4), x21(4), y21(4), x31(4), y31(4), x41(4), y41(4)
DIM SHARED x12(4), y12(4), x22(4), y22(4), x32(4), y32(4), x42(4), y42(4)
DIM SHARED xSpeed1%(3), xSpeed2%(3), ySpeed1%(3), ySpeed2%(3)

FOR x% = 0 TO 3
    xSpeed1%(x%) = 5
    xSpeed2%(x%) = 5
    ySpeed1%(x%) = 5
    ySpeed2%(x%) = 5
NEXT x%

RANDOMIZE TIMER
f1% = RangeRand%(32, 96)
f2% = RangeRand%(32, 96)
x11(4) = RangeRand%(0, scrX% - 1)
x21(4) = RangeRand%(0, scrX% - 1)
x31(4) = RangeRand%(0, scrX% - 1)
x41(4) = RangeRand%(0, scrX% - 1)

x12(4) = RangeRand%(0, scrX% - 1)
x22(4) = RangeRand%(0, scrX% - 1)
x32(4) = RangeRand%(0, scrX% - 1)
x42(4) = RangeRand%(0, scrX% - 1)

y11(4) = RangeRand%(0, scrY% - 1)
y21(4) = RangeRand%(0, scrY% - 1)
y31(4) = RangeRand%(0, scrY% - 1)
y41(4) = RangeRand%(0, scrY% - 1)

y12(4) = RangeRand%(0, scrY% - 1)
y22(4) = RangeRand%(0, scrY% - 1)
y32(4) = RangeRand%(0, scrY% - 1)
y42(4) = RangeRand%(0, scrY% - 1)

_MOUSEHIDE
WHILE INKEY$ = "" AND mx% = 0 AND my% = 0
    FOR x% = 0 TO 3
        x11(x%) = x11(x% + 1)
        x21(x%) = x21(x% + 1)
        x31(x%) = x31(x% + 1)
        x41(x%) = x41(x% + 1)

        x12(x%) = x12(x% + 1)
        x22(x%) = x22(x% + 1)
        x32(x%) = x32(x% + 1)
        x42(x%) = x42(x% + 1)

        y11(x%) = y11(x% + 1)
        y21(x%) = y21(x% + 1)
        y31(x%) = y31(x% + 1)
        y41(x%) = y41(x% + 1)

        y12(x%) = y12(x% + 1)
        y22(x%) = y22(x% + 1)
        y32(x%) = y32(x% + 1)
        y42(x%) = y42(x% + 1)
    NEXT x%

    x11(4) = x11(4) + xSpeed1%(0)
    x21(4) = x21(4) + xSpeed1%(1)
    x31(4) = x31(4) + xSpeed1%(2)
    x41(4) = x41(4) + xSpeed1%(3)

    x12(4) = x12(4) + xSpeed2%(0)
    x22(4) = x22(4) + xSpeed2%(1)
    x32(4) = x32(4) + xSpeed2%(2)
    x42(4) = x42(4) + xSpeed2%(3)

    y11(4) = y11(4) + ySpeed1%(0)
    y21(4) = y21(4) + ySpeed1%(1)
    y31(4) = y31(4) + ySpeed1%(2)
    y41(4) = y41(4) + ySpeed1%(3)

    y12(4) = y12(4) + ySpeed2%(0)
    y22(4) = y22(4) + ySpeed2%(1)
    y32(4) = y32(4) + ySpeed2%(2)
    y42(4) = y42(4) + ySpeed2%(3)

    IF x11(4) > (scrX% - 1) OR x11(4) < 0 THEN
        f1% = RangeRand%(32, 96)
        xSpeed1%(0) = RangeRand%(5, 7) * SGN(xSpeed1%(0))
        xSpeed1%(0) = -xSpeed1%(0)
        x11(4) = x11(4) + xSpeed1%(0)
    END IF
    IF x21(4) > (scrX% - 1) OR x21(4) < 0 THEN
        xSpeed1%(1) = RangeRand%(5, 7) * SGN(xSpeed1%(1))
        xSpeed1%(1) = -xSpeed1%(1)
        x21(4) = x21(4) + xSpeed1%(1)
    END IF
    IF x31(4) > (scrX% - 1) OR x31(4) < 0 THEN
        xSpeed1%(2) = RangeRand%(5, 7) * SGN(xSpeed1%(2))
        xSpeed1%(2) = -xSpeed1%(2)
        x31(4) = x31(4) + xSpeed1%(2)
    END IF
    IF x41(4) > (scrX% - 1) OR x41(4) < 0 THEN
        xSpeed1%(3) = RangeRand%(5, 7) * SGN(xSpeed1%(3))
        xSpeed1%(3) = -xSpeed1%(3)
        x41(4) = x41(4) + xSpeed1%(3)
    END IF

    IF x12(4) > (scrX% - 1) OR x12(4) < 0 THEN
        f2% = RangeRand%(32, 96)
        xSpeed2%(0) = RangeRand%(5, 7) * SGN(xSpeed2%(0))
        xSpeed2%(0) = -xSpeed2%(0)
        x12(4) = x12(4) + xSpeed2%(0)
    END IF
    IF x22(4) > (scrX% - 1) OR x22(4) < 0 THEN
        xSpeed2%(1) = RangeRand%(5, 7) * SGN(xSpeed2%(1))
        xSpeed2%(1) = -xSpeed2%(1)
        x22(4) = x22(4) + xSpeed2%(1)
    END IF
    IF x32(4) > (scrX% - 1) OR x32(4) < 0 THEN
        xSpeed2%(2) = RangeRand%(5, 7) * SGN(xSpeed2%(2))
        xSpeed2%(2) = -xSpeed2%(2)
        x32(4) = x32(4) + xSpeed2%(2)
    END IF
    IF x42(4) > (scrX% - 1) OR x42(4) < 0 THEN
        xSpeed2%(3) = RangeRand%(5, 7) * SGN(xSpeed2%(3))
        xSpeed2%(3) = -xSpeed2%(3)
        x42(4) = x42(4) + xSpeed2%(3)
    END IF

    IF y11(4) > (scrY% - 1) OR y11(4) < 0 THEN
        f1% = RangeRand%(32, 96)
        ySpeed1%(0) = RangeRand%(5, 7) * SGN(ySpeed1%(0))
        ySpeed1%(0) = -ySpeed1%(0)
        y11(4) = y11(4) + ySpeed1%(0)
    END IF
    IF y21(4) > (scrY% - 1) OR y21(4) < 0 THEN
        ySpeed1%(1) = RangeRand%(5, 7) * SGN(ySpeed1%(1))
        ySpeed1%(1) = -ySpeed1%(1)
        y21(4) = y21(4) + ySpeed1%(1)
    END IF
    IF y31(4) > (scrY% - 1) OR y31(4) < 0 THEN
        ySpeed1%(2) = RangeRand%(5, 7) * SGN(ySpeed1%(2))
        ySpeed1%(2) = -ySpeed1%(2)
        y31(4) = y31(4) + ySpeed1%(2)
    END IF
    IF y41(4) > (scrY% - 1) OR y41(4) < 0 THEN
        ySpeed1%(3) = RangeRand%(5, 7) * SGN(ySpeed1%(3))
        ySpeed1%(3) = -ySpeed1%(3)
        y41(4) = y41(4) + ySpeed1%(3)
    END IF

    IF y12(4) > (scrY% - 1) OR y12(4) < 0 THEN
        f2% = RangeRand%(32, 96)
        ySpeed2%(0) = RangeRand%(5, 7) * SGN(ySpeed2%(0))
        ySpeed2%(0) = -ySpeed2%(0)
        y12(4) = y12(4) + ySpeed2%(0)
    END IF
    IF y22(4) > (scrY% - 1) OR y22(4) < 0 THEN
        ySpeed2%(1) = RangeRand%(5, 7) * SGN(ySpeed2%(1))
        ySpeed2%(1) = -ySpeed2%(1)
        y22(4) = y22(4) + ySpeed2%(1)
    END IF
    IF y32(4) > (scrY% - 1) OR y32(4) < 0 THEN
        ySpeed2%(2) = RangeRand%(5, 7) * SGN(ySpeed2%(2))
        ySpeed2%(2) = -ySpeed2%(2)
        y32(4) = y32(4) + ySpeed2%(2)
    END IF
    IF y42(4) > (scrY% - 1) OR y42(4) < 0 THEN
        ySpeed2%(3) = RangeRand%(5, 7) * SGN(ySpeed2%(3))
        ySpeed2%(3) = -ySpeed2%(3)
        y42(4) = y42(4) + ySpeed2%(3)
    END IF

    LINE (x11(4), y11(4))-(x21(4), y21(4)), f1%
    LINE (x21(4), y21(4))-(x31(4), y31(4)), f1%
    LINE (x31(4), y31(4))-(x41(4), y41(4)), f1%
    LINE (x41(4), y41(4))-(x11(4), y11(4)), f1%
    LINE (x12(4), y12(4))-(x22(4), y22(4)), f2%
    LINE (x22(4), y22(4))-(x32(4), y32(4)), f2%
    LINE (x32(4), y32(4))-(x42(4), y42(4)), f2%
    LINE (x42(4), y42(4))-(x12(4), y12(4)), f2%

    LINE (x11(0), y11(0))-(x21(0), y21(0)), 0
    LINE (x21(0), y21(0))-(x31(0), y31(0)), 0
    LINE (x31(0), y31(0))-(x41(0), y41(0)), 0
    LINE (x41(0), y41(0))-(x11(0), y11(0)), 0
    LINE (x12(0), y12(0))-(x22(0), y22(0)), 0
    LINE (x22(0), y22(0))-(x32(0), y32(0)), 0
    LINE (x32(0), y32(0))-(x42(0), y42(0)), 0
    LINE (x42(0), y42(0))-(x12(0), y12(0)), 0

    _LIMIT 60
    _DISPLAY
    DO WHILE _MOUSEINPUT
        mx% = mx% + _MOUSEMOVEMENTX
        my% = my% + _MOUSEMOVEMENTY
    LOOP
WEND

_FULLSCREEN _OFF
_DELAY 0.2: SCREEN 0
_DELAY 0.2: _FREEIMAGE si&
SYSTEM

ColorTab:
DATA &H00,&H00,&H00
DATA &H08,&H00,&H10
DATA &H10,&H00,&H20
DATA &H18,&H00,&H30
DATA &H20,&H00,&H40
DATA &H28,&H00,&H50
DATA &H30,&H00,&H60
DATA &H38,&H00,&H70
DATA &H40,&H00,&H80
DATA &H48,&H00,&H90
DATA &H50,&H00,&HA0
DATA &H58,&H00,&HB0
DATA &H60,&H00,&HC0
DATA &H68,&H00,&HD0
DATA &H70,&H00,&HE0
DATA &H78,&H00,&HF0
DATA &H80,&H00,&HFF
DATA &H78,&H00,&HFF
DATA &H70,&H00,&HFF
DATA &H68,&H00,&HFF
DATA &H60,&H00,&HFF
DATA &H58,&H00,&HFF
DATA &H50,&H00,&HFF
DATA &H48,&H00,&HFF
DATA &H40,&H00,&HFF
DATA &H38,&H00,&HFF
DATA &H30,&H00,&HFF
DATA &H28,&H00,&HFF
DATA &H20,&H00,&HFF
DATA &H18,&H00,&HFF
DATA &H10,&H00,&HFF
DATA &H08,&H00,&HFF
DATA &H00,&H00,&HFF
DATA &H00,&H10,&HFF
DATA &H00,&H20,&HFF
DATA &H00,&H30,&HFF
DATA &H00,&H40,&HFF
DATA &H00,&H50,&HFF
DATA &H00,&H60,&HFF
DATA &H00,&H70,&HFF
DATA &H00,&H80,&HFF
DATA &H00,&H90,&HFF
DATA &H00,&HA0,&HFF
DATA &H00,&HB0,&HFF
DATA &H00,&HC0,&HFF
DATA &H00,&HD0,&HFF
DATA &H00,&HE0,&HFF
DATA &H00,&HF0,&HFF
DATA &H00,&HFF,&HFF
DATA &H00,&HFF,&HF0
DATA &H00,&HFF,&HE0
DATA &H00,&HFF,&HD0
DATA &H00,&HFF,&HC0
DATA &H00,&HFF,&HB0
DATA &H00,&HFF,&HA0
DATA &H00,&HFF,&H90
DATA &H00,&HFF,&H80
DATA &H00,&HFF,&H70
DATA &H00,&HFF,&H60
DATA &H00,&HFF,&H50
DATA &H00,&HFF,&H40
DATA &H00,&HFF,&H30
DATA &H00,&HFF,&H20
DATA &H00,&HFF,&H10
DATA &H00,&HFF,&H00
DATA &H10,&HFF,&H00
DATA &H20,&HFF,&H00
DATA &H30,&HFF,&H00
DATA &H40,&HFF,&H00
DATA &H50,&HFF,&H00
DATA &H60,&HFF,&H00
DATA &H70,&HFF,&H00
DATA &H80,&HFF,&H00
DATA &H90,&HFF,&H00
DATA &HA0,&HFF,&H00
DATA &HB0,&HFF,&H00
DATA &HC0,&HFF,&H00
DATA &HD0,&HFF,&H00
DATA &HE0,&HFF,&H00
DATA &HF0,&HFF,&H00
DATA &HFF,&HFF,&H00
DATA &HFF,&HF0,&H00
DATA &HFF,&HE0,&H00
DATA &HFF,&HD0,&H00
DATA &HFF,&HC0,&H00
DATA &HFF,&HB0,&H00
DATA &HFF,&HA0,&H00
DATA &HFF,&H90,&H00
DATA &HFF,&H80,&H00
DATA &HFF,&H70,&H00
DATA &HFF,&H60,&H00
DATA &HFF,&H50,&H00
DATA &HFF,&H40,&H00
DATA &HFF,&H30,&H00
DATA &HFF,&H20,&H00
DATA &HFF,&H10,&H00
DATA &HFF,&H00,&H00
DATA &HFF,&H00,&H08
DATA &HFF,&H00,&H10
DATA &HFF,&H00,&H18
DATA &HFF,&H00,&H20
DATA &HFF,&H00,&H28
DATA &HFF,&H00,&H30
DATA &HFF,&H00,&H38
DATA &HFF,&H00,&H40
DATA &HFF,&H00,&H48
DATA &HFF,&H00,&H50
DATA &HFF,&H00,&H58
DATA &HFF,&H00,&H60
DATA &HFF,&H00,&H68
DATA &HFF,&H00,&H70
DATA &HFF,&H00,&H78
DATA &HFF,&H00,&H80
DATA &HF0,&H00,&H78
DATA &HE0,&H00,&H70
DATA &HD0,&H00,&H68
DATA &HC0,&H00,&H60
DATA &HB0,&H00,&H58
DATA &HA0,&H00,&H50
DATA &H90,&H00,&H48
DATA &H80,&H00,&H40
DATA &H70,&H00,&H38
DATA &H60,&H00,&H30
DATA &H50,&H00,&H28
DATA &H40,&H00,&H20
DATA &H30,&H00,&H18
DATA &H20,&H00,&H10
DATA &H10,&H00,&H08

'======================================================================
FUNCTION RangeRand% (low%, high%)
RangeRand% = INT(RND(1) * (high% - low% + 1)) + low%
END FUNCTION

'=====================================================================
FUNCTION VersionMystify$
VersionMystify$ = MID$("$VER: Mystify blanker 1.0 (20-Aug-2010) by RhoSigma :END$", 7, 45)
END FUNCTION

