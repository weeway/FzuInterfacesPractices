;8253产生1ms延迟，16次产生锯齿波，最高点-5V
;波形(16阶梯):
;
;_ 0V
; |_
;   |_
;	  |_
;    	|_
;         |_
;           |_...
;				 |_	
;                  |_ -5V


DATA SEGMENT
    T0      EQU 280H
    T1      EQU 281H
    T2      EQU 282H
    CLT1    EQU 283H
    PA      EQU 288H
    PB      EQU 289H
    PC      EQU 28AH
    CTL     EQU 28BH	
DATA ENDS

STACK1 SEGMENT PARA STACK
	DW 20H DUP(0)
STACK1 ENDS

CODE SEGMENT
	ASSUME CS:CODE,DS:DATA,SS:STACK1
START:
	MOV  AX,DATA
	MOV  DS,AX

	CALL INIT_8253

	MOV  AL,00H
AGAIN:
	MOV   DX,280H	
	OUT   DX,AL		    ;写入0832输入寄存器，直通DAC寄存器
	CALL  DELAY_1ms     ;延时
	ADD   AL,10H		;步进10H,16次后AL溢出清零。周期性产生锯齿波
	JMP   AGAIN

	MOV  AH,4CH
	INT  21H


;1ms 方波
INIT_8253 PROC
    PUSH DX
    PUSH AX

    MOV DX,CLT1
    MOV AL,00110111B 
    OUT DX,AL

    MOV DX,T0
    MOV AL,00H
    OUT DX,AL

    MOV AL,20H
    OUT DX,AL

    
    MOV DX,CLT1
    MOV AL,01110111B 
    OUT DX,AL

    MOV DX,T1
    MOV AL,00H
    OUT DX,AL

    MOV AL,10H
    OUT DX,AL

    POP AX
    POP DX

    RET
INIT_8253 ENDP

DELAY_1ms PROC
    PUSH DX
    PUSH AX

;检测负脉冲
LOOP_CHECK:      
    MOV  DX,PC
    IN   AL,DX
    TEST AL,80H
    JNZ  LOOP_CHECK

;等待负脉冲消耗完
LOOP_C:       
    MOV  DX,PC
    IN   AL,DX
    TEST AL,80H
    JNZ  LOOP_C

    POP  AX
    POP  DX
    RET
DELAY_1ms ENDP

CODE ENDS
END  START