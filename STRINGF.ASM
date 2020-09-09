.model tiny
.code
org 100h

screen_width = 80
height = 25

public memset 
public memcpy 
public memcpy_add_attr 
public memchr 
public memcmp 
public strlen 
public strchr 
public str2chr 
public strrchr 
public strcpy
public strcpy_add_attr
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
;Memcpy but add attribute after each copied symbol for graphics
;In
;	dir flag - direction
;	es - seg addr dest
;	di - addr dest
;	ds - seg addr source
;	si - addr source
;	dx - size
;	al - attribute to add after symbol
;Out
;	ax - addr dest
;---------------------------------------------------;
memcpy_add_attr	proc
	push di cx bx dx

	mov cx, dx
	mov bh, al		; color

	cmp cx, 0
	je loop_MAZ_end
loop_MAZ:
	cmp di, 4000
	jl no_scroll_MAZ
	call do_scroll_or_not
	
no_scroll_MAZ:
	movsb
	stosb

	inc dx
	loop loop_MAZ

loop_MAZ_end:
	pop dx bx cx ax
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
	cmp al, dl
	je memcmp_equal
	jb memcmp_below
	mov ax, 01h
	jmp memcmp_done

memcmp_below:
	mov ah, 0FFh
	jmp memcmp_done
memcmp_equal:
	mov ax, 0h

memcmp_done:

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
;	ds - seg addr
;	di - search_value
;	si - addr
;Out	
;	ax - addr of first occurance of value in string or 0
;---------------------------------------------------;
strchr	proc
	pushf
	cld
	push dx

	mov dx, di

strchr_loop:

	lodsb
	cmp al, 0
	je strchr_not_found

	cmp al, dl
	je strchr_loop_end

	jmp strchr_loop

strchr_loop_end:
	mov ax, si
	dec ax
	jmp strchr_found	

strchr_not_found:
	mov ax, 0
strchr_found:

	pop dx
	popf
	ret
endp


;---------------------------------------------------;
;In
;	ds - seg addr
;	bx - first search_value
;	si - addr
;	cx - second search_value
;Out	
;	ax - addr of first occurance of value in string or 0
;	bx - found_value
;DESTROYED ax bx
;---------------------------------------------------;
str2chr	proc


str2chr_loop:

	lodsb
	cmp al, 0
	je str2chr_not_found

	cmp al, bl
	je str2chr_loop_end_1
	cmp al, cl
	je str2chr_loop_end_2

	jmp str2chr_loop

str2chr_loop_end_2:
	mov bx, cx
str2chr_loop_end_1:
	mov ax, si
	dec ax
	jmp str2chr_found	

str2chr_not_found:
	mov ax, 0
str2chr_found:

	ret
endp

;---------------------------------------------------;
;In
;	ds - seg addr
;	si - addr
;	di - search_value
;Out	
;	ax - addr of last occurance of value in string or 0
;---------------------------------------------------;
strrchr proc
	pushf
	cld
	push cx

	mov cx, di
	mov ax, 0

strrchr_loop:

	lodsb
	cmp al, 0
	je strrchr_loop_end

	cmp al, cl
	jne strrchr_next
	mov ax, si

strrchr_next:
	jmp strrchr_loop

strrchr_loop_end:

	pop cx
	popf
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
	push di

strcpy_loop:

	lodsb
	cmp al, 0
	je strcpy_loop_end

	stosb
	jmp strcpy_loop

strcpy_loop_end:
	mov byte ptr es:[di], 0h
	
	pop ax
	popf
	ret
endp


;---------------------------------------------------;
;strcpy but add attribute after each symbol for graphics
;In
;	es - seg addr dest
;	di - addr dest
;	ds - seg addr source
;	si - addr source
;	ah - attribute to add after symbol
;Out
;	ax - addr dest
;---------------------------------------------------;
strcpy_add_attr	proc

	push di

strcpy_loop_AZ:

	lodsb
	cmp al, 0
	je strcpy_loop_end_AZ
	cmp di, 4000
	jl no_call_AZ
	call do_scroll_or_not
no_call_AZ:
	stosw
	jmp strcpy_loop_AZ

strcpy_loop_end_AZ:

	mov al, 0h
	stosw
	
	pop ax
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
	pushf
	cld
	push cx dx

	push es di
	mov ax, ds
	mov es, ax
	mov di, si
	call strlen
	pop di es

	mov dx, ax	;dx = len(s2)

strstr_loop:

	push si
	mov si, word ptr ds:[si]
	call strchr
	pop si

	cmp ax, 0
	je strstr_not_found

	mov di, ax
	push di si
	call memcmp
	pop si di

	cmp ax, 0
	je strstr_found

	inc di
	jmp strstr_loop

strstr_found:
	mov ax, di
strstr_not_found:
	pop cx dx
	popf
	ret
endp

do_scroll_or_not proc

	cmp di, screen_width*height*2
	jl no_scroll
	push ax cx dx
	mov ah, 06h
	mov al, 01h
	mov cx, 0000h
	mov dh, height - 1
	mov dl, screen_width - 1
	int 10h
	pop dx cx ax
	sub di, screen_width*2
no_scroll:

ret
endp

end 	start



















