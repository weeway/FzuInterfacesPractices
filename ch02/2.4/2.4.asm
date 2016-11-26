;4、A 口工作在方式 0 输入方式，接 4 个开关，B 口工作在方式 0 输出方式，
;接 1 个七段显示器，PC7 接单脉冲发生器，输入负脉冲时，读一次 A 口，同时
;在 B 口显示，读 16 次结束





DATA SEGMENT
    T0      EQU 280H
    T1      EQU 281H
    T2      EQU 282H
    CLT1    EQU 283H
    PA      EQU 288H
    PB      EQU 289H
    PC      EQU 28AH
    CTL     EQU 28BH
    LTABLE  DB  3FH,06H,58H,4FH,66H,60H,7DH,07H
            DB  7FH,6FH,77H,7CH,39H,5EH,79H,71H
    DAT     DB  21H
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA

START:
    MOV AX,DATA
    MOV DS,AX

    CALL INIT_8255

    MOV  SI,0
AGAIN:
    CALL READ_PA
    INC SI
    CMP SI,16           ;按16次单次负脉冲结束程序
    JNC BREAK
    JMP AGAIN

BREAK:
    MOV AH,4CH
    INT 21H

LED_1 PROC
    PUSH SI
    LEA  SI,LTABLE       ;段码表首地址
    ADD  SI,BX           
 
    MOV AL,[SI] 
    AND AL,7FH           ;段码，最高置0，熄小数点

    MOV DX,PB            ;到B口
    OUT DX,AL

    POP SI
    RET
LED_1 ENDP

LED_S PROC
    PUSH CX
    PUSH BX

    MOV DX,PC           
    MOV AL,0H
    OUT DX,AL

    MOV  BH,0
    AND  BL,0FH         
    CALL LED_1

    MOV DX,PC           
    MOV AL,1H
    OUT DX,AL

    MOV DX,PC          
    MOV AL,0H
    OUT DX,AL

    POP BX
    POP CX
    RET
LED_S ENDP

READ_PA PROC
    PUSH DX
    PUSH AX

;检测负脉冲
LOOP_CHECK:
    MOV  BH,0
    MOV  BL,DAT
    CALL LED_S         

    MOV  DX,PC
    IN   AL,DX
    TEST AL,80H
    JNZ  LOOP_CHECK

;等待负脉冲消耗完
LOOP_C:
    MOV  DX,PA
    IN   AL,DX          
    MOV  DAT,AL

    ;MOV  BH,0
    ;MOV  BL,DAT
    CALL LED_S         

    MOV  DX,PC
    IN   AL,DX
    TEST AL,80H
    JNZ  LOOP_C

    POP  AX
    POP  DX
    RET
READ_PA ENDP

INIT_8255 PROC
    PUSH DX
    PUSH AX

    MOV DX,CTL
    MOV AL,98H
    OUT DX,AL

    POP AX
    POP DX

    RET
INIT_8255 ENDP

CODE ENDS
END START    