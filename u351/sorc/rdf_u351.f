      SUBROUTINE RDF_U351(KFILDO,IPN,KFIL,DATA,ND,TEMP,NT,FMT,
     &			  NVAL,TERM,IER) 
C 
C        JANUARY 1994   GLAHN   TDL   MOS-2000 
C        JUNE 2000/2001 ALLEN   MODIFIED THE ORIGINAL RDF SO THAT IT WOULD
C                               READ THE DATA VALUES INTO A CHARACTER STRING
C                               INSTEAD OF A REAL ARRAY.  THIS ALLOWED FOR
C                               DELETING TRUE BLANKS, BUT MAINTAINING TRUE
C                               VALUES OF ZERO.  THE DATA IS THEN PUT INTO
C                               A REAL ARRAY.  THE CURRENT CONFIGURATION
C                               REQUIRES THAT THE DATA HAVE A FIELD WIDTH
C                               OF 9.  (THE FIX WAS ORIGINALLY DEVISED IN
C                               JUNE 2000, BUT NOT MADE OFFICIAL UNTIL
C                               JUNE 2001)
C        DECEMBER 2002  RLC     MODIFIED SOME FORMAT STATEMENTS FOR THE IBM
C
C        PURPOSE 
C            TO READ A LIST OF REAL DATA ACCORDING TO A SPECIFIED
C            FORMAT AND RETURN THE LIST IN ARRAY DATA( ).
C            THE LIST IS TERMINATED BY A TERMINATOR TERM. 
C            THE TERMINATER TERM MUST BE A REAL IN THE CALLING PROGRAM.
C            NOTE THAT THE REAL VARIABLE CAN BE FILLED WITH CHARACTERS,
C            BUT CANNOT BE DECLARED CHARACTER IN THE CALLING PROGRAM. 
C            FMT MUST BE DECLARED CHARACTER OR BE A CHARACTER STRING IN
C            THE CALLING PROGRAM. FMT WILL INDICATE
C            HOW MANY VALUES TO READ PER RECORD (NT OR LESS); HOWEVER,
C            THE RECORD NEED NOT HAVE THAT MANY VALUES.    
C
C        DATA SET USE 
C            KFILDO - DEFAULT UNIT NUMBER FOR OUTPUT (PRINT) FILE.  (OUTPUT) 
C            IPN    - UNIT NUMBER FOR OUTPUT (PRINT) FILE.  (OUTPUT) 
C            KFIL   - UNIT NUMBER FROM WHICH TO READ DATA.  (INPUT) 
C 
C        VARIABLES 
C 
C            INPUT 
C              KFILDO = DEFAULT UNIT NUMBER FOR OUTPUT (PRINT) FILE. 
C                       DIAGNOSTICS WILL BE WRITTEN HERE.
C                 IPN = UNIT NUMBER FOR OPTIONAL OUTPUT (PRINT) FILE.
C                       WHEN DIAGNOSTICS ARE WRITTEN TO KFILDO, THEY WILL
C                       ALSO BE WRITTEN TO UNIT NO. IPN UNLESS IPN = KFILDO
C                       OR IPN <= 0.
C                KFIL = UNIT NUMBER FROM WHICH TO READ DATA. 
C                  ND = SIZE OF ARRAY DATA( ). 
C             TEMP( ) = TEMPORARY REAL ARRAY THAT MUST BE OF AT LEAST SIZE NT. 
C            CTEMP( ) = TEMPORARY CHARACTER ARRAY THAT IS USED TO LOOK FOR
C                       BLANKS IN THE DATA.  MUST BE OF AT LEAST SIZE NT. 
C                  NT = NUMBER OF WORDS PER RECORD. 
C              FMT( ) = CONTAINS FORMAT OF DATA.  THIS MUST PERTAIN TO
C                       REAL DATA.  (CHARACTER*(*)) 
C                NVAL = COUNT OF ELEMENTS IN ARRAY RETURNED. 
C                TERM = TERMINATOR.
C              STRING = 80 CHARACTER STRING USED TO READ IN ONE LINE OF THE
C                       INPUT DATA AT A TIME.
C               BLANK = 9 BLANK SPACES, USED TO IDENTIFY A BLANK SPACE IN 
C                       THE INPUT DATA.
C                 IER = STATUS RETURN.
C                       0  = GOOD RETURN.
C                       20 = ERROR OR END OF FILE ON UNIT KFIL.
C                       21 = LIST TOO LONG FOR DIMENSION ND ON UNIT KFIL.
C
C            OUTPUT 
C             DATA( ) = ARRAY IN WHICH DATA ARE RETURNED (J=1,NVAL). 
C 
C        NONSYSTEM SUBROUTINES CALLED 
C            NONE. 
C
      CHARACTER*(*) FMT
      CHARACTER*9 BLANK,CTEMP(NT)
      CHARACTER*80 STRING
C 
      DIMENSION DATA(ND),TEMP(NT)
C
      DATA BLANK/'        '/
C
      IER=0 
      NVAL=0 
C
C        READ A RECORD AS A CHARACTER STRING.
C      
 115  READ(KFIL,100,IOSTAT=IOS,ERR=116,END=116)STRING
 100  FORMAT(A80)
C        MORE VALUES IN THE RECORD THAN NT DOES NOT CAUSE AN ERROR.
C        ONLY NT WILL BE READ.  A RECORD TOO LONG MAY CAUSE THE
C        TERMINATOR TO BE SKIPPED.
      GO TO 119 
C 
 116  IER=20 
      WRITE(KFILDO,117)KFIL,IOS,IER 
      IF(IPN.NE.KFILDO.AND.IPN.GT.0)WRITE(IPN,117)KFIL,IOS,IER 
 117  FORMAT(/' ****ERROR OR END OF FILE ON UNIT NO.',I3,'.  IOSTAT =', 
     1        I5,/,'     RETURN FROM RDI AT 117 WITH IER =',I3)
      GO TO 135 
C
C        PROCESS DATA IN RECORD.
C 
C        FIRST, USE AN INTERNAL READ TO ASSIGN THE DATA VALUES TO 
C        THE REAL VARIABLE TEMP
 119  READ(STRING,FMT)(TEMP(J),J=1,NT)
      DO 125 K=1,NT 
C        NEXT, PARSE THE CHARACTER STRING INTO 7 9-CHARACTER PIECES
C        WHICH CAN THEN BE CHECKED FOR BLANKS.
      KK=(9*K)-8
      JJ=(9*K)
      CTEMP(K)=STRING(KK:JJ)
C        BLANK SPACES ARE IGNORED, THE TERMINATOR ENDS THE PROCESSING
      IF(CTEMP(K).EQ.BLANK)GO TO 125 
      IF(CTEMP(K).EQ.'   999999')GO TO 135
C        THE LIST IS TERMINATED WITH THE TERMINATOR TERM. 
      NVAL=NVAL+1 
      IF(NVAL.GT.ND)GO TO 130 
      DATA(NVAL)=TEMP(K) 
 125  CONTINUE 
C
C        READ ANOTHER RECORD.
      GO TO 115 
C 
C        THE LIST IS TOO LONG FOR THE ARRAY DATA( ).
C
 130  NVAL=NVAL-1
      IER=21 
      WRITE(KFILDO,131)KFIL,IER 
      IF(IPN.NE.KFILDO.AND.IPN.GT.0)WRITE(IPN,131)KFIL 
 131  FORMAT(/' ****LIST TOO LONG ON UNIT NO.',I3,
     1        '.  RETURN FROM RDF AT 131 WITH IER = ',I3,'.') 
C****      WRITE(KFILDO,132)(DATA(J),J=1,NVAL),TEMP 
C**** 132  FORMAT(' '10E12.6)      
      IER=21 
C 
 135  RETURN 
      END 
