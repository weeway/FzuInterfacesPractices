;延时法,16次产生三角波，最高点-2.5V



DATA SEGMENT
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE,DS:DATA

START:
	MOV  AX,DATA
	MOV  DS,AX
	MOV  AL,0H

DRAW_ASCEND-LINE:		;画下降的边
	MOV  DX,280H
	OUT  DX,AL
	CALL DELAY
	CMP  AL,80H
	JZ   DRAW_DESCEND_LINE

	ADD  AL,08H
	JMP  DRAW_ASCEND_LINE
DRAW_DESCNED_LINE:
	SUB  AL,08H
	MOV  DX,280H
	OUT  DX,AL
	CALL DELAY
	CMP  AL,00H
	JZ   DRAW_ASCEND_LINE
	JMP  DRAW_DESCNED_LINE
	MOV  AH,4CH
	INT  21H
DELAY PROC 
	PUSH CX
	MOV  CX,200H
L1:
	LOOP L1
	POP  CX
	RET
DELAY ENDP
CODE  ENDS
END  START