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
    push es
    push ax
    push cx
    push si
    push di
    
    mov ax, [bp+10]
    imul ax, 10
    add ax, 0xb800
    add ax, 10
    mov es, ax
    mov cx, [bp+6]
    sub cx, [bp+10]
    
    nextrow:
        mov di, [bp+8]
        imul di, 2
        push cx
        mov cx, [bp+4]
        sub cx, [bp+8]
        mov ah, 0x47
        nextchar:
            mov al, 0x20
            mov [es:di], ax
            add di, 2
            add si, 1
            loop nextchar
        pop cx
        mov ax, es
        add ax, 10
        mov es, ax
        loop nextrow
    
    pop di
    pop si
    pop cx
    pop ax
    pop es
    pop bp
    ret 4
    