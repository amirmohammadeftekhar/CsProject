MAIN start 0							; segment declaration
STM R14, R12, 12(R13)					; storing the register values of the parent segment in its RegSaveArea variable
BALR R12, R0							; storing PC value in R12
using *, R12							; declaration of R12 as the base register
ST R13,SAVEAREA_4
LA R13,SAVEAREA

	LA	R3,1
	L	R1,N_INPUT
	A	R1,M_INPUT
	LA	R9,0
LOOP_1:
	LR	R7,R1
	SR	R7,R9
	MR	R2,R7
	LA	R9,1(R9)
	C	R9,N_INPUT
	BL	LOOP_1

	ST	R3,RES



	LA	R9,1
LOOP_2:
	DR	R2,R9
	LA	R9,1(R9)
	C	R9,N_INPUT
	BNH	LOOP_2

	ST	R3,RES




L  R13,SAVEAREA_4
LM R14,R12,12(R13)
BR R14

N_INPUT DC F'4'
M_INPUT DC F'6'
RES DS F

REG_SAVE		DS 10F
SAVEAREA  	DS F
SAVEAREA_4	DS 17F

end


















