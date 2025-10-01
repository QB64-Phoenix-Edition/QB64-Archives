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
'| === MakeCARR.bas ===                                              |
'|                                                                   |
'| == Create a C/C++ array out of the given file, so you can embed   |
'| == it into your program and read it or write it back when needed. |
'|                                                                   |
'| == Two files are created, the .h file, which contains the array(s)|
'| == and some functions, and a respective .bm file which needs to   |
'| == be $INCLUDEd with your program and does provide the FUNCTIONs  |
'| == to read the array(s) into a string or write them back into any |
'| == file. All used functions are standard library calls, no API    |
'| == calls are involved, so the read and writeback should work on   |
'| == all QB64 supported platforms.                                  |
'|                                                                   |
'| == Make sure to adjust the path for the .h file for your personal |
'| == needs in the created .bm files (DECLARE LIBRARY), if required. |
'| == You may specify default paths right below this header.         |
'|                                                                   |
'| == This program needs the 'lzwpacker.bm' file available from the  |
'| == Libraries Collection here:                                     |
'| ==      http://qb64phoenix.com/forum/forumdisplay.php?fid=23      |
'| == as it will try to pack the given file to keep the array(s) as  |
'| == small as possible. If compression is successful, then your     |
'| == program also must $INCLUDE 'lzwpacker.bm' to be able to unpack |
'| == the file data again for write back. MakeCARR.bas is printing   |
'| == a reminder message in such a case.                             |
'|                                                                   |
'+-------------------------------------------------------------------+
'| Done by RhoSigma, R.Heyder, provided AS IS, use at your own risk. |
'| Find me in the QB64 Forum or mail to support@rhosigma-cw.net for  |
'| any questions or suggestions. Thanx for your interest in my work. |
'+-------------------------------------------------------------------+

_TITLE "MakeCARR - Convert File to C-Array v2.0, Done by RhoSigma, Roland Heyder"

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
LINE INPUT "Source Filename: "; src$ 'any file you want to put into a C/C++ array
IF src$ = "" GOTO source
target:
LINE INPUT "Target Basename: "; tar$ 'write stuff into this file(s) (.h/.bm is added)
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

'---------------------------------------------------------------------
' Depending on the source file's size, one or more array(s) are
' created. This is because some C/C++ compilers seem to have problems
' with arrays with more than 65535 elements. This does not affect the
' write back, as the write function will take this behavior into account.
'---------------------------------------------------------------------

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
cntV& = INT(cntL& / 8180)
cntB& = (fl& - (cntL& * 32))

'--- .h include file ---
OPEN "O", #2, tarPath$ + tar$ + ".h"
PRINT #2, "// ============================================================"
PRINT #2, "// === This file was created with MakeCARR.bas by RhoSigma, ==="
PRINT #2, "// === use it in conjunction with its respective .bm file.  ==="
PRINT #2, "// ============================================================"
PRINT #2, ""
PRINT #2, "// --- Array(s) representing the contents of file "; srcName$
PRINT #2, "// ---------------------------------------------------------------------"
'--- read LONGs ---
tmpI$ = SPACE$(32)
FOR vc& = 0 TO cntV&
    IF vc& = cntV& THEN numL& = (cntL& MOD 8180): ELSE numL& = 8180
    PRINT #2, "static const uint32_t "; tarName$; "L"; LTRIM$(STR$(vc&)); "[] = {"
    PRINT #2, "    "; LTRIM$(STR$(numL& * 8)); ","
    FOR z& = 1 TO numL&
        GET #1, , tmpI$: offI% = 1
        tmpO$ = "    " + STRING$(88, ","): offO% = 5
        DO
            tmpL& = CVL(MID$(tmpI$, offI%, 4)): offI% = offI% + 4
            MID$(tmpO$, offO%, 10) = "0x" + RIGHT$("00000000" + HEX$(tmpL&), 8)
            offO% = offO% + 11
        LOOP UNTIL offO% > 92
        IF z& < numL& THEN PRINT #2, tmpO$: ELSE PRINT #2, LEFT$(tmpO$, 91)
    NEXT z&
    PRINT #2, "};"
    PRINT #2, ""
NEXT vc&
'--- read remaining BYTEs ---
IF cntB& > 0 THEN
    PRINT #2, "static const uint8_t "; tarName$; "B[] = {"
    PRINT #2, "    "; LTRIM$(STR$(cntB&)); ","
    PRINT #2, "    ";
    FOR x% = 1 TO cntB&
        GET #1, , tmpB%%
        PRINT #2, "0x" + RIGHT$("00" + HEX$(tmpB%%), 2);
        IF x% <> 16 THEN
            IF x% <> cntB& THEN PRINT #2, ",";
        ELSE
            IF x% <> cntB& THEN
                PRINT #2, ","
                PRINT #2, "    ";
            END IF
        END IF
    NEXT x%
    PRINT #2, ""
    PRINT #2, "};"
    PRINT #2, ""
END IF
'--- some functions ---
PRINT #2, "// --- Function to copy the array(s) into the provided string buffer."
PRINT #2, "// --- Buffer size is not checked, as MakeCARR makes sure it's sufficient."
PRINT #2, "// ---------------------------------------------------------------------"
PRINT #2, "void Read"; tarName$; "Data(char *Buffer)"
PRINT #2, "{"
FOR vc& = 0 TO cntV&
    PRINT #2, "    memcpy(Buffer, &"; tarName$; "L"; LTRIM$(STR$(vc&)); "[1], "; tarName$; "L"; LTRIM$(STR$(vc&)); "[0] << 2);"
    IF vc& < cntV& OR cntB& > 0 THEN
        PRINT #2, "    Buffer += ("; tarName$; "L"; LTRIM$(STR$(vc&)); "[0] << 2);"
        PRINT #2, ""
    END IF
NEXT vc&
IF cntB& > 0 THEN
    PRINT #2, "    memcpy(Buffer, &"; tarName$; "B[1], "; tarName$; "B[0]);"
END IF
PRINT #2, "}"
PRINT #2, ""
PRINT #2, "// --- Saved full qualified output path and filename, so we've no troubles"
PRINT #2, "// --- when cleaning up, even if the current working folder was changed"
PRINT #2, "// --- during program runtime."
PRINT #2, "// ---------------------------------------------------------------------"
PRINT #2, "char "; tarName$; "Name[8192]; // it's a safe size for any current OS"
PRINT #2, ""
PRINT #2, "// --- Cleanup function to delete the written file, called by the atexit()"
PRINT #2, "// --- handler at program termination time, if requested by user."
PRINT #2, "// ---------------------------------------------------------------------"
PRINT #2, "void Kill"; tarName$; "Data(void)"
PRINT #2, "{"
PRINT #2, "    remove("; tarName$; "Name);"
PRINT #2, "}"
PRINT #2, ""
PRINT #2, "// --- Function to write the array(s) back into a file, will return the"
PRINT #2, "// --- full qualified output path and filename on success, otherwise an"
PRINT #2, "// --- empty string is returned (access/write errors, file truncated)."
PRINT #2, "// ---------------------------------------------------------------------"
PRINT #2, "const char *Write"; tarName$; "Data(const char *FileName, int16_t AutoClean)"
PRINT #2, "{"
PRINT #2, "    FILE   *han = NULL; // file handle"
PRINT #2, "    int32_t num = NULL; // written elements"
PRINT #2, ""
PRINT #2, "    #ifdef QB64_WINDOWS"
PRINT #2, "    if (!_fullpath("; tarName$; "Name, FileName, 8192)) return "; CHR$(34); CHR$(34); ";"
PRINT #2, "    #else"
PRINT #2, "    if (!realpath(FileName, "; tarName$; "Name)) return "; CHR$(34); CHR$(34); ";"
PRINT #2, "    #endif"
PRINT #2, ""
PRINT #2, "    if (!(han = fopen("; tarName$; "Name, "; CHR$(34); "wb"; CHR$(34); "))) return "; CHR$(34); CHR$(34); ";"
PRINT #2, "    if (AutoClean) atexit(Kill"; tarName$; "Data);"
PRINT #2, ""
FOR vc& = 0 TO cntV&
    PRINT #2, "    num = fwrite(&"; tarName$; "L"; LTRIM$(STR$(vc&)); "[1], 4, "; tarName$; "L"; LTRIM$(STR$(vc&)); "[0], han);"
    PRINT #2, "    if (num != "; tarName$; "L"; LTRIM$(STR$(vc&)); "[0]) {fclose(han); return "; CHR$(34); CHR$(34); ";}"
    PRINT #2, ""
NEXT vc&
IF cntB& > 0 THEN
    PRINT #2, "    num = fwrite(&"; tarName$; "B[1], 1, "; tarName$; "B[0], han);"
    PRINT #2, "    if (num != "; tarName$; "B[0]) {fclose(han); return "; CHR$(34); CHR$(34); ";}"
    PRINT #2, ""
END IF
PRINT #2, "    fclose(han);"
PRINT #2, "    return "; tarName$; "Name;"
PRINT #2, "}"
PRINT #2, ""
'--- ending ---
CLOSE #2
CLOSE #1

'--- .bm include file ---
OPEN "O", #2, tarPath$ + tar$ + ".bm"
PRINT #2, "'============================================================"
PRINT #2, "'=== This file was created with MakeCARR.bas by RhoSigma, ==="
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
PRINT #2, "'-----------------"
PRINT #2, "'--- Important ---"
PRINT #2, "'-----------------"
PRINT #2, "' If you need to move around this .bm file and its respective .h file"
PRINT #2, "' to fit in your project, then make sure the path in the DECLARE LIBRARY"
PRINT #2, "' statement below does match the actual .h file location. It's best to"
PRINT #2, "' specify a relative path assuming your QB64 installation folder as root."
PRINT #2, "'---------------------------------------------------------------------"
PRINT #2, ""
PRINT #2, "'--- declare C/C++ functions ---"
PRINT #2, "DECLARE LIBRARY "; CHR$(34); tarPath$; tar$; CHR$(34); " 'Do not add .h here !!"
PRINT #2, "    SUB Read"; tarName$; "Data (StrBuf$)"
PRINT #2, "    FUNCTION Write"; tarName$; "Data$ (FileName$, BYVAL AutoClean%)"
PRINT #2, "END DECLARE"
PRINT #2, ""
'--- read function ---
PRINT #2, "'"; STRING$(LEN(tarName$) + 18, "-")
PRINT #2, "'--- Read"; tarName$; "Array$ ---"
PRINT #2, "'"; STRING$(LEN(tarName$) + 18, "-")
PRINT #2, "' This function will read the array(s) you've created with MakeCARR.bas"
PRINT #2, "' into a string, no data will be written to disk. If you rather wanna"
PRINT #2, "' rebuild the original file on disk, then use the write function below."
PRINT #2, "'"
PRINT #2, "' You may directly pass the returned string to _SNDOPEN, _LOADIMAGE or"
PRINT #2, "' _LOADFONT when using the memory load capabilities of these commands."
PRINT #2, "'----------"
PRINT #2, "' SYNTAX:"
PRINT #2, "'   arrData$ = Read"; tarName$; "Array$"
PRINT #2, "'----------"
PRINT #2, "' RESULT:"
PRINT #2, "'   --- arrData$ ---"
PRINT #2, "'    The data of the embedded file. This is in fact the same as if you"
PRINT #2, "'    had opend the file and read its entire content into a single string."
PRINT #2, "'---------------------------------------------------------------------"
PRINT #2, "FUNCTION Read"; tarName$; "Array$"
PRINT #2, "'--- option _explicit requirements ---"
PRINT #2, "DIM temp$"
PRINT #2, "'--- get array & set result ---"
PRINT #2, "temp$ = SPACE$("; LTRIM$(STR$(fl&)); ") 'Do not change this number !!"
PRINT #2, "Read"; tarName$; "Data temp$"
IF NOT packed% THEN
    PRINT #2, "Read"; tarName$; "Array$ = temp$"
ELSE
    PRINT #2, "Read"; tarName$; "Array$ = LzwUnpack$(temp$)"
END IF
PRINT #2, "END FUNCTION"
PRINT #2, ""
'--- writeback function ---
PRINT #2, "'"; STRING$(LEN(tarName$) + 19, "-")
PRINT #2, "'--- Write"; tarName$; "Array$ ---"
PRINT #2, "'"; STRING$(LEN(tarName$) + 19, "-")
PRINT #2, "' This function will write the array(s) you've created with MakeCARR.bas"
PRINT #2, "' back to disk and so it rebuilds the original file."
PRINT #2, "'"
PRINT #2, "' After the writeback call, only use the returned realFile$ to access the"
PRINT #2, "' written file. It's the full qualified absolute path and filename, which"
PRINT #2, "' is made by expanding your maybe given relative path and an maybe altered"
PRINT #2, "' filename (number added) in order to avoid the overwriting of an already"
PRINT #2, "' existing file with the same name in the given location. By this means"
PRINT #2, "' you'll always have safe access to the file, no matter how your current"
PRINT #2, "' working folder changes during runtime."
PRINT #2, "'"
PRINT #2, "' If you wish, the written file can automatically be deleted for you when"
PRINT #2, "' your program will end, so you don't need to do the cleanup yourself."
PRINT #2, "'----------"
PRINT #2, "' SYNTAX:"
PRINT #2, "'   realFile$ = Write"; tarName$; "Array$ (wantFile$, autoDel%)"
PRINT #2, "'----------"
PRINT #2, "' INPUTS:"
PRINT #2, "'   --- wantFile$ ---"
PRINT #2, "'    The filename you would like to write the array(s) to, can contain"
PRINT #2, "'    a full or relative path."
PRINT #2, "'   --- autoDel% ---"
PRINT #2, "'    Shows whether you want the auto cleanup (see description above) at"
PRINT #2, "'    the program end or not (-1 = delete file, 0 = don't delete file)."
PRINT #2, "'----------"
PRINT #2, "' RESULT:"
PRINT #2, "'   --- realFile$ ---"
PRINT #2, "'    - On success this is the full qualified path and filename finally"
PRINT #2, "'      used after all applied checks, use only this returned filename"
PRINT #2, "'      to access the written file."
PRINT #2, "'    - On failure (write/access) this will be an empty string, so you"
PRINT #2, "'      should check for this before trying to access/open the file."
PRINT #2, "'---------------------------------------------------------------------"
PRINT #2, "FUNCTION Write"; tarName$; "Array$ (file$, clean%)"
PRINT #2, "'--- option _explicit requirements ---"
PRINT #2, "DIM po%, body$, ext$, num%";
IF packed% THEN PRINT #2, ", real$, ff%, rawdata$, filedata$": ELSE PRINT #2, ""
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
PRINT #2, "'--- write array & set result ---"
IF NOT packed% THEN
    PRINT #2, "Write"; tarName$; "Array$ = Write"; tarName$; "Data$(file$ + CHR$(0), clean%)"
ELSE
    PRINT #2, "real$ = Write"; tarName$; "Data$(file$ + CHR$(0), clean%)"
    PRINT #2, "IF real$ <> "; CHR$(34); CHR$(34); " THEN"
    PRINT #2, "    ff% = FREEFILE"
    PRINT #2, "    OPEN real$ FOR BINARY AS ff%"
    PRINT #2, "    rawdata$ = SPACE$(LOF(ff%))"
    PRINT #2, "    GET #ff%, , rawdata$"
    PRINT #2, "    filedata$ = LzwUnpack$(rawdata$)"
    PRINT #2, "    PUT #ff%, 1, filedata$"
    PRINT #2, "    CLOSE ff%"
    PRINT #2, "END IF"
    PRINT #2, "Write"; tarName$; "Array$ = real$"
END IF
PRINT #2, "END FUNCTION"
PRINT #2, ""
'--- ending ---
CLOSE #2

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
FUNCTION VersionMakeCARR$
VersionMakeCARR$ = MID$("$VER: MakeCARR 2.0 (26-Oct-2023) by RhoSigma :END$", 7, 38)
END FUNCTION

'$INCLUDE: 'QB64Library\LZW-Compress\lzwpacker.bm'

