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
'| === Lightning.bas ===                                             |
'|                                                                   |
'| == It's a flash thing.                                            |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

DIM SHARED scrX%, scrY%
di& = _SCREENIMAGE
scrX% = _WIDTH(di&)
scrY% = _HEIGHT(di&)
_FREEIMAGE di&
si& = _NEWIMAGE(scrX%, scrY%, 256)
SCREEN si&
_DELAY 0.2: _SCREENMOVE _MIDDLE
_DELAY 0.2: _FULLSCREEN

CONST FORKINESS = 10 '1 to 20
CONST FREQUENCY = 12 '1 to 15

RANDOMIZE TIMER
_PALETTECOLOR 0, _RGB32(0, 0, 0)
_PALETTECOLOR 1, _RGB32(0, 0, 0)
_PALETTECOLOR 2, _RGB32(0, 0, 0)
_PALETTECOLOR 3, _RGB32(0, 0, 0)

_MOUSEHIDE
WHILE INKEY$ = "" AND mx% = 0 AND my% = 0
    CLS
    IF RangeRand%(1, 100) > 50 THEN
        DrawLightning RangeRand%(0, (scrX% / 2)), 0, 50, 0.785398163, 1
    ELSE
        DrawLightning RangeRand%((scrX% / 2), (scrX% - 1)), 0, 50, 2.35619449, 1
    END IF

    i% = RangeRand%(1, 100)
    IF i% < 25 THEN
        j% = 8
        j% = j% + (i% AND 7)
        WHILE j% > 0
            _PALETTECOLOR 1, _RGB32(170, 127, 255)
            _PALETTECOLOR 2, _RGB32(102, 76, 153)
            _PALETTECOLOR 3, _RGB32(34, 25, 51)
            _DISPLAY
            _PALETTECOLOR 1, _RGB32(0, 0, 0)
            _PALETTECOLOR 2, _RGB32(0, 0, 0)
            _PALETTECOLOR 3, _RGB32(0, 0, 0)
            _DISPLAY
            j% = j% - 1
        WEND
    ELSE
        _PALETTECOLOR 1, _RGB32(170, 127, 255)
        _PALETTECOLOR 2, _RGB32(102, 76, 153)
        _PALETTECOLOR 3, _RGB32(34, 25, 51)
        _DISPLAY
        _DELAY 0.1
        _PALETTECOLOR 1, _RGB32(0, 0, 0)
        _PALETTECOLOR 2, _RGB32(0, 0, 0)
        _PALETTECOLOR 3, _RGB32(0, 0, 0)
        _DISPLAY
    END IF

    _DELAY (10 * (20 - FREQUENCY - RangeRand%(0, 3))) * 0.02

    DO WHILE _MOUSEINPUT
        mx% = mx% + _MOUSEMOVEMENTX
        my% = my% + _MOUSEMOVEMENTY
    LOOP
WEND

_FULLSCREEN _OFF
_DELAY 0.2: SCREEN 0
_DELAY 0.2: _FREEIMAGE si&
SYSTEM

'======================================================================
SUB DrawLightning (X&, Y&, Segments&, Dir#, Fork&)
Sign# = 0.392699081
xSeg# = scrX% / (15.0 * Fork&)
ySeg# = scrY% / (15.0 * Fork&)
DO
    Angle& = RangeRand%(0, 100)
    DeltaAngle# = Sign# * Angle& / 100.0
    Dir# = Dir# + DeltaAngle#
    Sign# = Sign# * -1.0

    nX& = X& + (COS(Dir#) * xSeg#)
    nY& = Y& + (SIN(Dir#) * ySeg#)
    DrawLine X&, Y&, nX&, nY&, Fork&
    X& = nX&
    Y& = nY&

    IF ((Fork& < 3) AND (RangeRand%(0, 50) < (FORKINESS / Fork&))) THEN
        DrawLightning (X&), (Y&), 5 + RangeRand%(1, 10), Dir# - (2.0 * DeltaAngle#), Fork& + 1
    END IF
    Segments& = Segments& - 1
LOOP WHILE Segments& > 0 AND Y& < scrY%
END SUB

'======================================================================
SUB DrawLine (x1%, y1%, x2%, y2%, col%)
IF x1% < 0 THEN
    IF x2% < 0 THEN EXIT SUB
    x1% = 0
ELSEIF x1% >= scrX% THEN
    IF x2% >= scrX% THEN EXIT SUB
    x1% = scrX% - 1
END IF
IF y1% < 0 THEN
    IF y2% < 0 THEN EXIT SUB
    y1% = 0
ELSEIF y1% >= scrY% THEN
    IF y2% >= scrY% THEN EXIT SUB
    y1% = scrY% - 1
END IF

IF x2% < 0 THEN
    x2% = 0
ELSEIF x2% >= scrX% THEN
    x2% = scrX% - 1
END IF
IF y2% < 0 THEN
    y2% = 0
ELSEIF y2% >= scrY% THEN
    y2% = scrY% - 1
END IF

LINE (x1%, y1%)-(x2%, y2%), col%
END SUB

'======================================================================
FUNCTION RangeRand% (low%, high%)
RangeRand% = INT(RND(1) * (high% - low% + 1)) + low%
END FUNCTION

'=====================================================================
FUNCTION VersionLightning$
VersionLightning$ = MID$("$VER: Lightning blanker 1.0 (28-Jan-2017) by RhoSigma :END$", 7, 47)
END FUNCTION

