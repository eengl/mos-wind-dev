      SUBROUTINE INT625(KFILDI,KFILDO,KFILEQ,KFILEO,KFILD,KFILCP,
     1                  KFILM,IP,ND11,L3264B,IPINIT,
     2                  NALPH,NEW,NDATE,EQNNAM,EQNNAMO,DIRNAM,
     3                  MODNUM,JFOPEN,NUMIN,NUMOUT,
     4                  RUNID,IER) 
C
C        NOVEMBER 1999   DREWRY   TDL   MOS-2000
C        JUNE     2000   GLAHN    ADDED IUSE( ); TEST FOR ND11 AT 153;
C                                 SOME FORMAT CHANGES; ADDED IP(10)
C                                 AND KFILM
C        AUG      2000   MCE      MODIFIED FORMAT STMNTS FOR IBM
C        MAY      2006   RUDACK   MODIFIED CODE TO ACCOMMODATE MODIFIED
C                                 OUTPUT EQUATION FILES THAT CONTAIN 
C                                 NO DUPLICATE STATIONS.
C        AUGUST   2014   ENGLE    ADDED IP(11) and IP(12)
C
C        PURPOSE
C            INT625 PERFORMS MUCH OF THE INITIALIZATION FOR U625.
C
C        DATA SET USE
C            IP(J)     - UNIT NUMBERS OF OPTIONAL OUTPUT (J=1, 25).
C                        (OUTPUT)
C            KFILCP    - UNIT NUMBER OF PREDICTOR CONSTANT FILE. (INPUT)
C            KFILDI    - UNIT NUMBER OF CONTROL FILE. (INPUT)
C            KFILDO    - UNIT NUMBER OF DIAGNOSTIC OUTPUT FILE. (OUTPUT)
C            KFILEO(J) - UNIT NUMBER(S) OF MODIFIED EQUATION FILE(S),
C                        (J=1, ND11). (OUTPUT)
C            KFILEQ(J) - UNIT NUMBER OF EQUATION FILE(S), (J=1, ND11).
C                        (INPUT)
C            KFILD(J)  - UNIT NUMBER OF MASTER STATION LIST (J=1) AND
C                        STATION DICTIONARY (J=2). (INPUT)
C
C        VARIABLES
C              KFILDI = UNIT NUMBER OF CONTROL FILE. 
C              KFILDO = UNIT NUMBER OF DIAGNOSTIC OUTPUT FILE. 
C            KFILEO(J)= UNIT NUMBER(S) OF MODIFIED EQUATION FILE(S),
C                       (J=1, ND11). 
C            KFILEQ(J)= UNIT NUMBER OF THE EQUATION FILE(S) (J=1,NUMIN).
C                       (INPUT)
C            KFILD(J) = UNIT NUMBER OF MASTER STATION LIST (J=1) AND
C                       STATION DICTIONARY (J=2). (INPUT)
C              KFILCP = UNIT NUMBER OF PREDICTOR CONSTANT FILE.  (INPUT)
C               KFILM = UNIT NUMBER FOR READING THE VARIABLE LIST
C                       TO MATCH WITH THE UNIQUE PREDICTOR LIST.
C                       (INPUT) 
C               IP(J) = EACH VALUE (J=1,25) INDICATES WHETHER (>1)
C                       OR NOT (=0) CERTAIN INFORMATION WILL BE WRITTEN.
C                       WHEN IP( ) > 0, THE VALUE INDICATES THE UNIT
C                       NUMBER FOR OUTPUT.  THESE VALUES SHOULD NOT BE
C                       THE SAME AS ANY KFILX VALUES EXCEPT POSSIBLY
C                       KFILDO, WHICH IS THE DEFAULT OUTPUT FILE.  THIS
C                       IS ASCII OUTPUT, GENERALLY FOR DIAGNOSTIC 
C                       PURPOSES.  THE FILE NAMES WILL BE 4 CHARACTERS
C                       'U600', THEN 4 CHARACTERS FROM IPINIT, THEN 
C                       2 CHARACTERS FROM IP(J) (E.G., 'U600HRG130').
C                       THE ARRAY IS INITIALIZED TO ZERO IN CASE LESS
C                       THAN THE EXPECTED NUMBER OF VALUES ARE READ IN.
C                       EACH OUTPUT ASCII FILE WILL BE TIME STAMPED.
C                       NOTE THAT THE TIME ON EACH FILE SHOULD BE VERY
C                       NEARLY THE SAME, BUT COULD VARY BY A FRACTION
C                       OF A SECOND.  IT IS INTENDED THAT ALL ERRORS
C                       BE INDICATED ON THE DEFAULT, SOMETIMES IN
C                       ADDITION TO BEING INDICATED ON A FILE WITH
C                       A SPECIFIC IP( ) NUMBER, SO THAT THE USER
C                       WILL NOT MISS AN ERROR.
C                       (1) = ALL ERRORS AND OTHER INFORMATION NOT
C                           SPECIFICALLY IDENTIFIED WITH OTHER IP( )
C                           NUMBERS.  WHEN IP(1) IS READ AS NONZERO,
C                           KFILDO, THE DEFAULT OUTPUT FILE UNIT NUMBER,
C                           WILL BE SET TO IP(1).  WHEN IP(1) IS READ
C                           AS ZERO, KFILDO WILL BE USED UNCHANGED.
C                       (4) = THE EQUATION FILE STATION LIST, CALL 
C                           LETTERS ONLY.
C                       (5) = THE EQUATION FILE CALL LETTERS ALONG
C                           WITH THEIR CORRESPONDING NAMES.
C                       (6) = THE EQUATION FILE CALL LETTERS OUTPUT
C                           BY REGION. 
C                       (7) = STATIONS WHICH WERE DUPLICATED IN THE
C                           EQUATION FILE. THE REGIONS IN WHICH THESE
C                           DUPLICATED STATIONS APPEAR IS ALSO OUTPUT.
C                       (8) = ALL STATIONS WHICH APPEAR IN THE EQUATION
C                           FILE BUT WHICH ARE MISSING FROM THE MASTER 
C                           STATION LIST, AS WELL AS ALL STATIONS WHICH
C                           APPEAR IN THE MASTER STATION LIST BUT WHICH
C                           ARE MISSING FROM THE EQUATION FILE.
C                       (9) = ALL STATIONS AND PREDICTANDS FOR WHICH
C                           THERE ARE NO EQUATIONS.
C                       (10) = THE LIST OF U201 VARIABLES READ IN AND
C                           THE LIST OF UNIQUE PREDICTORS NOT IN
C                           THE U201 LIST. 
C                       (11) = THE TOTAL NUMBER OF EQUATIONS, STATIONS
C                            (INCLUDING DUPLICATES), AND FILENAME OF INPUT
C                            EQUATION FILES.
C                       (12) = THE TOTAL NUMBER OF EQUATIONS, STATIONS
C                            (SANS DUPLICATES), AND FILENAME OF OUTPUT
C                            (MODIFIED) EQUATION FILES.
C                       (15) = LIST OF ALL UNIQUE PREDICTORS.
C                       (OUTPUT)
C                ND11 = MAXIMUM NUMBER OF EQUATION FILES.  (INPUT)
C              L3264B = INTEGER WORD LENGTH OF MACHINE BEING USED.
C                       (INPUT)
C              IPINIT = FOUR CHARACTERS READ FROM THE CONTROL FILE THAT
c                       GO INTO THE FILE NAME OF EACH IP USED.  (OUTPUT)
C               NALPH = 1 = OUTPUT FILES WILL HAVE ALPHABATIZED STATIONS.
C                       0 = OTHERWISE.
C                       (OUTPUT)
C                 NEW = 0 WHEN THE CALL LETTERS FROM THE EQUATION FILE 
C                         ARE TO BE OUTPUT.
C                     = 1 WHEN THE ICAO CALL LETTERS ARE TO BE OUTPUT.
C                       (OUTPUT)   
C               NDATE = FOR FILES AS READ BY U700, NDATE MUST = 9999.
C                       FOR FILES AS READ BY U900, NDATE MUST BE OF FORMAT
C                       YYMMDDHH AND BE WITHIN THE RANGE OF THE DATES
C                       ON THE EQUATION FILE.  (INPUT)
C           EQNNAM(J) = NAME OF EACH EQUATION FILE (J=1,NUMIN).
C                       (OUTPUT) 
C       EQNNAMO(ND11) = PATH(S) OF THE MODIFIED EQUATION FILE(S).
C           DIRNAM(J) = HOLDS THE NAMES OF THE FILES OF THE MASTER 
C                       STATION LIST (J=1) AND THE STATION DICTIONARY
C                       (J=2).  (OUTPUT)
C           MODNUM(J) = VARIABLE USED BY RDSNAM (J=1,NUMIN).  NOT 
C                       ACTUALLY NEEDED.  (OUTPUT)
C           JFOPEN(J) = VARIABLE USED IN RDSNAM (J=1,NUMIN).  NOT
C                       ACTUALLY NEEDED.  (OUTPUT)
C               NUMIN = NUMBER OF EQUATION FILES INPUT.  (OUTPUT) 
C               RUNID = RUN ID INPUT IN THE CONTROL FILE BY THE USER.           
C                 IER = STATUS RETURN.  (OUTPUT)
C               CPNAM = NAME AND PATH OF THE PREDICTOR CONSTANT FILE.
C                       (CHARACTER*60) (INTERNAL)
C                   I = LOOP CONTROL VARIABLE. 
C                   J = LOOP CONTROL VARIABLE.
C                 IOS = IOSTAT RETURN.
C               ITEMP = VARIABLE USED BY RDSNAM.
C                   N = VARIABLE USED BY RDSNAM.
C             IUSE(J) = EACH VALUE J PERTAINS TO IP(J).  WHEN AN IP(J)
C                       VALUE IS USED BY THE PROGRAM, IPRINT(J) = 1;
C                       OTHERWISE, IPRINT(J) = 0.  USED BY IPRINT TO
C                       PRINT IP( ) VALUES.  (INTERNAL)
C     
C        NONSYSTEM SUBROUTINES USED
C            IPOPEN, IPRINT, TIMPR, RDSNAM
C
      IMPLICIT NONE
C      
      INTEGER       :: KFILDI, KFILDO, KFILEQ, KFILD, KFILCP, KFILM,
     1                 KFILEO, NALPH, NEW, NDATE, L3264B, ND11, 
     2                 IP, IUSE, MODNUM, MODNUMO, JFOPEN, JFOPENO, 
     3                 NUMIN, NUMOUT , N, ITEMP, I, J, IOS, IER
C
      CHARACTER*4   :: IPINIT, STATE
      CHARACTER*60  :: EQNNAM, EQNNAMO, DIRNAM, CPNAM, CMNAM
      CHARACTER*72  :: RUNID
C     
      DIMENSION KFILEQ(ND11), KFILEO(ND11), EQNNAM(ND11), 
     1          EQNNAMO(ND11), MODNUM(ND11), MODNUMO(ND11),
     2          JFOPEN(ND11), JFOPENO(ND11)
      DIMENSION KFILD(2), DIRNAM(2), IP(25), IUSE(25)
C
      DATA IUSE/1,0,0,1,1,1,1,1,1,1,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0/
C
C        OPEN THE CONTROL FILE
      STATE='105 '     
      OPEN(UNIT=KFILDI,FILE='U625.CN',STATUS='OLD',IOSTAT=IOS,ERR=1000)
C
C        READ AND PROCESS THE PRINT UNIT NUMBERS.  FIRST,
C        INITIALIZE IP( ) IN CASE NOT ALL 25 VALUES ARE READ.  
C
      DO J=1,25
         IP(J)=0
      ENDDO  
C
      STATE='108 '
      READ(KFILDI,108,IOSTAT=IOS,ERR=1000,END=109)IPINIT,(IP(J),J=1,25)
 108  FORMAT(A4,25I3)
C
C        LESS THAN 25 IP( ) VALUES WILL NOT BE INDICATED AS AN ERROR.
C        SOME IP( ) VALUES ARE NOT USED; SEE IUSE( ).
C
      CALL IPOPEN(KFILDO,'U625',IPINIT,IP,IER)
C        WHEN IP(1) NE 0, KFILDO HAS BEEN SET TO IP(1).
C        A FILE WILL BE OPENED FOR EVERY DIFFERENT VALUE IN IP( ).
C        THE FILE NAMES WILL BE 4 CHARACTERS 'U625' THEN 4 CHARACTERS
C        FROM IPINIT, THEN 2 CHARACTERS FROM IP(J).  IPINIT MIGHT BE
C        'HRG1' INDICATING THE PERSONS INITIALS PLUS A SEQUENCE NUMBER.
C
 109  WRITE(KFILDO,110)IPINIT
 110  FORMAT(/,' IPINIT = ',A4)
      CALL IPRINT(KFILDO,IP,IUSE)
C
C        TIME STAMP ALL ASCII OUTPUT OTHER THAN KFILDO.
C        THIS IS NOT DONE IN IPOPEN BECAUSE SOME PROGRAMS
C        MIGHT NOT WANT SOME FILE TO BE TIME STAMPED.
C
      DO 113 J=1,25
      IF(IP(J).EQ.0.OR.IP(J).EQ.KFILDO)GO TO 113
      IF(J.EQ.1)GO TO 112
C
      DO 111 I=1,J-1
      IF(IP(J).EQ.IP(I))GO TO 113
 111  CONTINUE
C
 112  CALL TIMPR(IP(J),IP(J),'START U625          ')
 113  CONTINUE
C
C        READ AND PRINT THE RUN IDENTIFICATION.
C
      STATE='115 '
      READ(KFILDI,115,IOSTAT=IOS,ERR=1000,END=116)RUNID 
 115  FORMAT(A72)
C        LESS THAN 72 CHARACTERS WILL NOT BE CONSIDERED AN ERROR.  
 116  WRITE(KFILDO,117)RUNID
 117  FORMAT(/,' ',A72)
C
C        PRINT TO MAKE SURE USER KNOWS WHAT MACHINE IS BEING USED.
C
      WRITE(KFILDO,119)L3264B
 119  FORMAT(/,' RUNNING ON A',I3,'-BIT MACHINE.')
C
C        READ AND PRINT CONTROL INFORMATION.
C
      STATE='125 '
      READ(KFILDI,125,IOSTAT=IOS,ERR=1000,END=127)
     1     NALPH, NEW, NDATE
 125  FORMAT(2(I10,/),I10)
      GO TO 130
C
C        INCOMPLETE CONTROL INFORMATION SHOULD BE CONSIDERED AN ERROR.
C        HOWEVER, A SHORT RECORD DOES NOT CAUSE AN "END" CONDITION.
C
 127  WRITE(KFILDO,128)
 128  FORMAT(/' ****CONTROL INFORMATION NOT COMPLETE.')
C 
 130  WRITE(KFILDO,135) NALPH, NEW, NDATE
 135  FORMAT(/' NALPH ',I10,'   ALPHABATIZE CALL LETTERS ACCORDING',
     1                      ' TO DIRECTORY, 1 = YES, 0 = NO'/
     2        ' NEW   ',I10,'   NEW ICAO CALL LETTERS, 1 = YES,',
     3                      ' 0 = NO'/
     4        ' NDATE ',I10,'   9999 FOR U700 EQUATION FILES,',
     5                      ' DATE/TIME AT WHICH EQUATIONS ARE',
     6                      ' VALID FOR U900 EQUATION FILES')
C
C        READ AND PROCESS UNIT NUMBERS AND FILE NAMES FOR THE EQUATION
C        FILES. EACH FILE WILL BE OPENED AS 'OLD'.
C
      CALL RDSNAM(KFILDI,KFILDO,KFILEQ,EQNNAM,MODNUM,JFOPEN,ND11,
     1            NUMIN,'OLD','FORMATTED',IP,IER)
      IF (NUMIN.NE.0) THEN
         WRITE(KFILDO,152)(KFILEQ(J),EQNNAM(J),J=1,NUMIN)
 152     FORMAT(/' EQUATION FILE(S) TO READ, UNITS AND NAMES.'/
     1         (' ',I4,2X,A60))
      ENDIF
C
      IF(IER.NE.0)THEN
         WRITE(KFILDO,153)ND11
 153     FORMAT(/,' ****NUMBER OF EQUATION FILES EXCEEDS ND11 = ',I4,/,
     1            '     INCREASE ND11 IN DRIVER.',
     2            '  STOP IN INT625 AT 153.')
         STOP 153
      ENDIF
C
C        READ AND PROCESS UNIT NUMBER(S) AND FILE NAME(S) FOR THE OUTPUT
C        EQUATION FILE(S). THE NUMBER OF THESE FILES MUST EXACTLY EQUAL
C        THE NUMBER OF INPUT EQUATION FILES. EACH FILE WILL BE OPENED AS 'NEW'.
C
      CALL RDSNAM(KFILDI,KFILDO,KFILEO,EQNNAMO,MODNUMO,JFOPENO,ND11,
     1            NUMOUT,'NEW','FORMATTED',IP,IER)
      IF (NUMOUT.NE.0) THEN
         WRITE(KFILDO,154)(KFILEO(J),EQNNAMO(J),J=1,NUMOUT)
 154     FORMAT(/,' MODIFIED EQUATION FILE(S) TO BE OUTPUT, UNITS',
     1            ' AND NAMES.',/,(' ',I4,2X,A60))
       ELSE
         WRITE(KFILDO,155) 
 155     FORMAT(/, ' NO MODIFIED EQUATION FILE(S) WILL BE WRITTEN',
     1             ' TO OUTPUT.')
      ENDIF
C
C        IF THE USER HAS SUPPLIED A MODIFIED EQUATION OUTPUT FILE(S),
C        ENSURE THAT THE NUMBER OF INPUT EQUATION FILES EQUALS THE 
C        NUMBER OF OUTPUT MODIFIED EQUATION FILES.
C
      IF(NUMOUT.GT.0) THEN
         IF (NUMOUT .NE. NUMIN) THEN
            WRITE(KFILDO,156)
 156        FORMAT(/,' ****ERROR:  THE NUMBER OF INPUT EQUATION FILES ',
     1             'DOES NOT',/,'              EQUAL THE NUMBER OF ',
     2             'OUTPUT EQUATION FILES.')
            STOP 156
         ENDIF
      ENDIF
C
C        READ AND PROCESS UNIT NUMBERS AND FILE NAMES FOR THE MASTER
C        STATION LIST (CALL LETTERS) AND STATION DIRECTORY WHICH HOLDS 
C        CALL LETTERS, LATITUDE, LONGITUDE, WBAN NUMBER, ELEVATION, 
C        AND NAMES FOR EACH POSSIBLE STATION.  THIS CAN BE A MASTER
C        DIRECTORY, OR BE A DIRECTORY SUPPLIED BY A USER.  THE 
C        STATION LIST IS OPTIONAL; IF IT IS NOT TO BE USED, JUST
C        SET KFILD(1) = 0 ON INPUT.  NOTE THAT EACH IS READ WITH
C        A TERMINATOR, BECAUSE KFILD(1) MAY BE ZERO.
C
      CALL RDSNAM(KFILDI,KFILDO,KFILD(1),DIRNAM(1),ITEMP,ITEMP,1,N,
     1            'OLD','FORMATTED',IP,IER)
      CALL RDSNAM(KFILDI,KFILDO,KFILD(2),DIRNAM(2),ITEMP,ITEMP,1,N,
     1            'OLD','FORMATTED',IP,IER)
C
      WRITE(KFILDO,157)(KFILD(J),DIRNAM(J),J=1,2)
 157  FORMAT(/' STATION LIST AND DIRECTORY DATA SETS, UNITS AND NAMES.'/
     1       (' ',I4,2X,A60))
C
C        READ AND PROCESS THE UNIT NUMBER AND FILE NAME FOR THE 
C        PREDICTOR CONSTANT FILE.
C
      CALL RDSNAM(KFILDI,KFILDO,KFILCP,CPNAM,ITEMP,ITEMP,1,N,
     1            'OLD','FORMATTED',IP,IER)
      WRITE(KFILDO,160)KFILCP,CPNAM
 160  FORMAT(/' VARIABLE CONSTANT DIRECTORY, UNIT AND NAME.'/
     1       (' ',I4,2X,A60))
C
C        READ AND PROCESS THE UNIT NUMBER AND FILE NAME FOR THE
C        U201-LIKE LIST TO COMPARE WITH THE UNIQUE PREDICTOR LIST.
C
      CALL RDSNAM(KFILDI,KFILDO,KFILM,CMNAM,ITEMP,ITEMP,1,N,
     1            'OLD','FORMATTED',IP,IER)
      WRITE(KFILDO,170)KFILM,CMNAM
 170  FORMAT(/' U201 INPUT VARIABLE LIST, UNIT AND NAME.'/
     1       (' ',I4,2X,A60))
      RETURN
C
 1000 CALL IERX(KFILDO,KFILDO,IOS,'INT625',STATE)
      STOP 1000
      END
   
