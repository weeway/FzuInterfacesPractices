DATA SEGMENT
    T0      EQU 280H
    T1      EQU 281H
    T2      EQU 282H
    CLT1     EQU 283H
    PA        EQU 288H
    PB        EQU 289H
    PC        EQU 28AH
    CTL    EQU 28BH
    LTABLE    DB 3FH,06H,5BH,4FH,66H,60H,7DH,07H
            DB 7FH,6FH,77H,7CH,39H,5EH,79H,71H
    DAT        DB 21H
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA

START:
    MOV AX,DATA
    MOV DS,AX

    CALL INIT_8253
    CALL INIT_8255

AGAIN:
    CALL READ_PA
    CALL DISP_DAT
    JMP AGAIN

    MOV AH,4CH
    INT 21H

LED_1 PROC
    LEA SI,LTABLE   ;获得段码表的首地址
    ADD SI,BX       ;获取段码地址

    MOV AL,[SI] 
    AND AL,7FH      ;高位置0，不显示小数点

    MOV DX,PB       ;段码送到 B 端口
    OUT DX,AL

    RET
LED_1 ENDP

LED_S PROC
    PUSH CX
    PUSH BX

    MOV DX,PC       ;熄位码
    MOV AL,0H
    OUT DX,AL

    MOV BH,0
    AND BL,0FH      ;取低4位（A口开关输入）
    CALL LED_1      ;显示低4位
    MOV DX,PC      
    MOV AL,1H       ;PC0 接数码管0 共阳极
    OUT DX,AL

    MOV DX,PC       ;熄位码
    MOV AL,0H
    OUT DX,AL

    MOV BH,0
    MOV CL,4
    SHR BL,CL
    AND BL,0FH      ;取高4位
    CALL LED_1      ;显示低四位
    MOV DX,PC
    MOV AL,02H      ;PC1 接数码管1 共阳极
    OUT DX,AL

    MOV DX,PC       ;熄位码
    MOV AL,0
    OUT DX,AL

    POP BX
    POP CX
    RET
LED_S ENDP

READ_PA PROC
    PUSH DX
    PUSH AX

LOOP_CHECK:
    MOV  BH,0
    MOV  BL,DAT
    CALL LED_S      ;开关数据DAT->BL->显示

    MOV  DX,PC      ;循环检测 负脉冲
    IN   AL,DX
    TEST AL,80H
    JNZ  LOOP_CHECK

    MOV  DX,PA      ;读入新数据
    IN   AL,DX       
    MOV  DAT,AL     ;存到内存 DAT

    POP  AX
    POP  DX
    RET
READ_PA ENDP

DISP_DAT PROC
    PUSH DX
    PUSH AX
    PUSH CX

    MOV AL,DAT
    MOV CL,4
    SHR AL,CL
    AND AL,0FH      ;高4位

    CMP AL,0AH      ;大于10 加7->后边再加30H->assci
    JC  S1
    ADD AL,7H       
S1:
    ADD AL,30H
    MOV DL,AL

    MOV AH,02H
    INT 21H         ;显示到屏幕

    MOV AL,DAT      ;低4位
    AND AL,0FH
    
    CMP AL,0AH
    JC  S2
    ADD AL,7H
S2:
    ADD AL,30H
    MOV DL,AL
    MOV AH,02H
    INT 21H        ;显示到屏幕

    MOV DL,' '     ;插入空格
    MOV AH,02H
    INT 21H

    POP CX
    POP AX
    POP DX
    RET
DISP_DAT ENDP

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