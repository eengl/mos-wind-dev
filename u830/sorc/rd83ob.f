      SUBROUTINE RD83OB(KFILDO,KFILAA,AA,NVRBL,NSTA,KGP,NGP,ND1,
     1                  ND4,IDPARS3,IDISCT,TRESHL,TRESHU,JCOUNT,
     2                  NDATES,IER)
C
C        SEPTEMBER 2007   RUDACK   MDL   MOS-2000
C        AUGUST    2014   ENGLE    MDL   SWITCHED LOOPING VARIABLES ASSOCIATED
C                                        WITH DO 129 (WAS N, NOW L) AND DO 128
C                                        (WAS L, NOW N). THIS FIXES A PROBLEM WHERE
C                                        U830 WOULD CORE DUMP ON INTEL/LINUX.
C
C        PURPOSE
C            RD83OB COUNTS THE TOTAL NUMBER OF MATCHED OBSERVED-FORECAST
C            EVENTS FOR EACH GROUP-CATEGORY PROCESSED BY U830.  
C   
C        DATA SET USE
C            KFILDO    - UNIT NUMBER OF OUTPUT (PRINT) FILE.  (OUTPUT)
C            KFILAA    - UNIT NUMBER OF INTERNAL BINARY FILE.  (INPUT/OUTPUT)
C
C        VARIABLES
C              KFILDO = UNIT NUMBER OF OUTPUT (PRINT) FILE.  (INPUT)
C              KFILAA = UNIT NUMBER OF INTERNAL BINARY FILE.  SET BY
C                       DATA STATEMENT TO 97.  (INPUT)
C             AA(L,K) = THE MATRIX OF DATA (L=1,NVRBL) (K=1,NSTA).  IT IS
C                       ASSUMED THE FIRST VARIABLE (L=1) IS THE OBSERVATION AND 
C                       THE NVRBL-1 OTHERS ARE THE FORECAST PROBABILITIES.  
C                       (INPUT)
C               NVRBL = THE NUMBER OF VARIABLES.  (INPUT)
C                NSTA = THE NUMBER OF STATIONS BEING DEALT WITH.  (INPUT)
C                 KGP = THE NUMBER OF GROUPS OF STATIONS TO BE PROCESSED.
C                       (INPUT)
C              NGP(L) = THE NUMBER OF STATIONS IN EACH GROUP (L=1,KGP).
C                       (INPUT)
C                 ND1 = MAXIMUM NUMBER OF STATIONS THAT CAN BE DEALT WITH.
C                       STORAGE SPACE IS HIGHLY DEPENDENT ON ND1.  (INPUT)
C                 ND4 = MAXIMUM NUMBER OF VARIABLES THAT CAN BE DEALT WITH 
C                       IN ONE RUN.  (INPUT) 
C             IDPARS3 = PORTION OF THE MOS-2000 ID THAT INDICATES
C                       WHETER THE PROCESSING IS CUMULATIVE FROM BELOW, 
C                       CUMULATIVE FROM ABOVE, OR DISCRETE.  (INPUT)
C              IDISCT = IDENTIFIES CUMULATIVE FROM ABOVE OR BELOW IN DISCRETE
C                       CASE (1 = ABOVE, 2 = BELOW) (INPUT)
C           TRESHL(N) = THE LOWER BINARY THRESHOLD CORRESPONDING TO IDPARS( ,N)
C                       (N=1,ND4).  (INPUT)
C           TRESHU(N) = THE UPPER BINARY THRESHOLD CORRESPONDING TO IDPARS( ,N)
C                       (N=1,ND4).  (INPUT)
C         JCOUNT(L,N) = TOTAL NUMBER OF MATCHED OBSERVED-FORECAST EVENTS FOR 
C                       EACH GROUP-CATEGORY PAIR. (L=1,KGP) (N=1,NVRBL) (OUTPUT)
C              NDATES = TOTAL NUMBER OF DATES.  (INPUT)
C                 IER = ERROR RETURN (OUTPUT)
C                       0  = GOOD RETURN.
C                       70 = ERROR READING.
C             KSTA(L) = DURING A PASS, THE TOTAL NUMBER OF STATIONS ALREADY
C                       USED (FOR ALL GROUPS) INCLUDING THE FIRST STATION OF
C                       THE CURRENT GROUP (L=1,KGP).  (INTERNAL)
C                        
C        NONSYSTEM SUBROUTINES USED
C           RD83AA, RD83DA, RD83MS, AND RD83DB
C
      DIMENSION AA(NVRBL,NSTA),KSTA(ND1),NGP(ND1),TRESHL(ND4),
     1          TRESHU(ND4),JCOUNT(KGP,NVRBL)
C
C        DETERMINE THE ACCUMULATED NUMBER OF STATIONS TO BE USED 
C        DURING A PASS FOR THE SET OF GROUP-VARIABLE PAIRS IN THE 
C        SEQUENCE.
C     
      IER=0
      NUMIER=0
C
      KSTA(1)=1
      LSUM=1
      DO 10 L=2,KGP
         LSUM=LSUM+NGP(L-1)
         KSTA(L)=LSUM
 10   CONTINUE
C
      DO 129 L=1,KGP
         DO 128 N=1,NVRBL
            JCOUNT(L,N)=0
 128     CONTINUE
 129  CONTINUE
C
C        ASSIGN THE APPROPRIATE LOOPING INDICES.
C
C        WHEN SUBSEQUENTLY ENTERING SUBROUTINES 'BFABVE'
C        OR 'TSABVE', ASSIGN THESE LOOPING INDICES.
C
      IF ((IDISCT.EQ.0).AND.(IDPARS3.EQ.1)) THEN
         IRUN=1
      ELSEIF ((IDISCT.EQ.1).AND.(IDPARS3.EQ.3)) THEN
         IRUN=2
C
C        WHEN SUBSEQUENTLY ENTERING SUBROUTINES 'BFBLOW' 
C        OR 'TSBLOW', ASSIGN THESE LOOPING INDICES.
C
      ELSEIF ((IDISCT.EQ.0).AND.(IDPARS3.EQ.2)) THEN 
         IFINSH=NVRBL-1
      ELSEIF ((IDISCT.EQ.2).AND.(IDPARS3.EQ.3)) THEN
         IFINSH=NVRBL-2
      ENDIF
C
C        PASS THROUGH THE DATA ONCE TO DETERMINE THE TOTAL
C        NUMBER OF MATCHED OBSERVED-FORECASTS EVENTS FOR EACH 
C        GROUP-CATEGORY PAIR.
C
      DO 500 ND=1,NDATES
C
         CALL RD83AA(KFILDO,KFILAA,AA,NVRBL*NSTA,IER)
C
C           IF RD83AA COULD NOT READ ANY OF THE DATA FOR ALL NDATES
C           RETURN AN IER VALUE OF 80 TO DIAGNOSTIC PRINT AND TERMINATE 
C           THE PROGRAM.  IF ONLY A PORTION OF THE DAYS COULD NOT BE 
C           READ BY RD83AA THEN CONTINUE READING AA AND LET THE PROGRAM 
C           RUN TO COMPLETION.
C
         IF(IER.NE.0)THEN
C
            WRITE(KFILDO,145) ND
 145        FORMAT(/,' ****ERROR READING MATRIX AA ON DAY',I5,
     1               ' BY SUBROUTINE RD83AA IN RD83OB.')
            NUMIER=NUMIER+1
C
            IF(NUMIER.EQ.NDATES) THEN
               IER=80
               WRITE(KFILDO,180) NUMIER,IER
 180           FORMAT(/,' **** DATA FOR ALL ',I4,' DATES COULD NOT BE',
     1                  ' PROCESSED IN RD83OB.  IER = ',I2,
     2                  ' STOP 180 IN RD83OB.')
               STOP 180
            ENDIF
C
C              TRY READING ANOTHER DAYS WORTH OF DATA.
            GO TO 500
C
         ENDIF
C
C           ENSURE THAT ALL OF THE CATEGORICAL PROBABILITIES ARE EITHER
C           ALL AVAILABLE OR ALL MISSING.
C
         CALL RD83MS(KFILDO,AA,NVRBL,NSTA,KGP,NGP,KSTA,ND1,ND4)
C
C           IF PROCESSING CUMULATIVE FROM ABOVE PROBABILITIES OR
C           DISCRETE PROBABILITES COMING FROM ABOVE, DO THE FOLLOWING.
C
         IF (((IDISCT.EQ.0).AND.(IDPARS3.EQ.1)).OR.
     1       ((IDISCT.EQ.1).AND.(IDPARS3.EQ.3))) THEN
C
C              IF THE USER IS PROCESSING DISCRETE PROBABILITIES COMING
C              FROM ABOVE.
            IF(IDISCT.EQ.1)
     1         CALL RD83DA(KFILDO,AA,NVRBL,NSTA,KGP,NGP,KSTA,ND1,ND4)
C
C              COUNT THE NUMBER OF MATCHED OBSERVATION-FORECAST EVENTS
C              FOR EACH GROUP-CATEGORY.
C
            DO 249 N=IRUN,NVRBL-1
               DO 248 L=1,KGP
                  DO 247 K=KSTA(L),NGP(L)+KSTA(L)-1
                     IF(((NINT(AA(1,K)).NE.9999).AND.
     1                  (AA(1,K).GE.TRESHL(N+1))).AND.
     2                 ((NINT(AA(N+1,K)).NE.9999).AND.
     3                  (NINT(AA(N+1,K)).NE.9997)))
     4                  JCOUNT(L,N)=JCOUNT(L,N)+1
 247              CONTINUE
 248           CONTINUE
 249        CONTINUE
C
C           IF PROCESSING CUMULATIVE FROM BELOW PROBABILITIES OR
C           DISCRETE PROBABILITES COMING FROM BELOW, DO THE FOLLOWING.
C
         ELSEIF(((IDISCT.EQ.0).AND.(IDPARS3.EQ.2)).OR.
     1          ((IDISCT.EQ.2).AND.(IDPARS3.EQ.3))) THEN
C
C              IF THE USER IS PROCESSING DISCRETE PROBABILITIES COMING
C              FROM BELOW.
            IF(IDISCT.EQ.2) 
     1         CALL RD83DB(KFILDO,AA,NVRBL,NSTA,KGP,NGP,KSTA,ND1,ND4)
C
C              COUNT THE NUMBER OF MATCHED OBSERVATION-FORECAST EVENTS
C              FOR EACH GROUP-CATEGORY.
C
            DO 349 N=1,IFINSH
               DO 348 L=1,KGP
                  DO 347 K=KSTA(L),NGP(L)+KSTA(L)-1
C
                     IF(((NINT(AA(1,K)).NE.9999).AND.
     1                  (AA(1,K).LT.TRESHU(N+1))).AND.
     2                 ((NINT(AA(N+1,K)).NE.9999).AND.
     3                  (NINT(AA(N+1,K)).NE.9997)))
     4                  JCOUNT(L,N)=JCOUNT(L,N)+1
 347              CONTINUE
 348           CONTINUE
 349        CONTINUE
C
         ENDIF
C
 500  CONTINUE 
C
D     DO 600 L=1,KGP
D        DO 599 N=2,NVRBL
D            WRITE(KFILDO,*) 'CATEGORY = ',N
D            DO 598 K=KSTA(L),NGP(L)+KSTA(L)-1
D               WRITE(KFILDO,*) 'AA = ',AA(N,K)
D 598        CONTINUE 
D 599     CONTINUE
D 600  CONTINUE
C
      REWIND KFILAA
C
      RETURN
      END  