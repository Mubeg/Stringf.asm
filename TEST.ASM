.model tiny
.data
Msg1 db "Hello world!1"
Msg2 db "Hello world!2"
Msg3 db "Hello world!3"
Msg4 db "Helo world!4"
Msg5 db "Hello world!5", 0
Msg6 db " wor", 0

.code
org 100h

extrn memset:proc
extrn memcpy:proc
extrn memchr:proc
extrn memcmp:proc
extrn strlen:proc
extrn strchr:proc
extrn strrchr:proc
extrn strcpy:proc
extrn strstr:proc

start:

	mov di, offset Msg1
	mov si, '-'
	mov dx, 7
	call memset

	mov di, offset Msg1
	mov si, offset Msg2
	mov dx, 7
	call memcpy
	
	mov di, offset Msg3
	mov si, 'o'
	mov dx, 5
	call memchr
	mov di, ax
	mov ax, [di]

	mov di, offset Msg3
	mov si, offset Msg4
	mov dx, 10h
	call memcmp

	mov di, offset Msg5
	call strlen

	mov di, offset Msg5
	mov si, 'o'
	call strchr	

	mov di, offset Msg5
	mov si, 'o'
	call strrchr

	mov di, offset Msg1
	inc di
	mov si, offset Msg5
	call strcpy

	mov di, offset Msg5
	mov si, offset Msg6
	call strstr

	mov ax, 4c00h
	int 21h
end start
