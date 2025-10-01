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
'| === KaleidoscopeMill.bas ===                                      |
'|                                                                   |
'| == Draws spinning Kaleidoscope tubes with color cycling effect.   |
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
DIM r&(fa%), g&(fa%), b&(fa%)
RESTORE ColorTab
FOR l% = 0 TO (fa% - 1)
    READ r&(l%), g&(l%), b&(l%)
NEXT l%
_PALETTECOLOR (fa% + 2), &H000000
_PALETTECOLOR (fa% + 3), &HFFFFFF
COLOR (fa% + 3), (fa% + 2)
CLS

DIM ox%(3), oy%(3)
x% = 0
y% = 0
dx% = 6
dy% = 6
d% = 1
f% = 0
w% = 45
bo! = 3.141592653589793 / 180

_MOUSEHIDE
WHILE INKEY$ = "" AND mx% = 0 AND my% = 0
    _PALETTECOLOR 0, (r&(0) * 65536) + (g&(0) * 256) + b&(0)
    SWAP r&(0), r&(fa%)
    SWAP g&(0), g&(fa%)
    SWAP b&(0), b&(fa%)
    FOR l% = 1 TO fa%
        IF l% < fa% THEN _PALETTECOLOR l%, (r&(l%) * 65536) + (g&(l%) * 256) + b&(l%)
        SWAP r&(l%), r&(l% - 1)
        SWAP g&(l%), g&(l% - 1)
        SWAP b&(l%), b&(l% - 1)
    NEXT l%

    px1% = d% * COS(bo! * w%)
    py1% = d% * SIN(bo! * w%)
    px2% = d% * COS(bo! * (w% + 90))
    py2% = d% * SIN(bo! * (w% + 90))
    px3% = d% * COS(bo! * (w% + 180))
    py3% = d% * SIN(bo! * (w% + 180))
    px4% = d% * COS(bo! * (w% + 270))
    py4% = d% * SIN(bo! * (w% + 270))
    LINE (x% + px1%, y% + py1%)-(x% + px2%, y% + py2%), f%
    LINE (x% + px2%, y% + py2%)-(x% + px3%, y% + py3%), f%
    LINE (x% + px3%, y% + py3%)-(x% + px4%, y% + py4%), f%
    LINE (x% + px4%, y% + py4%)-(x% + px1%, y% + py1%), f%

    LINE (ox%(0), oy%(0))-(x% + px1%, y% + py1%), (fa% + 3)
    LINE (ox%(1), oy%(1))-(x% + px2%, y% + py2%), (fa% + 3)
    LINE (ox%(2), oy%(2))-(x% + px3%, y% + py3%), (fa% + 3)
    LINE (ox%(3), oy%(3))-(x% + px4%, y% + py4%), (fa% + 3)
    ox%(0) = x% + px1%: oy%(0) = y% + py1%
    ox%(1) = x% + px2%: oy%(1) = y% + py2%
    ox%(2) = x% + px3%: oy%(2) = y% + py3%
    ox%(3) = x% + px4%: oy%(3) = y% + py4%
    xAgain:
    x% = x% + dx%
    IF x% < 0 OR x% > (scrX% - 1) THEN
        dx% = -dx%
        GOTO xAgain
    END IF
    yAgain:
    y% = y% + dy%
    IF y% < 0 OR y% > (scrY% - 1) THEN
        dy% = -dy%
        GOTO yAgain
    END IF
    d% = d% + 1
    dAgain:
    IF x% - d% < 0 OR x% + d% > (scrX% - 1) OR y% - d% < 0 OR y% + d% > (scrY% - 1) THEN
        d% = d% - 1
        GOTO dAgain
    END IF
    f% = f% + 1
    IF f% = fa% THEN f% = 0
    w% = w% + 5
    IF w% = 405 THEN w% = 45

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

'=====================================================================
FUNCTION VersionKaleidoscopeMill$
VersionKaleidoscopeMill$ = MID$("$VER: KaleidoscopeMill blanker 1.0 (19-Aug-2010) by RhoSigma :END$", 7, 54)
END FUNCTION

