      PROGRAM DRU201
C
C        FEBRUARY 1995   GLAHN   TDL   MOS-2000
C        JANUARY  1996   GLAHN   EQUIVALENCED IWBAN( ) AND SDATA( ).
C        JANUARY  1996   GLAHN   REMOVED VARIABLE NBYTES
C        MARCH    1997   GLAHN   ADDED JFOPEN( ).
C        JUNE     1997   GLAHN   ADDED ISTAV( ) AND INDEXC( , )
C                                CHANGED DIMENSION OF CCALLD( ), ETC.
C        JULY     1997   GLAHN   OPEN 'U201.CN' FILE MOVED FROM U201.
C        JULY     1997   GLAHN   DIMENSIONS OF CCALL( ) AND ICALL( , )
C                                CHANGED 
C        MAY      1998   GLAHN   ADDED ITIMEZ( ) 
C        AUGUST   1998   GLAHN   REDEFINED ND5 AND ND2X3
C        NOVEMBER 1998   GLAHN   REMOVED ICALLP( , ) AND CCALLP( )
C        FEBRUARY 2003   WEISS   THE PARAMETER STATEMENT:
C                                PARAMETER (ND5=ND2X3)
C                                HAS BEEN CHANGED TO:
C                                PARAMETER (ND5=MAX(ND2X3,###)
C                                WHERE ### IS A NUMBER USED FOR 
C                                VERY LARGE GRIDS.
C        MARCH    2003   WEISS   ADDED PARAMETER MAXGRD: THE MAXIMUM
C                                GRID SIZE. 
C        APRIL    2003   SHEETS  COMMENTED LARGE ND2X3 AND LOWERED 
C                                MAXGRD AS TEMP GFETCH FIX
C
C        PURPOSE
C           DRIVER FOR PROGRAM U201.  SEE U201 COMMENTS OR PROGRAM
C           WRITEUP FOR VARIABLE DEFINITIONS.  AN ATTEMPT HAS BEEN
C           MADE TO INCLUDE ALL INFORMATION IN THIS DRIVER THAT
C           THE USER OF U201 MIGHT HAVE TO CHANGE.  THE OPEN TO
C           THE CONTROL FILE 'U201.CN' IS HERE SO THAT ACCESS TO THE
C           CONTROL FILE CAN BE MODIFIED FOR CRAY OR BATCH HP JOBS.
C           U201 AND DRU201 HAVE BEEN ADAPTED (FEBRUARY, 2003) TO 
C           HANDLE VERY LARGE GRIDS IF REQUIRED.
C
C        DATA SET USE
C            KFILDI    - UNIT NUMBER OF DEFAULT INPUT FILE.
C                        THIS IS PROBABLY SPECIFIED FOR THE SYSTEM
C                        BEING USED.  SET IN DATA STATEMENT.
C            KFILDO    - UNIT NUMBER OF DEFAULT OUTPUT (PRINT) FILE.
C                        THIS IS PROBABLY SPECIFIED FOR THE SYSTEM
C                        BEING USED.  SET IN DATA STATEMENT.
C
C        LET ND1  = THE MAXIMUM NUMBER OF STATIONS THAT CAN BE DEALT WITH.
C                   ALSO, IT MUST BE GE NBLOCK IN LINEARIZATION ROUTINES.
C            ND2  = ND2*ND3 IS THE MAXIMUM SIZE OF THE GRID THAT CAN
C                   BE DEALT WITH.
C            ND3  = ND2*ND3 IS THE MAXIMUM SIZE OF THE GRID THAT CAN
C                   BE DEALT WITH.  SEE ND2.  BECAUSE ND5 = ND2X3,
C                   AND ND5 MAY NEED TO BE LARGER THAN ND2X3, ND2
C                   OR ND3 MAY NEED TO BE SET LARGER THAN NECESSARY.
C                   SINCE THE INDIVIDUAL VALUES OF ND2 AND ND3 ARE
C                   NOT USED, THIS IS OK.
C            ND4  = THE MAXIMUM NUMBER OF PREDICTORS FOR WHICH 
C                   INTERPOLATED VALUES CAN BE PROVIDED.
C            ND5  = DIMENSION OF IPACK( ), IWORK( ), AND DATA( ).
C                   THESE ARE GENERAL PURPOSE ARRAYS, SOMETIMES USED
C                   FOR GRIDS.  ND5 MUST BE SET GE ND2X3.
C                   ALSO, BECAUSE IPACK( ) AND IWORK( ) ARE
C                   USED AS WORK ARRAYS IN RDSNAM, ND5 SHOULD NOT BE
C                   LT ND12.
C            ND6  = MAXIMUM NUMBER OF MODELS THAT CAN BE DEALT WITH.
C            ND7  = DIMENSION OF IS0( ), IS1( ), IS2( ), AND IS4( ).
C                   SHOULD BE GE 54.
C            ND8  = MAXIMUM NUMBER OF DATES THAT CAN BE DEALT WITH.
C            ND9  = MAXIMUM NUMBER OF FIELDS THAT CAN BE DEALT WITH.
C                   EFFECTIVELY, THIS IS THE TOTAL NUMBER OF FIELDS
C                   IN ALL MODELS USED FOR DAY 1.
C            ND10 = THE MEMORY IN WORDS ALLOCATED TO THE SAVING OF 
C                   PACKED GRIDPOINT FIELDS AND UNPACKED VECTOR DATA.
C                   WHEN THIS SPACE IS EXHAUSTED, SCRATCH DISK WILL
C                   BE USED.
C            ND11 = MAXIMUM NUMBER OF GRID COMBINATIONS THAT CAN BE
C                   DEALT WITH ON THIS RUN.
C            ND12 = THE NUMBER OF MOS-2000 EXTERNAL RANDOM ACCESS
C                   FILES THAT CAN BE USE ON THIS RUN.
C        THEN IT IS SUFFICIENT THAT THE DIMENSIONS OF VARIABLES BE
C        AS INDICATED BELOW IN THIS EXAMPLE DRIVER.  NOTE THAT THE
C        VARIABLE L3264B IS SET TO 32 FOR A 32-BIT MACHINE AND TO
C        64 FOR A 64-BIT MACHINE.  L3264W AND NBLOCK WILL
C        AUTOMATICALLY ADJUST ACCORDINGLY.
C
      PARAMETER (L3264B=32)
      PARAMETER (L3264W=64/L3264B)
      PARAMETER (NBLOCK=6400/L3264B)
      PARAMETER (MAXSTA=13000)
      PARAMETER (ND1=MAX(NBLOCK,MAXSTA))
C***      PARAMETER (MAXGRD=5100000) GTOPO 5 KM GRID
      PARAMETER (MAXGRD=13700)
      PARAMETER (ND2=297, 
     1           ND3=169)
C***      PARAMETER (ND2=270,
C***     1           ND3=270)
      PARAMETER (ND4=10000)
      PARAMETER (ND6=150)
      PARAMETER (ND7=54)
      PARAMETER (ND8=10000)
      PARAMETER (ND9=10000)
      PARAMETER (ND10=8000000)
      PARAMETER (ND11=4)
      PARAMETER (ND12=5)
      PARAMETER (ND2X3=MAX(ND1,ND2*ND3,ND12))
      PARAMETER (ND5=MAX(ND2X3,MAXGRD))
C
      CHARACTER*8 CCALL(ND1,6)
      CHARACTER*8 CCALLD(ND5)
      CHARACTER*12 UNITS(ND4)
      CHARACTER*20 NAME(ND1)
      CHARACTER*32 PLAIN(ND4)
      CHARACTER*60 NAMIN(ND6),RACESS(ND12)
C
      DIMENSION ICALL(L3264W,ND1,6),
     1          NELEV(ND1),IWBAN(ND1),STALAT(ND1),STALON(ND1),
     2          ITIMEZ(ND1),ISDATA(ND1),SDATA(ND1),SDATA1(ND1),
     3          L1DATA(ND1)
      DIMENSION FD1(ND2X3),FD2(ND2X3),FD3(ND2X3),FD4(ND2X3),
     1          FD5(ND2X3),FD6(ND2X3),FD7(ND2X3),
     2          FDVERT(ND2X3),FDTIME(ND2X3),
     3          FDA(ND2X3),
     4          FDSINS(ND2X3),FDMS(ND2X3)
      DIMENSION ID(4,ND4),IDPARS(15,ND4),THRESH(ND4),JD(4,ND4),
     1          INDEX(ND4),JP(3,ND4),IFIND(ND4),ISTAV(ND4),ITIME(ND4),
     2          ISCALD(ND4),SMULT(ND4),SADD(ND4),ORIGIN(ND4),CINT(ND4)
      DIMENSION IPLAIN(L3264W,4,ND4)
      DIMENSION IPACK(ND5),DATA(ND5),IWORK(ND5),ICALLD(L3264W,ND5)
      DIMENSION KFILIN(ND6),MODNUM(ND6),LDATB(ND6),LDATE(ND6),
     1          JFOPEN(ND6),LKHERE(ND6),MSDATE(ND6)
      DIMENSION INDEXC(ND1,ND6)
      DIMENSION IS0(ND7),IS1(ND7),IS2(ND7),IS4(ND7)
      DIMENSION IDATE(ND8),NWORK(ND8)
      DIMENSION LSTORE(12,ND9),MSTORE(7,ND9)
      DIMENSION CORE(ND10)
      DIMENSION DIR(ND1,2,ND11),NGRIDC(6,ND11)
      DIMENSION KFILRA(ND12)
C
      EQUIVALENCE (PLAIN,IPLAIN)
      EQUIVALENCE (ICALL,CCALL),(ICALLD,CCALLD)
      EQUIVALENCE (IWBAN,SDATA)
C
      DATA KFILDI/5/,
     1     KFILDO/12/
      DATA PLAIN/ND4*' '/ 
      DATA LDATB/ND6*2100000000/
      DATA LDATE/ND6*-2100000000/
      DATA LKHERE/ND6*1/
C
      CALL TIMPR(KFILDO,KFILDO,'START U201          ')
      OPEN(UNIT=KFILDI,FILE='U201.CN',STATUS='OLD',IOSTAT=IOS,ERR=900)
C
      CALL U201(KFILDI,KFILDO,
     1          ICALL,CCALL,NELEV,
     2          IWBAN,STALAT,STALON,ITIMEZ,ISDATA,SDATA,SDATA1,
     3          L1DATA,NAME,ND1,FD1,FD2,FD3,FD4,FD5,FD6,FD7,
     4          FDA,FDVERT,FDTIME,FDSINS,FDMS,ND2,ND3,ND2X3,
     5          ID,IDPARS,THRESH,JD,INDEX,JP,IFIND,ISTAV,ITIME,
     6          ISCALD,SMULT,SADD,ORIGIN,CINT,UNITS,ND4,
     7          PLAIN,IPLAIN,L3264B,L3264W,
     8          IPACK,DATA,IWORK,ICALLD,CCALLD,ND5,
     9          KFILIN,NAMIN,JFOPEN,MODNUM,LDATB,LDATE,
     A          LKHERE,MSDATE,INDEXC,ND6,
     B          IS0,IS1,IS2,IS4,ND7,
     C          IDATE,NWORK,ND8,
     D          LSTORE,MSTORE,ND9,
     E          CORE,ND10,NBLOCK,
     F          DIR,NGRIDC,ND11,
     G          KFILRA,RACESS,ND12)
C
      CALL TIMPR(KFILDO,KFILDO,'END U201            ')
      STOP 201
C
 900  CALL IERX(KFILDO,KFILDO,IOS,'DRU201','900 ')
      STOP 900
C
      END
