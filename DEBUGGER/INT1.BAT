; goto label

	.model tiny
	.386
	.code
	org 100h
start:	
	jmp next

int1_handler:
	push bp			;save BP
	mov bp, sp
	pusha			;save AX, BX, CX, DX, BP(=SP), SP, DI, SI
	push ds			;save DS
	push es			;save ES
	push cs
	pop ax
	mov ds, ax		;DS = CS
	mov es, ax		;ES = CS
	lea di, buff		
	mov bx, word ptr [bp+2] ;BX = instrustion addr.
	call h4			;write BP to buff
	mov ah, 09h
	lea dx, buff
	int 21h			;print buff
	pop es			;restore ES
	pop ds			;restore DS
	popa			;restore AX, BX, CX, DX, BP(=SP), SP, DI, SI
	pop bp			;restore BP
	iret	

buff db "____", 13, 10, '$'


next:	
	lea ax, int1_handler	;get addr.(IP)
	xor di, di		
	mov es, di		 
	mov es:[4], ax		;mov addr to 0000:0004
	push cs
	pop ax	
	mov es:[4] + 2, ax	;mov CS to 0000:0006
		
	mov ax, 3D00h
	lea dx, filename
	int 21h			;open file (filename) ->  AX
	jc error
	
	mov bx, ax		
	mov cx, 0FFh		;read 255 bytes
	lea dx, prog		;buffer
	mov ah, 3Fh
	int 21h 		;read file from handle 
	jc error

	mov ah, 3Eh		;close file
	int 21h
	
	mov ax, offset psp	;ax = XXXX
	shr ax, 4 		;ax = 0XXX
	mov dx, cs		
	add ax, dx		
	mov ds, ax		;DS = CS + 0XXX = [PSP]

	lea cx, retaddr
	pushf
	push cs			;return segment
	push cx			;return offset
	push 0			;for ret in prog

	mov cx, ax
	pushf
	pop ax			;ax <- flags
	or ax, 100h		;set TF flag (8th bit)
	push ax			;push new flag register

	push cx			;segment of dest prog
	push 100h		;offset of dest prog

	iret			;IP = 100h, CS = [PSP], TF = 1

retaddr:
	push cs
	pop ds
	lea dx, endmes
	mov ah, 09h
	int 21h

error:
	ret

endmes db "Finished", 13, 10, '$'
filename db "hw.com", 0

h4:				;ES:DI <- hex of BX
	ror bx, 8
	call h2
	ror bx, 8
h2:				;ES:DI <- hex of BL
	mov al, bl
	shr al, 4
	cmp al, 10
	sbb al, 69h
	das			;AL = hex of BL (h)
	cld			;DF = 0 (DI++, SI++ on str ops)
	stosb			;ES:DI <- AL
	mov al, bl
	and al, 0Fh
	cmp al, 10
	sbb al, 69h
	das			;AL = hex of BL (l)
	stosb			;ES:DI <- AL			
	ret

align 16
psp db 0CFh, 255 dup(0)		;empty buffer for org 100h in program
				;0CFh == IRET
prog db 256 dup(0)		;empty buffer for program

	end start	
; :label
; tasm /m5 int1.bat
; tlink /x/t int1.obj
; del int1.obj