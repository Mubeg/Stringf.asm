.model tiny
.data
Msg db "Hello world"
.code
org 100h

public memset 
public memcpy 
public memchr 
public memcmp 
public strlen 
public strchr 
public strrchr 
public strcp 
public strstr


start:
	mov ax, 4c00h
	int 21h

;---------------------------------------------------;
;In
;	dir flag - for direction cld = address inc, std = address dec
;	es - offset string segment
;	di - offset string intersegment
;	si - set_value (only lower byte is used)
;	dx - size (in bytes)
;Out
;	ax - offset string intesegment
;---------------------------------------------------;
memset	proc
	push di cx

	mov cx, dx
	mov ax, si 
	mov ah, al	; ax = al:al
	
	shr dx, 1
	jnc	even_byte_num_mst
	stosb

even_byte_num_mst:
	shr cx, 1	; cx /= 2
	rep stosw	; word ptr es:[di] = al; di+=2

	pop cx ax
	ret
endp
;---------------------------------------------------;
;In
;	dir flag - direction
;	es - seg addr dest
;	di - addr dest
;	ds - seg addr source
;	si - addr source
;	dx - size
;Out
;	ax - addr dest
;---------------------------------------------------;
memcpy	proc
	push di cx

	mov cx, dx
	shr dx, 1h	; cf = low bit
	jnc even_byte_num_mcp	; jmp if cf = 0
	movsb

even_byte_num_mcp:
	shr cx, 1h
	rep movsw
	pop cx ax
	ret
endp

;---------------------------------------------------;
;In
;	dir flag - for direction cld = address inc, std = address dec
;	es - offset string segment
;	di - offset string intersegment
;	si - search_value (only lower byte is used)
;	dx - size (in bytes)
;Out
;	ax - addr search_value occurance
;---------------------------------------------------;
memchr	proc
	pushf
	push cx

	mov cx, dx
	mov ax, si 
	repne scasb	; cx times : cmp until meet
	jne not_found

	pushf
	pop ax
	xor ax, 400h
	push ax
	popf

	scasb		; dec di in dir

	
	mov ax, di
	jmp found
not_found:
	mov ax, 0
found:
	pop cx
	popf
	ret
endp

;---------------------------------------------------;
;In
;	dir flag - direction
;	es - seg addr 1
;	di - addr 1
;	ds - seg addr 2
;	si - addr 2
;	dx - size
;Out
;	ax - cmp_result if <0 -> 1 < 2; >0 -> 1 > 2; =0 -> 1 === 2
;---------------------------------------------------;
memcmp	proc
	pushf
	push cx

	mov cx, dx
	repe cmpsb	; cx times : cmp until not equal

	pushf
	pop ax
	xor ax, 400h
	push ax
	popf
	cmpsb


	mov al, byte ptr es:[di]
	mov dl, byte ptr ds:[si]
	sub al, dl
	
	pop cx
	popf
	ret
endp

strlen	proc

	ret
endp

strchr	proc

	ret
endp

strrchr proc

	ret
endp

strcp	proc

	ret
endp

strstr	proc

	ret
endp

end 	start



















