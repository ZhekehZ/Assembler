; goto label

	.model tiny
	.386
	.code
	org 100h
start:	
	jmp next

bp_pos	equ 03h			;breakpoint position
old_com	db 90h			;default = NOP

int3_handler:	
	push bp			;save BP
	mov bp, sp
	pusha			;save AX, BX, CX, DX, BP(=SP), SP, DI, SI
	push ds			;save DS
	push es			;save ES
	
	add bp, 2		;[BP] = old_IP
	dec word ptr [bp]	;old_IP--

	push cs	
	pop ax
	mov ds, ax		;DS = CS
	mov es, ax		;ES = CS

	lea di, buff	
	add di, 17	
	mov bx, word ptr [bp+2]	;BX = instrustion IP
	call h4			;write BP to buff

	add di, 6
	mov bx, word ptr [bp] 	;BX = instrustion CS
	call h4

	add di, 8
	mov bl, old_com
	call h2

	mov ah, 09h
	lea dx, buff
	int 21h			;print buff
	
	mov es, [bp + 2]	;ES <- old_CS
	mov di, [bp]		;DI <- old_IP
	mov al, old_com
	mov [es:di], al
	mov old_com, 90h	;set default	
	
	pop es			;restore ES
	pop ds			;restore DS
	popa			;restore AX, BX, CX, DX, BP(=SP), SP, DI, SI
	pop bp			;restore BP
	iret	

buff db "BREAKPOINT > CS: ____, IP: ____, CODE: __", 13, 10, '$'
;buff2 db "CURRENT CS: ____", 13, 10, '$'

next:	
	push cs
	pop ds
	lea dx, stames
	mov ah, 09h
	int 21h

	;mov bx, cs
	;lea di, buff2
	;add di, 12
	;call h4
	;lea dx, buff2
	;mov ah, 09h
	;int 21h

	lea ax, int3_handler	;get addr.(IP)
	xor di, di		
	mov es, di		 
	mov es:[4 * 3], ax	;mov addr to 0000:000C
	push cs
	pop ax	
	mov es:[4 * 3] + 2, ax	;mov CS to 0000:000E
	
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

	mov al, cs:[prog + bp_pos]
	mov cs:[prog + bp_pos], 0CCh
	mov old_com, al

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

	pushf
	push ax			;segment of dest prog
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
stames db "Started", 13, 10, '$'
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
; tasm /m5 int3.bat
; tlink /x/t int3.obj
; del int3.obj