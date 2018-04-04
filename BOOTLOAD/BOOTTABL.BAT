; goto label
		.model	tiny
		.386
		.code
		org	100h
start:		
		mov ax, 03h
		int 10h

		mov ax, 0B800h
		mov es, ax
;jmp tbl
		mov di, 80*2+4
		mov word ptr es:[di], 0EC9h
		mov di, 80*36+4
		mov word ptr es:[di], 0EC8h		
		mov di, 80*36+4+4*17
		mov word ptr es:[di], 0EBCh
		sub di, 2
		mov word ptr es:[di], 0ECDh
		sub di, 80*34
		mov word ptr es:[di], 0ECDh
		add di, 2
		mov word ptr es:[di], 0EBBh		

		mov cx, 10h
		mov dx, 17*80*2
		jmp WW
line:		pop bx
l1:		;mov bx, offset w
		mov al, cl
		dec al 
		xlat
		mov di, cx
		inc di
		add di, di
		add di, di
		mov ah, 04h
		mov word ptr es:[di], ax
		add di, 160
		mov word ptr es:[di], 0ECDh
		sub di, 2

		mov word ptr es:[di], 0ECDh
		add di, 80*2*17
		mov word ptr es:[di], 0ECDh
		add di, 2
		mov word ptr es:[di], 0ECDh
		mov di, dx
		sub dx, 80*2
		;mov dx, 0B800h
		;mov es, dx
		mov word ptr es:[di], ax
		add di, 4
		mov word ptr es:[di], 0EBAh
		add di, 17*2*2
		mov word ptr es:[di], 0EBAh		
		loop l1

tbl:		mov cx, 0010h	
		mov dx, 17*160 
kek0:
		push cx
		mov cx, 10h
	kek:	mov ax, cx
		dec ax		
		add ax, 2
		add ax, ax
		add ax, ax
		add ax, dx
		mov di, ax
		mov al, cl
		dec al
		pop bx
		push bx
		dec bl
		shl bl, 4 
		add al, bl 
		mov ah, 0Fh
		mov word ptr es:[di], ax
		loop kek

		sub dx, 160
		pop cx
	
		loop kek0
		cli
		hlt
		;ret
d db 10h
WW:  call line
w db '0123456789ABCDEF'

		db	(510 - ($ - start)) dup(0)		
		db  	55h, 0AAh
		end	start
; :label
; tasm /m5 boottabl.bat
; tlink /x/t boottabl.obj
; del boottabl.obj