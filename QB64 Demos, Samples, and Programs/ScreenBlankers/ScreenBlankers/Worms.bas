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
'| === Worms.bas ===                                                 |
'|                                                                   |
'| == A lot of very hungry worms are eating your delicious Desktop   |
'| == and will only leave some dark slimy traces.                    |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

di& = _SCREENIMAGE
scrX% = _WIDTH(di&)
scrY% = _HEIGHT(di&)
SCREEN di&
_DELAY 0.2: _SCREENMOVE _MIDDLE
_DELAY 0.2: _FULLSCREEN

CONST MAX_WORMS = 25
CONST MAX_TAIL = 30
CONST WORM_RAD = 4

TYPE Worm
    cx AS INTEGER
    cy AS INTEGER
    cc AS LONG
    cd AS INTEGER
END TYPE
DIM Worms(MAX_WORMS - 1) AS Worm
DIM ox%(MAX_WORMS - 1, MAX_TAIL - 1)
DIM oy%(MAX_WORMS - 1, MAX_TAIL - 1)
l% = MAX_TAIL

RANDOMIZE TIMER
FOR i% = 0 TO MAX_WORMS - 1
    Worms(i%).cx = scrX% \ 2
    Worms(i%).cy = scrY% \ 2
    Worms(i%).cc = HSBA32~&((RangeRand%(0, 360) AND &HFFF0~&), 85, 90, 96)
    Worms(i%).cd = (RangeRand%(90, 420) \ 30) * 30
NEXT i%

_MOUSEHIDE
WHILE INKEY$ = "" AND mx% = 0 AND my% = 0
    FOR i% = 0 TO MAX_WORMS - 1
        IF l% = 0 THEN LINE (ox%(i%, 0) - WORM_RAD, oy%(i%, 0) - WORM_RAD)-(ox%(i%, 0) + WORM_RAD, oy%(i%, 0) + WORM_RAD), &HE0000000~&, BF
        LINE (Worms(i%).cx - WORM_RAD, Worms(i%).cy - WORM_RAD)-(Worms(i%).cx + WORM_RAD, Worms(i%).cy + WORM_RAD), Worms(i%).cc, BF
        LINE (Worms(i%).cx - WORM_RAD, Worms(i%).cy - WORM_RAD)-(Worms(i%).cx + WORM_RAD, Worms(i%).cy + WORM_RAD), &H60000000~&, B
        ox%(i%, MAX_TAIL - 1) = Worms(i%).cx
        oy%(i%, MAX_TAIL - 1) = Worms(i%).cy
        IF RangeRand%(1, 100) AND 1 THEN
            od% = Worms(i%).cd
            DO
                nd% = (RangeRand%(90, 420) \ 30) * 30
            LOOP WHILE nd% < (od% - 30) OR nd% > (od% + 30)
            Worms(i%).cd = nd%
        END IF
        Worms(i%).cx = Worms(i%).cx + PolToCartX%(Worms(i%).cd, WORM_RAD + (WORM_RAD \ 5))
        Worms(i%).cy = Worms(i%).cy + PolToCartY%(Worms(i%).cd, WORM_RAD + (WORM_RAD \ 5))
        IF Worms(i%).cx < 0 THEN Worms(i%).cx = scrX%
        IF Worms(i%).cx > scrX% THEN Worms(i%).cx = 0
        IF Worms(i%).cy < 0 THEN Worms(i%).cy = scrY%
        IF Worms(i%).cy > scrY% THEN Worms(i%).cy = 0
    NEXT i%
    IF l% > 0 THEN l% = l% - 1
    FOR i% = 0 TO MAX_WORMS - 1
        FOR j% = 1 TO MAX_TAIL - 1
            ox%(i%, j% - 1) = ox%(i%, j%)
            oy%(i%, j% - 1) = oy%(i%, j%)
        NEXT j%
    NEXT i%

    _LIMIT 30
    _DISPLAY
    DO WHILE _MOUSEINPUT
        mx% = mx% + _MOUSEMOVEMENTX
        my% = my% + _MOUSEMOVEMENTY
    LOOP
WEND

_FULLSCREEN _OFF
_DELAY 0.2: SCREEN 0
_DELAY 0.2: _FREEIMAGE di&
SYSTEM

'=== RS:COPYFROM:converthelper.bm/PolToCartX% (original) =============
FUNCTION PolToCartX% (ang!, rad!)
PolToCartX% = CINT(rad! * COS(ang! * 0.017453292519943))
END FUNCTION

'=== RS:COPYFROM:converthelper.bm/PolToCartY% (original) =============
FUNCTION PolToCartY% (ang!, rad!)
PolToCartY% = CINT(rad! * SIN(ang! * 0.017453292519943))
END FUNCTION

'=== RS:COPYFROM:converthelper.bm/HSB32~& (--OPT_EX) =================
FUNCTION HSB32~& (hue!, sat!, bri!)
IF hue! < 0 THEN hue! = 0: ELSE IF hue! > 360 THEN hue! = 360
IF sat! < 0 THEN sat! = 0: ELSE IF sat! > 100 THEN sat! = 100
IF bri! < 0 THEN bri! = 0: ELSE IF bri! > 100 THEN bri! = 100
HSBtoRGB CLNG(hue! * 182.041666666666666#), CLNG(sat! * 655.35#), CLNG(bri! * 655.35#), red~&, gre~&, blu~&
HSB32~& = _RGB32(red~& \ 256, gre~& \ 256, blu~& \ 256)
END FUNCTION

'=== RS:COPYFROM:converthelper.bm/HSBA32~& (--OPT_EX) ================
FUNCTION HSBA32~& (hue!, sat!, bri!, alp%)
IF hue! < 0 THEN hue! = 0: ELSE IF hue! > 360 THEN hue! = 360
IF sat! < 0 THEN sat! = 0: ELSE IF sat! > 100 THEN sat! = 100
IF bri! < 0 THEN bri! = 0: ELSE IF bri! > 100 THEN bri! = 100
HSBtoRGB CLNG(hue! * 182.041666666666666#), CLNG(sat! * 655.35#), CLNG(bri! * 655.35#), red~&, gre~&, blu~&
HSBA32~& = _RGBA32(red~& \ 256, gre~& \ 256, blu~& \ 256, alp%)
END FUNCTION

'=== RS:COPYFROM:converthelper.bm/HSBtoRGB (--OPT_EX) ================
SUB HSBtoRGB (hue~&, sat~&, bri~&, red~&, gre~&, blu~&)
IF sat~& = 0 THEN
    red~& = bri~&: gre~& = bri~&: blu~& = bri~&
ELSE
    v~& = bri~&
    i~& = hue~& \ 10923 '(65535 \ 6) + 1
    f~& = (hue~& MOD 10923) * 6 '(65535 \ 6) + 1
    f~& = f~& + (f~& \ 16384) '(65536 \ 4)

    p~& = bri~& * (65535 - sat~&) \ 65536
    q~& = bri~& * (65535 - ((sat~& * f~&) \ 65536)) \ 65536
    t~& = bri~& * (65535 - ((sat~& * (65535 - f~&)) \ 65536)) \ 65536

    SELECT CASE i~&
        CASE 0: red~& = v~&: gre~& = t~&: blu~& = p~&
        CASE 1: red~& = q~&: gre~& = v~&: blu~& = p~&
        CASE 2: red~& = p~&: gre~& = v~&: blu~& = t~&
        CASE 3: red~& = p~&: gre~& = q~&: blu~& = v~&
        CASE 4: red~& = t~&: gre~& = p~&: blu~& = v~&
        CASE 5: red~& = v~&: gre~& = p~&: blu~& = q~&
    END SELECT
END IF
END SUB

'=====================================================================
FUNCTION RangeRand% (low%, high%)
RangeRand% = INT(RND(1) * (high% - low% + 1)) + low%
END FUNCTION

'=====================================================================
FUNCTION VersionWorms$
VersionWorms$ = MID$("$VER: Worms blanker 1.0 (06-Feb-2017) by RhoSigma :END$", 7, 43)
END FUNCTION

