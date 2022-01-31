
MAIN start 0							; segment declaration
STM R14, R12, 12(R13)						; storing the register values of the parent segment in its RegSaveArea variable
BALR R12, R0							; storing PC value in R12
using *, R12							; declaration of R12 as the base register
ST R13, Reg13							; storing R13 in Reg13
LA R13, RegSaveArea 						; R13 <- address of RegSaveArea, this will be passed to the child segment

								; Main code

	L  R15, =V(FIB)						; Address of FIB in R15
	LA R10,INPUT_N
	LA R11,FIB_RES
	BALR R14,R15

	L  R15, =V(FACT)						; Address of FACT in R15
	LA R10,INPUT_N
	LA R11,FACT_RES
	BALR R14,R15

	L R1,FACT_RES
	S R1,FIB_RES
	ST R1,RES



L  R13, Reg13 							; restoring R13 from Reg13
LM R14, R12, 12(R13)						; restoring the register values of the parent segment
BR R14								; returning control to the parent segment


INPUT_N DC    F'5'          						; N
FIB_RES DS F
FACT_RES DS F
RES DS F

RegSaveArea DS 15 F						; variable to store the values of the registers by the child segment
Reg13 DS F								; variable to store the value of R13 so that we can restore it after the child segment has changed it


end								; end of segment

FIB start 0								; segment declaration
STM R14, R12, 0(R13)						; storing the original values of registers
BALR R12, R0							; storing PC value in R12
using *, R12							; declaration of R12 as the base register

	LA    R1,0           					; f(n-2)=0
         LA    R2,1           					; f(n-1)=1
         L    R7,0(R10)          					; limit
	SR R7,R2
LOOP:		              					; for n=2 to nn
         LR    R3,R2            					; f(n)=f(n-1)
         AR    R3,R1            					; f(n)=f(n-1)+f(n-2)
         LR    R1,R2            					; f(n-2)=f(n-1)
         LR    R2,R3            					; f(n-1)=f(n)
         BCT  R7,LOOP     					; endfor n
OUT:
	ST R3,0(R11)


LM R14, R12, 0(R13)						; restoring the original values of registers
BR R14								; returning control to OS

end									; end of segment

FACT start 0								; segment declaration
STM R14, R12, 0(R13)						; storing the original values of registers
BALR R12, R0							; storing PC value in R12
using *, R12							; declaration of R12 as the base register

	L R7,0(R10)
	LA R3,1
	LA R2,0
LOOP:

	MR R2,R7
	BCT R7,LOOP
OUT:
	ST R3,0(R11)


LM R14, R12, 0(R13)						; restoring the original values of registers
BR R14								; returning control to OS

end									; end of segment
