[org 0x0100]

call clrscr

xor ax, ax
mov es, ax
cli
mov word [es:9*4], kbisr
mov [es:9*4+2], cs
sti

l1:
    jmp l1
    
    
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


kbisr:
    push ax
    push es

    mov ax, 0xb800
    mov es, ax

    in al, 0x60
    cmp al, 0x2a
    jne nextcmp
    
    mov byte [es:0], 'L'
    jmp nomatch

    nextcmp:
        cmp al, 0x36
        jne nomatch
    
    mov byte [es:0], 'R'
        
    nomatch:
        mov al, 0x20
        out 0x20, al
    
    pop es
    pop ax
    iret
