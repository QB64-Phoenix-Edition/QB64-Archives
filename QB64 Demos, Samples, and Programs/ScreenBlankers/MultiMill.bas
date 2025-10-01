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
'| === MultiMill.bas ===                                             |
'|                                                                   |
'| == Draws many spinning elements with color cycling effect.        |
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

fa% = 128
RESTORE ColorTab
FOR l% = 0 TO (fa% - 1)
    READ r&, g&, b&
    _PALETTECOLOR l%, (r& * 65536) + (g& * 256) + b&
NEXT l%
_PALETTECOLOR (fa% + 2), &H000000
_PALETTECOLOR (fa% + 3), &HFFFFFF
COLOR (fa% + 3), (fa% + 2)
CLS

RANDOMIZE TIMER
rad! = 3.141592653589793 / 180

f% = 0
x1% = RangeRand%(0, scrX% - 1)
y1% = RangeRand%(0, scrY% - 1)
dx1% = 1
dy1% = 1
v1% = RangeRand%(2, 5)
w1% = 0
w2% = 45

bx11! = COS(rad! * w1%)
bx12! = COS(rad! * (w1% + 90))
bx13! = COS(rad! * (w1% + 180))
bx14! = COS(rad! * (w1% + 270))
by11! = SIN(rad! * w1%)
by12! = SIN(rad! * (w1% + 90))
by13! = SIN(rad! * (w1% + 180))
by14! = SIN(rad! * (w1% + 270))

bx21! = COS(rad! * w2%)
bx22! = COS(rad! * (w2% + 90))
bx23! = COS(rad! * (w2% + 180))
bx24! = COS(rad! * (w2% + 270))
by21! = SIN(rad! * w2%)
by22! = SIN(rad! * (w2% + 90))
by23! = SIN(rad! * (w2% + 180))
by24! = SIN(rad! * (w2% + 270))

ex11% = x1% + 60 * bx11!
ex12% = x1% + 60 * bx12!
ex13% = x1% + 60 * bx13!
ex14% = x1% + 60 * bx14!
ey11% = y1% + 60 * by11!
ey12% = y1% + 60 * by12!
ey13% = y1% + 60 * by13!
ey14% = y1% + 60 * by14!

_MOUSEHIDE
WHILE INKEY$ = "" AND mx% = 0 AND my% = 0
    CIRCLE (x1%, y1%), 38, (fa% + 2)
    LINE (x1% + 95 * bx21!, y1% + 95 * by21!)-(x1% + 120 * bx21!, y1% + 120 * by21!), (fa% + 2)
    LINE (x1% + 95 * bx22!, y1% + 95 * by22!)-(x1% + 120 * bx22!, y1% + 120 * by22!), (fa% + 2)
    LINE (x1% + 95 * bx23!, y1% + 95 * by23!)-(x1% + 120 * bx23!, y1% + 120 * by23!), (fa% + 2)
    LINE (x1% + 95 * bx24!, y1% + 95 * by24!)-(x1% + 120 * bx24!, y1% + 120 * by24!), (fa% + 2)
    LINE (x1% + 95 * bx11!, y1% + 95 * by11!)-(x1% + 120 * bx11!, y1% + 120 * by11!), (fa% + 2)
    LINE (x1% + 95 * bx12!, y1% + 95 * by12!)-(x1% + 120 * bx12!, y1% + 120 * by12!), (fa% + 2)
    LINE (x1% + 95 * bx13!, y1% + 95 * by13!)-(x1% + 120 * bx13!, y1% + 120 * by13!), (fa% + 2)
    LINE (x1% + 95 * bx14!, y1% + 95 * by14!)-(x1% + 120 * bx14!, y1% + 120 * by14!), (fa% + 2)

    LINE (ex11%, ey11%)-(ex12%, ey12%), (fa% + 2)
    LINE (ex12%, ey12%)-(ex13%, ey13%), (fa% + 2)
    LINE (ex13%, ey13%)-(ex14%, ey14%), (fa% + 2)
    LINE (ex14%, ey14%)-(ex11%, ey11%), (fa% + 2)

    LINE (ex11% + 20 * bx21!, ey11% + 20 * by21!)-(ex11% + 20 * bx23!, ey11% + 20 * by23!), (fa% + 2)
    LINE (ex11% + 20 * bx22!, ey11% + 20 * by22!)-(ex11% + 20 * bx24!, ey11% + 20 * by24!), (fa% + 2)
    CIRCLE (ex11% + 20 * bx21!, ey11% + 20 * by21!), 5, (fa% + 2)
    CIRCLE (ex11% + 20 * bx23!, ey11% + 20 * by23!), 5, (fa% + 2)
    CIRCLE (ex11% + 20 * bx22!, ey11% + 20 * by22!), 5, (fa% + 2)
    CIRCLE (ex11% + 20 * bx24!, ey11% + 20 * by24!), 5, (fa% + 2)

    LINE (ex12% + 20 * bx21!, ey12% + 20 * by21!)-(ex12% + 20 * bx23!, ey12% + 20 * by23!), (fa% + 2)
    LINE (ex12% + 20 * bx22!, ey12% + 20 * by22!)-(ex12% + 20 * bx24!, ey12% + 20 * by24!), (fa% + 2)
    CIRCLE (ex12% + 20 * bx21!, ey12% + 20 * by21!), 5, (fa% + 2)
    CIRCLE (ex12% + 20 * bx23!, ey12% + 20 * by23!), 5, (fa% + 2)
    CIRCLE (ex12% + 20 * bx22!, ey12% + 20 * by22!), 5, (fa% + 2)
    CIRCLE (ex12% + 20 * bx24!, ey12% + 20 * by24!), 5, (fa% + 2)

    LINE (ex13% + 20 * bx21!, ey13% + 20 * by21!)-(ex13% + 20 * bx23!, ey13% + 20 * by23!), (fa% + 2)
    LINE (ex13% + 20 * bx22!, ey13% + 20 * by22!)-(ex13% + 20 * bx24!, ey13% + 20 * by24!), (fa% + 2)
    CIRCLE (ex13% + 20 * bx21!, ey13% + 20 * by21!), 5, (fa% + 2)
    CIRCLE (ex13% + 20 * bx23!, ey13% + 20 * by23!), 5, (fa% + 2)
    CIRCLE (ex13% + 20 * bx22!, ey13% + 20 * by22!), 5, (fa% + 2)
    CIRCLE (ex13% + 20 * bx24!, ey13% + 20 * by24!), 5, (fa% + 2)

    LINE (ex14% + 20 * bx21!, ey14% + 20 * by21!)-(ex14% + 20 * bx23!, ey14% + 20 * by23!), (fa% + 2)
    LINE (ex14% + 20 * bx22!, ey14% + 20 * by22!)-(ex14% + 20 * bx24!, ey14% + 20 * by24!), (fa% + 2)
    CIRCLE (ex14% + 20 * bx21!, ey14% + 20 * by21!), 5, (fa% + 2)
    CIRCLE (ex14% + 20 * bx23!, ey14% + 20 * by23!), 5, (fa% + 2)
    CIRCLE (ex14% + 20 * bx22!, ey14% + 20 * by22!), 5, (fa% + 2)
    CIRCLE (ex14% + 20 * bx24!, ey14% + 20 * by24!), 5, (fa% + 2)

    LINE (x1% + 20 * bx21!, y1% + 20 * by21!)-(x1% + 20 * bx22!, y1% + 20 * by22!), (fa% + 2), B
    LINE (x1% + 20 * bx22!, y1% + 20 * by22!)-(x1% + 20 * bx23!, y1% + 20 * by23!), (fa% + 2), B
    LINE (x1% + 20 * bx23!, y1% + 20 * by23!)-(x1% + 20 * bx24!, y1% + 20 * by24!), (fa% + 2), B
    LINE (x1% + 20 * bx24!, y1% + 20 * by24!)-(x1% + 20 * bx21!, y1% + 20 * by21!), (fa% + 2), B

    x1% = x1% + (v1% * dx1%)
    IF x1% < 0 OR x1% > (scrX% - 1) THEN
        x1% = x1% - (2 * (v1% * dx1%))
        dx1% = -dx1%
        v1% = RangeRand%(2, 5)
    END IF
    y1% = y1% + (v1% * dy1%)
    IF y1% < 0 OR y1% > (scrY% - 1) THEN
        y1% = y1% - (2 * (v1% * dy1%))
        dy1% = -dy1%
        v1% = RangeRand%(2, 5)
    END IF
    w1% = w1% + 5
    IF w1% > 360 THEN w1% = w1% - 360
    w2% = w2% - 5
    IF w2% < 0 THEN w2% = w2% + 360

    bx11! = COS(rad! * w1%)
    bx12! = COS(rad! * (w1% + 90))
    bx13! = COS(rad! * (w1% + 180))
    bx14! = COS(rad! * (w1% + 270))
    by11! = SIN(rad! * w1%)
    by12! = SIN(rad! * (w1% + 90))
    by13! = SIN(rad! * (w1% + 180))
    by14! = SIN(rad! * (w1% + 270))

    bx21! = COS(rad! * w2%)
    bx22! = COS(rad! * (w2% + 90))
    bx23! = COS(rad! * (w2% + 180))
    bx24! = COS(rad! * (w2% + 270))
    by21! = SIN(rad! * w2%)
    by22! = SIN(rad! * (w2% + 90))
    by23! = SIN(rad! * (w2% + 180))
    by24! = SIN(rad! * (w2% + 270))

    ex11% = x1% + 60 * bx11!
    ex12% = x1% + 60 * bx12!
    ex13% = x1% + 60 * bx13!
    ex14% = x1% + 60 * bx14!
    ey11% = y1% + 60 * by11!
    ey12% = y1% + 60 * by12!
    ey13% = y1% + 60 * by13!
    ey14% = y1% + 60 * by14!

    CIRCLE (x1%, y1%), 38, f%
    LINE (x1% + 95 * bx21!, y1% + 95 * by21!)-(x1% + 120 * bx21!, y1% + 120 * by21!), f% + 1
    LINE (x1% + 95 * bx22!, y1% + 95 * by22!)-(x1% + 120 * bx22!, y1% + 120 * by22!), f% + 2
    LINE (x1% + 95 * bx23!, y1% + 95 * by23!)-(x1% + 120 * bx23!, y1% + 120 * by23!), f% + 3
    LINE (x1% + 95 * bx24!, y1% + 95 * by24!)-(x1% + 120 * bx24!, y1% + 120 * by24!), f% + 4
    LINE (x1% + 95 * bx11!, y1% + 95 * by11!)-(x1% + 120 * bx11!, y1% + 120 * by11!), f% + 5
    LINE (x1% + 95 * bx12!, y1% + 95 * by12!)-(x1% + 120 * bx12!, y1% + 120 * by12!), f% + 6
    LINE (x1% + 95 * bx13!, y1% + 95 * by13!)-(x1% + 120 * bx13!, y1% + 120 * by13!), f% + 7
    LINE (x1% + 95 * bx14!, y1% + 95 * by14!)-(x1% + 120 * bx14!, y1% + 120 * by14!), f% + 8

    LINE (ex11%, ey11%)-(ex12%, ey12%), f% + 9
    LINE (ex12%, ey12%)-(ex13%, ey13%), f% + 10
    LINE (ex13%, ey13%)-(ex14%, ey14%), f% + 11
    LINE (ex14%, ey14%)-(ex11%, ey11%), f% + 12

    LINE (ex11% + 20 * bx21!, ey11% + 20 * by21!)-(ex11% + 20 * bx23!, ey11% + 20 * by23!), f% + 13
    LINE (ex11% + 20 * bx22!, ey11% + 20 * by22!)-(ex11% + 20 * bx24!, ey11% + 20 * by24!), f% + 14
    CIRCLE (ex11% + 20 * bx21!, ey11% + 20 * by21!), 5, f% + 15
    CIRCLE (ex11% + 20 * bx23!, ey11% + 20 * by23!), 5, f% + 16
    CIRCLE (ex11% + 20 * bx22!, ey11% + 20 * by22!), 5, f% + 17
    CIRCLE (ex11% + 20 * bx24!, ey11% + 20 * by24!), 5, f% + 18

    LINE (ex12% + 20 * bx21!, ey12% + 20 * by21!)-(ex12% + 20 * bx23!, ey12% + 20 * by23!), f% + 19
    LINE (ex12% + 20 * bx22!, ey12% + 20 * by22!)-(ex12% + 20 * bx24!, ey12% + 20 * by24!), f% + 20
    CIRCLE (ex12% + 20 * bx21!, ey12% + 20 * by21!), 5, f% + 21
    CIRCLE (ex12% + 20 * bx23!, ey12% + 20 * by23!), 5, f% + 22
    CIRCLE (ex12% + 20 * bx22!, ey12% + 20 * by22!), 5, f% + 23
    CIRCLE (ex12% + 20 * bx24!, ey12% + 20 * by24!), 5, f% + 24

    LINE (ex13% + 20 * bx21!, ey13% + 20 * by21!)-(ex13% + 20 * bx23!, ey13% + 20 * by23!), f% + 25
    LINE (ex13% + 20 * bx22!, ey13% + 20 * by22!)-(ex13% + 20 * bx24!, ey13% + 20 * by24!), f% + 26
    CIRCLE (ex13% + 20 * bx21!, ey13% + 20 * by21!), 5, f% + 27
    CIRCLE (ex13% + 20 * bx23!, ey13% + 20 * by23!), 5, f% + 28
    CIRCLE (ex13% + 20 * bx22!, ey13% + 20 * by22!), 5, f% + 29
    CIRCLE (ex13% + 20 * bx24!, ey13% + 20 * by24!), 5, f% + 30

    LINE (ex14% + 20 * bx21!, ey14% + 20 * by21!)-(ex14% + 20 * bx23!, ey14% + 20 * by23!), f% + 31
    LINE (ex14% + 20 * bx22!, ey14% + 20 * by22!)-(ex14% + 20 * bx24!, ey14% + 20 * by24!), f% + 32
    CIRCLE (ex14% + 20 * bx21!, ey14% + 20 * by21!), 5, f% + 33
    CIRCLE (ex14% + 20 * bx23!, ey14% + 20 * by23!), 5, f% + 34
    CIRCLE (ex14% + 20 * bx22!, ey14% + 20 * by22!), 5, f% + 35
    CIRCLE (ex14% + 20 * bx24!, ey14% + 20 * by24!), 5, f% + 36

    LINE (x1% + 20 * bx21!, y1% + 20 * by21!)-(x1% + 20 * bx22!, y1% + 20 * by22!), f%, B
    LINE (x1% + 20 * bx22!, y1% + 20 * by22!)-(x1% + 20 * bx23!, y1% + 20 * by23!), f%, B
    LINE (x1% + 20 * bx23!, y1% + 20 * by23!)-(x1% + 20 * bx24!, y1% + 20 * by24!), f%, B
    LINE (x1% + 20 * bx24!, y1% + 20 * by24!)-(x1% + 20 * bx21!, y1% + 20 * by21!), f%, B

    f% = f% + 1
    IF f% = fa% - 36 THEN f% = 0
    _LIMIT 30
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
FUNCTION VersionMultiMill$
VersionMultiMill$ = MID$("$VER: MultiMill blanker 1.0 (21-Aug-2010) by RhoSigma :END$", 7, 47)
END FUNCTION

