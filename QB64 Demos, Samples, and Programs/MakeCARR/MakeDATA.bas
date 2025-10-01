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
'| === MakeDATA.bas ===                                              |
'|                                                                   |
'| == Create a DATA block out of the given file, so you can embed it |
'| == into your program and read it or write it back when needed.    |
'|                                                                   |
'| == The DATAs are written into a .bm file together with ready to   |
'| == use read and write back FUNCTIONs. You just $INCLUDE this .bm  |
'| == file into your program and call the desired FUNCTION somewhere.|
'|                                                                   |
'| == This program needs the 'lzwpacker.bm' file available from the  |
'| == Libraries Collection here:                                     |
'| ==      http://qb64phoenix.com/forum/forumdisplay.php?fid=23      |
'| == as it will try to pack the given file to keep the DATA block   |
'| == as small as possible. If compression is successful, then your  |
'| == program also must $INCLUDE 'lzwpacker.bm' to be able to unpack |
'| == the file data again for write back. MakeDATA.bas is printing   |
'| == a reminder message in such a case.                             |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

_TITLE "MakeDATA - Convert File to DATAs v2.0, Done by RhoSigma, Roland Heyder"

'--- if you wish, set any default paths, end with a backslash ---
srcPath$ = "" 'source path
tarPath$ = "" 'target path
'-----
IF srcPath$ <> "" THEN
    COLOR 15: PRINT "Default source path: ": COLOR 7: PRINT srcPath$: PRINT
END IF
IF tarPath$ <> "" THEN
    COLOR 15: PRINT "Default target path: ": COLOR 7: PRINT tarPath$: PRINT
END IF

'--- collect inputs (relative paths allowed, based on default paths) ---
source:
LINE INPUT "Source Filename: "; src$ 'any file you want to put into DATAs
IF src$ = "" GOTO source
target:
LINE INPUT "Target Basename: "; tar$ 'write stuff into this file (.bm is added)
IF tar$ = "" GOTO target
'-----
ON ERROR GOTO abort
OPEN "I", #1, srcPath$ + src$: CLOSE #1 'file exist check
OPEN "O", #2, tarPath$ + tar$ + ".bm": CLOSE #2 'path exist check
ON ERROR GOTO 0

'--- separate source filename part ---
FOR po% = LEN(src$) TO 1 STEP -1
    IF MID$(src$, po%, 1) = "\" OR MID$(src$, po%, 1) = "/" THEN
        srcName$ = MID$(src$, po% + 1)
        EXIT FOR
    ELSEIF po% = 1 THEN
        srcName$ = src$
    END IF
NEXT po%
'--- separate target filename part ---
FOR po% = LEN(tar$) TO 1 STEP -1
    IF MID$(tar$, po%, 1) = "\" OR MID$(tar$, po%, 1) = "/" THEN
        tarName$ = MID$(tar$, po% + 1)
        EXIT FOR
    ELSEIF po% = 1 THEN
        tarName$ = tar$
    END IF
NEXT po%
MID$(tarName$, 1, 1) = UCASE$(MID$(tarName$, 1, 1)) 'capitalize 1st letter

'--- init ---
OPEN "B", #1, srcPath$ + src$
filedata$ = SPACE$(LOF(1))
GET #1, , filedata$
CLOSE #1
rawdata$ = LzwPack$(filedata$, 20)
IF rawdata$ <> "" THEN
    OPEN "O", #1, tarPath$ + tar$ + ".lzw"
    CLOSE #1
    OPEN "B", #1, tarPath$ + tar$ + ".lzw"
    PUT #1, , rawdata$
    CLOSE #1
    packed% = -1
    OPEN "B", #1, tarPath$ + tar$ + ".lzw"
ELSE
    packed% = 0
    OPEN "B", #1, srcPath$ + src$
END IF
fl& = LOF(1)
cntL& = INT(fl& / 32)
cntB& = (fl& - (cntL& * 32))

'--- .bm include file ---
OPEN "O", #2, tarPath$ + tar$ + ".bm"
PRINT #2, "'============================================================"
PRINT #2, "'=== This file was created with MakeDATA.bas by RhoSigma, ==="
PRINT #2, "'=== you must $INCLUDE this at the end of your program.   ==="
IF packed% THEN
    PRINT #2, "'=== ---------------------------------------------------- ==="
    PRINT #2, "'=== If your program is NOT a GuiTools based application, ==="
    PRINT #2, "'=== then it must also $INCLUDE: 'lzwpacker.bm' available ==="
    PRINT #2, "'=== from the Libraries Collection here:                  ==="
    PRINT #2, "'=== http://qb64phoenix.com/forum/forumdisplay.php?fid=23 ==="
END IF
PRINT #2, "'============================================================"
PRINT #2, ""
'--- read function ---
PRINT #2, "'"; STRING$(LEN(tarName$) + 17, "-")
PRINT #2, "'--- Read"; tarName$; "Data$ ---"
PRINT #2, "'"; STRING$(LEN(tarName$) + 17, "-")
PRINT #2, "' This function will read the DATAs you've created with MakeDATA.bas"
PRINT #2, "' into a string, no data will be written to disk. If you rather wanna"
PRINT #2, "' rebuild the original file on disk, then use the write function below."
PRINT #2, "'"
PRINT #2, "' You may directly pass the returned string to _SNDOPEN, _LOADIMAGE or"
PRINT #2, "' _LOADFONT when using the memory load capabilities of these commands."
PRINT #2, "'----------"
PRINT #2, "' SYNTAX:"
PRINT #2, "'   dataStr$ = Read"; tarName$; "Data$"
PRINT #2, "'----------"
PRINT #2, "' RESULT:"
PRINT #2, "'   --- dataStr$ ---"
PRINT #2, "'    The data of the embedded file. This is in fact the same as if you"
PRINT #2, "'    had opend the file and read its entire content into a single string."
PRINT #2, "'---------------------------------------------------------------------"
PRINT #2, "FUNCTION Read"; tarName$; "Data$"
PRINT #2, "'--- option _explicit requirements ---"
PRINT #2, "DIM numL&, numB&, rawdata$, stroffs&, i&, dat&"
PRINT #2, "'--- read DATAs ---"
PRINT #2, "RESTORE "; tarName$
PRINT #2, "READ numL&, numB&"
PRINT #2, "rawdata$ = SPACE$((numL& * 4) + numB&)"
PRINT #2, "stroffs& = 1"
PRINT #2, "FOR i& = 1 TO numL&"
PRINT #2, "    READ dat&"
PRINT #2, "    MID$(rawdata$, stroffs&, 4) = MKL$(dat&)"
PRINT #2, "    stroffs& = stroffs& + 4"
PRINT #2, "NEXT i&"
PRINT #2, "IF numB& > 0 THEN"
PRINT #2, "    FOR i& = 1 TO numB&"
PRINT #2, "        READ dat&"
PRINT #2, "        MID$(rawdata$, stroffs&, 1) = CHR$(dat&)"
PRINT #2, "        stroffs& = stroffs& + 1"
PRINT #2, "    NEXT i&"
PRINT #2, "END IF"
PRINT #2, "'--- set result ---"
PRINT #2, "Read"; tarName$; "Data$ = ";
IF packed% THEN PRINT #2, "LzwUnpack$(rawdata$)": ELSE PRINT #2, "rawdata$"
PRINT #2, "END FUNCTION"
PRINT #2, ""
'--- writeback function ---
PRINT #2, "'"; STRING$(LEN(tarName$) + 18, "-")
PRINT #2, "'--- Write"; tarName$; "Data$ ---"
PRINT #2, "'"; STRING$(LEN(tarName$) + 18, "-")
PRINT #2, "' This function will write the DATAs you've created with MakeDATA.bas"
PRINT #2, "' back to disk and so it rebuilds the original file."
PRINT #2, "'"
PRINT #2, "' After the writeback call, only use the returned realFile$ to access the"
PRINT #2, "' written file. It's your given path, but with an maybe altered filename"
PRINT #2, "' (number added) in order to avoid the overwriting of an already existing"
PRINT #2, "' file with the same name in the given location."
PRINT #2, "'----------"
PRINT #2, "' SYNTAX:"
PRINT #2, "'   realFile$ = Write"; tarName$; "Data$ (wantFile$)"
PRINT #2, "'----------"
PRINT #2, "' INPUTS:"
PRINT #2, "'   --- wantFile$ ---"
PRINT #2, "'    The filename you would like to write the DATAs to, can contain"
PRINT #2, "'    a full or relative path."
PRINT #2, "'----------"
PRINT #2, "' RESULT:"
PRINT #2, "'   --- realFile$ ---"
PRINT #2, "'    - On success this is the path and filename finally used after all"
PRINT #2, "'      applied checks, use only this returned filename to access the"
PRINT #2, "'      written file."
PRINT #2, "'    - On failure this function will panic with the appropriate runtime"
PRINT #2, "'      error code which you may trap and handle as needed with your own"
PRINT #2, "'      ON ERROR GOTO... handler."
PRINT #2, "'---------------------------------------------------------------------"
PRINT #2, "FUNCTION Write"; tarName$; "Data$ (file$)"
PRINT #2, "'--- option _explicit requirements ---"
PRINT #2, "DIM po%, body$, ext$, num%, numL&, numB&, rawdata$, stroffs&, i&, dat&, ff%";
IF packed% THEN PRINT #2, ", filedata$": ELSE PRINT #2, ""
PRINT #2, "'--- separate filename body & extension ---"
PRINT #2, "FOR po% = LEN(file$) TO 1 STEP -1"
PRINT #2, "    IF MID$(file$, po%, 1) = "; CHR$(34); "."; CHR$(34); " THEN"
PRINT #2, "        body$ = LEFT$(file$, po% - 1)"
PRINT #2, "        ext$ = MID$(file$, po%)"
PRINT #2, "        EXIT FOR"
PRINT #2, "    ELSEIF MID$(file$, po%, 1) = "; CHR$(34); "\"; CHR$(34); " OR MID$(file$, po%, 1) = "; CHR$(34); "/"; CHR$(34); " OR po% = 1 THEN"
PRINT #2, "        body$ = file$"
PRINT #2, "        ext$ = "; CHR$(34); CHR$(34)
PRINT #2, "        EXIT FOR"
PRINT #2, "    END IF"
PRINT #2, "NEXT po%"
PRINT #2, "'--- avoid overwriting of existing files ---"
PRINT #2, "num% = 1"
PRINT #2, "WHILE _FILEEXISTS(file$)"
PRINT #2, "    file$ = body$ + "; CHR$(34); "("; CHR$(34); " + LTRIM$(STR$(num%)) + "; CHR$(34); ")"; CHR$(34); " + ext$"
PRINT #2, "    num% = num% + 1"
PRINT #2, "WEND"
PRINT #2, "'--- write DATAs ---"
PRINT #2, "RESTORE "; tarName$
PRINT #2, "READ numL&, numB&"
PRINT #2, "rawdata$ = SPACE$((numL& * 4) + numB&)"
PRINT #2, "stroffs& = 1"
PRINT #2, "FOR i& = 1 TO numL&"
PRINT #2, "    READ dat&"
PRINT #2, "    MID$(rawdata$, stroffs&, 4) = MKL$(dat&)"
PRINT #2, "    stroffs& = stroffs& + 4"
PRINT #2, "NEXT i&"
PRINT #2, "IF numB& > 0 THEN"
PRINT #2, "    FOR i& = 1 TO numB&"
PRINT #2, "        READ dat&"
PRINT #2, "        MID$(rawdata$, stroffs&, 1) = CHR$(dat&)"
PRINT #2, "        stroffs& = stroffs& + 1"
PRINT #2, "    NEXT i&"
PRINT #2, "END IF"
PRINT #2, "ff% = FREEFILE"
PRINT #2, "OPEN file$ FOR OUTPUT AS ff%"
IF packed% THEN
    PRINT #2, "CLOSE ff%"
    PRINT #2, "filedata$ = LzwUnpack$(rawdata$)"
    PRINT #2, "OPEN file$ FOR BINARY AS ff%"
    PRINT #2, "PUT #ff%, , filedata$"
ELSE
    PRINT #2, "PRINT #ff%, rawdata$;"
END IF
PRINT #2, "CLOSE ff%"
PRINT #2, "'--- set result ---"
PRINT #2, "Write"; tarName$; "Data$ = file$"
PRINT #2, "EXIT FUNCTION"
PRINT #2, ""
PRINT #2, "'--- DATAs representing the contents of file "; srcName$
PRINT #2, "'---------------------------------------------------------------------"
PRINT #2, tarName$; ":"
'--- read LONGs ---
PRINT #2, "DATA "; LTRIM$(STR$(cntL& * 8)); ","; LTRIM$(STR$(cntB&))
tmpI$ = SPACE$(32)
FOR z& = 1 TO cntL&
    GET #1, , tmpI$: offI% = 1
    tmpO$ = "DATA " + STRING$(87, ","): offO% = 6
    DO
        tmpL& = CVL(MID$(tmpI$, offI%, 4)): offI% = offI% + 4
        MID$(tmpO$, offO%, 10) = "&H" + RIGHT$("00000000" + HEX$(tmpL&), 8)
        offO% = offO% + 11
    LOOP UNTIL offO% > 92
    PRINT #2, tmpO$
NEXT z&
'--- read remaining BYTEs ---
IF cntB& > 0 THEN
    PRINT #2, "DATA ";
    FOR x% = 1 TO cntB&
        GET #1, , tmpB%%
        PRINT #2, "&H" + RIGHT$("00" + HEX$(tmpB%%), 2);
        IF x% <> 16 THEN
            IF x% <> cntB& THEN PRINT #2, ",";
        ELSE
            IF x% <> cntB& THEN
                PRINT #2, ""
                PRINT #2, "DATA ";
            END IF
        END IF
    NEXT x%
    PRINT #2, ""
END IF
PRINT #2, "END FUNCTION"
PRINT #2, ""
'--- ending ---
CLOSE #2
CLOSE #1

'--- finish message ---
COLOR 10: PRINT: PRINT "file successfully processed..."
COLOR 9: PRINT: PRINT "You must $INCLUDE the created file (target name + .bm extension) at"
PRINT "the end of your program. Look into that file to learn about the"
PRINT "available options to read or write back the embedded data."
IF packed% THEN
    COLOR 12: PRINT: PRINT "Your program must also $INCLUDE 'lzwpacker.bm' available from"
    PRINT "the Libraries Collection here:"
    PRINT "     http://qb64phoenix.com/forum/forumdisplay.php?fid=23"
    PRINT "to be able to read or write back the just processed file."
    KILL tarPath$ + tar$ + ".lzw"
END IF
done:
COLOR 7
END
'--- error handler ---
abort:
COLOR 12: PRINT: PRINT "something is wrong with path/file access, check your inputs and try again..."
RESUME done

'--- Function to define/return the program's version string.
'-----
FUNCTION VersionMakeDATA$
VersionMakeDATA$ = MID$("$VER: MakeDATA 2.0 (26-Oct-2023) by RhoSigma :END$", 7, 38)
END FUNCTION

'$INCLUDE: 'QB64Library\LZW-Compress\lzwpacker.bm'

