000100190313         // **************************************************************************              
000200200326        //  CUSTOMER20 READ BY NATIVE LANGUAGE (ILE RPG)                                            
000300200709        //  CONTACTS20 ROW RETRIEVED WITH EMBEDDED SQL                                              
000400200709        //  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER20 AND CONTACTS20                  
000500190313        //  SUMMARRY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS                      
000600190314                                                                                                    
000700190313           DCL-F PHNREPORT PRINTER OFLIND(*IN01) ;                                                  
000800200326           DCL-F CUSTOMER20 DISK(*EXT) KEYED USAGE(*INPUT)                                          
000900200326                 RENAME(CUSTOMER20:CUSTR);                                                          
001000200709                      // data structure for host variables from CONTACTS20                          
001100210328           DCL-DS CONTACTS20 EXT END-DS;                                                            
001200190314                     // Standalone fields for indicator variables                                   
001300210328           DCL-S INDLastCDate BINDEC(4:0);                                                          
001400210328           DCL-S INDNextCDate BINDEC(4:0);                                                          
001500190314                                                                                                    
001600190314           DCL-S Dummy  Zoned(1);                                                                   
001700190314                                                                                                    
001800190314        //**************************************************************************                
001900190314        //*                        ***   M A I N   R O U T I N E   ***                              
002000190314        //**************************************************************************                
002100190314                                                                                                    
002200070119                EXSR SummaryInfo;                                                                   
002300200709                WRITE NEWPAGE;                                                                      
002400200326                READ CUSTOMER20;                                                                    
002500070119                DOW NOT %EOF;                                                                       
002600070119                    EXSR SQLSelect;                                                                 
002601210328                                                                                                    
002602210328                      IF PHNLDC = OldestDate;                                                       
002603210328                      HIGHLIGHT = '<-------';                                                       
002604210328                      ELSE;                                                                         
002605210328                       HIGHLIGHT = '';                                                              
002606210328                      ENDIF;                                                                        
002607210328                                                                                                    
002700190313                    IF *IN01 = *ON;                                                                 
002800200709                       Write NEWPAGE;                                                               
002900190313                       *IN01 = *OFF;                                                                
003000070119                    ENDIF;                                                                          
003100200709                    Write RPTLINE;                                                                  
003200200326                   READ CUSTOMER20;                                                                 
003300070119                ENDDO;                                                                              
003400190313                Write SUMMARY;                                                                      
003500070119                *INLR = *ON;                                                                        
003600070119                RETURN;                                                                             
003700080923        //**********************************************************************                    
003800080923        //   S Q L S E L E C T   S U B R O U T I N E                                                
003900080923   //   //********************************************************************                      
004000080923   //                  BEGSR    SQLSelect ;                                                         
004100080923   //    // A row from the contacts table that has the same customer number as t                    
004200200326   //    // read from the CUSTOMER20 file is retrieved to find out the last date                    
004300080923   //    // phone number, comments and the salesperson number.                                      
004400080923   //                                                                                               
004500080923   //    //  The call back interval is added to the last date called to determin                    
004600080923   //    //  next date to call.  Since null values may be stored in the last dat                    
004700080923   //    // indicator variables are used.                                                           
004800210328             EXEC SQL                                                                               
004801210328               SELECT PHNLDC + PHNSIT DAYS, PHNLDC, CSTPHN, PHNCOM, CSTSLN                          
004802210328                 INTO :NEXTCDATE :INDNEXTCDATE, :PHNLDC :INDLastCDate,                              
004803210328                 :CSTPHN, :PHNCOM, :CSTSLN                                                          
004804210328                 FROM BSI433LIB/CONTACTS20                                                          
004805210328                 WHERE CSTNUM = :CSTNUM;                                                            
004806210328                                                                                                    
004807210328             SELECT;                                                                                
004808210328               WHEN SQLSTATE = '00000';                                                             
004809210328                 Dummy = 0;                                                                         
004810210328               WHEN SQLSTATE = '02000';                                                             
004811210328                 CSTPHN = 'Not Found';                                                              
004812210328                 NEXTCDATE = D'9999-09-09';                                                         
004813210328                 PHNLDC = D'9999-09-09';                                                            
004814210328                 PHNCOM = *ALL'*';                                                                  
004815210328                 CSTSLN = *ALL'*';                                                                  
004816210328               WHEN %SUBST(SQLSTATE :1 :2) = '01';                                                  
004817210328                 NEXTCDATE = D'9999-09-09';                                                         
004818210328                 PHNLDC = D'9999-09-09';                                                            
004819210328                 PHNCOM = *ALL'*';                                                                  
004820210328                 CSTSLN = *ALL'*';                                                                  
004821210328                 CSTPHN = *ALL'*';                                                                  
004822210328               OTHER;                                                                               
004823210328                 CSTPHN = *ALL'*';                                                                  
004824210328                 NEXTCDATE = D'9999-09-09';                                                         
004825210328                 PHNLDC = D'9999-09-09';                                                            
004826210328                 PHNCOM = *ALL'*';                                                                  
004827210328                 CSTSLN = *ALL'*';                                                                  
004828210328             ENDSL;                                                                                 
004900190314                                                                                                    
005000210328             IF IndLastCDate = -1;                                                                  
005001210328                 CSTPHN = 'UNKNOWN DATE';                                                           
005002210328                 NEXTCDATE = D'9999-09-09';                                                         
005003210328                 PHNLDC = D'9999-09-09';                                                            
005004210328             ELSE ;                                                                                 
005005210328                 IF INDLastCDate <> 0;                                                              
005006210328                 CSTPHN = 'DATE PROBLEM';                                                           
005007210328                 NEXTCDATE = D'9999-09-09';                                                         
005008210328                 PHNLDC = D'9999-09-09';                                                            
005009210328                 ENDIF;                                                                             
005010210328             ENDIF;                                                                                 
005011210328                                                                                                    
006900080923                         ENDSR ;                                                                    
007000080923        //**********************************************************************                    
007100080923        // S U M M A R Y I N F O   S U B R O U T I N E                                              
007200080923        //**********************************************************************                    
007300080923                         BEGSR  SummaryInfo;                                                        
007400200709        //  D E T E R M I N E   T O T A L S   F O R   CONTACTS20 & CUSTOMER20                       
007500210328         EXEC SQL                                                                                   
007600210328              SELECT COUNT(*) INTO :CONTACTT                                                        
007700210328                     FROM BCI433LIB/CONTACTS20;                                                     
007800210328              IF (SQLCODE <> 0) OR (SQLWN0 = 'W');                                                  
007900210328                 CONTACTT = -99999;                                                                 
008000210328              ENDIF;                                                                                
008100190314                                                                                                    
008200210328          EXEC SQL                                                                                  
008201210328              SELECT COUNT(*) INTO :CUSTOMERT                                                       
008202210328                     FROM BCI433LIB/CUSTOMER20;                                                     
008203210328              IF (SQLCODE <> 0) OR (SQLWN0 = 'W');                                                  
008204210328                 CUSTOMERT = -99999;                                                                
008205210328              ENDIF;                                                                                
008800190314                                                                                                    
008900190314                                                                                                    
009000190314        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   LAST   DATE CALLED               
009100210328          EXEC SQL                                                                                  
009200210328              SELECT COUNT(*)                                                                       
009300210328              INTO :UNKNOWNT                                                                        
009400210328              FROM BCI433LIB/CONTACTS20                                                             
009500210328              WHERE CstLastCallDate IS NULL;                                                        
009600190314                                                                                                    
009700210328              IF NOT(SQLCODE = 0) OR (SQLWN0 = 'W');                                                
009800210328                  UNKNOWNT = -99999;                                                                
009900210328              ENDIF;                                                                                
010000190314                                                                                                    
010100080923        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  L A S T                     
010200210328              EXEC SQL                                                                              
010300210328                  SELECT MIN(PHNLDC) INTO :OldestDate                                               
010400210328                     FROM BCI433LIB/CONTACTS20;                                                     
010500210328                  IF (SQLCODE <> 0) OR (SQLWN0 = 'W') AND (SQLWN2 <> 'W');                          
010600210328                     OldestDate = D'9999-09-09';                                                    
010700210328                  ENDIF;                                                                            
010800190314                                                                                                    
010900190314                                                                                                    
011000210328              EXEC SQL                                                                              
011001210328                  SELECT MAX(PHNLDC) INTO :MOSTRECENT                                               
011002210328                     FROM BCI433LIB/CONTACTS20;                                                     
011003210328                  IF (SQLCODE <> 0) OR (SQLWN0 = 'W') AND (SQLWN2 <> 'W');                          
011004210328                     MOSTRECENT = D'9999-09-09';                                                    
011005210328                  ENDIF;                                                                            
011100210328                                                                                                    
012000190314                                                                                                    
012100080923       // D E T E R M I N E   T H E   U S E R   S E R V E R   &   T I M E S T A                     
012200210328           EXEC SQL                                                                                 
012300210328                SELECT USER, CURRENT TIMESTAMP, CURRENT SERVER                                      
012400210328                  INTO :User, :TimeStamp, :Server                                                   
012500210328                  FROM SYSIBM/SYSDUMMY1;                                                            
012700190314                                                                                                    
012800210328             ENDSR;                                                                                 
