[org 0x0100]

start:
    call clrscr
    
    push word [top]
    push word [left]
    push word [bottom]
    push word [right]
    call drawrect
    
    mov ax, 0x4c00
    int 0x21
    

top:        dw  5
left:       dw  10
bottom:     dw  15
right:      dw  50


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
    mov [bp-4], ax
    
    ; width
    mov ax, [bp+4]
    sub ax, [bp+8]
    mov [bp-2], ax
    
    mov ax, [bp+10]
    imul ax, 10
    add ax, 0xb800
    add ax, 10
    mov es, ax
    
    xor bx, bx
    
    nextrow:
        mov di, [bp+8]
        imul di, 2
        mov ah, 0x07
        xor cx, cx

        nextchar:
        ;---------------- conditions
            cmp bx, 0
            je printplus
            cmp cx, 0
            je printplus
            mov dx, bx
            inc dx
            cmp dx, [bp-4]
            je printplus
            mov dx, cx
            inc dx
            cmp dx, [bp-2]
            je printplus
        ;----------------
            jmp nextcharcontinue
            printplus:
            mov al, 43
            mov [es:di], ax
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
    