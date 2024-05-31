[org 0x0100]

call clrscr

push word [top]
push word [left]
push word [bottom]
push word [right]
call drawrect

mov al, 'P'
push ax
call drawchar

xor ax, ax
mov es, ax
mov ax, [es:9*4]
mov [oldisr], ax
mov ax, [es:9*4+2]
mov [oldisr+2], ax
cli
mov word [es:9*4], kbisr
mov [es:9*4+2], cs
sti

l1:
    mov ah, 0
    int 0x16

    cmp al, 27
    jne l1

    mov ax, [oldisr]
    mov bx, [oldisr+2]
    cli
    mov [es:9*4], ax
    mov [es:9*4+2], bx
    sti
    
    mov ax, 0x4c00
    int 0x21
    
top:        dw  10
left:       dw  20
bottom:     dw  20
right:      dw  40
oldisr:     dd  0
playery:    dw  15
playerx:    dw  30


clrscr:
    push es
    push ax
    push di

    mov ax, 0xb800
    mov es, ax
    mov di, 0
        
    nextloc:
        mov word [es:di], 0x0720
        add di, 2
        cmp di, 4000
        jne nextloc
        
    pop di
    pop ax
    pop es
    ret
    

drawchar:
    push bp
    mov bp, sp
    push ax

    mov ax, 10
    imul ax, [playery]
    add ax, 0xb800
    mov es, ax
    
    mov di, [playerx]
    imul di, 2

    mov ax, [bp+4]
    mov byte [es:di], al
    
    pop ax
    pop bp
    ret 2

movup:
    mov ax, [playery]
    dec ax
    cmp ax, [top]
    je return
    dec word [playery]
    return:
        ret

movleft:
    mov ax, [playerx]
    dec ax
    cmp ax, [left]
    je return
    dec word [playerx]
    return:
        ret
    
movdown:
    mov ax, [playery]
    inc ax
    cmp ax, [bottom]
    je return
    inc word [playery]
    return:
        ret

movright:
    mov ax, [playerx]
    inc ax
    cmp ax, [right]
    je return
    inc word [playerx]
    return:
        ret

kbisr:
    push ax
    push es

    mov ax, 0xb800
    mov es, ax

    in al, 0x60
    cmp al, 0x48
    jne nextcmp
    
    mov al, ' '
    push ax
    call drawchar

    call movup
    
    mov al, 'P'
    push ax
    call drawchar

    jmp nomatch

    nextcmp:
        cmp al, 0x4b
        jne nextcmp2
    
        mov al, ' '
        push ax
        call drawchar

        call movleft
        
        mov al, 'P'
        push ax
        call drawchar
        
        jmp nomatch
    
    nextcmp2:
        cmp al, 0x50
        jne nextcmp3
    
        mov al, ' '
        push ax
        call drawchar

        call movdown
        
        mov al, 'P'
        push ax
        call drawchar
        
        jmp nomatch
    
    nextcmp3:
        cmp al, 0x4d
        jne nomatch
        
        mov al, ' '
        push ax
        call drawchar

        call movright
        
        mov al, 'P'
        push ax
        call drawchar

        
    nomatch:
        ; mov al, 0x20
        ; out 0x20, al
        
    pop es
    pop ax
    jmp far [cs:oldisr]
    ; iret


drawrect:
    push bp
    mov bp, sp
    sub sp, 4
    push es
    push ax
    push cx
    push si
    push di
    
    ; height
    mov ax, [bp+6]
    sub ax, [bp+10]
    inc ax
    mov [bp-4], ax
    
    ; width
    mov ax, [bp+4]
    sub ax, [bp+8]
    inc ax
    mov [bp-2], ax
    
    mov ax, [bp+10]
    imul ax, 10
    add ax, 0xb800
    ; add ax, 10
    mov es, ax

    xor bx, bx
    
    nextrow:
        mov di, [bp+8]
        imul di, 2
        mov ah, 0x07
        xor cx, cx

        nextchar:
        
        ;------bx == 0--------------
            cmp bx, 0
            jne afterbxzero
            cmp cx, 0
            jne aftercxzero1
            jmp printplus
            aftercxzero1:
            mov dx, cx
            inc dx
            cmp dx, [bp-2]
            jne aftercxn1
            jmp printplus
            aftercxn1:
            jmp printminus
            afterbxzero:
        ;------bx == height - 1 ---------------------------
            mov dx, bx
            inc dx
            cmp dx, [bp-4]
            jne afterbxm
            cmp cx, 0
            jne aftercxzero2
            jmp printplus
            aftercxzero2:
            mov dx, cx
            inc dx
            cmp dx, [bp-2]
            jne aftercxn2
            jmp printplus
            aftercxn2:
            jmp printminus
            afterbxm:
        ;-------------cx == 0 ---------------
            cmp cx, 0
            je printbar
        ;------------cx = width - 1 -------------
            mov dx, cx
            inc dx
            cmp dx, [bp-2]
            je printbar
        ;----------------
            jmp nextcharcontinue
            printplus:
            mov al, 43
            mov [es:di], ax
            jmp nextcharcontinue
            printbar:
            mov al, 124
            mov [es:di], ax
            jmp nextcharcontinue
            printminus:
            mov al, 45
            mov [es:di], ax
            jmp nextcharcontinue
            nextcharcontinue:
            add di, 2
            inc cx
            cmp cx, [bp-2]
            jne nextchar
        afternextchar:
        mov ax, es
        add ax, 10
        mov es, ax
        inc bx
        cmp bx, [bp-4]
        jne nextrow
    
    pop di
    pop si
    pop cx
    pop ax
    pop es
    mov sp, bp
    pop bp
    ret 8
    