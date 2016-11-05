;8255 A口，工作方式0，输入，接8个开关，B口方式0，输出，接8个LED，PC7
;接单脉冲，输入负脉冲时，读一次A口，存入TABLE内存单元中，并在B口显示


DATA SEGMENT
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

    MOV DX,CTLS
    MOV AL,10011000B
    OUT DX,AL

    MOV CX,10
    MOV SI,0
WAT:
    MOV DX,PC
    IN  AL,DX
    AND AL,80H
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
    AND AL,80H
    JZ  WAT1

    LOOP WAT

    MOV  AH,4CH
    INT  21H
CODE ENDS
END START