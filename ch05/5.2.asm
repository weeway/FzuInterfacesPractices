;十字路口交通灯的变化规律要求： 
;（1） 南北路口的绿灯、东西路口的红灯同时亮 30 秒左右。 
;（2） 南北路口的黄灯闪烁若干次，同时东西路口的红灯继续亮。 
;（3） 南北路口的红灯、东西路口的绿灯同时亮 30 秒左右。 
;（4） 南北路口的红灯继续亮、同时东西路口的黄灯亮闪烁若干次。 
;（5） 转(1)重复。
;
; 8255 C口 接LED
; 

DATA SEGMENT 
IO8255C     EQU 28AH 
IO8255CTL   EQU 28BH 
PORTC1  	DB  24H, 44H, 04H, 44H, 04H, 44H, 04H		;六个灯可能        
			DB  81H, 82H, 80H, 82H, 80H, 82H, 80H    	;的状态数据        
			DB  0FFH                            		;结束标志 
DATA ENDS 
CODE  SEGMENT       
	ASSUME  CS:CODE, DS:DATA 
START:     
	MOV   AX, DATA     
	MOV   DS, AX

	MOV   DX, IO8255CTL     
	MOV   AL, 90H     
	OUT   DX, AL           	   ;设置 8255 为 C 口输出     
	
	MOV   DX, IO8255C 
RE_ON:        
	MOV   BX,0 
ON:      
	MOV   AL, PORTC1[BX]     
	CMP   AL, 0FFH     
	JZ    RE_ON     
	
	OUT   DX, AL           	    ;点亮相应的灯     
	INC   BX     
	
	MOV   CX, 200          		;参数赋初值     
	TEST  AL, 21H          		;是否有绿灯亮     
	JZ    L0                	;没有,短延时     
	
	MOV   CX, 2000         		;有,长延时 
L0:    
	MOV   DI, 9000         		;DI 赋初值 9000 
L1:    
	DEC   DI               		;减 1 计数     
	JNZ   L1              		;DI 不为 0 
	LOOP  L0  
	
	PUSH  DX     
	
	MOV   AH, 06H     
	MOV   DL, 0FFH     
	INT   21H     
	
	POP   DX      				;判断是否有按键 

	JZ    ON                	;没有,转到 ON 
EXIT:        
	MOV   AH,4CH          		;返回     
	INT   21H 
CODE ENDS 
END START 