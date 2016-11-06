;��INT0-INT7�ֱ����ӵ�2���ɱ�����ϣ�����ɼ�һ��0809ת��������
;����Ҫ��
;1����ת�������������·����CRT����ʾ��ͬʱ��ת�������������͵�8
;8����ʾ����ʾ���ɼ�10��ѭ�������
;2�����ɼ����������͵��ڴ�TABLE��ʼ��240����Ԫ�д��


DATA SEGMENT
    TABLE_LED    DB  3FH,06H,5BH,4FH,66H,6DH,7DH,07H
                 DB  7FH,6FH,77H,7CH,39H,5EH,79H,71H
                 DB  80H
    TABLE_CRT    DB    30H,31H,32H,33H,34H,35H,36H,37H,38H
                 DB    39H,41H,42H,43H,44H,45H,46H
    TABLE_KONG   DW    0,290H,291H,292H,293H,294H,295H,296H,297H
    NUM1         DB    10H
    NUM2         DW    1010H
    TABLE_CUN    DB    240    DUP(0)
DATA ENDS

STACK1 SEGMENT PARA STACK
    DW    40H DUP(0)
STACK1    ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA,SS:STACK1

;===========������===========
START:
    MOV  AX,DATA
    MOV  DS,AX

    CALL INIT_8253
    CALL INIT_8255
    
    CALL WAIT_INSPACE
    MOV  CX,11
    MOV  SI,0

INIT:
    MOV  DI,0

READ_INPUT:
    CALL LIGHT_LED
    MOV  DX,282H
    IN   AL,DX
    AND  AL,01H
    JZ   READ_INPUT

    INC  DI
    CMP  DI,9
    JZ   NEXT_INPUT

    PUSH DI
    SHL  DI,1
    MOV  DX,TABLE_KONG[DI]
    POP  DI
    OUT  DX,AL
    CALL DELAY
    IN   AL,DX
    MOV  AH,AL
    PUSH CX
    MOV  CL,4
    SHR  AH,CL
    POP  CX
    AND  AL,0FH
    MOV  NUM2,AX
    MOV  AX,DI
    MOV  NUM1,AL
    CALL CRT
    CALL SAVE2BUF

WAIT_TIMEOUT:
    MOV  DX,282H
    IN   AL,DX
    AND  AL,01H
    JNZ  WAIT_TIMEOUT
    JMP  READ_INPUT
NEXT_INPUT:
    DEC  CX
    CMP CX,0
    JZ   FINAL
    JMP  INIT
FINAL:
    MOV  AH,4CH
    INT  21H
;============����ʵ��============
DELAY PROC NEAR
    PUSH DX
AGAIN:
    MOV  DX,282H
    IN   AL,DX
    AND  AL,80H
    JZ   AGAIN
    POP  DX
    RET
DELAY ENDP

LIGHT_LED PROC NEAR
    MOV  AL,0H
    MOV  DX,281H
    OUT  DX,AL

    MOV  AX,NUM2
    LEA  BX,TABLE_LED
    XLAT TABLE_LED       ;��DS:[BX+AL]Ϊ��ַ����ȡ�洢��
                         ;�е�һ���ֽ�������AL    MOV  DX,280H
    OUT  DX,AL

    MOV  AL,10H
    MOV  DX,281H
    OUT  DX,AL

    MOV  AL,0H
    MOV  DX,281H
    OUT  DX,AL

    MOV  AX,NUM2
    MOV  AL,AH
    XLAT TABLE_LED
    MOV  DX,280H
    OUT  DX,AL

    MOV  AL,20H
    MOV  DX,281H
    OUT  DX,AL

    MOV  AL,0H
    MOV  DX,281H
    OUT  DX,AL

    RET
LIGHT_LED ENDP

CRT PROC NEAR
    MOV  AL,NUM1
    LEA  BX,TABLE_CRT
    XLAT TABLE_CRT
    MOV  DL,AL
    MOV  AH,02H
    INT  21H
    MOV  DL,' '
    MOV  AH,02H
    INT  21H

    MOV  AX,NUM2
    MOV  AL,AH
    LEA  BX,TABLE_CRT
    XLAT TABLE_CRT
    MOV  DL,AL
    MOV  AH,02H
    INT  21H
    MOV  AX,NUM2
    XLAT TABLE_CRT
    MOV  DL,AL
    MOV  AH,02H
    INT  21H
    MOV  DL,' '
    MOV  AH,02H
    INT  21H
    MOV  DL,' '
    MOV  AH,02H
    INT  21H
    RET
CRT ENDP

SAVE2BUF PROC NEAR
    MOV  AL,NUM1
    MOV  TABLE_CUN[SI],AL
    INC  SI
    MOV  AX,NUM2
    MOV  TABLE_CUN[SI],AH
    INC  SI
    MOV  TABLE_CUN[SI],AL
    INC  SI
    RET
SAVE2BUF ENDP

INIT_8253 PROC NEAR
    MOV  DX,28BH
    MOV  AL,00100101B
    OUT  DX,AL
    MOV  DX,288H
    MOV  AL,10H
    OUT  DX,AL
    MOV  DX,28BH
    MOV  AL,01100111B
    OUT  DX,AL
    MOV  DX,289H
    MOV  AL,10H
    OUT  DX,AL
    RET

;    MOV DX,CLT
;    MOV AL,00110111B 
;    OUT DX,AL

;    MOV DX,T0
;    MOV AL,00H
;    OUT DX,AL

 ;   MOV AL,20H
 ;   OUT DX,AL

    
 ;   MOV DX,CLT
;    MOV AL,01110111B 
;    OUT DX,AL

;    MOV DX,T1
;    MOV AL,00H
;    OUT DX,AL

;    MOV AL,10H
;    OUT DX,AL
;    RET
INIT_8253 ENDP

INIT_8255 PROC NEAR
    MOV  AL,10001001B
    MOV  DX,283H
    OUT  DX,AL
    RET
INIT_8255 ENDP

WAIT_INSPACE PROC
NEXT:
    MOV  AH,01H
    INT  21H
    CMP  AL,20H
    JNZ  NEXT
    RET
WAIT_INSPACE ENDP

CODE ENDS
END START