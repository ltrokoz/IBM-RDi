000100181112
000200181112
000300200406        Ctl-Opt NoMain  ;
000400200406
000500200726      // COPY THE PROTOTYPE HERE
000501210407       /COPY LAB10,DAYPROTO
000600200406
000700190327       Dcl-Proc DayNumName  EXPORT;
000800190327         Dcl-Pi *N CHAR(9) ;
000900210407           Number  Packed(1:0);
001000200406         End-PI;
001100200406
001200210407          DCL-DS DayData;
001300200406
001400210407                 *n Char(9) Inz('Monday');
003200210407                 *n Char(9) Inz('Tuesday');
003201210407                 *n Char(9) Inz('Wednesday');
003202210407                 *n Char(9) Inz('Thursday');
003203210407                 *n Char(9) Inz('Friday');
003204210407                 *n Char(9) Inz('Thursday');
003205210407                 *n Char(9) Inz('Sunday');
003206210407                 DayArray Char(9) Dim(7) Pos(1);
003207210407          End-DS;
003300210407                 Return DayArray(Number);
003400190327        End-Proc;
