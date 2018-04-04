; goto cmpl
; 2.2.2
	.model tiny
	.486
	.code
	org 100h
start:	jmp next
next:
	cli 
	in al, 61h
	or al, 11b
	out 61h, al
	mov al,10110110b
	out 43h, al
	mov ax, 1809
	out 42h, al
	ror ax, 8
	out 42h, al 
		
	sti
	ret


	cli
	mov dx, 1000
	in al, 61h
	and al, 11111110b	
lab1:	or al, 00000010b
	out 61h, al
	mov cx, 300
delay:  loop delay
	and al, 11111101b
	out 61h, al
	mov cx, 300
delay2: loop delay2
	dec dx
	jnz lab1
	sti
	ret
h4:	ror bx, 8h
	call h2
	ror bx, 8h
h2:	cld
	mov al, bl
	shr al, 04h
	cmp al, 10
	sbb al, 69h
	das
	stosb
	mov al, bl
	and al, 0Fh
	cmp al, 10
	sbb al, 69h
	das
	stosb
	ret

buff	db '____', '$'
	end start
; :cmpl
; tasm /m5 sound.bat
; tlink /x/t sound.obj
; del sound.obj
