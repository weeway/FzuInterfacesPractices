;8255 A口，工作方式0，输入，接8个开关，B口方式0，输出，接8个LED，PC0
;接1s的8253，8253输入负脉冲时，读一次A口，存入TABLE内存单元中，并在B口显示

DATA SEGMENT
    T0      EQU 280H
    T1      EQU 281H
    T2      EQU 282H
    CLT1    EQU 283H
    PA   EQU 288H
    PB   EQU 289H
    PC   EQU 28AH
    CTLS EQU 28BH
    LTABLE DB 10 DUP(?)
DATA ENDS

STACK1 SEGMENT PARA STACK
    DW 20H DUP(0)
STACK1 ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA

START:
    MOV AX,DATA
    MOV DS,AX
    
    CALL INIT_8253
    
    MOV DX,CTLS
    MOV AL,10011001B
    OUT DX,AL

    MOV CX,256
    MOV SI,0
WAT:
    MOV DX,PC
    IN  AL,DX
    AND AL,01H
    JNZ WAT

    MOV DX,PA
    IN  AL,DX
    MOV DX,PB
    OUT DX,AL
    MOV LTABLE[SI],AL
    INC SI
WAT1:
    MOV DX,PC
    IN  AL,DX
    AND AL,01H
    JZ  WAT1

    LOOP WAT

    MOV  AH,4CH
    INT  21H

;产生1s方波
INIT_8253 PROC
    PUSH DX
    PUSH AX

    MOV DX,CLT1
    MOV AL,00110111B ;写入8253控制字
    OUT DX,AL

    ;产生 1ms 方波
    MOV DX,T0
    MOV AL,00H
    OUT DX,AL

    MOV AL,20H
    OUT DX,AL

    
    ;产生 1s 方波
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
    
CODE ENDS
END START