000100190304         DCL-F UPDREPORT  PRINTER OflInd(*IN01);
000200181025         DCL-F SALESTRANS DISK(*EXT) KEYED USAGE(*INPUT)
000300181025               RENAME(SALESTRANS:SALESTRANR);
000400181025         DCL-F SALESSTAF2 DISK(*EXT) KEYED
000500181025               USAGE(*UPDATE : *OUTPUT : *DELETE);
000501210321
000600181025         DCL-DS FullKey ;
000700181025               ADept    CHAR(3);
000800181025               ASalesId CHAR(4);
000900181025         END-DS FullKey;
000901210321
001000190305         DCL-DS SalesTransDS;
001100181025               TDept;
001200181025               TSalesId;
001300181025               TFName;
001400181025               TLName;
001500181025               TCity;
001600181025               TAddress;
001700181025               TPCode;
001800190305         End-Ds SalesTransDs;
001801210321
001900190305         DCL-DS SalesStaf2DS;
002000181025               Dept;
002100181025               SalesId;
002200181025               FName;
002300181025               LName;
002400181025               City;
002500181025               Address;
002600181025               PCode;
002700210321         End-Ds SalesStaf2Ds;
002900181025
003000190304                   WRITE   HEADING;
003100171124                   READ      SALESTRANS;
003200101110                   DOW       NOT %EOF;
003201210318
003300210318                      FullKey = TDept + TSalesID;
003301210318                      CHAIN %KDS(FullKey) SalesStaf2;
003400190305
003500101110                      SELECT;
003600101110                        WHEN      %FOUND(SALESSTAF2);
003700101110                        SELECT;
003800101110                           WHEN      TCODE = 'C';
003900101110                              EXSR      CHGREC;
004000101110                           WHEN      TCODE = 'D';
004100101110                              EXSR      DELREC;
004200101110                           OTHER;
004300101110                              EXSR      ERROR;
004400101110                        ENDSL;
004500101110                        WHEN      NOT %FOUND(SALESSTAF2);
004600101110                           IF        TCODE = 'A';
004700101110                              EXSR      ADDREC;
004800101110                           ELSE;
004900101110                              EXSR      ERROR;
005000101110                           ENDIF;
005100101110                        WHEN      %ERROR;
005200101110                              EXSR      ERROR;
005300101110                        ENDSL;
005400190304                        IF *IN01 = *ON;
005500190304                          WRITE HEADING;
005600190304                          *IN01 = *OFF;
005700190304                        ENDIF;
005800190304                        WRITE    DETAIL;
005900171124                        READ      SALESTRANS;
006000101110                   ENDDO;
006100101110                   *INLR = *ON;
006200101110                   RETURN;
006300101110         BEGSR  ADDREC;
006400210318                SALESSTAF2DS = SALESTRANSDS;
006500210318                Phone = %Dec(TPhone:10:0);
006600210318                WRITE SALESTFR;
006700101110         ENDSR;
006701210321
006800101110         BEGSR  CHGREC;
006900210318                SALESSTAF2DS = SALESTRANSDS;
006901210318                Phone = %Dec(TPhone:10:0);
006902210318                UPDATE SALESTFR;
007200101110         ENDSR;
007201210321
007300101110         BEGSR  DELREC;
007400101110                   DELETE    SALESTFR;
007500101110         ENDSR;
007600101110         BEGSR  ERROR;
007700101110                   TFNAME = 'UPDATE/DELETE/CHANGE';
007800101110                   TLNAME = 'E R R O R';
007900101110         ENDSR;
