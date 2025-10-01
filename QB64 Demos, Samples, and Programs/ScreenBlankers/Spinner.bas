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
'| === Spinner.bas ===                                               |
'|                                                                   |
'| == This is a program originally posted by forum member bplus.     |
'| == I just made it compatible with the old QB64 versions and       |
'| == turned it into a screen blanker, ie. quit on input activity.   |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

_SCREENMOVE -32000, -32000
_DELAY 0.2

di& = _SCREENIMAGE
pdi& = _SCREENIMAGE
DIM SHARED scrX%, scrY%
scrX% = _WIDTH(di&)
scrY% = _HEIGHT(di&)
SCREEN di&
_DELAY 0.2: _SCREENMOVE _MIDDLE
_DELAY 0.2: _FULLSCREEN

CONST MAX_SPINNERS = 100

TYPE Spinner
    x AS SINGLE
    y AS SINGLE
    dx AS SINGLE
    dy AS SINGLE
    sz AS SINGLE
    c AS _UNSIGNED LONG
END TYPE
DIM SHARED Spinners(1 TO MAX_SPINNERS) AS Spinner

RANDOMIZE TIMER
FOR i = 1 TO MAX_SPINNERS
    newSpinner i
NEXT
i2 = 1: lc = 0

_MOUSEHIDE
WHILE INKEY$ = "" AND mx% = 0 AND my% = 0
    _PUTIMAGE , pdi&
    lc = lc + 1
    IF lc MOD 100 = 99 THEN
        lc = 0
        IF i2 < MAX_SPINNERS THEN i2 = i2 + 1
    END IF
    FOR i = 1 TO i2
        drawSpinner Spinners(i).x, Spinners(i).y, Spinners(i).sz, ARCTAN2(Spinners(i).dy, Spinners(i).dx), Spinners(i).c
        Spinners(i).x = Spinners(i).x + Spinners(i).dx: Spinners(i).y = Spinners(i).y + Spinners(i).dy
        IF Spinners(i).x < -100 OR Spinners(i).x > scrX% + 100 OR Spinners(i).y < -100 OR Spinners(i).y > scrY% + 100 THEN newSpinner i
    NEXT

    _LIMIT 20
    _DISPLAY
    DO WHILE _MOUSEINPUT
        mx% = mx% + _MOUSEMOVEMENTX
        my% = my% + _MOUSEMOVEMENTY
    LOOP
WEND

_FULLSCREEN _OFF
_DELAY 0.2: SCREEN 0
_DELAY 0.2: _FREEIMAGE pdi&: _FREEIMAGE di&
SYSTEM

'======================================================================
SUB newSpinner (i AS INTEGER) 'set Spinners dimensions start angles, color?
DIM r
Spinners(i).sz = RND * .25 + .5
IF RND < .5 THEN r = -1 ELSE r = 1
Spinners(i).dx = (Spinners(i).sz * RND * 8) * r * 2: Spinners(i).dy = (Spinners(i).sz * RND * 8) * r * 2
r = INT(RND * 4)
SELECT CASE r
    CASE 0: Spinners(i).x = RND * (scrX% - 120) + 60: Spinners(i).y = 0: IF Spinners(i).dy < 0 THEN Spinners(i).dy = -Spinners(i).dy
    CASE 1: Spinners(i).x = RND * (scrX% - 120) + 60: Spinners(i).y = scrY%: IF Spinners(i).dy > 0 THEN Spinners(i).dy = -Spinners(i).dy
    CASE 2: Spinners(i).x = 0: Spinners(i).y = RND * (scrY% - 120) + 60: IF Spinners(i).dx < 0 THEN Spinners(i).dx = -Spinners(i).dx
    CASE 3: Spinners(i).x = scrX%: Spinners(i).y = RND * (scrY% - 120) + 60: IF Spinners(i).dx > 0 THEN Spinners(i).dx = -Spinners(i).dx
END SELECT
r = RND * 120
Spinners(i).c = _RGB32(r, RND * .5 * r, RND * .25 * r)
END SUB

'======================================================================
SUB drawSpinner (x AS INTEGER, y AS INTEGER, scale AS SINGLE, heading AS SINGLE, c AS _UNSIGNED LONG)
DIM x1, x2, x3, x4, y1, y2, y3, y4, r, a, a1, a2, lg, d, rd, red, blue, green
STATIC switch AS INTEGER
switch = switch + 2
switch = switch MOD 16 + 1
red = _RED32(c): green = _GREEN32(c): blue = _BLUE32(c)
r = 10 * scale
x1 = x + r * COS(heading): y1 = y + r * SIN(heading)
r = 2 * r 'lg lengths
FOR lg = 1 TO 8
    IF lg < 5 THEN
        a = heading + .9 * lg * MultPI(1 / 5) + (lg = switch) * MultPI(1 / 10)
    ELSE
        a = heading - .9 * (lg - 4) * MultPI(1 / 5) - (lg = switch) * MultPI(1 / 10)
    END IF
    x2 = x1 + r * COS(a): y2 = y1 + r * SIN(a)
    drawLink x1, y1, 3 * scale, x2, y2, 2 * scale, _RGB32(red + 20, green + 10, blue + 5)
    IF lg = 1 OR lg = 2 OR lg = 7 OR lg = 8 THEN d = -1 ELSE d = 1
    a1 = a + d * MultPI(1 / 12)
    x3 = x2 + r * 1.5 * COS(a1): y3 = y2 + r * 1.5 * SIN(a1)
    drawLink x2, y2, 2 * scale, x3, y3, scale, _RGB32(red + 35, green + 17, blue + 8)
    rd = INT(RND * 8) + 1
    a2 = a1 + d * MultPI(1 / 8) * rd / 8
    x4 = x3 + r * 1.5 * COS(a2): y4 = y3 + r * 1.5 * SIN(a2)
    drawLink x3, y3, scale, x4, y4, scale, _RGB32(red + 50, green + 25, blue + 12)
NEXT
r = r * .5
fcirc x1, y1, r, _RGB32(red - 20, green - 10, blue - 5)
x2 = x1 + (r + 1) * COS(heading - MultPI(1 / 12)): y2 = y1 + (r + 1) * SIN(heading - MultPI(1 / 12))
fcirc x2, y2, r * .2, &HFF000000
x2 = x1 + (r + 1) * COS(heading + MultPI(1 / 12)): y2 = y1 + (r + 1) * SIN(heading + MultPI(1 / 12))
fcirc x2, y2, r * .2, &HFF000000
r = r * 2
x1 = x + r * .9 * COS(heading + ConstPI): y1 = y + r * .9 * SIN(heading + ConstPI)
TiltedEllipseFill 0, x1, y1, r, .7 * r, heading + ConstPI, _RGB32(red, green, blue)
END SUB

'======================================================================
SUB drawLink (x1, y1, r1, x2, y2, r2, c AS _UNSIGNED LONG)
DIM a, a1, a2, x3, x4, x5, x6, y3, y4, y5, y6
a = ARCTAN2(y2 - y1, x2 - x1)
a1 = a + MultPI(1 / 2)
a2 = a - MultPI(1 / 2)
x3 = x1 + r1 * COS(a1): y3 = y1 + r1 * SIN(a1)
x4 = x1 + r1 * COS(a2): y4 = y1 + r1 * SIN(a2)
x5 = x2 + r2 * COS(a1): y5 = y2 + r2 * SIN(a1)
x6 = x2 + r2 * COS(a2): y6 = y2 + r2 * SIN(a2)
fquad x3, y3, x4, y4, x5, y5, x6, y6, c
fcirc x1, y1, r1, c
fcirc x2, y2, r2, c
END SUB

'======================================================================
'need 4 non linear points (not all on 1 line) list them clockwise so x2, y2 is opposite of x4, y4
SUB fquad (x1 AS INTEGER, y1 AS INTEGER, x2 AS INTEGER, y2 AS INTEGER, x3 AS INTEGER, y3 AS INTEGER, x4 AS INTEGER, y4 AS INTEGER, c AS _UNSIGNED LONG)
ftri x1, y1, x2, y2, x4, y4, c
ftri x3, y3, x4, y4, x1, y1, c
END SUB

'======================================================================
SUB ftri (x1, y1, x2, y2, x3, y3, K AS _UNSIGNED LONG)
DIM a&
a& = _NEWIMAGE(1, 1, 32)
_DEST a&
PSET (0, 0), K
_DEST 0
_MAPTRIANGLE _SEAMLESS(0, 0)-(0, 0)-(0, 0), a& TO(x1, y1)-(x2, y2)-(x3, y3)
_FREEIMAGE a& '<<< this is important!
END SUB

'======================================================================
SUB fcirc (CX AS INTEGER, CY AS INTEGER, R AS INTEGER, C AS _UNSIGNED LONG)
DIM Radius AS INTEGER, RadiusError AS INTEGER
DIM X AS INTEGER, Y AS INTEGER
Radius = ABS(R): RadiusError = -Radius: X = Radius: Y = 0
IF Radius = 0 THEN PSET (CX, CY), C: EXIT SUB
LINE (CX - X, CY)-(CX + X, CY), C, BF
WHILE X > Y
    RadiusError = RadiusError + Y * 2 + 1
    IF RadiusError >= 0 THEN
        IF X <> Y + 1 THEN
            LINE (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
            LINE (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
        END IF
        X = X - 1
        RadiusError = RadiusError - X * 2
    END IF
    Y = Y + 1
    LINE (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
    LINE (CX - X, CY + Y)-(CX + X, CY + Y), C, BF
WEND
END SUB

'======================================================================
SUB TiltedEllipseFill (destHandle&, x0, y0, a, b, ang, c AS _UNSIGNED LONG)
DIM max AS INTEGER, mx2 AS INTEGER, i AS INTEGER, j AS INTEGER, k AS SINGLE, lasti AS SINGLE, lastj AS SINGLE
DIM prc AS _UNSIGNED LONG, tef AS LONG
prc = _RGBA32(255, 255, 255, 255)
IF a > b THEN max = a + 1 ELSE max = b + 1
mx2 = max + max
tef = _NEWIMAGE(mx2, mx2)
_DEST tef
_SOURCE tef 'point wont read without this!
FOR k = 0 TO 6.2832 + .05 STEP .1
    i = max + a * COS(k) * COS(ang) + b * SIN(k) * SIN(ang)
    j = max + a * COS(k) * SIN(ang) - b * SIN(k) * COS(ang)
    IF k <> 0 THEN
        LINE (lasti, lastj)-(i, j), prc
    ELSE
        PSET (i, j), prc
    END IF
    lasti = i: lastj = j
NEXT
DIM xleft(mx2) AS INTEGER, xright(mx2) AS INTEGER, x AS INTEGER, y AS INTEGER
FOR y = 0 TO mx2
    x = 0
    WHILE POINT(x, y) <> prc AND x < mx2
        x = x + 1
    WEND
    xleft(y) = x
    WHILE POINT(x, y) = prc AND x < mx2
        x = x + 1
    WEND
    WHILE POINT(x, y) <> prc AND x < mx2
        x = x + 1
    WEND
    IF x = mx2 THEN xright(y) = xleft(y) ELSE xright(y) = x
NEXT
_DEST destHandle&
FOR y = 0 TO mx2
    IF xleft(y) <> mx2 THEN LINE (xleft(y) + x0 - max, y + y0 - max)-(xright(y) + x0 - max, y + y0 - max), c, BF
NEXT
_FREEIMAGE tef
END SUB

'=== _ATAN2 replacement for older QB64 versions =======================
FUNCTION ARCTAN2# (y#, x#)
IF y# = 0 THEN
    IF x# >= 0 THEN r# = 0: ELSE r# = 3.141592653589793
ELSE
    IF x# = 0 THEN r# = 1.570796326794896 * SGN(y#): ELSE r# = 2 * ATN(y# / (SQR((x# * x#) + (y# * y#)) + x#))
END IF
ARCTAN2# = r#
END FUNCTION

'=== _PI replacement for older QB64 versions ==========================
FUNCTION ConstPI#
ConstPI# = 3.141592653589793
END FUNCTION

'=== _PI(multiplier) replacement for older QB64 versions ==============
FUNCTION MultPI# (m#)
MultPI# = 3.141592653589793 * m#
END FUNCTION

'=====================================================================
FUNCTION VersionSpinner$
VersionSpinner$ = MID$("$VER: Spinner blanker 1.0 (15-Jun-2019) by bplus & RhoSigma :END$", 7, 53)
END FUNCTION

