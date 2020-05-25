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
public strcpy
public strstr


start:
	mov ax, 4c00h
	int 21h

;---------------------------------------------------;
;In
;	dir flag - for direction
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



;---------------------------------------------------;
;In
;	es - seg addr
;	di - addr
;Out	
;	ax - num of bytes
;---------------------------------------------------;
strlen	proc
	pushf
	push cx
	cld	; dir flag = 0

	mov ax, 0h
	mov cx, 0ffffh		; seg size - 'max' size

	repne scasb

	mov ax, 0fffeh
	sub ax, cx

	pop cx
	popf
	ret
endp

;---------------------------------------------------;
;In
;	es - seg addr
;	di - addr
;	si - search_value
;Out	
;	ax - addr of first occurance of value in string or 0
;---------------------------------------------------;
strchr	proc

	mov ax, si

strchr_loop:

	cmp byte ptr es:[di], 0
	je strchr_not_found

	cmp byte ptr es:[di], al
	je strchr_loop_end

	inc di
	jmp strchr_loop

strchr_loop_end:
	mov ax, di
	jmp strchr_found	

strchr_not_found:
	mov ax, 0
strchr_found:

	ret
endp

;---------------------------------------------------;
;In
;	es - seg addr
;	di - addr
;	si - search_value
;Out	
;	ax - addr of last occurance of value in string or 0
;---------------------------------------------------;
strrchr proc
	push cx

	mov cx, si
	mov ax, 0

strrchr_loop:

	cmp byte ptr es:[di], 0
	je strrchr_loop_end

	cmp byte ptr es:[di], cl
	jne strrchr_next
	mov ax, di

strrchr_next:
	inc di
	jmp strrchr_loop

strrchr_loop_end:

	pop cx
	ret
endp

;---------------------------------------------------;
;In
;	es - seg addr dest
;	di - addr dest
;	ds - seg addr source
;	si - addr source
;Out
;	ax - addr dest
;---------------------------------------------------;
strcpy	proc
	pushf
	cld

	mov ax, di

strcpy_loop:

	cmp byte ptr ds:[si], 0
	je strcpy_loop_end

	movsb
	jmp strcpy_loop

strcpy_loop_end:
	mov byte ptr es:[di], 0h
	
	popf
	ret
endp

;---------------------------------------------------;
;In
;	es - seg addr 1
;	di - addr 1
;	ds - seg addr 2
;	si - addr 2
;Out
;	ax - addr of first occurance of str2 in str1 or 0
;---------------------------------------------------;
strstr	proc

	ret
endp

end 	start



















