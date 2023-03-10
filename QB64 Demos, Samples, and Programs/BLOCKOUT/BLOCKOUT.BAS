'-----------------------------------------------------------------------------------------------------
' These are some metacommands and compiler options for QB64 to write modern & type-strict code
'-----------------------------------------------------------------------------------------------------
' This will disable prefixing all modern QB64 calls using a underscore prefix.
$NoPrefix
' Whatever indentifiers are not defined, should default to signed longs (ex. constants and functions).
DefLng A-Z
' All variables must be defined.
Option Explicit
' All arrays must be defined.
Option ExplicitArray
' Array lower bounds should always start from 1 unless explicitly specified.
' This allows a(4) as integer to have 4 members with index 1-4.
Option Base 1
' All arrays should be static by default. Allocate dynamic array using ReDim
'$Static
' This allows the executable window & it's contents to be resized.
$Resize:Smooth
'-----------------------------------------------------------------------------------------------------

Const FALSE = 0, true = Not FALSE

Randomize Timer

Dim gameArea As Long
gameArea = NewImage(800, 600, 32)
Screen gameArea
Title "Blockout"
PrintMode KeepBackground
AllowFullScreen SquarePixels , Smooth

Type Block
    x As Integer
    y As Integer
    c As Unsigned Long
    state As Byte
    special As Byte
    kind As Byte
End Type

Type Ball
    x As Single
    y As Single
    c As Unsigned Long
    radius As Integer
    state As Byte
    xDir As Byte
    yDir As Byte
    xVel As Single
    yVel As Single
End Type

Type Particle
    x As Single
    y As Single
    xAcc As Single
    yAcc As Single
    xVel As Single
    yVel As Single
    r As Unsigned Byte
    g As Unsigned Byte
    b As Unsigned Byte
    state As Byte
    size As Integer
    lifeSpan As Single
    birth As Single
    special As Byte
    kind As Byte
End Type

Type Special
    start As Single
    span As Integer
End Type

Const gravity = .03

Const blockWidth = 80
Const blockHeight = 30
Const paddleHeight = 15

Const s_round = 0
Const s_square = 1
Const specialPower = 2

Const left = -1
Const right = 1
Const up = -1
Const down = 1

Const regular = 0
Const hitTwice = 1
Const unbreakable = 2

Const bullet = 1

Dim Shared block(1 To 100) As Block, ball As Ball
Dim Shared particle(1 To 10000) As Particle
Dim Shared win As Byte, quit As String * 1
Dim Shared paddleX As Integer, paddleY As Integer
Dim Shared paddleWidth As Single, magneticOffset As Integer
Dim Shared score As Integer, lives As Integer
Dim Shared paused As Byte, stillImage&

Dim Shared electricColor(1 To 2) As Unsigned Long
electricColor(1) = RGB32(255)
electricColor(2) = RGB32(50, 211, 255)

Const FireBall = 1
Const Shooter = 2
Const BreakThrough = 3
Const Magnetic = 4
Const StretchPaddle = 5
Const StretchPaddle2 = 6
Const totalSpecialPowers = 6

Dim Shared special(1 To totalSpecialPowers) As Special

Dim i As Long
For i = 1 To totalSpecialPowers
    special(i).span = 15
Next

Const defaultPaddleWidth = 150

paddleY = Height - blockHeight - paddleHeight - 1

Do
    If lives = 0 Then score = 0: lives = 3
    win = FALSE
    paused = FALSE
    generateBlocks
    paddleWidth = defaultPaddleWidth
    ball.state = FALSE
    ball.c = RGB32(161, 161, 155)
    ball.radius = 10
    ball.xDir = right
    ball.yDir = up
    ball.xVel = 5
    ball.yVel = 5
    For i = 1 To totalSpecialPowers
        special(i).start = 0
    Next
    magneticOffset = paddleWidth / 2

    For i = 1 To UBound(particle)
        resetParticle particle(i)
    Next

    MouseHide

    Dim As Byte noFocus, showFullScreenMessage
    Dim k As Long
    Dim As Double pauseStart, pauseDiff
    Dim As String m
    Dim As Long bAlpha

    Do
        k& = KeyHit
        'remove before release:
        If k& = Asc("s") Then special(Shooter).start = Timer
        If k& = Asc("m") Then special(Magnetic).start = Timer
        If k& = Asc("b") Then special(BreakThrough).start = Timer
        If k& = Asc("f") Then special(FireBall).start = Timer
        If k& = Asc("p") Then special(StretchPaddle).start = Timer
        If k& = Asc("P") Then special(StretchPaddle2).start = Timer
        If k& = Asc("r") Then Exit Do

        noFocus%% = lostFocus
        If (paused = true And k& = 13) Or k& = 27 Or noFocus%% Then
            If paused Then
                FreeImage stillImage&
                paused = FALSE
                showFullScreenMessage%% = FALSE
                pauseDiff = Timer - pauseStart
                For i = 1 To totalSpecialPowers
                    If special(i).start > 0 Then
                        special(i).start = special(i).start + pauseDiff
                    End If
                Next
                For i = 1 To UBound(particle)
                    If particle(i).birth > 0 Then
                        particle(i).birth = particle(i).birth + pauseDiff
                    End If
                Next
            Else
                paused = true
                If noFocus%% Then showFullScreenMessage%% = true
                pauseStart = Timer
                stillImage& = CopyImage(0)
            End If
        End If

        If paused Then
            PutImage , stillImage&
            m$ = "Paused (ENTER to continue)"
            Color RGB32(0)
            PrintString ((Width - PrintWidth(m$)) / 2 + 1, (Height - FontHeight) / 2 + 1 + FontHeight), m$
            Color RGB32(255)
            PrintString ((Width - PrintWidth(m$)) / 2, (Height - FontHeight) / 2 + FontHeight), m$

            If showFullScreenMessage%% Then
                m$ = "(Hit Alt+Enter to switch to fullscreen)"
                Color RGB32(0)
                PrintString ((Width - PrintWidth(m$)) / 2 + 1, (Height - FontHeight) / 2 + 1 + FontHeight * 2), m$
                Color RGB32(255)
                PrintString ((Width - PrintWidth(m$)) / 2, (Height - FontHeight) / 2 + FontHeight * 2), m$
            End If
        Else
            If Timer - special(BreakThrough).start < special(BreakThrough).span Then
                bAlpha = map(ball.xVel, 5, 10, 80, 30)
            Else
                bAlpha = 255
            End If
            Line (0, 0)-(Width, Height), RGBA32(0, 0, 0, bAlpha), BF

            showBlocks
            doPaddle
            doBall
            doParticles

            m$ = "Score:" + Str$(score) + " Lives:" + Str$(lives)
            Color RGB32(0)
            PrintString (1, 1), m$
            Color RGB32(255)
            PrintString (0, 0), m$

            'remove before release:
            If Timer - special(FireBall).start < special(FireBall).span Then
                PrintString (0, 350), "fireball: " + Str$(Int(Timer - special(FireBall).start))
            End If

            If Timer - special(BreakThrough).start < special(BreakThrough).span Then
                PrintString (0, 370), "breakthrough: " + Str$(Int(Timer - special(BreakThrough).start))
            End If

            If Timer - special(Shooter).start < special(Shooter).span Then
                PrintString (0, 388), "shooter: " + Str$(Int(Timer - special(Shooter).start))
            End If

            If Timer - special(Magnetic).start < special(Magnetic).span Then
                PrintString (0, 406), "magnetic: " + Str$(Int(Timer - special(Magnetic).start))
            End If

            If Timer - special(StretchPaddle).start < special(StretchPaddle).span Then
                'remove before release:
                PrintString (0, 422), "stretch: " + Str$(Int(Timer - special(StretchPaddle).start))
                paddleWidth = defaultPaddleWidth * 1.5
            Else
                paddleWidth = defaultPaddleWidth
            End If

            If Timer - special(StretchPaddle2).start < special(StretchPaddle2).span Then
                'remove before release:
                PrintString (0, 438), "stretch2: " + Str$(Int(Timer - special(StretchPaddle2).start))
                paddleWidth = defaultPaddleWidth * 2
            Else
                If Timer - special(StretchPaddle).start > special(StretchPaddle).span Or special(StretchPaddle).start = 0 Then
                    paddleWidth = defaultPaddleWidth
                End If
            End If

        End If

        Display
        Limit 60
    Loop Until win Or lives = 0

    MouseShow

    Cls
    If win Then
        Print "Good job, you win."
        Print "Continue (y/n)?"
    Else
        Print "You lose."
        Print "Restart (y/n)?"
    End If

    AutoDisplay
    KeyClear

    Do
        quit = LCase$(Input$(1))
    Loop Until quit = "y" Or quit = "n"

Loop While quit = "y"

System

Function lostFocus%%
    Static Focused As Byte

    If WindowHasFocus = FALSE Then
        If Focused Then
            Focused = FALSE
            lostFocus%% = true
        End If
    Else
        Focused = true
    End If
End Function

Sub doParticles
    Dim thisColor As Unsigned Long, bAlpha As Unsigned Byte
    Dim As Long i, l, size, j, k
    Dim As Byte specialDrawn
    Dim As String m

    For i = 1 To UBound(particle)
        If particle(i).state = FALSE Then Continue
        If particle(i).lifeSpan > 0 And Timer - particle(i).birth > particle(i).lifeSpan Then particle(i).state = FALSE: Continue

        'move
        particle(i).xVel = particle(i).xVel + particle(i).xAcc
        particle(i).yVel = particle(i).yVel + particle(i).yAcc + gravity
        particle(i).x = particle(i).x + particle(i).xVel
        particle(i).y = particle(i).y + particle(i).yVel

        If particle(i).kind = bullet Then
            l = newParticle
            If l Then
                particle(l).r = 222 + (Rnd * 30)
                particle(l).g = 100 + (Rnd * 70)
                particle(l).x = particle(i).x
                particle(l).y = particle(i).y
                particle(l).lifeSpan = 0.05
            End If
        End If

        'check visibility
        If particle(i).x - particle(i).size / 2 < 0 Or particle(i).x + particle(i).size / 2 > Width Or particle(i).y - particle(i).size / 2 < 0 Or particle(i).y + particle(i).size / 2 > Height Then
            particle(i).state = FALSE
            Continue
        End If

        'show
        If particle(i).lifeSpan > 0 Then
            bAlpha = map(Timer - particle(i).birth, 0, particle(i).lifeSpan, 255, 0)
        Else
            bAlpha = 255
        End If

        thisColor = RGBA32(particle(i).r, particle(i).g, particle(i).b, bAlpha)

        If particle(i).size > 0 Then
            Select Case particle(i).kind
                Case s_round, bullet
                    CircleFill particle(i).x, particle(i).y, particle(i).size, thisColor
                Case s_square
                    Line (particle(i).x - size / 2, particle(i).y - size / 2)-Step(particle(i).size, particle(i).size), thisColor, BF
                Case specialPower
                    Select Case particle(i).special
                        'CONST FireBall = 1
                        'CONST Shooter = 2
                        'CONST BreakThrough = 3
                        'CONST Magnetic = 4
                        'CONST StretchPaddle = 5
                        'CONST StretchPaddle2 = 6
                        Case FireBall
                            For j = 1 To 10
                                l = newParticle
                                If l = 0 Then Exit For
                                particle(l).r = 222 + (Rnd * 30)
                                particle(l).g = 100 + (Rnd * 70)
                                particle(l).x = particle(i).x + Cos(Rnd * Pi(2)) * (ball.radius * Rnd)
                                particle(l).y = particle(i).y + Sin(Rnd * Pi(2)) * (ball.radius * Rnd)
                                particle(l).lifeSpan = .1
                            Next
                            CircleFill particle(i).x, particle(i).y, particle(i).size, RGBA32(222 + (Rnd * 30), 100 + (Rnd * 70), 0, Rnd * 255)
                            specialDrawn = true
                        Case Shooter
                            Line (particle(i).x - 7, particle(i).y + 1)-Step(15, 8), RGB32(89, 161, 255), BF
                            CircleFill particle(i).x - 7, particle(i).y + 5, 4, RGB32(194, 89, 61)
                            CircleFill particle(i).x - 7, particle(i).y + 2, 3, RGB32(194, 133, 61)
                            CircleFill particle(i).x - 7, particle(i).y, 3, RGB32(194, 188, 61)

                            l = newParticle
                            If l > 0 Then
                                particle(l).r = 222 + (Rnd * 30)
                                particle(l).g = 100 + (Rnd * 70)
                                particle(l).x = particle(i).x - 7
                                particle(l).y = particle(i).y
                                particle(l).lifeSpan = .1
                            End If

                            specialDrawn = true
                        Case BreakThrough
                            CircleFill particle(i).x - 8, particle(i).y + 8, 3, RGB32(177, 30)
                            CircleFill particle(i).x - 6, particle(i).y + 6, 3, RGB32(177, 50)
                            CircleFill particle(i).x - 3, particle(i).y + 3, 4, RGB32(177, 100)
                            CircleFill particle(i).x, particle(i).y, 4, RGB32(177, 200)
                            specialDrawn = true
                        Case Magnetic
                            For j = 1 To 2
                                PSet (particle(i).x + Cos(0) * (particle(i).size + particle(i).size * Rnd), particle(i).y + Sin(0) * (particle(i).size + particle(i).size * Rnd)), electricColor(j)
                                For k = 0 To Pi(2) Step .2
                                    Line -(particle(i).x + Cos(k) * (particle(i).size + particle(i).size * Rnd), particle(i).y + Sin(k) * (particle(i).size + particle(i).size * Rnd)), electricColor(j)
                                Next
                                Line -(particle(i).x + Cos(0) * (particle(i).size + particle(i).size * Rnd), particle(i).y + Sin(0) * (particle(i).size + particle(i).size * Rnd)), electricColor(j)
                            Next
                            specialDrawn = true
                        Case StretchPaddle
                            Line (particle(i).x - 7, particle(i).y + 1)-Step(15, 8), RGB32(89, 161, 255), BF
                            CircleFill particle(i).x - 7, particle(i).y + 5, 4, RGB32(194, 89, 61)
                            Font 8
                            Color RGB32(255, 150)
                            PrintString (particle(i).x - 16, particle(i).y - 10), "1.5x"
                            Font 16
                            specialDrawn = true
                        Case StretchPaddle2
                            Line (particle(i).x - 3, particle(i).y + 1)-Step(15, 8), RGB32(89, 161, 255), BF
                            CircleFill particle(i).x - 3, particle(i).y + 5, 4, RGB32(194, 89, 61)
                            Font 8
                            Color RGB32(255, 150)
                            PrintString (particle(i).x + 8, particle(i).y - 10), "2x"
                            Font 16
                            specialDrawn = true
                    End Select
            End Select
        Else
            PSet (particle(i).x, particle(i).y), thisColor
        End If

        'check collision with paddle if this particle contains a special power
        If particle(i).special Then
            'remove before release:
            If specialDrawn = FALSE Then
                m$ = LTrim$(Str$(particle(i).special))
                Color RGB32(0)
                PrintString (particle(i).x + 1, particle(i).y + 1), m$
                Color RGB32(255)
                PrintString (particle(i).x, particle(i).y), m$
            End If

            If particle(i).x - particle(i).size / 2 > paddleX And particle(i).x + particle(i).size / 2 < paddleX + paddleWidth And particle(i).y + particle(i).size / 2 >= paddleY Then
                particle(i).state = FALSE
                special(particle(i).special).start = Timer
            End If
        End If

        'check collision with blocks if this particle is a bullet
        If particle(i).kind = bullet Then
            For j = 1 To UBound(block)
                If block(j).state = FALSE Then Continue
                If particle(i).x > block(j).x And particle(i).x < block(j).x + blockWidth And particle(i).y < block(j).y + blockHeight Then
                    destroyBlock j, FALSE
                    If Timer - special(BreakThrough).start > special(BreakThrough).span Or special(BreakThrough).start = 0 Then
                        particle(i).state = FALSE
                    End If
                    Exit For
                End If
            Next
        End If
    Next
End Sub

Sub resetParticle (this As Particle)
    Dim empty As Particle
    this = empty
End Sub

Sub generateBlocks
    Dim As Long i, j, b, minRGB, cRed, cGreen, cBlue, r

    For i = 1 To 10
        For j = 1 To 10
            b = b + 1
            block(b).x = (i - 1) * blockWidth
            block(b).y = (j - 1) * blockHeight
            minRGB = 50
            Do
                cRed = 255 * Rnd
                cGreen = 255 * Rnd
                cBlue = 255 * Rnd
            Loop Until cRed > minRGB And cGreen > minRGB And cBlue > minRGB
            block(b).c = RGB32(cRed, cGreen, cBlue)
            block(b).state = Rnd
            r = Rnd * 1000
            If r > 150 And r < 200 Then
                block(b).special = Rnd * totalSpecialPowers
            End If

            r = Rnd * 1000
            If r > 150 And r < 200 Then
                block(b).kind = Rnd * 2
            End If
        Next
    Next
End Sub

Sub showBlocks
    Dim As Long i, activeBlocks, x, y, j

    For i = 1 To UBound(block)
        If block(i).state = FALSE Then Continue
        activeBlocks = activeBlocks + 1
        If block(i).kind <> unbreakable Then
            Line (block(i).x, block(i).y)-Step(blockWidth - 1, blockHeight - 1), block(i).c, BF
        End If

        If block(i).kind = hitTwice Then
            For x = block(i).x To block(i).x + blockWidth - 1 Step 5
                Line (x, block(i).y)-(x, block(i).y + blockHeight - 1), RGB32(188)
            Next
        ElseIf block(i).kind = unbreakable Then
            activeBlocks = activeBlocks - 1
            For x = block(i).x To block(i).x + blockWidth - 1 Step 5
                Line (x, block(i).y)-(x, block(i).y + blockHeight - 1), RGB32(72)
            Next
            For y = block(i).y To block(i).y + blockHeight - 1 Step 5
                Line (block(i).x, y)-(block(i).x + blockWidth - 1, y), RGB32(72)
            Next
        End If

        Line (block(i).x, block(i).y)-Step(blockWidth - 1, blockHeight - 1), RGB32(255), B
        Line (block(i).x + 1, block(i).y + 1)-Step(blockWidth - 3, blockHeight - 3), RGB32(0), B

        If block(i).special Then
            For j = 1 To 6 Step 2
                Line (block(i).x + j, block(i).y + j)-Step(blockWidth - j * 2, blockHeight - j * 2), RGB32(255, 166, 0), B
                Line (block(i).x + j + 1, block(i).y + j + 1)-Step(blockWidth - j * 3, blockHeight - j * 3), RGB32(255, 238, 0), B
            Next

            'remove before release:
            Color RGB32(0)
            PrintString (block(i).x + 1, block(i).y + 1), Str$(block(i).special)
            Color RGB32(255)
            PrintString (block(i).x, block(i).y), Str$(block(i).special)
        End If
    Next
    win = (activeBlocks = 0)
End Sub

Sub doPaddle
    Static lastX As Integer
    Dim As Long j, i, l

    While MouseInput: Wend

    If MouseX <> lastX Then
        lastX = MouseX
        paddleX = MouseX - paddleWidth / 2
    End If

    If KeyDown(19200) Then paddleX = paddleX - 5
    If KeyDown(19712) Then paddleX = paddleX + 5

    If paddleX < 0 Then paddleX = 0
    If paddleX + paddleWidth > Width - 1 Then paddleX = Width - 1 - paddleWidth

    Line (paddleX + paddleHeight / 2, paddleY)-Step(paddleWidth - paddleHeight, paddleHeight), RGB32(89, 161, 255), BF
    CircleFill paddleX + paddleHeight / 2, paddleY + paddleHeight / 2, paddleHeight / 2, RGB32(194, 89, 61)
    CircleFill paddleX + paddleWidth - paddleHeight / 2, paddleY + paddleHeight / 2, paddleHeight / 2, RGB32(194, 89, 61)

    If Timer - special(Magnetic).start < special(Magnetic).span Then
        For j = 1 To 2
            PSet (paddleX + paddleHeight / 2, paddleY), electricColor(j)
            For i = paddleX + paddleHeight To paddleX + paddleWidth - paddleHeight Step paddleWidth / 10
                Line -(i, paddleY - (Rnd * 10)), electricColor(j)
            Next
            Line -(paddleX + paddleWidth - paddleHeight / 2, paddleY), electricColor(j)

        Next
    End If

    If MouseButton(1) Or KeyDown(13) Then ball.state = true

    If MouseButton(1) Then
        Static mouseWasDown As Byte
        mouseWasDown = true
    End If

    If Timer - special(Shooter).start < special(Shooter).span Then
        CircleFill paddleX + paddleHeight / 2, paddleY, paddleHeight / 3, RGB32(194, 133, 61)
        CircleFill paddleX + paddleWidth - paddleHeight / 2, paddleY, paddleHeight / 3, RGB32(194, 133, 61)

        CircleFill paddleX + paddleHeight / 2, paddleY - paddleHeight / 4, paddleHeight / 4, RGB32(194, 188, 61)
        CircleFill paddleX + paddleWidth - paddleHeight / 2, paddleY - paddleHeight / 4, paddleHeight / 4, RGB32(194, 188, 61)

        If MouseButton(1) = FALSE And mouseWasDown Then
            mouseWasDown = FALSE

            For i = 1 To 2
                l = newParticle
                particle(l).r = 100
                particle(l).g = 100
                particle(l).b = 100
                If i = 1 Then particle(l).x = paddleX + paddleHeight / 2 Else particle(l).x = paddleX + paddleWidth - paddleHeight / 2
                particle(l).y = paddleY
                particle(l).yVel = -4.5
                particle(l).yAcc = -gravity * 1.5
                particle(l).size = 2
                particle(l).kind = bullet
            Next
        End If
    End If

End Sub

Sub doBall
    Dim As Long j, l

    If ball.state = FALSE Then
        ball.x = paddleX + magneticOffset
        ball.y = paddleY - (ball.radius)
    Else
        ball.x = ball.x + ball.xDir * ball.xVel
        ball.y = ball.y + ball.yDir * ball.yVel

        ballCollision
    End If

    If Timer - special(FireBall).start < special(FireBall).span Then
        For j = 1 To 10
            l = newParticle
            If l = 0 Then Exit For
            particle(l).r = 222 + (Rnd * 30)
            particle(l).g = 100 + (Rnd * 70)
            particle(l).x = ball.x + Cos(Rnd * Pi(2)) * (ball.radius * Rnd)
            particle(l).y = ball.y + Sin(Rnd * Pi(2)) * (ball.radius * Rnd)
            particle(l).lifeSpan = Rnd
        Next
    End If

    CircleFill ball.x, ball.y, ball.radius, ball.c
End Sub

Function newParticle&
    Dim As Long i

    For i = 1 To UBound(particle)
        If particle(i).state = FALSE Then
            newParticle& = i
            resetParticle particle(i)
            particle(i).state = true
            particle(i).birth = Timer
            Exit Function
        End If
    Next
End Function

Sub ballCollision
    Dim As Long i

    'paddle
    If ball.x > paddleX And ball.x < paddleX + paddleWidth And ball.y > paddleY And ball.y < paddleY + paddleHeight Then
        If Timer - special(Magnetic).start < special(Magnetic).span Then
            ball.state = FALSE
            magneticOffset = ball.x - paddleX
        End If

        If ball.x < paddleX + paddleWidth / 2 Then
            ball.xDir = left
            ball.xVel = map(ball.x, paddleX, paddleX + paddleWidth / 3, 10, 5)
        Else
            ball.xDir = right
            ball.xVel = map(ball.x, paddleX + paddleWidth / 3, paddleX + paddleWidth, 5, 10)
        End If
        If ball.xVel < 5 Then ball.xVel = 5

        If ball.yDir = 1 And ball.y < paddleY + paddleHeight / 2 Then ball.yDir = -1
        Exit Sub
    End If

    'blocks
    For i = 1 To UBound(block)
        If block(i).state = FALSE Then Continue
        If ball.x > block(i).x And ball.x < block(i).x + blockWidth And ball.y > block(i).y And ball.y < block(i).y + blockHeight Then
            destroyBlock i, true
            Exit Sub
        End If
    Next

    'walls
    If ball.x < ball.radius Then ball.xDir = right
    If ball.x > Width - ball.radius Then ball.xDir = left
    If ball.y > Height + ball.radius Then
        lives = lives - 1
        magneticOffset = paddleWidth / 2
        ball.state = FALSE
        ball.xDir = right
        ball.yDir = up
        ball.xVel = 5
        ball.yVel = 5
    End If
    If ball.y < 0 Then ball.yDir = down
End Sub

Sub destroyBlock (i As Long, ballHit As Byte)
    Dim As Long maxJ, maxK, j, k, l, a, points

    Select Case block(i).kind
        Case regular
            block(i).state = FALSE

            If Timer - special(BreakThrough).start < special(BreakThrough).span Then
                maxJ = 10
                maxK = 3
                For j = 1 To maxJ
                    For k = 1 To maxK
                        l = newParticle
                        If l = 0 Then Exit For
                        a = Rnd * 1000
                        If a < 100 Then
                            particle(l).r = Red32(block(i).c)
                            particle(l).g = Green32(block(i).c)
                            particle(l).b = Blue32(block(i).c)
                        Else
                            particle(l).r = map(a, 0, 1000, 50, 255)
                            particle(l).g = map(a, 0, 1000, 50, 255)
                            particle(l).b = map(a, 0, 1000, 50, 255)
                        End If
                        particle(l).x = block(i).x + ((blockWidth / maxJ) * (j - 1))
                        particle(l).y = block(i).y + ((blockHeight / maxK) * (k - 1))
                        a = Rnd
                        If ball.xDir = right And ball.yDir = up Then
                            particle(l).xAcc = Cos(map(a, 0, 1, Pi(1.5), Pi(2)))
                            particle(l).yAcc = Sin(map(a, 0, 1, Pi(1.5), Pi(2)))
                        ElseIf ball.xDir = right And ball.yDir = down Then
                            particle(l).xAcc = Cos(map(a, 0, 1, 0, Pi(.5)))
                            particle(l).yAcc = Sin(map(a, 0, 1, 0, Pi(.5)))
                        ElseIf ball.xDir = left And ball.yDir = up Then
                            particle(l).xAcc = Cos(map(a, 0, 1, Pi, Pi(1.5)))
                            particle(l).yAcc = Sin(map(a, 0, 1, Pi, Pi(1.5)))
                        ElseIf ball.xDir = left And ball.yDir = down Then
                            particle(l).xAcc = Cos(map(a, 0, 1, Pi(.5), Pi))
                            particle(l).yAcc = Sin(map(a, 0, 1, Pi(.5), Pi))
                        End If
                        particle(l).lifeSpan = .5
                        particle(l).size = 1
                    Next
                Next
            End If

            If block(i).special Then
                Static lastSpecialGiven As Single
                If Timer - lastSpecialGiven > 3 Then
                    lastSpecialGiven = Timer
                    l = newParticle
                    If l Then
                        particle(l).size = 6
                        particle(l).x = block(i).x + blockWidth / 2
                        particle(l).y = block(i).y + blockHeight / 2
                        particle(l).r = 255
                        particle(l).g = 255
                        particle(l).b = 255
                        particle(l).kind = specialPower
                        particle(l).special = block(i).special
                    End If
                End If
            End If

            points = ((Red32(block(i).c) + Green32(block(i).c) + Blue32(block(i).c)) / 3) / 10
            score = score + points
        Case hitTwice
            block(i).kind = regular
            If ballHit Then
                If Timer - special(FireBall).start < special(FireBall).span Then destroyBlock i, ballHit
            End If
        Case unbreakable
            'check if the ball is trapped between two unbreakable blocks
            Static lastBlock(1 To 3) As Block
            lastBlock(3) = lastBlock(2)
            lastBlock(2) = lastBlock(1)
            lastBlock(1) = block(i)
            If (lastBlock(1).x = lastBlock(3).x And lastBlock(1).y = lastBlock(3).y) Or lastBlock(1).x = lastBlock(2).x And lastBlock(1).y = lastBlock(2).y Then
                If ball.xVel > 7.5 And ball.xVel < 10 Then
                    ball.xVel = 10
                ElseIf ball.xVel = 10 Then
                    ball.xVel = 8
                End If

                If ball.xVel <= 7.5 And ball.xVel > 5 Then
                    ball.xVel = 5
                ElseIf ball.xVel = 5 Then
                    ball.xVel = 6
                End If
            End If
    End Select

    If ballHit Then
        If (block(i).kind = unbreakable Or block(i).kind = hitTwice) Then
            For j = 1 To map(ball.xVel, 5, 10, 10, 30)
                l = newParticle
                If l = 0 Then Exit For
                particle(l).r = 222 + (Rnd * 30)
                particle(l).g = 100 + (Rnd * 70)
                particle(l).x = ball.x + Cos(Rnd * Pi(2)) * (ball.radius * Rnd)
                particle(l).y = ball.y + Sin(Rnd * Pi(2)) * (ball.radius * Rnd)
                particle(l).lifeSpan = Rnd

                a = Rnd
                If ball.xDir = right And ball.yDir = up Then
                    particle(l).xVel = Cos(map(a, 0, 1, Pi(1.5), Pi(2)))
                    particle(l).yVel = Sin(map(a, 0, 1, Pi(1.5), Pi(2)))
                ElseIf ball.xDir = right And ball.yDir = down Then
                    particle(l).xVel = Cos(map(a, 0, 1, 0, Pi(.5)))
                    particle(l).yVel = Sin(map(a, 0, 1, 0, Pi(.5)))
                ElseIf ball.xDir = left And ball.yDir = up Then
                    particle(l).xVel = Cos(map(a, 0, 1, Pi, Pi(1.5)))
                    particle(l).yVel = Sin(map(a, 0, 1, Pi, Pi(1.5)))
                ElseIf ball.xDir = left And ball.yDir = down Then
                    particle(l).xVel = Cos(map(a, 0, 1, Pi(.5), Pi))
                    particle(l).yVel = Sin(map(a, 0, 1, Pi(.5), Pi))
                End If
            Next
        End If

        If Timer - special(BreakThrough).start > special(BreakThrough).span Or special(BreakThrough).start = 0 Then
            If ball.x < block(i).x + blockWidth / 2 Then ball.xDir = left Else ball.xDir = right
            If ball.y < block(i).y + blockHeight / 2 Then ball.yDir = up Else ball.yDir = down
        End If
    End If
End Sub

Sub CircleFill (CX As Integer, CY As Integer, R As Integer, C As Unsigned Long)
    ' CX = center x coordinate
    ' CY = center y coordinate
    '  R = radius
    '  C = fill color
    Dim Radius As Integer, RadiusError As Integer
    Dim X As Integer, Y As Integer
    Radius = Abs(R)
    RadiusError = -Radius
    X = Radius
    Y = 0
    If Radius = 0 Then PSet (CX, CY), C: Exit Sub
    Line (CX - X, CY)-(CX + X, CY), C, BF
    While X > Y
        RadiusError = RadiusError + Y * 2 + 1
        If RadiusError >= 0 Then
            If X <> Y + 1 Then
                Line (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
                Line (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
            End If
            X = X - 1
            RadiusError = RadiusError - X * 2
        End If
        Y = Y + 1
        Line (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
        Line (CX - X, CY + Y)-(CX + X, CY + Y), C, BF
    Wend
End Sub

Function map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
End Function

