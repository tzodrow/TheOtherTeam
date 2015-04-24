
KEYSTROKE:  	MOV R6 R27
				RD S1 XCRD R7
				RD S1 YCRD R8
				MOV R11 R7
				MOV R12 R8
CHECK_LEFT:		SUBi R3 R6 0x0B
				B EQ CALC_POS
CHECK_RIGHT:	SUBi R3 R6 0x07
				B NEQ UP
				ADDi R7 R7 7
				B UNCON CALC_POS
CHECK_UP:		SUBi R3 R6 0x0E
				B EQ CALC_POS		
CHECK_DOWN:		SUBi R3 R6 0x0C
				B NEQ CALC_POS
				ADDi R8 R8 280
				MOV R10 R8		
CALC_POS:   	SRA R9 R7 3
Y_LOOP:			SUB R3 R10 R0
				B EQ Y_LOOP_END
				ADDi R9 R9 40 #increment mem position
				SUBi R10 R10 1 #decrement counter
				B UNCON Y_LOOP
Y_LOOP_END: 	LW R13 R9 150 							#Immediate index for 					memory location
				SUBi R3 R13 1
				B EQ KEYSTROKE
LEFT:			SUBi R3 R6 0x0B	
				B NEQ RIGHT
				SUBi R7 R7 1			

