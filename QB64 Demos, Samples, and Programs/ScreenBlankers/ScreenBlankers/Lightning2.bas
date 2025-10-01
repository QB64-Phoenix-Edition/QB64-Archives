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
'| === Lightning2.bas ===                                            |
'|                                                                   |
'| == The result of joint efforts by bplus, TylerDarko and myself.   |
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
si& = _NEWIMAGE(scrX%, scrY%, 32)
SCREEN si&
_DELAY 0.2: _SCREENMOVE _MIDDLE
_DELAY 0.2: _FULLSCREEN

CONST FORKINESS = 15 '1 to 20

DIM SHARED scrX2%, scrX10%, scrXE%
DIM SHARED scrY4%, scrY6%, scrYE%
scrX2% = scrX% \ 2: scrX10% = scrX% \ 10: scrXE% = scrX% - 1
scrY4% = scrY% \ 4: scrY6% = scrY% \ 6: scrYE% = scrY% - 1

RANDOMIZE TIMER
flash& = _NEWIMAGE(scrX%, scrY%, 32)
land& = _NEWIMAGE(scrX%, scrY%, 32)
_DEST land&
DrawLandscape 6
_DEST 0

_MOUSEHIDE
WHILE INKEY$ = "" AND mx% = 0 AND my% = 0
    _PUTIMAGE , land&
    _DEST flash&
    CLS , _RGBA32(0, 0, 0, 0)
    SELECT CASE RangeRand%(0, 180)
        CASE 0 TO 35
            DrawLightning scrXE%, RangeRand%(25, scrY6%), 50, 2.748893571, 1
        CASE 36 TO 71
            DrawLightning RangeRand%(scrX2% + scrX10%, scrXE%), 0, 50, 1.963495408, 1
        CASE 72 TO 107
            DrawLightning RangeRand%(scrX2% - scrX10%, scrX2% + scrX10%), 0, 50, 1.570796326, 1
        CASE 108 TO 144
            DrawLightning RangeRand%(0, scrX2% - scrX10%), 0, 50, 1.178097245, 1
        CASE 145 TO 180
            DrawLightning 0, RangeRand%(25, scrY6%), 50, 0.392699081, 1
    END SELECT
    _DEST 0
    _PUTIMAGE , flash&
    _DISPLAY
    _DELAY 0.05
    pulse% = RangeRand%(0, 3)
    FOR fade% = 1 TO 24
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA32(0, 0, 0, 25), BF
        IF fade% > 4 AND fade% < 8 AND pulse% > 0 AND RangeRand%(1, 100) > 50 THEN
            _PUTIMAGE , land&
            _PUTIMAGE , flash&
            pulse% = pulse% - 1
            fade% = 0
        END IF
        _DISPLAY
        _LIMIT 80
    NEXT fade%
    _PUTIMAGE , land&
    FOR fade% = 1 TO 24
        LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA32(0, 0, 0, 25), BF
    NEXT fade%
    _DISPLAY

    _DELAY RangeRand%(50, 2000) / 1000 '<< milliseconds to next lightning

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
SUB DrawLandscape (hills%)
'--- sky ---
FOR i% = 0 TO scrY%
    LINE (0, i%)-(scrX%, i%), _RGB32(128 * (i% / scrY%), 128 * (i% / scrY%), 128 * (i% / scrY%))
NEXT i%
'--- land ---
startH# = scrY% - scrY4%
rr% = 70: gg% = 70: bb% = 90
FOR hill% = 1 TO hills%
    Xright# = 0
    y# = startH#
    WHILE Xright# < scrX%
        'upDown# = local up / down over range, change along Y
        'range#  = how far up / down, along X
        upDown# = ((RND(1) * 0.8) - 0.35) * (hill% * 0.5)
        range# = Xright# + RangeRand%(15, 25) * (2.5 / hill%)
        lastX# = Xright# - 1
        FOR x# = Xright# TO range#
            y# = y# + upDown#
            LINE (lastX#, y#)-(x#, scrY%), _RGB32(rr%, gg%, bb%), BF 'just lines weren't filling right
            lastX# = x#
        NEXT x#
        Xright# = range#
    WEND
    rr% = RangeRand%(rr% - 15, rr%): IF rr% < 0 THEN rr% = 0
    gg% = RangeRand%(gg% - 15, gg%): IF gg% < 0 THEN gg% = 0
    bb% = RangeRand%(bb% - 25, bb%): IF bb% < 0 THEN bb% = 0
    startH# = startH# + RangeRand%(5, 20)
NEXT hill%
END SUB

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
    DrawLine X&, Y&, nX&, nY&, _RGBA32(RangeRand%(160, 180), _
                                       RangeRand%(117, 137), _
                                       RangeRand%(235, 255), _
                                       75 + (180 \ Fork&))
    X& = nX&
    Y& = nY&

    IF ((Fork& < 3) AND (RangeRand%(0, 50) < (FORKINESS \ Fork&))) THEN
        DrawLightning (X&), (Y&), 5 + RangeRand%(1, 10), Dir# - (2.0 * DeltaAngle#), Fork& + 1
    END IF
    Segments& = Segments& - 1
LOOP WHILE Segments& > 0 AND Y& < scrY% - RangeRand%(75, scrY4% - 50)
END SUB

'======================================================================
SUB DrawLine (x1%, y1%, x2%, y2%, col&)
IF x1% < 0 THEN
    IF x2% < 0 THEN EXIT SUB
    x1% = 0
ELSEIF x1% >= scrX% THEN
    IF x2% >= scrX% THEN EXIT SUB
    x1% = scrXE%
END IF
IF y1% < 0 THEN
    IF y2% < 0 THEN EXIT SUB
    y1% = 0
ELSEIF y1% >= scrY% THEN
    IF y2% >= scrY% THEN EXIT SUB
    y1% = scrYE%
END IF

IF x2% < 0 THEN
    x2% = 0
ELSEIF x2% >= scrX% THEN
    x2% = scrXE%
END IF
IF y2% < 0 THEN
    y2% = 0
ELSEIF y2% >= scrY% THEN
    y2% = scrYE%
END IF

LINE (x1%, y1%)-(x2%, y2%), col&
END SUB

'======================================================================
FUNCTION RangeRand% (low%, high%)
RangeRand% = INT(RND(1) * (high% - low% + 1)) + low%
END FUNCTION

'=====================================================================
FUNCTION VersionLightning2$
VersionLightning2$ = MID$("$VER: Lightning2 blanker 1.0 (08-Feb-2017) by RhoSigma, bplus & TylerDarko :END$", 7, 68)
END FUNCTION

