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
'| === Splines.bas ===                                               |
'|                                                                   |
'| == Similar to the Mystify screen blanker, but adds Splines.       |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

DIM SHARED scrw%, scrh%
di& = _SCREENIMAGE
scrw% = _WIDTH(di&)
scrh% = _HEIGHT(di&)
_FREEIMAGE di&
si& = _NEWIMAGE(scrw%, scrh%, 256)
SCREEN si&
_DELAY 0.2: _SCREENMOVE _MIDDLE
_DELAY 0.2: _FULLSCREEN

CONST MAX_LINES = 30 'at least 1 !!!
CONST MAX_POINTS = 20 'at least 16 !!!
CONST ANIM_INTERVAL = 15 'change anim type every n seconds

DIM SHARED storex%(MAX_LINES - 1, MAX_POINTS - 1)
DIM SHARED storey%(MAX_LINES - 1, MAX_POINTS - 1)
DIM SHARED ptr%, eptr%
DIM SHARED numLines%, mdelta%, maxLines%
mdelta% = -1: maxLines% = MAX_LINES \ 2
DIM SHARED maxPoints%
DIM SHARED dx%(MAX_POINTS - 1), dy%(MAX_POINTS - 1)
DIM SHARED ox%(MAX_POINTS - 1), oy%(MAX_POINTS - 1)
DIM SHARED nx%(MAX_POINTS - 1), ny%(MAX_POINTS - 1)
DIM SHARED dr%, dg%, db%
DIM SHARED nr%, ng%, nb%
DIM SHARED animTimeout%
DIM SHARED closed%
DIM SHARED nextlegal$(9)
nextlegal$(0) = "01458": nextlegal$(1) = "236": nextlegal$(2) = "01458"
nextlegal$(3) = "236": nextlegal$(4) = "01458": nextlegal$(5) = "23"
nextlegal$(6) = "01458": nextlegal$(7) = "": nextlegal$(8) = "0145"
nextlegal$(9) = ""
DIM SHARED advval%(9)
advval%(0) = 3: advval%(1) = 2: advval%(2) = 3: advval%(3) = 2: advval%(4) = 1
advval%(5) = 0: advval%(6) = 1: advval%(7) = 0: advval%(8) = 1: advval%(9) = 0
DIM SHARED realfunc%(13)

DIM SHARED sp&
sp& = 1000
DIM SHARED stack&(sp& - 1)
DIM SHARED oldx&, oldy&

RANDOMIZE TIMER
animTimeout% = 0
COLOR 1
MakeFunc
StartLines
Colors
_MOUSEHIDE
ON TIMER(1) GOSUB raiseTimeout
TIMER ON
WHILE INKEY$ = "" AND mx% = 0 AND my% = 0

    AdvanceLines
    DrawNew
    Colors

    IF animTimeout% >= ANIM_INTERVAL THEN
        RANDOMIZE TIMER
        animTimeout% = 0
        MakeFunc
        CLS
        StartLines
    END IF

    _LIMIT 60
    _DISPLAY
    DO WHILE _MOUSEINPUT
        mx% = mx% + _MOUSEMOVEMENTX
        my% = my% + _MOUSEMOVEMENTY
    LOOP
WEND
TIMER OFF

_FULLSCREEN _OFF
_DELAY 0.2: SCREEN 0
_DELAY 0.2: _FREEIMAGE si&
SYSTEM

raiseTimeout:
animTimeout% = animTimeout% + 1
RETURN

'======================================================================
SUB StartLines
ptr% = 0
eptr% = 0
numLines% = 0
IF dx%(0) = 0 THEN
    FOR i% = 0 TO MAX_POINTS - 1
        ox%(i%) = RangeRand%(0, scrw% - 1)
        oy%(i%) = RangeRand%(0, scrh% - 1)
        dx%(i%) = RangeRand%(4, 7)
        dy%(i%) = RangeRand%(4, 7)
    NEXT i%
END IF

nr% = 53
ng% = 33
nb% = 35
dr% = -3
dg% = 5
db% = 7
_PALETTECOLOR 1, _RGB32(nr%, ng%, nb%)

FOR i% = 0 TO maxLines% - 1
    AdvanceLines
    DrawNew
NEXT i%
END SUB

'======================================================================
SUB AdvanceLines
FOR i% = 0 TO maxPoints% - 1
    Adv ox%(i%), dx%(i%), nx%(i%), scrw%
    Adv oy%(i%), dy%(i%), ny%(i%), scrh%
NEXT i%
END SUB

'======================================================================
SUB DrawNew
WHILE numLines% >= maxLines%
    COLOR 0
    bptr% = eptr%
    DrawFunc bptr%
    COLOR 1
    numLines% = numLines% - 1
    bptr% = bptr% + 1
    IF bptr% = MAX_LINES THEN bptr% = 0
    eptr% = bptr%
WEND

bptr% = ptr%
FOR i% = 0 TO maxPoints% - 1
    ox%(i%) = nx%(i%)
    storex%(bptr%, i%) = ox%(i%)
    oy%(i%) = ny%(i%)
    storey%(bptr%, i%) = oy%(i%)
NEXT i%

DrawFunc bptr%
numLines% = numLines% + 1
bptr% = bptr% + 1
IF bptr% = MAX_LINES THEN
    bptr% = 0
    IF mdelta% = 1 THEN
        maxLines% = maxLines% + 1
        IF maxLines% >= MAX_LINES - 1 THEN mdelta% = -1
    ELSE
        maxLines% = maxLines% - 1
        IF maxLines% <= 2 THEN mdelta% = 1
    END IF
END IF
ptr% = bptr%
END SUB

'======================================================================
SUB MakeFunc
closed% = RangeRand%(0, 3)
SELECT CASE closed%
    CASE 3: closed% = 2: goallen% = RangeRand%(3, 6)
    CASE 2: goallen% = RangeRand%(3, 6)
    CASE 1: goallen% = RangeRand%(4, 10)
    CASE 0: goallen% = RangeRand%(2, 9)
END SELECT

DO
    IF closed% = 0 THEN nextpossib$ = "0145": ELSE nextpossib$ = "0123456"

    sofar% = 0: p% = 0
    WHILE sofar% < goallen%
        i% = ASC(MID$(nextpossib$, RangeRand%(1, LEN(nextpossib$)), 1)) - 48
        realfunc%(p%) = i%
        p% = p% + 1
        nextpossib$ = nextlegal$(i%)
        sofar% = sofar% + advval%(i%)
    WEND

    IF sofar% = goallen% THEN
        IF closed% = 0 THEN
            IF LEFT$(nextpossib$, 1) = "0" THEN EXIT DO
        ELSE
            IF (LEFT$(nextpossib$, 1) = "0") OR (realfunc%(0) < 4) OR (realfunc%(p% - 1) < 4) THEN
                IF ((LEFT$(nextpossib$, 1) = "0") AND ((realfunc%(0) AND 2) <> 0)) OR ((LEFT$(nextpossib$, 1) <> "0") AND ((realfunc%(0) AND 2) = 0)) THEN
                    IF realfunc%(0) <> 5 THEN
                        realfunc%(0) = realfunc%(0) ^ 2
                        EXIT DO
                    END IF
                ELSE
                    EXIT DO
                END IF
            END IF
        END IF
    END IF
LOOP

realfunc%(p%) = 100
maxPoints% = goallen%
SELECT CASE closed%
    CASE 2
        FOR i% = 0 TO p% - 1
            realfunc%(p% + i%) = realfunc%(i%)
        NEXT i%
        realfunc%(p% + i%) = 100
    CASE 0
        maxPoints% = maxPoints% + 1
END SELECT
END SUB

'======================================================================
SUB DrawFunc (bptr%)
SELECT CASE closed%
    CASE 2
        FOR i% = 0 TO maxPoints% - 1
            storex%(bptr%, maxPoints% + i%) = scrw% - 1 - storex%(bptr%, i%)
            storey%(bptr%, maxPoints% + i%) = scrh% - 1 - storey%(bptr%, i%)
        NEXT i%
        GOSUB setup
    CASE 1
        i% = 0
        GOSUB setup
END SELECT

p% = 0: i% = 0
WHILE realfunc%(p%) < 10
    SELECT CASE realfunc%(p%)
        CASE 0: DrawSF bptr%, i%
        CASE 1: DrawS_F bptr%, i%
        CASE 2: Draw_SF bptr%, i%
        CASE 3: Draw_S_F bptr%, i%
        CASE 4: DrawLF bptr%, i%
        CASE 5: DrawL_F bptr%, i%
        CASE 6: Draw_LF bptr%, i%
    END SELECT
    i% = i% + advval%(realfunc%(p%))
    p% = p% + 1
WEND
IF p% = 0 THEN animTimeout% = ANIM_INTERVAL 'skip null random loop
EXIT SUB
setup:
storex%(bptr%, maxPoints% + i%) = storex%(bptr%, 0)
storey%(bptr%, maxPoints% + i%) = storey%(bptr%, 0)
storex%(bptr%, maxPoints% + i% + 1) = storex%(bptr%, 1)
storey%(bptr%, maxPoints% + i% + 1) = storey%(bptr%, 1)
RETURN
END SUB

'======================================================================
SUB DrawSF (l%, p%)
oldx& = storex%(l%, p% + 0)
oldy& = storey%(l%, p% + 0)
DrawSpline storex%(l%, p%+0) * 128, storey%(l%, p%+0) * 128,_
           storex%(l%, p%+1) * 128, storey%(l%, p%+1) * 128,_
           storex%(l%, p%+2) * 128, storey%(l%, p%+2) * 128,_
           storex%(l%, p%+3) * 128, storey%(l%, p%+3) * 128
END SUB

'======================================================================
SUB DrawS_F (l%, p%)
oldx& = storex%(l%, p% + 0)
oldy& = storey%(l%, p% + 0)
DrawSpline storex%(l%, p%+0) * 128, storey%(l%, p%+0) * 128,_
           storex%(l%, p%+1) * 128, storey%(l%, p%+1) * 128,_
           storex%(l%, p%+2) * 128, storey%(l%, p%+2) * 128,_
           ((storex%(l%, p%+2) + storex%(l%, p%+3)) \ 2) * 128,_
           ((storey%(l%, p%+2) + storey%(l%, p%+3)) \ 2) * 128
END SUB

'======================================================================
SUB Draw_SF (l%, p%)
oldx& = (storex%(l%, p% + 0) + storex%(l%, p% + 1)) \ 2
oldy& = (storey%(l%, p% + 0) + storey%(l%, p% + 1)) \ 2
DrawSpline oldx& * 128, oldy& * 128,_
           storex%(l%, p%+1) * 128, storey%(l%, p%+1) * 128,_
           storex%(l%, p%+2) * 128, storey%(l%, p%+2) * 128,_
           storex%(l%, p%+3) * 128, storey%(l%, p%+3) * 128
END SUB

'======================================================================
SUB Draw_S_F (l%, p%)
oldx& = (storex%(l%, p% + 0) + storex%(l%, p% + 1)) \ 2
oldy& = (storey%(l%, p% + 0) + storey%(l%, p% + 1)) \ 2
DrawSpline oldx& * 128, oldy& * 128,_
           storex%(l%, p%+1) * 128, storey%(l%, p%+1) * 128,_
           storex%(l%, p%+2) * 128, storey%(l%, p%+2) * 128,_
           ((storex%(l%, p%+2) + storex%(l%, p%+3)) \ 2) * 128,_
           ((storey%(l%, p%+2) + storey%(l%, p%+3)) \ 2) * 128
END SUB

'======================================================================
SUB DrawLF (l%, p%)
PSET (storex%(l%, p% + 0), storey%(l%, p% + 0))
LINE -(storex%(l%, p% + 1), storey%(l%, p% + 1))
END SUB

'======================================================================
SUB DrawL_F (l%, p%)
PSET (storex%(l%, p% + 0), storey%(l%, p% + 0))
LINE -((storex%(l%, p%+0) + storex%(l%, p%+1)) \ 2,_
       (storey%(l%, p%+0) + storey%(l%, p%+1)) \ 2)
END SUB

'======================================================================
SUB Draw_LF (l%, p%)
PSET ((storex%(l%, p%+0) + storex%(l%, p%+1)) \ 2,_
      (storey%(l%, p%+0) + storey%(l%, p%+1)) \ 2)
LINE -(storex%(l%, p% + 1), storey%(l%, p% + 1))
END SUB

'======================================================================
SUB Colors
ar% = nr%
ag% = ng%
ab% = nb%
Adv ar%, dr%, nr%, 240
Adv ag%, dg%, ng%, 240
Adv ab%, db%, nb%, 240
_PALETTECOLOR 1, _RGB32(nr%, ng%, nb%)
END SUB

'======================================================================
SUB Adv (a%, d%, n%, w%)
n% = a% + d%
IF n% < 0 THEN
    n% = 0
    d% = RangeRand%(1, 6)
ELSEIF n% >= w% THEN
    n% = w% - 1
    d% = RangeRand%(-6, -1)
END IF
END SUB

'======================================================================
SUB DrawSpline (x1&, y1&, x2&, y2&, x3&, y3&, x4&, y4&)

PSET (oldx&, oldy&) 'move to start point
GOSUB rspline
EXIT SUB

'line by line convert from Motorola 68k assembler
'a0-a7 -> 32 bits long address registers (a7 = sp)
'd0-d7 -> 32 bits long data registers
'Inputs:
'a0 AS LONG x1, a1 AS LONG y1
'a2 AS LONG x2, a3 AS LONG y2
'a5 AS LONG x3, a6 AS LONG y3
'd6 AS LONG x4, d7 AS LONG y4
rspline:
d0& = x1& '                                              move.l  a0,d0
d0& = d0& - x4& '                                        sub.l   d6,d0
d3& = d0& '                                              move.l  d0,d3
IF d0& >= 0 GOTO save1 '                                 bpl.s   save1
d0& = -d0& '                                             neg.l   d0
save1:
d1& = y1& '                                              move.l  a1,d1
d1& = d1& - y4& '                                        sub.l   d7,d1
d4& = d1& '                                              move.l  d1,d4
IF d1& >= 0 GOTO save2 '                                 bpl.s   save2
d1& = -d1& '                                             neg.l   d1
save2:
d2& = d0& '                                              move.l  d0,d2
tmp& = d1& - d0& '                                       cmp.l   d0,d1
IF tmp& < 0 GOTO save3 '                                 bmi.s   save3
d2& = (d2& \ 8) AND &H1FFFFFFF~& '                       lsr.l   #3,d2
GOTO save9 '                                             bra.s   save9
save3:
d1& = (d1& \ 8) AND &H1FFFFFFF~& '                       lsr.l   #3,d1
save9:
d2& = d2& + d1& '                                        add.l   d1,d2
d2& = d2& \ 8 '                                          asr.l   #3,d2
IF d2& = 0 GOTO check2 '                                 beq.s   check2
d3& = d3& \ 32 '                                         asr.l   #5,d3
d4& = d4& \ 32 '                                         asr.l   #5,d4
d0& = x2& '                                              move.l  a2,d0
d0& = d0& - x1& '                                        sub.l   a0,d0
d1& = y2& '                                              move.l  a3,d1
d1& = d1& - y1& '                                        sub.l   a1,d1
d0& = d0& \ 32 '                                         asr.l   #5,d0
d1& = d1& \ 32 '                                         asr.l   #5,d1
d0& = (d0& AND &HFFFF~&) * (d4& AND &HFFFF~&) '          muls.w  d4,d0
d1& = (d1& AND &HFFFF~&) * (d3& AND &HFFFF~&) '          muls.w  d3,d1
d0& = d0& - d1& '                                        sub.l   d1,d0
IF d0& >= 0 GOTO save4 '                                 bpl.s   save4
d0& = -d0& '                                             neg.l   d0
save4:
tmp& = d2& - d0& '                                       cmp.l   d0,d2
IF tmp& <= 0 GOTO pushem '                               ble.s   pushem
d0& = x3& '                                              move.l  a5,d0
d0& = d0& - x1& '                                        sub.l   a0,d0
d1& = y3& '                                              move.l  a6,d1
d1& = d1& - y1& '                                        sub.l   a1,d1
d0& = d0& \ 32 '                                         asr.l   #5,d0
d1& = d1& \ 32 '                                         asr.l   #5,d1
d0& = (d0& AND &HFFFF~&) * (d4& AND &HFFFF~&) '          muls.w  d4,d0
d1& = (d1& AND &HFFFF~&) * (d3& AND &HFFFF~&) '          muls.w  d3,d1
d0& = d0& - d1& '                                        sub.l   d1,d0
IF d0& >= 0 GOTO save5 '                                 bpl.s   save5
d0& = -d0& '                                             neg.l   d0
save5:
tmp& = d2& - d0& '                                       cmp.l   d0,d2
IF tmp& <= 0 GOTO pushem '                               ble.s   pushem
makeline:
y4& = (y4& \ 128) AND &H01FFFFFF~& '                     lsr.l   #7,d7
d1& = y4& '                                              move.l  d7,d1
x4& = (x4& \ 128) AND &H01FFFFFF~& '                     lsr.l   #7,d6
d0& = x4& '                                              move.l  d6,d0
oldx& = d0& '                                            move.l  d0,_oldx
oldy& = d1& '                                            move.l  d1,_oldy
LINE -(d0&, d1&) '                                       jsr     _LVODraw
RETURN '                                                 rts

check2:
d0& = x1& '                                              move.l  a0,d0
d0& = d0& - x2& '                                        sub.l   a2,d0
IF d0& >= 0 GOTO ch1 '                                   bpl.s   ch1
d0& = -d0& '                                             neg.l   d0
ch1:
d1& = y1& '                                              move.l  a1,d1
d1& = d1& - y2& '                                        sub.l   a3,d1
IF d1& >= 0 GOTO ch2 '                                   bpl.s   ch2
d1& = -d1& '                                             neg.l   d1
ch2:
d1& = d1& + d0& '                                        add.l   d0,d1
d1& = d1& \ 8 '                                          asr.l   #3,d1
IF d1& <> 0 GOTO pushem '                                bne.s   pushem
d0& = x1& '                                              move.l  a0,d0
d0& = d0& - x3& '                                        sub.l   a5,d0
IF d0& >= 0 GOTO ch3 '                                   bpl.s   ch3
d0& = -d0& '                                             neg.l   d0
ch3:
d1& = y1& '                                              move.l  a1,d1
d1& = d1& - y3& '                                        sub.l   a6,d1
IF d1& >= 0 GOTO ch4 '                                   bpl.s   ch4
d1& = -d1& '                                             neg.l   d1
ch4:
d1& = d1& + d0& '                                        add.l   d0,d1
d1& = d1& \ 8 '                                          asr.l   #3,d1
IF d1& = 0 GOTO makeline '                               beq.s   makeline
pushem:
sp& = sp& - 2: stack&(sp&) = x4&: stack&(sp& + 1) = y4& 'movem.l d6/d7,-(sp)
d0& = x3& '                                              move.l  a5,d0
d0& = d0& + x4& '                                        add.l   d6,d0
d0& = d0& \ 2 '                                          asr.l   #1,d0
d1& = y3& '                                              move.l  a6,d1
d1& = d1& + y4& '                                        add.l   d7,d1
d1& = d1& \ 2 '                                          asr.l   #1,d1
sp& = sp& - 2: stack&(sp&) = d0&: stack&(sp& + 1) = d1& 'movem.l d0/d1,-(sp)
d2& = x2& '                                              move.l  a2,d2
d2& = d2& + x3& '                                        add.l   a5,d2
d2& = d2& \ 2 '                                          asr.l   #1,d2
d3& = y2& '                                              move.l  a3,d3
d3& = d3& + y3& '                                        add.l   a6,d3
d3& = d3& \ 2 '                                          asr.l   #1,d3
d4& = d0& '                                              move.l  d0,d4
d4& = d4& + d2& '                                        add.l   d2,d4
d4& = d4& \ 2 '                                          asr.l   #1,d4
d5& = d1& '                                              move.l  d1,d5
d5& = d5& + d3& '                                        add.l   d3,d5
d5& = d5& \ 2 '                                          asr.l   #1,d5
sp& = sp& - 2: stack&(sp&) = d4&: stack&(sp& + 1) = d5& 'movem.l d4/d5,-(sp)
x4& = x1& '                                              move.l  a0,d6
x4& = x4& + x2& '                                        add.l   a2,d6
x4& = x4& \ 2 '                                          asr.l   #1,d6
y4& = y1& '                                              move.l  a1,d7
y4& = y4& + y2& '                                        add.l   a3,d7
y4& = y4& \ 2 '                                          asr.l   #1,d7
d0& = d2& '                                              move.l  d2,d0
d0& = d0& + x4& '                                        add.l   d6,d0
d0& = d0& \ 2 '                                          asr.l   #1,d0
d1& = d3& '                                              move.l  d3,d1
d1& = d1& + y4& '                                        add.l   d7,d1
d1& = d1& \ 2 '                                          asr.l   #1,d1
x2& = x4& '                                              move.l  d6,a2
y2& = y4& '                                              move.l  d7,a3
x4& = d0& '                                              move.l  d0,d6
x4& = x4& + d4& '                                        add.l   d4,d6
x4& = x4& \ 2 '                                          asr.l   #1,d6
y4& = d1& '                                              move.l  d1,d7
y4& = y4& + d5& '                                        add.l   d5,d7
y4& = y4& \ 2 '                                          asr.l   #1,d7
sp& = sp& - 2: stack&(sp&) = x4&: stack&(sp& + 1) = y4& 'movem.l d6/d7,-(sp)
x3& = d0& '                                              move.l  d0,a5
y3& = d1& '                                              move.l  d1,a6
GOSUB rspline '                                          bsr rspline
x1& = stack&(sp&): y1& = stack&(sp& + 1): sp& = sp& + 2 'movem.l (sp)+,a0/a1
x2& = stack&(sp&): y2& = stack&(sp& + 1): sp& = sp& + 2 'movem.l (sp)+,a2/a3
x3& = stack&(sp&): y3& = stack&(sp& + 1): sp& = sp& + 2 'movem.l (sp)+,a5/a6
x4& = stack&(sp&): y4& = stack&(sp& + 1): sp& = sp& + 2 'movem.l (sp)+,d6/d7
GOTO rspline '                                           bra rspline

END SUB

'======================================================================
FUNCTION RangeRand% (low%, high%)
RangeRand% = INT(RND(1) * (high% - low% + 1)) + low%
END FUNCTION

'=====================================================================
FUNCTION VersionSplines$
VersionSplines$ = MID$("$VER: Splines blanker 1.0 (11-Apr-2018) by RhoSigma :END$", 7, 45)
END FUNCTION

