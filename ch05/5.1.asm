;直接用手动产单脉冲作为中断请求信号(只需连接一根导 线)。
;要求每按一次开关产生一次中断，在屏幕上显示一次“TPCA Interrupt!”，
;中断 10 次后程序退出。  


DATA SEGMENT
 	MESS DB 'TPCA INTERRUPT!',0DH,0AH,'$' 
DATA ENDS 

CODE SEGMENT 
	ASSUME  CS:CODE, DS:DATA 

START:     
	MOV  AX, CS     
	MOV  DS, AX     
	
	MOV  DX, OFFSET INT3
	MOV  AX, 250BH     
	INT  21H       		;设置 IRQ3 的中断矢量     
	
	IN   AL, 21H    	;读中断屏蔽寄存器     
	AND  AL, 0F7H   	;开放 IRQ3 中断  1111 0111B    
	OUT  21H,  AL       ;开放 IRQ3 中断
	
	MOV  CX, 10     	     
	STI                 ;置中断标志位 
L1:    
	JMP L1 

INT3:                 	;中断服务程序     
	MOV  AX, DATA     
	MOV  DS, AX     
	
	MOV  DX, OFFSET MESS      
	MOV  AH, 09     
	INT  21H    		;显示每次中断的提示信息 
	
	MOV  AL, 20H     
	OUT  20H, AL    	;发出 EOI 结束中断     
	LOOP NEXT     
	
	IN   AL, 21H     	;读中断屏蔽寄存器     
	OR   AL, 08H     	;关闭 IRQ3 中断     
	OUT  21H, AL     
	STI 				;置中断标志位   
	                	  
	MOV  AH, 4CH     
	INT  21H 
NEXT:    
	IRET 
CODE ENDS 
END START  