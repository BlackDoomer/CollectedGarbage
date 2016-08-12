'Falling Circle v1.5 by Chernov Dmitry
'Nothing preserved. It makes me sad. :C

'Subprograms and functions declaring
DECLARE SUB MainGame ()
DECLARE SUB GameMenu ()
DECLARE SUB HallOfFame (Add)
DECLARE SUB Credits ()
DECLARE SUB ExitGame ()
DECLARE SUB CBText (Text$, TRow, TCol)
DECLARE SUB MTimer (TimeVal AS SINGLE)
DECLARE SUB TrEffect (TEColor!)
DECLARE FUNCTION GetRND (LBnd, UBnd)
DECLARE FUNCTION FixVAL (PVal, PFix)
DECLARE FUNCTION NameInput$ (IFY!, IFX!)

'Global arrays
DIM SHARED HOFNames(1 TO 15) AS STRING * 10
DIM SHARED HOFScore(1 TO 15) AS INTEGER

'Keys and some other variables
DIM SHARED KeyUp AS STRING: KeyUp$ = CHR$(0) + CHR$(72)
DIM SHARED KeyDown AS STRING: KeyDown$ = CHR$(0) + CHR$(80)
DIM SHARED KeyLeft AS STRING: KeyLeft$ = CHR$(0) + CHR$(75)
DIM SHARED KeyRight AS STRING: KeyRight$ = CHR$(0) + CHR$(77)
BackColor = 1

'Initialization code
FOR Cycle = 1 TO 15
  HOFNames(Cycle) = "----------"
NEXT Cycle

SCREEN 0: CLS
COLOR 14, 1
PRINT SPACE$(31); "Falling Circle 1.5"; SPACE$(31)
COLOR 7, 0

PRINT "   Reading data from FALLDOWN.DAT..."
OPEN "FALLDOWN.DAT" FOR BINARY AS #1
IF LOF(1) <> 0 THEN
  FOR Cycle = 1 TO 15
    GET #1, , HOFNames(Cycle)
    GET #1, , HOFScore(Cycle)
  NEXT Cycle
  SEEK #1, 1
  LOCATE 2, 38: PRINT "DONE"
ELSE
  PRINT "   WARNING: FALLDOWN.DAT is empty!"
END IF

SCREEN 7                               'setting screen mode to EGA 320x200
PALETTE 0, BackColor: PALETTE BackColor, 0
GameMenu

'CBText Sub
'Prints randomly coloured text in a given place
SUB CBText (Text$, TRow, TCol)
FOR Cycle = 1 TO 13
  TClr = GetRND(8, 15)
  COLOR TClr
  LOCATE TRow, TCol: PRINT Text$
  MTimer (.1)
NEXT Cycle
COLOR 15: LOCATE TRow, TCol: PRINT SPACE$(LEN(Text$))
END SUB

SUB Credits
FOR Cycle = 13 TO 16
  LOCATE Cycle: PRINT SPACE$(15)
NEXT Cycle
LOCATE 13, 16: PRINT "Version 1.5"
LOCATE 14, 10: PRINT "Everything was written"
LOCATE 15, 8: PRINT "by Chernov Dmitry in 2012."
LOCATE 16, 9: COLOR 8: PRINT "Press any key to return."
WHILE INKEY$ <> "": WEND
SLEEP
END SUB

'ExitGame subprogram
'Some code which should be executed on program's ending
SUB ExitGame
SHARED BackColor
FOR Cycle = 1 TO 15
  PUT #1, , HOFNames(Cycle)
  PUT #1, , HOFScore(Cycle)
NEXT Cycle
CLOSE #1
TrEffect (1)
PALETTE 0, 0: PALETTE BackColor, BackColor
SCREEN 0: WIDTH 80: SYSTEM
END SUB

'FixVAL Function
'Corrects the X coords and widthes of apertures
FUNCTION FixVAL (PVal, PFix)
FixVAL = FIX(PVal / PFix) * PFix
END FUNCTION

SUB GameMenu
'Menu subprogram

DIM MLines(0 TO 3) AS STRING
MLines(0) = "Play!"
MLines(1) = "Hall of Fame"
MLines(2) = "Credits"
MLines(3) = "Quit"

DO

MCursor = 0

CLS : COLOR 11
LOCATE 10, 15: PRINT "F A L L I N G"
LOCATE 11, 15: PRINT " C I R C L E "
COLOR 14

FOR Cycle = 0 TO 3
  LOCATE 13 + Cycle, 15: PRINT MLines(Cycle)
NEXT Cycle

LOCATE 13, 13: PRINT CHR$(16)

'Selecting line
WHILE INKEY$ <> "": WEND
DO
  SELECT CASE INKEY$
    CASE KeyUp$
      IF MCursor > 0 THEN
        LOCATE 13 + MCursor, 13: PRINT CHR$(0)
        MCursor = MCursor - 1
        LOCATE 13 + MCursor, 13: PRINT CHR$(16)
      ELSE
        LOCATE 13 + MCursor, 13: PRINT CHR$(0)
        MCursor = 3
        LOCATE 13 + MCursor, 13: PRINT CHR$(16)
      END IF
    CASE KeyDown$
      IF MCursor < 3 THEN
        LOCATE 13 + MCursor, 13: PRINT CHR$(0)
        MCursor = MCursor + 1
        LOCATE 13 + MCursor, 13: PRINT CHR$(16)
      ELSE
        LOCATE 13 + MCursor, 13: PRINT CHR$(0)
        MCursor = 0
        LOCATE 13 + MCursor, 13: PRINT CHR$(16)
      END IF
    CASE CHR$(27)
      ExitGame
    CASE CHR$(13)
      EXIT DO
  END SELECT
LOOP

'Checking for the selected line
SELECT CASE MCursor
  CASE 0                         'Play!
    TrEffect (1)
    MainGame
  CASE 1                         'Hall of Fame
    TrEffect (1)
    HallOfFame (0)
  CASE 2                         'Credits
    Credits
  CASE 3                         'Quit
    ExitGame
END SELECT

LOOP
END SUB

'GetRND Function
'Produces random integers in a given range
FUNCTION GetRND (LBnd, UBnd)
RANDOMIZE TIMER
GetRND = FIX((UBnd - LBnd + 1) * RND + LBnd)
END FUNCTION

'HallOfFame subprogram
'Shows hall of fame
'Adds new entry if argument > 0
SUB HallOfFame (Add)
CLS
COLOR 11: LOCATE 4, 10: PRINT "H A L L  O F  F A M E:": COLOR 14
LOCATE 6, 3: PRINT "No."
LOCATE 6, 7: PRINT "NAMES:"
LOCATE 6, 28: PRINT "SCORES:"
FOR Cycle = 1 TO 15
  IF LEN(STR$(Cycle)) = 1 THEN
    LOCATE 6 + Cycle, 4: PRINT Cycle
  ELSE
    LOCATE 6 + Cycle, 4 - LEN(STR$(Cycle)) + 1: PRINT Cycle
  END IF
  LOCATE 6 + Cycle, 5: PRINT ". "; HOFNames(Cycle); SPACE$(10); HOFScore(Cycle)
NEXT Cycle

IF Add > 0 THEN
  HOFNames(Add) = NameInput(6 + Add, 7)
  IF HOFNames(Add) = "Player    " THEN LOCATE 6 + Add, 7: PRINT "Player    "
  LOCATE 6 + Add, 27: PRINT HOFScore(Add)
END IF

COLOR 8: LOCATE 23, 9: PRINT "Press any key to return."
SLEEP: TrEffect (1)
END SUB

SUB MainGame
'Main game subprogram.

'Variables and arrays declaring
REDIM CGXErBuf(1 TO 7) AS INTEGER   'Two buffers for coords of the
REDIM CGYErBuf(1 TO 7) AS INTEGER   'previous positions of circle.
REDIM BGXErBuf(1 TO 7) AS INTEGER   'And two buffers for coords of the
REDIM BGYErBuf(1 TO 7) AS INTEGER   'previous positions of bonus.

'Game variables
CirRAD = 7                                               'Radius of the circle
CirSPD = 5                                       'Speed of the circle`s moving
CirCLD = 0                                                    'Collision state
CirX = 162                                              'X coord of the circle
CirY = 14                                               'Y coord of the circle
LineX1 = FixVAL(GetRND(29, 249), CirSPD) - 1    'X coord of the first aperture
LineY1 = 200                                    'Y coord of the first aperture
Width1 = FixVAL(GetRND(25, 70), CirSPD) + 1       'Width of the first aperture
LineX2 = FixVAL(GetRND(29, 249), CirSPD) - 1   'X coord of the second aperture
LineY2 = 301                                   'Y coord of the second aperture
Width2 = FixVAL(GetRND(25, 70), CirSPD) + 1      'Width of the second aperture
LineSPD = 35                                               'Speed of the lines
RealLS = 1                                                          'Step size
FallSPD = 77                       'Speed of the circle`s and bonuses` falling
RealFS = 1                                                          'Step size
iDebug = 0                                                     'ITADEBUG state
ITAInfo = 4                                 'Number of lines of the debug info
ITASPD = 23                                        'Speed reducer for ITADEBUG
ActPage = 1                                           'Active videopage number
VisPage = 0                                          'Visible videopage number
EBuf = 0                                'Number of the circles in erase buffer
Score = 0                                 'Score variable. Not more, not less.
RedSPD = .5                                     'Speed reducer on score giving
CalcFPS = 0                                          'FPS calculating variable
LastFPS = 0                                                          'Last FPS
TimeFPS = 0                             'One more variable for FPS calculating
ViewFPS = 0                                                 'FPS viewing state
BonusA = 0                                        'State of the bonus activity
BonusX = 0                                               'X coord of the bonus
BonusY = 0                                               'Y coord of the bonus
BonusT = 0                       'Type of the bonus. If 0, bonus isn`t spawned
BonRAD = 3                                                'Radius of the bonus
BonCLD = 0                                       'Collision state of the bonus
BonWRK = 7000                                     'Time of the bonus` activity
ProSPW = 700                                        'Bonus spawning probablity
BonSPW = 0                               'Variable to delay the bonus spawning
RealBS = 1                                     'Step size of the bonus falling
EBBuf = 0                           'Number of the bonuses in the erase buffer

CLS
LOCATE 1, 1: COLOR 11: PRINT " Score: 0": COLOR 15
TimeFPS = TIMER
DO
  'Updating the screen
  IF iDebug = 1 THEN GOSUB ITADebug 'updating debug info if ITADEBUG enabled
  GOSUB CirRDW                      'redrawing circle
  GOSUB BonRDW                      'redrawing bonus
  GOSUB LineRDW                     'redrawing lines
  IF TimeFPS + 1 <= TIMER THEN
    TimeFPS = TIMER
    LastFPS = CalcFPS + 1
    CalcFPS = 0
    IF ViewFPS = 1 THEN LOCATE 1, 31: PRINT "FPS:"; LastFPS; SPACE$(3)
  ELSE
    CalcFPS = CalcFPS + 1
  END IF

  'Checking for the game ending
  IF CirY + CirRAD - 1 = 7 AND BonusT <> 1 THEN
    LOCATE 13, 17: COLOR 10: PRINT "You lose."
    LINE (0, 0)-(319, 8), 0, BF
    LOCATE 1, 1: COLOR 11: PRINT " Score:"; Score: COLOR 15
    IF ViewFPS = 1 THEN LOCATE 1, 31: PRINT "FPS:"; LastFPS; SPACE$(3)
    MTimer (1.3): EXIT DO
  END IF

  'Processing lines moving
  RealLS = RealLS - 1
  IF RealLS <= 0 THEN
    RealLS = LineSPD
    LineY1 = LineY1 - 1
    IF LineY1 = 7 THEN
      LINE (0, 8)-(319, 8), 0
      LineX1 = LineX2
      LineY1 = LineY2
      Width1 = Width2
      LineX2 = FixVAL(GetRND(29, 249), CirSPD) - 1
      LineY2 = 201
      Width2 = FixVAL(GetRND(25, 70), CirSPD) + 1
      Score = Score + 10
      LOCATE 1, 1: COLOR 11: PRINT " Score:"; Score: COLOR 15

     'Checking for the scores
      'Speed enlargement if 50 scores has got
      IF Score MOD 50 = 0 AND Score >= 50 THEN LineSPD = LineSPD - RedSPD
      'SPEED REDUCING bonus
      IF Score MOD 700 = 0 AND Score >= 700 THEN
        LineSPD = 35
        RealLS = 1
        RedSPD = RedSPD + .5
        CALL CBText("SPEED REDUCING!", 1, 25)
        WHILE INKEY$ <> "": WEND
      END IF

    ELSE
      LineY2 = LineY2 - 1
    END IF
  END IF

  'Processing bonuses
  IF BonusT <> 0 THEN
    IF POINT(BonusX, BonusY + BonRAD - 1) = 14 THEN BonCLD = 1
    IF POINT(BonusX - BonRAD + 1, BonusY + BonRAD - 1) = 14 THEN BonCLD = 1
    IF POINT(BonusX + BonRAD - 1, BonusY + BonRAD - 1) = 14 THEN BonCLD = 1
    IF BonCLD = 1 THEN
      RealBS = FallSPD
      BonCLD = 0
      GOSUB BGErAdd
      BonusY = BonusY - 1
    ELSE
      IF BonusY + BonRAD - 1 < 199 THEN
        RealBS = RealBS - 1
        IF RealBS <= 0 THEN
          RealBS = FallSPD
          GOSUB BGErAdd
          BonusY = BonusY + 1
        END IF
      ELSE
        RealBS = FallSPD
      END IF
    END IF
    IF BonusY + BonRAD - 1 = 7 THEN
      GOSUB BGErAdd
      BonusX = 0
      BonusY = 0
      BonusT = 0
    END IF
  END IF

  IF BonusA <> 0 THEN
    IF BonWRK <= 0 THEN
      IF BonusA = 1 THEN GOSUB CGErAdd: CirY = 99
      IF BonusA = 2 THEN FallSPD = FallSPD + 70
      BonusA = 0
    ELSE
      IF BonusA = 1 THEN RealLS = 0
      BonWRK = BonWRK - 1
    END IF
  END IF

  IF BonusT = 0 AND BonusA = 0 AND Score >= 500 THEN
    IF BonSPW <= 0 THEN
      BonSPW = ProSPW
      IF GetRND(0, 50) = 25 THEN
        BonusX = GetRND(BonRAD, 319 - BonRAD)
        BonusY = GetRND(LineY1 + 1 + 7, LineY2 - 1 - 7)
        BonusT = GetRND(1, 3)
      END IF
    ELSE
      BonSPW = BonSPW - 1
    END IF
  END IF

  'Processing collisions
  IF POINT(CirX, CirY + CirRAD - 1) = 14 THEN CirCLD = 1
  IF POINT(CirX - CirRAD + 1, CirY + CirRAD - 1) = 14 THEN CirCLD = 1
  IF POINT(CirX + CirRAD - 1, CirY + CirRAD - 1) = 14 THEN CirCLD = 1
  IF CirCLD = 1 THEN
    GOSUB CGErAdd
    CirY = CirY - 1
    CirCLD = 0
    RealFS = FallSPD
  ELSE
    IF CirY + CirRAD - 1 < 199 THEN
      RealFS = RealFS - 1
      IF RealFS <= 0 THEN
        RealFS = FallSPD
        GOSUB CGErAdd
        CirY = CirY + 1
      END IF
      ELSE
        RealFS = FallSPD
    END IF
  END IF

  'Check for key pressing
  SELECT CASE INKEY$
    CASE KeyLeft$                   'if KeyLeft pressed
      IF CirX - 7 > 0 THEN
        FOR Cycle = CirY - CirRAD + 1 TO CirY + CirRAD - 1
          IF POINT(CirX - CirRAD - 1, Cycle) = 14 THEN CirCLD = 1: EXIT FOR
        NEXT Cycle
        IF CirCLD = 0 THEN
          GOSUB CGErAdd
          CirX = CirX - CirSPD
        ELSE
          CirCLD = 0
        END IF
      END IF
    CASE KeyRight$                  'if KeyRight pressed
      IF CirX + 7 < 319 THEN
        FOR Cycle = CirY - CirRAD + 1 TO CirY + CirRAD - 1
          IF POINT(CirX + CirRAD + 1, Cycle) = 14 THEN CirCLD = 1: EXIT FOR
        NEXT Cycle
        IF CirCLD = 0 THEN
          GOSUB CGErAdd
          CirX = CirX + CirSPD
        ELSE
          CirCLD = 0
        END IF
      END IF
    CASE CHR$(27)                   'if ESCape pressed
      EXIT DO
    CASE "p"                        'if "P" pressed (pause)
      LOCATE 13, 15: COLOR 10: PRINT "GAME PAUSED."
      DO UNTIL INKEY$ = "p": LOOP
      LOCATE 13, 15: PRINT SPACE$(12): COLOR 15
    CASE "I"                        'if SHIFT+I pressed (ITADEBUG)
      IF iDebug = 1 THEN
        FOR Cycle = 2 TO ITAInfo + 1
          LOCATE Cycle, 1: PRINT SPACE$(40)
        NEXT Cycle
        iDebug = 0
      ELSE
        iDebug = 1
      END IF
    CASE "r"                        'if "r" pressed with enabled ITADEBUG
      IF iDebug = 1 THEN
        GOSUB CGErAdd
        CirX = 162
        CirY = 193
      END IF
    CASE "s"                        'if "s" pressed with enabled ITADEBUG
      IF iDebug = 1 THEN
        Score = Score + 10
        LOCATE 1, 1: COLOR 11: PRINT " Score:"; Score: COLOR 15
      END IF
    CASE "F"                        'if SHIFT+F pressed (FPS viewing)
      IF ViewFPS = 0 THEN
        ViewFPS = 1
        LOCATE 1, 31: PRINT "FPS:"; LastFPS; SPACE$(3)
      ELSE
        ViewFPS = 0
        LOCATE 1, 31: PRINT SPACE$(10)
      END IF
  END SELECT

  'Checking collision with bonus
  IF BonusT <> 0 THEN
    IF CirY - CirRAD + 1 <= BonusY AND CirY + CirRAD - 1 >= BonusY THEN
      IF CirX - CirRAD + 1 <= BonusX AND CirX + CirRAD - 1 >= BonusX THEN
        GOSUB BGErAdd
        BonusX = 0
        BonusY = 0
        BonusA = BonusT
        BonusT = 0
        GOSUB BonusTime
      END IF
    END IF
  END IF
LOOP                                'End of the main game loop

WHILE INKEY$ <> "": WEND            'We clearing keyboard buffer,
TrEffect (1)                        'beautifully clears the screen,
IF iDebug = 0 THEN                  'checking for the good score,
  FOR Cycle = 1 TO 15
    IF Score > HOFScore(Cycle) THEN
      FOR CSwap = 15 TO Cycle + 1 STEP -1
        SWAP HOFNames(CSwap), HOFNames(CSwap - 1)
        SWAP HOFScore(CSwap), HOFScore(CSwap - 1)
      NEXT CSwap
      HOFNames(Cycle) = ""
      HOFScore(Cycle) = Score
      HallOfFame (Cycle)
      EXIT FOR
    END IF
  NEXT Cycle
END IF
EXIT SUB                            'and returning to the main menu.

CirRDW:                             'Circle redraw subprogram
FOR Cycle = 1 TO EBuf
  CIRCLE (CGXErBuf(Cycle), CGYErBuf(Cycle)), CirRAD, 0
NEXT Cycle
EBuf = 0
CIRCLE (CirX, CirY), CirRAD, 4
RETURN

BonRDW:                             'Bonus redraw subprogram
FOR Cycle = 1 TO EBBuf
  CIRCLE (BGXErBuf(Cycle), BGYErBuf(Cycle)), BonRAD, 0
NEXT Cycle
EBBuf = 0
IF BonusT <> 0 THEN CIRCLE (BonusX, BonusY), BonRAD, 10
RETURN

LineRDW:                            'Lines redraw subprogram
'First line
'Clearing previous lines
LINE (0, LineY1 + 1)-(LineX1, LineY1 + 1), 0
LINE (LineX1 + Width1, LineY1 + 1)-(319, LineY1 + 1), 0
'Drawing new lines
LINE (0, LineY1)-(LineX1, LineY1), 14
LINE (LineX1 + Width1, LineY1)-(319, LineY1), 14
'Second line
'Clearing previous lines
LINE (0, LineY2 + 1)-(LineX2, LineY2 + 1), 0
LINE (LineX2 + Width2, LineY2 + 1)-(319, LineY2 + 1), 0
'Drawing new lines
LINE (0, LineY2)-(LineX2, LineY2), 14
LINE (LineX2 + Width2, LineY2)-(319, LineY2), 14
'Drawing apertures if CRAZY KARATE bonus activated
IF BonusA = 1 THEN
  LINE (CirX - CirRAD + 1, LineY1)-(CirX + CirRAD - 1, LineY1), 0
END IF
RETURN

CGErAdd:                            'Redraw buffer filling subprogram
IF EBuf = 7 THEN RETURN
EBuf = EBuf + 1
CGXErBuf(EBuf) = CirX
CGYErBuf(EBuf) = CirY
RETURN

BGErAdd:                            'Bonus redraw buffer processing
IF EBBuf = 7 THEN RETURN
EBBuf = EBBuf + 1
BGXErBuf(EBBuf) = BonusX
BGYErBuf(EBBuf) = BonusY
RETURN

BonusTime:                          'HOLY M.I.T., it is a BONUS PROCESSING!
SELECT CASE BonusA
  CASE 1                            'CRAZY KARATE bonus
    RealLS = 0
    BonWRK = 7300
    CALL CBText("CRAZY KARATE!", 1, 27)
  CASE 2                            'SCHUMA COCKTAIL bonus
    FallSPD = FallSPD - 70
    BonWRK = 20000
    CALL CBText("SCHUMA COCKTAIL!", 1, 24)
  CASE 3                            'SLOWPOKE`S TABLET bonus
    RedSPD = .5
    BonWRK = 0
    CALL CBText("SLOWPOKE`S TABLET!", 1, 22)
END SELECT
WHILE INKEY$ <> "": WEND
RETURN

ITADebug: 'ITADEBUG module, I adore it!
LOCATE 2, 31: PRINT CHR$(248); "ITADEBUG"
LOCATE 2, 1: PRINT " X:"; CirX; "Y:"; CirY; SPACE$(3)
LOCATE 3, 1: PRINT " BonSPW:"; BonSPW; SPACE$(3)
LOCATE 4, 1: PRINT " LineSPD:"; LineSPD; SPACE$(3)
LOCATE 5, 1: PRINT " FallSPD:"; FallSPD; SPACE$(3)
RealLS = RealLS - ITASPD
RealFS = RealFS - ITASPD
'LINE (0, 0)-(319, 199), 1, B
RETURN

END SUB

'MTimer Subprogram
'Pauses program for a given time
SUB MTimer (TimeVal AS SINGLE)
TimX = 0
Tim1 = TIMER
Tim2 = TIMER - Tim1
DO WHILE TimX < TimeVal
  TimX = TIMER - Tim1 - Tim2
LOOP
END SUB

'NameInput Function
'Gets name from player
'IFY, IFX - input field's location
FUNCTION NameInput$ (IFY, IFX)
  Result$ = ""
  DO
    WHILE INKEY$ <> "": WEND                         'Clearing keyboard buffer
    LOCATE IFY, IFX: PRINT Result$; "_ "
    KEYIN$ = INKEY$
    SELECT CASE KEYIN$
      CASE CHR$(8)                                   'Backspace
        IF LEN(Result$) > 0 THEN
          Result$ = LEFT$(Result$, LEN(Result$) - 1)
        END IF
      CASE CHR$(13)                                  'Enter
        IF LEN(Result$) > 0 THEN NameInput$ = Result$: EXIT DO
      CASE CHR$(27)                                  'Esc
        NameInput$ = "Player    "
        EXIT DO
      CASE KeyUp$, KeyDown$, KeyLeft$, KeyRight$     'Arrows
        SOUND 700, .03
        SOUND 1000, .04
        SOUND 300, .03
      CASE ELSE                                      'Any other key
        IF LEN(Result$) < 10 THEN Result$ = Result$ + KEYIN$
    END SELECT
    KEYIN$ = ""
  LOOP
LOCATE IFY, IFX + LEN(Result$): PRINT " "
END FUNCTION

'TrEffect subprogram
'Beautiful transition effect
'TEColor - color index of effect
SUB TrEffect (TEColor)
FOR Cycle = 0 TO 9
  LINE (0 + Cycle, 0)-(0 + Cycle, 199), TEColor
  LINE (10 + Cycle, 0)-(10 + Cycle, 199), TEColor
  LINE (20 + Cycle, 0)-(20 + Cycle, 199), TEColor
  LINE (30 + Cycle, 0)-(30 + Cycle, 199), TEColor
  LINE (40 + Cycle, 0)-(40 + Cycle, 199), TEColor
  LINE (50 + Cycle, 0)-(50 + Cycle, 199), TEColor
  LINE (60 + Cycle, 0)-(60 + Cycle, 199), TEColor
  LINE (70 + Cycle, 0)-(70 + Cycle, 199), TEColor
  LINE (80 + Cycle, 0)-(80 + Cycle, 199), TEColor
  LINE (90 + Cycle, 0)-(90 + Cycle, 199), TEColor
  LINE (100 + Cycle, 0)-(100 + Cycle, 199), TEColor
  LINE (110 + Cycle, 0)-(110 + Cycle, 199), TEColor
  LINE (120 + Cycle, 0)-(120 + Cycle, 199), TEColor
  LINE (130 + Cycle, 0)-(130 + Cycle, 199), TEColor
  LINE (140 + Cycle, 0)-(140 + Cycle, 199), TEColor
  LINE (150 + Cycle, 0)-(150 + Cycle, 199), TEColor
  LINE (160 + Cycle, 0)-(160 + Cycle, 199), TEColor
  LINE (170 + Cycle, 0)-(170 + Cycle, 199), TEColor
  LINE (180 + Cycle, 0)-(180 + Cycle, 199), TEColor
  LINE (190 + Cycle, 0)-(190 + Cycle, 199), TEColor
  LINE (200 + Cycle, 0)-(200 + Cycle, 199), TEColor
  LINE (210 + Cycle, 0)-(210 + Cycle, 199), TEColor
  LINE (220 + Cycle, 0)-(220 + Cycle, 199), TEColor
  LINE (230 + Cycle, 0)-(230 + Cycle, 199), TEColor
  LINE (240 + Cycle, 0)-(240 + Cycle, 199), TEColor
  LINE (250 + Cycle, 0)-(250 + Cycle, 199), TEColor
  LINE (260 + Cycle, 0)-(260 + Cycle, 199), TEColor
  LINE (270 + Cycle, 0)-(270 + Cycle, 199), TEColor
  LINE (280 + Cycle, 0)-(280 + Cycle, 199), TEColor
  LINE (290 + Cycle, 0)-(290 + Cycle, 199), TEColor
  LINE (300 + Cycle, 0)-(300 + Cycle, 199), TEColor
  LINE (310 + Cycle, 0)-(310 + Cycle, 199), TEColor
  MTimer (.001)
NEXT Cycle
END SUB

