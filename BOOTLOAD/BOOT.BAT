; goto label
		.model	tiny
		.386
		.code
		org	100h
start:
		mov	ah, 13h			;write string
		mov	al, 0h			;service
		xor	dx, dx          	;position == 0
		mov	cx, 0Fh		 	;string length
		jmp	msg			;string addr
l1:		pop	bp
		mov	bx, 0Fh         	;color
		int	10h             	;bios video interrupt

		cli
		hlt

		ret
msg: 		call	l1
		db	'HELLO, WORLD!!!'
		;db	(446 - ($ - start)) dup(0)
		;db	80h
		;db	00h
		;db	00h
		;db	01h
		;db	00h
		;db	00h
		;db	00h
		;db	02h
		;dd	00h
		;dd	01h
		db	(510 - ($ - start)) dup(0)		
		db  	55h, 0AAh
		end	start
; :label
; tasm /m5 boot.bat
; tlink /x/t boot.obj
; del boot.obj