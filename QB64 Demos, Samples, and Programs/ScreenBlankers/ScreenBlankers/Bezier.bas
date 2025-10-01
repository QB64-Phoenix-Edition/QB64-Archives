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
'| === Bezier.bas ===                                                |
'|                                                                   |
'| == Similar to the Spline.bas screen blanker, this one also draws  |
'| == splines, Bezier curves to be exact. But it will also show the  |
'| == math behind it, hence the polygons which by solving it down to |
'| == first degree result into the final spline point to draw.       |
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
ti& = _NEWIMAGE(scrX%, scrY%, 256)
SCREEN si&
_DELAY 0.2: _SCREENMOVE _MIDDLE
_DELAY 0.2: _FULLSCREEN

CONST MAX_DEGREE = 10 '2 to 20

TYPE point
    x AS DOUBLE
    y AS DOUBLE
    s AS INTEGER
END TYPE
REDIM spans(0 TO 1) AS point

_MOUSEHIDE
WHILE INKEY$ = "" AND mx% = 0 AND my% = 0
    _DEST ti&: CLS
    _DEST 0: CLS

    RANDOMIZE TIMER
    np% = RangeRand%(2, MAX_DEGREE)
    REDIM points(0 TO np%) AS point
    FOR i% = 0 TO np%
        points(i%).x = RangeRand%(20, scrX% - 20)
        points(i%).y = RangeRand%(20, scrY% - 20)
    NEXT i%

    f# = 0: st# = 0.0001: done% = 0
    DO
        _LIMIT 20 / st# * 0.005
        IF f# > 1 THEN f# = 1: done% = -1

        CalcFracPoints points(), spans(), f#
        _DEST ti&
        x# = spans(UBOUND(spans)).x
        y# = spans(UBOUND(spans)).y
        IF c% < 32 OR c% > 56 THEN c% = 32
        CIRCLE (x#, y#), 1, c%
        CIRCLE (x#, y#), 2, c%
        CIRCLE (x#, y#), 3, c%
        c% = c% + 1
        _DEST 0
        CLS
        _PUTIMAGE , ti&
        DrawLines points(), &HFFFF
        DrawLines spans(), &B1001100110011001
        FOR i% = LBOUND(spans) TO UBOUND(spans) - 1
            CIRCLE (spans(i%).x, spans(i%).y), 1, 14
            CIRCLE (spans(i%).x, spans(i%).y), 2, 14
        NEXT i%
        CIRCLE (x#, y#), 1, 4
        CIRCLE (x#, y#), 2, 4
        CIRCLE (x#, y#), 3, 12
        CIRCLE (x#, y#), 4, 15
        CIRCLE (x#, y#), 5, 15
        _DISPLAY

        IF ox# <> 0 THEN
            IF ABS(ox# - x#) > 3 OR ABS(oy# - y#) > 3 THEN
                st# = st# / 2
            ELSEIF ABS(ox# - x#) < 2 OR ABS(oy# - y#) < 2 THEN
                st# = st# * 2
            END IF
            IF st# > 0.005 THEN st# = 0.005
        END IF
        ox# = x#: oy# = y#
        f# = f# + st#

        DO WHILE _MOUSEINPUT
            mx% = mx% + _MOUSEMOVEMENTX
            my% = my% + _MOUSEMOVEMENTY
        LOOP
        IF INKEY$ <> "" OR mx% + my% <> 0 THEN EXIT WHILE
    LOOP UNTIL done%

    done% = 50: mx% = 0: my% = 0
    DO
        _LIMIT 20
        DO WHILE _MOUSEINPUT
            mx% = mx% + _MOUSEMOVEMENTX
            my% = my% + _MOUSEMOVEMENTY
        LOOP
        IF INKEY$ <> "" OR mx% + my% <> 0 THEN EXIT WHILE
        done% = done% - 1
    LOOP WHILE done%

    _PUTIMAGE , ti&
    _DISPLAY

    done% = 100: mx% = 0: my% = 0
    DO
        _LIMIT 20
        col~& = _PALETTECOLOR(56)
        FOR i% = 56 TO 33 STEP -1
            _PALETTECOLOR i%, _PALETTECOLOR(i% - 1)
        NEXT i%
        _PALETTECOLOR 32, col~&
        _DISPLAY
        DO WHILE _MOUSEINPUT
            mx% = mx% + _MOUSEMOVEMENTX
            my% = my% + _MOUSEMOVEMENTY
        LOOP
        IF INKEY$ <> "" OR mx% + my% <> 0 THEN EXIT WHILE
        done% = done% - 1
    LOOP WHILE done%
WEND

_FULLSCREEN _OFF
_DELAY 0.2: SCREEN 0
_DELAY 0.2: _FREEIMAGE ti&
_DELAY 0.2: _FREEIMAGE si&
SYSTEM

'=====================================================================
SUB CalcFracPoints (pIn() AS point, pOut() AS point, frac#)
iLns% = UBOUND(pIn) - LBOUND(pIn) 'no +1 here, as lines = 1 less than points
oPts% = (iLns% * (iLns% + 1)) / 2 'sum up 1 to n, which is n*(n+1)/2
REDIM pOut(0 TO oPts% - 1) AS point

p% = 0
FOR i% = LBOUND(pIn) TO UBOUND(pIn) - 1
    pOut(p%).x = pIn(i%).x + frac# * (pIn(i% + 1).x - pIn(i%).x)
    pOut(p%).y = pIn(i%).y + frac# * (pIn(i% + 1).y - pIn(i%).y)
    p% = p% + 1
NEXT i%
pOut(p% - 1).s = -1 'stop flag for drawing

FOR j% = iLns% TO 2 STEP -1
    FOR i% = p% - j% TO p% - 2
        pOut(p%).x = pOut(i%).x + frac# * (pOut(i% + 1).x - pOut(i%).x)
        pOut(p%).y = pOut(i%).y + frac# * (pOut(i% + 1).y - pOut(i%).y)
        p% = p% + 1
    NEXT i%
    pOut(p% - 1).s = -1 'stop flag for drawing
NEXT j%
END SUB

'=====================================================================
SUB DrawLines (pIn() AS point, sty%)
col~& = 1
FOR i% = LBOUND(pIn) TO UBOUND(pIn) - 1
    LINE (pIn(i%).x, pIn(i%).y)-(pIn(i% + 1).x, pIn(i% + 1).y), col~&, , sty%
    IF pIn(i% + 1).s THEN
        col~& = (col~& + 1) AND 15
        i% = i% + 1 'skip to next sequence
    END IF
NEXT i%
END SUB

'=====================================================================
FUNCTION RangeRand% (low%, high%)
RangeRand% = INT(RND(1) * (high% - low% + 1)) + low%
END FUNCTION

'=====================================================================
FUNCTION VersionBezier$
VersionBezier$ = MID$("$VER: Bezier blanker 1.0 (07-Jul-2021) by RhoSigma :END$", 7, 44)
END FUNCTION

