000100210126**FREE
000101210126       DCL-F COVIDDSP WORKSTN;
000102210126
000103210126       EXSR CLEAR;
000104210126       EXFMT RISKFACTOR;
000105210126
000106210126       DOW NOT(*IN03);
000107210126          IF Gender = ' ';
000108210126            *IN95 = *ON;
000109210126            EXFMT RISKFACTOR;
000110210126            *IN95 = *OFF;
000111210126            ITER;
000112210126          ELSEIF CVDISEASE = ' ';
000113210126            *IN96 = *ON;
000114210126            EXFMT RISKFACTOR;
000115210126            *IN96 = *OFF;
000116210126            ITER;
000117210126          ELSEIF DIABETES = ' ';
000118210126            *IN97 = *ON;
000119210126            EXFMT RISKFACTOR;
000120210126            *IN97 = *OFF;
000121210126            ITER;
000122210126          ELSEIF RSPDISEASE = ' ';
000123210126            *IN98 = *ON;
000124210126            EXFMT RISKFACTOR;
000125210126            *IN98 = *OFF;
000126210126            ITER;
000127210126          ELSEIF HBPRESSURE = ' ';
000128210126            *IN99 = *ON;
000129210126            EXFMT RISKFACTOR;
000130210126            *IN99 = *OFF;
000131210126            ITER;
000132210126          ELSE;
000133210126            EXSR DetermineRisk;
000134210126            TOTALQ = TOTALQ + 1;
000135210126            *IN60 = *ON;
000136210126            write RISKFACTOR;
000137210126            exfmt RISKASSMNT;
000138210126            *IN60 = *OFF;
000139210126
000140210126          ENDIF;
000141210126
000142210126          IF *IN03 = *OFF;
000143210126            EXSR CLEAR;
000144210126            EXFMT RISKFACTOR;
000145210126          ENDIF;
000146210126
000147210126       ENDDO;
000148210126
000149210126         *INLR = *ON;
000150210126         RETURN;
000151210126
000152210126       BEGSR DetermineRisk;
000153210126         AGE = 25;
000155210126         FRATE = 0.051;
000156210126         COHORT = 'Group 4';
000157210126       ENDSR;
000158210126
000159210126       BEGSR CLEAR;
000160210126         *IN95 = *OFF;
000161210126         *IN96 = *OFF;
000162210126         *IN97 = *OFF;
000163210126         AGE = 0;
000164210126         GENDER = ' ';
000165210126         HBPRESSURE = ' ';
000166210126         CVDISEASE = ' ';
000167210126         DIABETES = ' ';
000168210126         RSPDISEASE = ' ';
000169210126       ENDSR;
