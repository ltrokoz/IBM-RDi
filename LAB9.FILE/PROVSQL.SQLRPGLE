000100190313       //**************************************************************************
000200191105       //* THIS PROGRAM USES A CURSOR TO LOAD A TEMPORARY RESULT TABLE FROM 3
000300191105       //* SEPARATE TABLES, ONTARIO, QUEBEC AND MANITOBA. A NUMBER IS PASSED
000400191105       //* TO THE PROGRAM TO DETERMINE WHICH RECORDS ARE INLCUDED FROM THE 3 TABLES
000500190313       //**************************************************************************
000600190313           DCL-F PROVREPORT PRINTER OFLIND(*IN01) ;
000700190313           DCL-S ProvinceH    Char(10);
000800190313           DCL-S EndOfFile    IND;
000900190313           DCL-S TotalRecords PACKED(5:0) ;
001000190315             // LowLimit is passed to the program
001100190315
001200210329           Dcl-PI Main extPgm('PROVSQLH');
001300210329              LowLimitIn Packed(15:5);
001301210329           End-PI;
001400190315             // All Host Variables available under a single name
001500210329           DCL-DS CustomerRecord;
001600210329               CustID Char(6);
001700210329               FullName Char(31);
001800210329               City Char(20);
001900210329               Purchase Packed(7:2);
002000210329               PDate Date;
002100210329               Province Char(10);
002200190313        End-Ds CustomerRecord;
002300070123     C/EJECT
002400070123     C**************************************************************************
002500070123     C*                        ***   M A I N   R O U T I N E   ***
002600070123     C**************************************************************************
002700070118      /FREE
002800210329                LowLimit = LowLimitIn;
002801210329                EXSR PrepareFiles;
002802210329
002900200709                Write ReportHdg;
003000200709                Write RColumns;
003001210329
003100100309                EXSR GetRow;
003101210329
003200190313                Write NewProv;
003300070209                ProvinceH = Province;
003301210329
003400070202                DOW NOT EndOfFile;
003500190313                    IF *IN01 = *ON;
003600210329                        Write RColumns;
003800190313                       *IN01 = *OFF;
003900070209                    ENDIF;
004000190315                    // Province may change
004100210329                IF ProvinceH = Province;
004200210329                   Write Detail;
004300210329                ELSE;
004400210329                   ProvinceH = Province;
004500210329                   Write Totals;
004600210329                   TotalPurch = 0;
004700210329                   Write NewProv;
004800210329                   Write Detail;
004900210329               ENDIF;
004901210329
005200210329                    TotalPurch += Purchase;
005300210329                    TotalRecords += 1;
005400100309                    EXSR GetRow;
005500070119                ENDDO;
005600190313                Write Totals;
005700070202                EXSR   WRAPUP;
005800190313                Write UnderLimit;
005900070119                *INLR = *ON;
006000070119                RETURN;
006100100309        //**********************************************************************
006200100309        // O P E N F I L E S   S U B R O U T I N E
006300100309        //**********************************************************************
006400100309         BEGSR  PrepareFiles;
006500190315        // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  STRUCTURE
006600210329         EXEC SQL
006700210329              DECLARE ALLPROVCURSOR CURSOR
006800210329            FOR
006900190315
007000210329            SELECT CUSTID, TRIM(FNAME) || ' ' || TRIM(LNAME),
007100210329                   CITY, PURCHASE, PDATE,
007200210329                   'Ontario' AS PROVINCE
007300210329            FROM BCI433LIB/ONTARIO
007400210329            WHERE PURCHASE > :LowLimit
007500190315
007600210329            UNION ALL
007601210329
007700210329            SELECT CUSTID, TRIM(FNAME) || ' ' || TRIM(LNAME),
007800210329                   CITY, PURCHASE, PDATE,
007900210329                   'Quebec' AS PROVINCE
008000210329            FROM BCI433LIB/QUEBEC
008100210329            WHERE PURCHASE > :LowLimit
008101210329
008200210329            UNION ALL
008201210329
008300210329            SELECT CUSTID, TRIM(FNAME) || ' ' || TRIM(LNAME),
008400210329                   CITY, PURCHASE, PDATE,
008500210329                   'Manitoba' AS PROVINCE
008600210329            FROM BCI433LIB/MANITOBA
008700210329            WHERE PURCHASE > :LowLimit
008701210329
008702210329            FOR READ ONLY;
008703210329
008800100309        // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D
008900210329         EXEC SQL
009000210329           OPEN ALLPROVCURSOR;
009100210329           If SQLCODE <> 0 OR SQLWN0 = 'W';
009200210329             EndOfFile = *ON;
009300210329           ENDIF;
009500190315
009600210329         ENDSR;
009700100309        //**********************************************************************
009800100309        //   G E T     R O W    S U B R O U T I N E
009900100309        //**********************************************************************
010000100309            BEGSR     GETROW;
010100100309
010200210329            EXEC SQL
010300210329            FETCH NEXT
010400210329               FROM ALLPROVCURSOR
010500210329               INTO :CUSTOMERRECORD;
010600210329            IF SQLCODE <> 0 OR SQLWN0 = 'W';
010700210329               EndOfFile = *ON;
010800210329            ENDIF;
011000190315
011100210329           ENDSR;
011200100309        //**********************************************************************
011300100309        // W R A P U P     S U B R O U T I N E
011400100309        //**********************************************************************
011500100309           BEGSR WRAPUP;
011501210329
011502210329             EXEC SQL
011503210329                CLOSE ALLPROVCURSOR;
011504210329
011505210329             If SQLCODE <> 0 OR SQLWN0 = 'W';
011506210329                 EndOfFile = *ON;
011507210329             ENDIF;
011508210329
011509210329             EXEC SQL
011510210329                SELECT COUNT(*) INTO :ONTTOTAL
011511210329                   From BCI433LIB/ONTARIO
011512210329                   Where Purchase <=:LowLimit;
011513210329              If SQLCODE <> 0 OR SQLWN0 = 'W';
011514210329                ONTTOTAL = -999;
011515210329              ENDIF;
011516210329
011517210329
011518210329              EXEC SQL
011519210329                SELECT COUNT(*) INTO :QUETOTAL
011520210329                     From BCI433LIB/QUEBEC
011521210329                     Where Purchase <=:LowLimit;
011522210329
011523210329              If SQLCODE <> 0 OR SQLWN0 = 'W';
011524210329                   QUETOTAL  = -999;
011525210329              ENDIF;
011526210329
011527210329
011528210329              EXEC SQL
011529210329                  SELECT COUNT(*) INTO :MANTOTAL
011530210329                     From BCI433LIB/MANITOBA
011531210329                     Where Purchase <=:LowLimit;
011532210329
011533210329              If SQLCODE <> 0 OR SQLWN0 = 'W';
011534210329                   MANTOTAL = -999;
011535210329              ENDIF;
011536210329
011600210329        ENDSR;
011601210329
011700190315
011800190315
011900190315
012000190315
012100190315
012200190315
012300190315
012400190315
012500190315
012600190315
012700190315
012800190315
012900190315
013000190315
013100190315
