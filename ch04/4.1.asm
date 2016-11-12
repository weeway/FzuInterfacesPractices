;将 INT0—INT7 分别连接到 2 个可变电阻器上，每秒采集一次 0809 
;转换的数字量， 要求： 
;  1、将转换后的数字量和路号在 CRT 上显示，同时将将转换后的数字
;     量送往 8 段显示器显示，采集 10 个循环后结束。 
;  2、将采集到的数据送往内存 TABLE 开始的 240 个单元中存放
;
;  输出格式：
;  ==================================================
;  | 1 FF  2 65  3 DF  4 DD  5 A3  6 ED  7 88  8 AA |
;  ==================================================
;
; 说明：程序启动后，需要先输入 空格 才能继续后面代码的执行
; TABLE_LED: 数码管对应的段码
; TABLE_CRT: 十六进制数对应的 ASSCI 码
;
; 连线 
; PC7--0809 EOC
; PC0--8253 OUT1
; PA --七段数码管
; PB4--数码管 S0
; PB5--数码管 S1
DATA SEGMENT
    TABLE_LED  DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H
               DB 7FH,6FH,77H,7CH,58H,5CH,79H,71H
               DB 80H
    TABLE_CRT  DB 30H,31H,32H,33H,34H,35H,36H,37H
               DB 38H,39H,41H,42H,43H,44H,45H,46H
    TABLE_KONG DW 0,290H,291H,292H,293H,294H,295H,296H,297H
    NUM1       DB 10H
    NUM2       DW 1010H
    TABLE_CUN  DB 240 DUP(0)
DATA ENDS

STACK1 SEGMENT PARA STACK
      DW 40H DUP(0)
STACK1 ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA,SS:STACK1
START:
    MOV AX,DATA            ;保存数据段起始地址
    MOV DS,AX              ;如果后面程序改变了DS,后续代码的访问地址将出错
    
    CALL Init_8253
    CALL Init_8255
    CALL WAIT_INSPACE
    MOV  CX,11
    MOV  SI,0
INIT:
    MOV DI,0
READ_INPUT:
    CALL LIGHT_LED
    MOV  DX,282H 			;PC 端口
    IN   AL,DX
    AND  AL,01H
    JZ   READ_INPUT 		;消耗完负脉冲

    INC DI              
    CMP DI,9                ;读取完IN0~IN7 8个端口 跳转到 NEXT_INPUT
    JZ  NEXT_INPUT          ;进行下一次读取

    PUSH DI                 ;保存 DI 数据 INDEX( IN0~IN7 地址下标)
    SHL  DI,1               ;INDEX*2=端口地址
    MOV  DX,TABLE_KONG[DI]  ;每个端口地址 占 2个 BYTE
    POP  DI
    OUT  DX,AL              ;选通TABLE_KONG[DI],启动A/D转换(AL值任意)
    CALL READ_INx 			;调用 READ_INx 读取 INx 的数据
    
    IN   AL,DX              ;读取端口（INx）数据
    MOV  AH,AL              
    
    PUSH CX				    ;INx 的数据高4位、低4位分别存
    MOV  CL,4 				;AH低4位，AL低4位
    SHR  AH,CL 				
    POP  CX
    AND  AL,0FH
    
    MOV  NUM2,AX 			;INx 存到全局变量 NUM2
    MOV  AX,DI				
    
    MOV  NUM1,AL			;index 存到全局变量 NUM1
    CALL CRT
    CALL SAVE2BUF

WAIT_TIMEOUT:
    MOV  DX,282H		    ;读取 8255 PC口
    IN   AL,DX
    AND  AL,01H
    JNZ  WAIT_TIMEOUT  		;PC0 = 0？
    JMP  READ_INPUT         ;PC0 接受负脉冲，读取 一组8个数据中的下一个
NEXT_INPUT:
    DEC  CX
    CMP  CX,0
    JZ   FINAL 				;读取 11 组数据后，结束程序
    JMP  INIT
FINAL:
    MOV  AH,4CH
    INT  21H

READ_INx PROC NEAR				;PC7 接EOC
    PUSH DX 				;等待 ADC 转换完成
  AGAIN:
    MOV  DX,282H
    IN   AL,DX
    AND  AL,80H
    JZ   AGAIN
    POP  DX
    RET
READ_INx ENDP

LIGHT_LED PROC NEAR
    MOV  AL,0H
    MOV  DX,281H 			;PB口  位码
    OUT  DX,AL

    MOV  AX,NUM2 			;显示低4位
    LEA  BX,TABLE_LED
    XLAT TABLE_LED 			;取出段码到 AL
    MOV  DX,280H 			;PA口
    OUT  DX,AL				;送往 PA 口 

    MOV  AL,10H				;PB4 = 1 点亮数码管 S0
    MOV  DX,281H
    OUT  DX,AL

    MOV  AL,0H 				;熄灭数码管
    MOV  DX,281H
    OUT  DX,AL

    MOV  AX,NUM2 			;显示高4位
    MOV  AL,AH 				
    XLAT TABLE_LED 			;换码操作：以DS:[BX+AL]为地址，提取存储器中的一个字节再送入AL
    MOV  DX,280H
    OUT  DX,AL
    
    MOV  AL,20H 			;PB5 = 1 点亮数码管 S1
    MOV  DX,281H
    OUT  DX,AL
    
    MOV  AL,0H
    MOV  DX,281H
    OUT  DX,AL
    RET
LIGHT_LED ENDP

CRT PROC NEAR				;显示在屏幕上
    MOV  AL,NUM1
    LEA  BX,TABLE_CRT
    XLAT TABLE_CRT
    
    MOV  DL,AL				;打印下标
    MOV  AH,02H
    INT  21H
    
    MOV  DL,' '
    MOV  AH,02H
    INT  21H

    MOV  AX,NUM2 			;打印高4位
    MOV  AL,AH
    LEA  BX,TABLE_CRT
    XLAT TABLE_CRT
    
    MOV  DL,AL
    MOV  AH,02H
    INT  21H
    
    MOV  AX,NUM2 			;打印低4位
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

Init_8253 PROC
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
Init_8253 ENDP

Init_8255 PROC
    MOV  AL,10001001B
    MOV  DX,283H
    OUT  DX,AL
    RET
Init_8255 ENDP

WAIT_INSPACE PROC    		;输入空格，启动程序
  NEXT:
    MOV  AH,01H
    INT  21H
    CMP  AL,20H
    JNZ  NEXT
    RET
WAIT_INSPACE ENDP

CODE ENDS
END START
