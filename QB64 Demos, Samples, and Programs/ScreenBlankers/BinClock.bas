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
'| === BinClock.bas ===                                              |
'|                                                                   |
'| == A simple binary (BCD) clock inspired by the alien countdown    |
'| == from the movie "Mission to Mars".                              |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

'get desktop sizes
di& = _SCREENIMAGE
desX% = _WIDTH(di&)
desY% = _HEIGHT(di&)
scrX% = _WIDTH(di&): IF scrX% < 875 THEN scrX% = 875
scrY% = _HEIGHT(di&): IF scrY% < 465 THEN scrY% = 465
_FREEIMAGE di&
DIM SHARED scale%, timg&
IF desX% <> scrX% OR desY% <> scrY% THEN scale% = -1: ELSE scale% = 0

'setup screen
SCREEN _NEWIMAGE(desX%, desY%, 256)
_DELAY 0.2: _SCREENMOVE _MIDDLE
_DELAY 0.2: _FULLSCREEN
IF scale% THEN
    timg& = _NEWIMAGE(scrX%, scrY%, 256)
    IF timg& < -1 THEN _DEST timg&: ELSE SYSTEM
END IF
scrFont& = _LOADFONT("C:\Windows\Fonts\timesbd.ttf", 72)
_FONT scrFont&

'3D space origin is on these screen coordinates
DIM SHARED dx%: dx% = (scrX% - 875) \ 2
DIM SHARED dy%: dy% = (scrY% - 465) \ 2
DIM SHARED cx%: cx% = 30 + dx%
DIM SHARED cy%: cy% = 250 + dy%

'init BCD discs
TYPE Disc
    x AS INTEGER
    y AS INTEGER
    z AS INTEGER
    r AS INTEGER
    a AS INTEGER
END TYPE
DIM SHARED Discs(23) AS Disc
InitDiscs
DIM SHARED curState&: curState& = 0
DIM SHARED newState&: newState& = 0

'draw hour/minute/seconds separators
Line3D 175, 0, 0, 175, 440, 0, 2
Line3D 175, 0, 0, 175, 0, -110, 2
Line3D 425, 0, 0, 425, 440, 0, 2
Line3D 425, 0, 0, 425, 0, -110, 2

'main loop
_MOUSEHIDE
_DISPLAY
DO
    _LIMIT 1
    FlipDiscs
    DO WHILE _MOUSEINPUT
        mx% = mx% + _MOUSEMOVEMENTX
        my% = my% + _MOUSEMOVEMENTY
    LOOP
LOOP WHILE INKEY$ = "" AND mx% = 0 AND my% = 0
_AUTODISPLAY

'cleanup
_FONT 16
_FREEFONT scrFont&
IF scale% THEN _FREEIMAGE timg&
SYSTEM

'run the clock
SUB FlipDiscs
t$ = TIME$
newState& = (VAL(MID$(t$, 1, 1)) * (2 ^ 20)) + (VAL(MID$(t$, 2, 1)) * (2 ^ 16)) +_
            (VAL(MID$(t$, 4, 1)) * (2 ^ 12)) + (VAL(MID$(t$, 5, 1)) * (2 ^ 8)) +_
            (VAL(MID$(t$, 7, 1)) * (2 ^ 4)) + (VAL(MID$(t$, 8, 1)) * (2 ^ 0))
diff& = curState& XOR newState&
curState& = newState&
FOR rot% = 5 TO 90 STEP 5
    FOR n% = 0 TO 23
        IF (n% MOD 4) = 0 THEN AxisSegments Discs(n%).x
        IF diff& AND (2 ^ n%) THEN
            Circle3D Discs(n%).x, Discs(n%).y, Discs(n%).z, Discs(n%).r, Discs(n%).a, 0
            Circle3D Discs(n%).x, Discs(n%).y, Discs(n%).z, Discs(n%).r, Discs(n%).a + 5, 15
            Discs(n%).a = Discs(n%).a + 5
            IF Discs(n%).a = 180 THEN Discs(n%).a = 0
        ELSE
            Circle3D Discs(n%).x, Discs(n%).y, Discs(n%).z, Discs(n%).r, Discs(n%).a, 15
        END IF
    NEXT n%
    IF rot% = 60 THEN
        COLOR 1
        _PRINTSTRING (50 + dx%, 280 + dy%), MID$(t$, 1, 2)
        _PRINTSTRING (300 + dx%, 280 + dy%), MID$(t$, 4, 2)
        _PRINTSTRING (550 + dx%, 280 + dy%), MID$(t$, 7, 2)
        _PRINTSTRING (300 - _PRINTWIDTH(LEFT$(DATE$, 4)) + dx%, 380 + dy%), DATE$
    END IF
    IF scale% THEN _PUTIMAGE , timg&, 0
    _DISPLAY
NEXT rot%
END SUB

'setup start values for all discs
SUB InitDiscs
n% = 0
FOR i% = 600 TO 500 STEP -100
    FOR j% = 70 TO 370 STEP 100
        Discs(n%).x = i%
        Discs(n%).y = j%
        Discs(n%).z = 0
        Discs(n%).r = 30
        Discs(n%).a = 0
        n% = n% + 1
    NEXT j%
NEXT i%
FOR i% = 350 TO 250 STEP -100
    FOR j% = 70 TO 370 STEP 100
        Discs(n%).x = i%
        Discs(n%).y = j%
        Discs(n%).z = 0
        Discs(n%).r = 30
        Discs(n%).a = 0
        n% = n% + 1
    NEXT j%
NEXT i%
FOR i% = 100 TO 0 STEP -100
    FOR j% = 70 TO 370 STEP 100
        Discs(n%).x = i%
        Discs(n%).y = j%
        Discs(n%).z = 0
        Discs(n%).r = 30
        Discs(n%).a = 0
        n% = n% + 1
    NEXT j%
NEXT i%
END SUB

'draw rotation axis segments between discs
SUB AxisSegments (x%)
Line3D x%, 0, 0, x%, 40, 0, 4
Line3D x%, 100, 0, x%, 140, 0, 4
Line3D x%, 200, 0, x%, 240, 0, 4
Line3D x%, 300, 0, x%, 340, 0, 4
Line3D x%, 400, 0, x%, 440, 0, 4
END SUB

SUB Line3D (x1%, y1%, z1%, x2%, y2%, z2%, col%)
'x1%/y1%/z1% = start, x2%/y2%/z2% = end, col% = color pen
x1# = (x1% + (y1% * 0.5)): z1# = (z1% + (y1% * 0.5))
x2# = (x2% + (y2% * 0.5)): z2# = (z2% + (y2% * 0.5))
LINE (x1# + cx% - 1, -z1# + cy%)-(x2# + cx% - 1, -z2# + cy%), col%
LINE (x1# + cx%, -z1# + cy%)-(x2# + cx%, -z2# + cy%), col%
LINE (x1# + cx% + 1, -z1# + cy%)-(x2# + cx% + 1, -z2# + cy%), col%
END SUB

SUB Circle3D (x%, y%, z%, r%, ba%, col%)
'x%/y%/z% = center, r% = radius, ba% = B-Axis angle, col% = color pen
mx# = (x% + (y% * 0.5)): mz# = (z% + (y% * 0.5))
zx# = r% * COS(ba% * 0.017453292519943)
zz# = r% * SIN(ba% * 0.017453292519943)
FOR cir% = 0 TO 359 STEP 5
    x# = zx# * COS(cir% * 0.017453292519943)
    y# = r% * SIN(cir% * 0.017453292519943)
    z# = zz# * COS(cir% * 0.017453292519943)
    x# = (x# + (y# * 0.5)): z# = (z# + (y# * 0.5))
    LINE (x# + mx# + cx% - 1, -z# + -mz# + cy% - 1)-(x# + mx# + cx% + 1, -z# + -mz# + cy% + 1), col%, BF
NEXT cir%
END SUB

'=====================================================================
FUNCTION VersionBinClock$
VersionBinClock$ = MID$("$VER: BinClock blanker 1.0 (10-Sep-2018) by RhoSigma :END$", 7, 46)
END FUNCTION

