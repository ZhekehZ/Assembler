; goto cmpl
	.model tiny
	.386
	.code
	org 100h
start:	lea dx, buf
	mov ah, 09h
	int 21h
	ret
buf	db 'Hello, world!', 13, 10, '$'
	end start
; :cmpl
; tasm /m5/l hw.bat
; tlink /x/t hw.obj
; del hw.obj