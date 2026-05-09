C	PFCORR - A program to assist in examining return on investment in
C	Power Factor Correction equipment selection.
C
C	-----------------------------------------------------------------
C	Functional Description:
C	Program accepts existing load value(s) and tabulates kVA demand
C	reduction versus applied kVAr correction capacity.
C
C
C
C
C	-----------------------------------------------------------------
C	PROGRAMMING NOTES:
C
C	1. Originated 12-JUN-87 to evaluate C/N 8640.
C
D10	ACCEPT 20, N, C
D20	FORMAT (I3,F8.4)
D	IF (N.LT.0) GO TO 100
D	CALL CRFTOI(N,C,T)
D	TYPE 30, T
D30	FORMAT (X'INTEREST',F8.4,'     (give -ve years to exit test)')
D	GO TO 10
C
C
C	-----------------------------------------------------------------
C
	DIMENSION ICENTS(12), MONTHS(12), RATRET(50), CRF(50), PAYBAK(50)
	BYTE BYTDAT(9),IDENT(80)
	LOGICAL FIRST,LEADIN
	INTEGER Q,QMIN,QMAX,QSTEP,PF,PFMIN,PFMAX,PFSTEP
C
100	CALL DATE(BYTDAT)
	FIRST = .TRUE.
C
C
	TYPE 105
105	FORMAT (X'PFCORR - A program to assist in examining
	1 return on investment in',/X,
	2'Power Factor Correction equipment selection.',//X,
	3'Identify the Job, C/N, designation,
	1 conditions and tariff introduction date (80A1):')
	ACCEPT 110, NIDENT,(IDENT(I),I=1,NIDENT)
110	FORMAT (Q,80A1)
C
200	TYPE 210
210	FORMAT (X,/X,'Give design values for load to be PFC controlled,
	4 and for uncontrolled load (if any'
	5,/X,'on same tariff meter), as kVA(I4), PF(F5.3),
	6 kVA, PF(F5.3),<CR>')
	ACCEPT 215, KVAC,CPF,KVAU,UPF
215	FORMAT (I5,F6.4,I5,F6.4)
	CS = FLOAT(KVAC)		!DEFINE LOAD CONDITIONS
	CP = CS * CPF
	CQ = SQRT(CS*CS - CP*CP)
	US = FLOAT(KVAU)
	UP = US * UPF	
	UQ = SQRT(US*US - UP*UP)
	S0 = SQRT((CP+UP)**2 + (CQ+UQ)**2)
	IF (.NOT. FIRST)GO TO 3000
C
C
220	TYPE 225
225	FORMAT (X'Enter kVA demand tariffs in cents per kVA per month
	1 and number of months of year',/X,'applying, as',/X,
	2'cccc,mm,<CR>cccc, ... ,mm<CR> (cents in I5, months in I2):
	3(<CR>cents terminates)')
	DO 226, L=1,12
	ICENTS(L) = 0
226	MONTHS(L) = 0
	L = 1
	MONSUM = 0
	TARIFF = 0.
227	ACCEPT 230, ICENTS(L),MONTHS(L)
230	FORMAT (I5,I2)
	L = L + 1
	MONSUM = MONSUM + MONTHS(L-1)
	TARIFF = TARIFF + FLOAT(ICENTS(L-1)*MONTHS(L-1))/100.	!dollars
	NTARIF = L-1	!No of tariff levels.
	IF (MONSUM-12)227,240,220
C
240	TYPE 250, TARIFF/12.,TARIFF,MONSUM
250	FORMAT (X'Tariff averages $',F7.2,'per kVA per month ($'
	1,F7.2,'/kVA/',I2,'month year).',/X,'(If you have made a mistake
	2 and this is first time through, give a zero next answer.')
	IF (MONSUM.NE.12)GO TO 220
	IF (.NOT. FIRST)GO TO 3000
C
C
260	TYPE 265
265	FORMAT (X'Enter plant costs as',/X,'CAPACITY STEP/STEP COST
	1 (kVAr,I5/$,I5), BASE COST/CAPACITY ($,I6/kVAr,I5):')
	ACCEPT 270, NDKVAR,NDCOST,ICOST,IKVAR
270	FORMAT (I5,I5,I7,I5)
	IF (.NOT. FIRST)GO TO 3000
C
C
280	TYPE 285
285	FORMAT (X'Capital recovery factors, rates of return based on
	1 a nominated plant life, and',/X,'nett annual savings based
	2 on finance cost with debt amortized and',/X,'equipment
	3 written off at end of life, will be tabulated.
	4 To assess these, enter:',/X,'LIFE (Years, I3), INTEREST
	5 RATE pa. for that term (%, F6.2):')
	ACCEPT 290, NYEARS,TEREST
290	FORMAT (I3,F7.3)
	IF (.NOT. FIRST)GO TO 3000
C
C
C
300	TYPE 310
310	FORMAT (X'Choose output device:'
	1,/X,'<7> - Terminal.'
	2,/X,'<6> - Printer.'
	3,/X,'<10> - Disk file.')
	ACCEPT 315,LUNOUT
315	FORMAT (I3)
	IF (LUNOUT.EQ.6.OR.LUNOUT.EQ.7)GO TO 325
	TYPE 320
320	FORMAT (X'DISK HANDLING NOT DONE, SORREEEEE!')
	GO TO 300
325	IF (.NOT. FIRST)GO TO 3000
C
C
C
350	TYPE 355
355	FORMAT (X'Choose from the following:'
	1,/X,'<1> - Evaluate one load figure (kVA / PF)'
	2,/X,'<2> - Range of load kVA''s at a constant load
	3 power factor.',/X,'<3> - Range of PFC plant
	4 capacities/settings for nominated site load.')
	ACCEPT 370,KINDOF
370	FORMAT (I3)
	IF (KINDOF.EQ.0)GO TO 220	!if previous tariff question bungled 
	GO TO (350,350,1300)KINDOF
C
C
1300	TYPE 1310
1310	FORMAT (X'Specify PFC CAPACITY for table index as',/X
	1,'MIN, MAX, STEP  kVAr  in I4 format.
	2 (STEP is controller step size)')
	ACCEPT 1315,QMIN,QMAX,QSTEP
1315	FORMAT (3I6)
C
	TYPE 1320
1320	FORMAT (X'Specify PFC CONTROL SETPOINTS for table index as',/X
	1,'MIN, MAX, STEP  in parts per thousand
	2 in I4 format (eg 1005 for 0.995PF leading)',/X,'(Of course
	3 PF>1.0 is only a convenient fiction to identify
	4 leading PF!')
	ACCEPT 1325,PFMIN,PFMAX,PFSTEP
1325	FORMAT (3I6)
	IF (.NOT. FIRST)GO TO 3000
C
C---------------------------------------------------------------------
C	!CALCULATION AND OUTPUT ALGORITHM
C
2000	FIRST = .FALSE.
C
C	--------------------------------------------------------
C	----- WRITE OUT A TABLE TO LUNOUT DEVICE ---------------
C
2020	WRITE (LUNOUT,2025) BYTDAT
2025	FORMAT (X'PFCORR     -    POWER FACTOR CORRECTION
	1 ANALYSIS   -   ',9A1)
	WRITE (LUNOUT,2030) (IDENT(I),I=1,NIDENT)
2030	FORMAT (X,80A1)
	WRITE (LUNOUT,2032) (ICENTS(I),MONTHS(I),I=1,NTARIF)
2032	FORMAT (X'TARIFF, (CENTS/kVA/MONTH,MONTHS): '
	1,6('(',I5,'c,',I3,'M)'))
C
	WRITE (LUNOUT,2035)ICOST,IKVAR,NDCOST,NDKVAR
2035	FORMAT (X'PFC PLANT INSTALLED COST =$',I6,' FOR',I5,'kVAr
	1 CAPACITY',/X,'INCREMENTAL CAPACITY COST = $',I4
	2,' FOR EACH ',I3,' kVAr ADDED.')
	WRITE (LUNOUT,2037) TEREST,NYEARS
2037	FORMAT (X'FINANCED AT INTEREST RATE',F6.2,'%pa OVER',I3
	1,' YEAR (PLANT LIFE) TERM.')
	WRITE (LUNOUT,2040) IFIX(CS),CPF,IFIX(US),UPF
2040	FORMAT (X'CONTROLLER    (CONTROL SENSED LOAD ='
	1,I4,' kVA at ',F4.2,'PF.)',/X,
	2'SETPOINT        (REMOTE UNSENSED LOAD =',I4,' kVA at '
	3,F4.2,'PF.)',/X,'PF.')	!No <CR> - to be ctd;
C
	IF (KINDOF.EQ.3) WRITE (LUNOUT,2050)
2050	FORMAT ('+','  CRF / % pa RETURN / NETT ANNUAL SAVINGS
	1 AFTER PRINCIPAL+INTEREST REPAYMENTS')
C
C
C	------------ ROW DO LOOP: ------------------------------------------
C
	M = 0
	DO 2300, PF = PFMAX,PFMIN,-PFSTEP	!Step backwards for abscissa
	M = M+1
C
C	(Examine leading quadrant cue and adjust CTRLPF, LEADIN flag.):
C
	IF (PF.GT.1000)CTRLPF = 1.- FLOAT(PF-1000)/1000.
	IF (PF.LE.1000)CTRLPF = FLOAT(PF)/1000.
	LEADIN = .FALSE.
	IF (PF.GT.1000) LEADIN = .TRUE.
C
C	--- Evaluate QCORR needed to achieve this level of net controlled PF.-
C
C				 ^	^	^
C			        /!	!	!
C			       / !	!	!
C			      /  !	!	!
C			     /   !	!	!
C			    /    !	!	!
C			   /     !	!	!
C			  /      !    QCORR     !
C			 /       !	!	!
C		     CS /        !	!	!
C		       /         !      !	CQ
C		      /          !	!	!
C		     /           !	!	!
C		    /            !	!	!
C		   /           . '   -------    !
C		  /    CS1 .     !	!	!
C		 /     .         ! CQ1=CQ-QCORR	!
C		/  .             !	!	!
C	       .------------------->	!	V
C			CP
C
C
	IF (CTRLPF .GE. 1.0)CTRLPF = 1.00!To avert root -ve thru rounding err.
	CS1=CP/CTRLPF	!ie CTRLPF=CP/CS1, the cosine.
	CQ1=SQRT(CS1*CS1 - CP*CP)	
	IF (LEADIN) CQ1=-CQ1	!Get sign of CQ1 right (NOTE THAT
C      			!PF axis is upside down - -ve actually means lagging)
	QCORR = CQ - CQ1	!(see graphics above)
	NSTAGE = INT(QCORR/FLOAT(QSTEP) + 0.5)!capacitor stages desired
C
C
C
C	------ COLUMN DO LOOP: (form row data) -------
C
	N = 0
	DO 2200, Q = QMIN, QMAX, QSTEP	!Do for each plant capacity specified)
	N = N+1
C
C	----FIND kVAR OF AVAILABLE CAPACITANCE STAGES THAT WILL BE USED--
C
	CORR = FLOAT(NSTAGE * QSTEP)	!CORR=kVAR desired (staged)
	IF (IFIX(CORR) .GT. Q)CORR = FLOAT(Q) !-limited to available kVAr.
	Q1 = (CQ - CORR) + UQ	!nett site reactive load, correction active.
	P1 = CP + UP		! ditto real load.
	S1 = SQRT(P1*P1 + Q1*Q1)! ditto vector magnitude, kVA.
C
C	----- DO FINANCIAL ANALYSIS --------------
C
	SAVING = (S0 - S1) * TARIFF	!$ per annum saved
	CAPITL = FLOAT(ICOST)	!GET BASE COST AND ADJUST FOR CAPACITY:
	CAPITL= CAPITL + FLOAT(Q-IKVAR)*FLOAT(NDCOST)/FLOAT(NDKVAR)
	CRF(N) = SAVING/CAPITL	!CAPITAL RECOVERY FACTOR.
	CALL CRFTOI(NYEARS,CRF(N),RATRET(N))	!Find rate of return.
	FINANC = CAPITL/USPWF(NYEARS,TEREST) !Cost pa. to amortize in NYEARS	
	PAYBAK(N) = SAVING - FINANC	!Nett annual savings after finance.
C	
C
C
2200	CONTINUE	!-------------------------
C
C
C	-------PRINT A ROW OF THE TABLE----
	WRITE (LUNOUT,2210) CTRLPF,(CRF(L),L=1,N)
2210	FORMAT (X,F5.3,'!',50F6.3)
	NDASH = '_'		!underline character.
	CR = "000015		!Carr. return
	IF (PF.GT.1000) EADLAG = 'LEAD'
	IF (PF.EQ.1000) EADLAG = '    '
	IF (PF.LT.1000) EADLAG = 'LAG '
	WRITE (LUNOUT,2220) EADLAG,(IFIX(RATRET(L)),L=1,N)
2220	FORMAT (X,A4,' !',50(I5,'%'))
	WRITE (LUNOUT,2225) (IFIX(PAYBAK(L)),L=1,N)
2225	FORMAT (X'_____!',50('$',I5))
C
C
2300	CONTINUE	!------------------------------------------
C
C
C
C 	----------- PRINT ABSCISSA INDEX, ----------------------
C
	WRITE (LUNOUT,2400) (Q,Q=QMIN,QMAX,QSTEP)
2400	FORMAT (X'--------------------
	1--------------------------- PFC PLANT CAPACITY
	2 (kVAR) --->',/X,'      ',50I6)
	WRITE (LUNOUT,2410) IFIX((FLOAT(QMAX)+.01)/FLOAT(QSTEP)),QSTEP
2410	FORMAT (X'           (Controller commands up to
	1 ',I3,' steps of',I5,'kVA each.)')
C
C
C
C	--------------- ASK NEXT OPTION -----------------------------

C
3000	TYPE 3010
3010	FORMAT (X'Enter <N> to: -'
	1,/X,'<1> - Restart.'
	2,/X,'<2> - Redefine System Loads.'
	3,/X,'<3> - Redefine Tariffs.'
	4,/X,'<4> - Enter revised PFC plant costs.'
	5,/X,'<5> - Redefine finance % / term.'
	6,/X,'<6> - Change output device.')
	TYPE 3011
3011	FORMAT (X'<7> - Select another kind of analysis.'
	8,/X,'<8> - Redefine PFC plant capacity and/or PF setting.'
	9,/X,'<9> - Calculate and output table.'
	1,/X,'<10> - Close output file / printer buffer.'
	2,/X,'<11> - Quit.')
	ACCEPT 3015,INPUT
3015	FORMAT (I4)
	IF (INPUT .EQ. 0)GO TO 220	!(see FORMAT stmt #250.)
	GO TO(100,200,220,260,280,300,350,1300,2000,3020,9999) INPUT
3020	CLOSE (UNIT = LUNOUT)
	GO TO 3000
C
9999	STOP
	END
C
C
C
	SUBROUTINE CRFTOI (N, C, T)
C
C	Evaluates rate of return T (%) for N year investment at Capital
C	Recovery Factor C. (recall CRF = Annual savings/Capital invested).
C	Newton Raphson iteration is used to get root of F(T)=CRF(T)-CRF=0.
C
	EN = FLOAT(N)	!to avoid mixed mode multiplication
	T = C		!Initial guess CRF (I->CRF as YEARS->infinity)
	I = 0	!Iteration counter.
10	I = I + 1
	T1 = T + 1. !(for convenience)
	FNUMR = T * T1**N	!Fraction numerator. [CRF= I(1+I)^N /
	FDENO = T1**N - 1.	!and denominator.           ((1+I)^N - 1)]
	F = FNUMR/FDENO - C	!(F = CRF(T) - CRF)
	DFNUMR = T1**N + EN * T1**(N-1) * T		!d(NUM)/dT
C
	T2=T1**N-1.	!ARTIFICE TO AVOID OVERFLOW AT ZERO INTEREST RATE.
	IF (T2.EQ.0)T2=.00001
D	TYPE 11,N,C,I,T1,T2
D11	FORMAT (X'N=',I3,' C=',F8.4,'ITER#=',I4,' T1=',F10.6,' T2=',F10.6)
C
	DFDENO = -(T2)**(-2.) * EN * T1**(N-1)	!d(1/DEN)/dT
	DF = DFNUMR/FDENO + FNUMR*DFDENO	!d(A/B)=d(A)/B + A*d(1/B)
	TLAST = T
	T = T - F/DF	!NEWTON RAPHSON -> new T.
	IF (ABS(T-TLAST).LT.1E-5.AND.ABS(F).LT.(1E-5*ABS(C)))GO TO 20
	IF (I.LT.100)GO TO 10
	TYPE 15
15	FORMAT (X'**CRFTOI SUBROUTINE N-R CONVERGENCE FAILURE**')
20	T = T*100	!convert to % rate of return
	RETURN
	END
C
C
C
C
	FUNCTION USPWF(N,T)	!UNIFORM SERIES PRESENT WORTH FUNCTION
	R=T/100.	!change % to /unit.
	IF (R.EQ.0.)R=0.0000001	!AVOID ZERO INTEREST OVERFLOW.
	USPWF = ((1.+R)**N - 1.)/(R*(1.+R)**N)
	RETURN
	END
                                                                                                                                                                                                                                                                                                                                                      