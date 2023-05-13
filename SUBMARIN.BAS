DEFINT A-Z

CONST DEFAULTEXPLOSION$ = "Ü°ÛÛÛÛÜÛ°Ü"
CONST DEFAULTTICKCOUNT = 10000
CONST FALSE = 0
CONST SUBMARINE$ = "ÜÜÛÜÜ"
CONST TICKCOUNTSTEP = 1000
CONST TRUE = -1

TYPE BombStr
 Dropped AS INTEGER
 x AS INTEGER
 y AS INTEGER
END TYPE

TYPE EnemyStr
 Disabled AS INTEGER
 x AS INTEGER
 y AS INTEGER
END TYPE

TYPE PlayerStr
 BombCount AS INTEGER
 HitCount AS INTEGER
 Level AS INTEGER
 LevelFinished AS INTEGER
 Score AS INTEGER
 x AS INTEGER
END TYPE

DECLARE SUB AskTryAgain ()
DECLARE SUB CreateSubmarines ()
DECLARE SUB Delay (DelayTickCount AS DOUBLE)
DECLARE SUB DisableEnemy (Enemy AS INTEGER)
DECLARE SUB DisplayStartScreen ()
DECLARE SUB DisplayStatus ()
DECLARE SUB DisplayYouHaveLost ()
DECLARE SUB DisplayYouHaveWon ()
DECLARE SUB DropBomb ()
DECLARE SUB GoToNextLevel ()
DECLARE SUB Initialize ()
DECLARE SUB Main ()
DECLARE SUB MoveSubmarines ()
DECLARE SUB Quit ()

DIM SHARED Bomb AS BombStr
DIM SHARED DelayTickCount AS DOUBLE
DIM SHARED Enemy(0 TO 8) AS EnemyStr
DIM SHARED LevelBackgroundColor(0 TO 4) AS INTEGER
DIM SHARED Player AS PlayerStr

CALL Main

SUB AskTryAgain ()
 PRINT "  Try again (Y/N)?";
 DO
  SELECT CASE UCASE$(INPUT$(1))
   CASE "N"
    Quit
   CASE "Y"
    Player.LevelFinished = TRUE
    Initialize
    DisplayStartScreen
    EXIT DO
  END SELECT
 LOOP
END SUB

SUB CreateSubmarines ()
DIM EnemyIndex AS INTEGER

 FOR EnemyIndex = LBOUND(Enemy) TO UBOUND(Enemy)
  Enemy(EnemyIndex).x = INT(RND * 20) + 3
  Enemy(EnemyIndex).y = INT(RND * 79) + 1
  IF Enemy(EnemyIndex).y + LEN(SUBMARINE) > 79 THEN Enemy(EnemyIndex).y = 79 - LEN(SUBMARINE)
  Enemy(EnemyIndex).Disabled = FALSE
 NEXT EnemyIndex
END SUB

SUB Delay (DelayTickCount AS DOUBLE)
DIM Tick AS DOUBLE

 FOR Tick = 0 TO DelayTickCount
 NEXT Tick
END SUB

SUB DisableEnemy (EnemyIndex AS INTEGER)
DIM Explosion AS STRING
DIM Flash AS INTEGER
DIM KeyStroke AS STRING
DIM x AS INTEGER

 IF NOT Enemy(EnemyIndex).Disabled THEN
  SELECT CASE Bomb.y
   CASE IS < 4
    LOCATE Bomb.x, Bomb.y
    Explosion = MID$(DEFAULTEXPLOSION$, Bomb.y)
   CASE IS > 75
    LOCATE Bomb.x, Bomb.y - 3
    Explosion = MID$(DEFAULTEXPLOSION$, 1, LEN(DEFAULTEXPLOSION$) - (80 - Bomb.y))
   CASE ELSE
    LOCATE Bomb.x, Bomb.y - 3
    Explosion = DEFAULTEXPLOSION$
  END SELECT

  COLOR 14
  PRINT Explosion;

  COLOR 12
  LOCATE Bomb.x, Bomb.y
  PRINT "BOOM!!!";
  FOR Flash = 0 TO 2
   PALETTE 0, 4
   SOUND 37, .3
   SOUND 100, .3
   PALETTE 0, LevelBackgroundColor(Player.Level)
  NEXT Flash

  DisplayStatus

  SLEEP 1
  KeyStroke = INKEY$

  LOCATE Bomb.x, Bomb.y - 3
  PRINT SPC(LEN(Explosion));

  Player.Score = Player.Score + Enemy(EnemyIndex).x
  Bomb.Dropped = FALSE
  Enemy(EnemyIndex).Disabled = TRUE

  FOR x = Enemy(EnemyIndex).x TO 21
   COLOR 9
   LOCATE x, Enemy(EnemyIndex).y
   PRINT "  o  ";
   COLOR 4
   LOCATE x + 1, Enemy(EnemyIndex).y
   PRINT SUBMARINE$;
   Delay DelayTickCount
  NEXT x

  FOR x = Enemy(EnemyIndex).x TO 22
   LOCATE x, Enemy(EnemyIndex).y
   PRINT SPC(LEN(SUBMARINE$));
  NEXT x

  Player.HitCount = Player.HitCount + 1
 END IF
END SUB

SUB DisplayStartScreen ()
 COLOR 14
 PRINT
 PRINT "   Submarine,   By: Peter Swinkels, ***2021***"
 PRINT
 PRINT "      + = go faster"
 PRINT "      - = slow down"
 PRINT "  Space = drop bomb"
 PRINT " Escape = quit"

 DO: LOOP WHILE INKEY$ = ""
END SUB

SUB DisplayStatus ()
 COLOR 2
 LOCATE 1, 1
 PRINT USING "Score: ###   Bombs: ####    Level: #"; Player.Score; Player.BombCount; Player.Level + 1
END SUB

SUB DisplayYouHaveLost ()
 CLS
 COLOR 4
 PRINT
 PRINT "  Û   Û ÜßßßÜ Û   Û  Û  Û ÜßßÜ Û   Û Ûßßß  Û    ÜßßßÜ Üßßß  ßßÛßß Û"
 PRINT "   ßÜß  Û   Û Û   Û  ÛßßÛ ÛßßÛ  Û Û  Ûßß   Û    Û   Û  ßßßÜ   Û   ß"
 PRINT "    ß    ßßß   ßßß   ß  ß ß  ß   ß   ßßßß  ßßßß  ßßß   ßßß    ß   ß"
END SUB

SUB DisplayYouHaveWon ()
 CLS
 COLOR 4
 PRINT
 PRINT "  Û   Û ÜßßßÜ Û   Û  Û  Û ÜßßÜ Û   Û Ûßßß  Û  Ü  Û ÜßßßÜ ÛÜ  Û Û"
 PRINT "   ßÜß  Û   Û Û   Û  ÛßßÛ ÛßßÛ  Û Û  Ûßß   Û Û Û Û Û   Û Û ßÜÛ ß"
 PRINT "    ß    ßßß   ßßß   ß  ß ß  ß   ß   ßßßß   ß   ß   ßßß  ß   ß ß"
END SUB

SUB DropBomb ()
 LOCATE Bomb.x, Bomb.y
 PRINT " ";
 IF Bomb.x = 22 THEN
  Bomb.Dropped = FALSE
 ELSE
  Bomb.x = Bomb.x + 1
  COLOR 8
  LOCATE Bomb.x, Bomb.y
  PRINT "o";
 END IF
END SUB

SUB GoToNextLevel ()
DIM EnemyIndex AS INTEGER

 IF Player.Level = 4 THEN
  DisplayYouHaveWon
  AskTryAgain
 ELSE
  Player.Level = Player.Level + 1
 END IF

 FOR EnemyIndex = LBOUND(Enemy) TO UBOUND(Enemy)
  Enemy(EnemyIndex).Disabled = FALSE
 NEXT EnemyIndex

 Player.BombCount = 25
 Player.HitCount = 0
 Player.LevelFinished = TRUE
END SUB

SUB Initialize ()
 RANDOMIZE TIMER
 PALETTE
 SCREEN 0
 WIDTH 80, 25
 COLOR 7, 0
 CLS
 PALETTE 0, 1

 ERASE Enemy
 ERASE LevelBackgroundColor

 DelayTickCount = DEFAULTTICKCOUNT

 Player.BombCount = 25
 Player.HitCount = 0
 Player.Level = 0
 Player.Score = 0
 Player.x = 1

 LevelBackgroundColor(0) = &H19
 LevelBackgroundColor(1) = &H9
 LevelBackgroundColor(2) = &H11
 LevelBackgroundColor(3) = &H1
 LevelBackgroundColor(4) = &H8
END SUB

SUB Main ()
DIM KeyStroke AS STRING

 Initialize
 DisplayStartScreen

 DO
  CLS
  PALETTE 0, LevelBackgroundColor(Player.Level)
  CreateSubmarines

  DO
   DisplayStatus
   DO
    KeyStroke = INKEY$
    MoveSubmarines
    IF Bomb.Dropped THEN
     DropBomb
    ELSEIF Player.BombCount = 0 THEN
     DisplayYouHaveLost
     AskTryAgain
    END IF
   LOOP WHILE (KeyStroke = "") AND (NOT Player.LevelFinished)
   SELECT CASE KeyStroke
    CASE CHR$(27)
     Quit
    CASE " "
     IF NOT Bomb.Dropped THEN
      Bomb.x = 3
      Bomb.y = Player.x
      Player.BombCount = Player.BombCount - 1
      Bomb.Dropped = TRUE
     END IF
    CASE "+"
     IF DelayTickCount - TICKCOUNTSTEP > 0 THEN DelayTickCount = DelayTickCount - TICKCOUNTSTEP
    CASE "-"
     IF DelayTickCount + TICKCOUNTSTEP < 2147483647 THEN DelayTickCount = DelayTickCount + TICKCOUNTSTEP
   END SELECT
  LOOP UNTIL Player.LevelFinished
  Player.LevelFinished = FALSE
 LOOP
END SUB

SUB MoveSubmarines ()
DIM EnemyIndex AS INTEGER

 LOCATE 2, Player.x
 IF Player.x + LEN(SUBMARINE$) > 79 THEN
  PRINT SPC(LEN(SUBMARINE$));
  Player.x = 1
 ELSE
  COLOR 7
  PRINT " "; SUBMARINE$;
  Player.x = Player.x + 1
 END IF

 FOR EnemyIndex = LBOUND(Enemy) TO UBOUND(Enemy)
  IF Bomb.Dropped THEN
   IF Bomb.x = Enemy(EnemyIndex).x AND Bomb.y >= Enemy(EnemyIndex).y AND Bomb.y <= Enemy(EnemyIndex).y + 5 THEN
    DisableEnemy EnemyIndex
    IF Player.HitCount = Player.Level + 5 THEN
     Player.HitCount = 0
     GoToNextLevel
     EXIT SUB
    END IF
   END IF
  END IF
  IF NOT Enemy(EnemyIndex).Disabled THEN
   LOCATE Enemy(EnemyIndex).x, Enemy(EnemyIndex).y
   IF Enemy(EnemyIndex).y = 1 THEN
    PRINT SPC(LEN(SUBMARINE$) + 1);
    Enemy(EnemyIndex).y = 79 - LEN(SUBMARINE$)
   ELSE
    COLOR 4
    PRINT SUBMARINE$; " ";
    Enemy(EnemyIndex).y = Enemy(EnemyIndex).y - 1
   END IF
  END IF
 NEXT EnemyIndex

 Delay DelayTickCount
END SUB

SUB Quit ()
 PALETTE
 SCREEN 0
 WIDTH 80, 25
 COLOR 7, 0
 CLS
 END
END SUB

