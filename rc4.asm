BITS 32
global Start
section .drectve info
    db '/entry:Start', 0


extern GetStdHandle
extern ReadConsoleA
extern WriteConsoleA
extern ExitProcess

%define STD_INPUT_HANDLE  -10
%define STD_OUTPUT_HANDLE -11

section .data
    ; Thông báo
    promptPlainText db "Enter plain text: ", 0
    lenPromptPlainText equ $ - promptPlainText

    promptKey db "Enter key: ", 0
    lenPromptKey equ $ - promptKey

    resultMsg db "Encrypted text (hex): ", 0x0A, 0
    lenResultMsg equ $ - resultMsg

    hexDigits db "0123456789ABCDEF"

section .bss
    hInput      resd 1
    hOutput     resd 1
    plain       resb 256
    plainLen    resd 1
    key         resb 256
    keyLen      resd 1
    s           resb 256
    cipher      resb 256
    hexCipher   resb 512

section .text
Start:
    ; Get handles
    push STD_INPUT_HANDLE
    call GetStdHandle
    mov [hInput], eax

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    mov [hOutput], eax

    ; --- Print prompt for plain text ---
    push 0
    push lenPromptPlainText
    push promptPlainText
    push dword [hOutput]
    call WriteConsoleA

    ; --- Read plain text ---
    push plainLen
    push 256
    push plain
    push dword [hInput]
    call ReadConsoleA
    mov eax, [plainLen]
    sub eax, 2               ; remove \r\n
    mov [plainLen], eax

    ; --- Print prompt for key ---
    push 0
    push lenPromptKey
    push promptKey
    push dword [hOutput]
    call WriteConsoleA

    ; --- Read key ---
    push keyLen
    push 256
    push key
    push dword [hInput]
    call ReadConsoleA
    mov eax, [keyLen]
    sub eax, 2               ; remove \r\n
    mov [keyLen], eax

    ; === RC4 KSA ===
    xor ecx, ecx
.fill_s:
    mov [s + ecx], cl
    inc ecx
    cmp ecx, 256
    jne .fill_s

    xor ecx, ecx
    xor edi, edi
    xor ebx, ebx
.ksa:
    movzx eax, byte [s + ecx]
    movzx edx, byte [key + ebx]
    add edi, eax
    add edi, edx
    and edi, 0xFF
    ; swap s[i], s[j]
    mov al, [s + ecx]
    mov ah, [s + edi]
    mov [s + ecx], ah
    mov [s + edi], al
    inc ecx
    inc ebx
    cmp ebx, [keyLen]
    jl .skip_reset
    xor ebx, ebx
.skip_reset:
    cmp ecx, 256
    jne .ksa

    ; === RC4 PRGA ===
    xor ecx, ecx    ; i
    xor esi, esi    ; j
    xor edi, edi    ; pos

.prga:
    mov eax, ecx
    inc eax
    and eax, 0xFF
    mov ecx, eax    ; i = (i + 1) % 256

    movzx ebx, byte [s + ecx]
    add esi, ebx
    and esi, 0xFF

    ; swap s[i], s[j]
    mov al, [s + ecx]
    mov ah, [s + esi]
    mov [s + ecx], ah
    mov [s + esi], al

    ; t = (s[i] + s[j]) % 256
    movzx eax, byte [s + ecx]
    movzx edx, byte [s + esi]
    add eax, edx
    and eax, 0xFF
    movzx ebx, byte [s + eax]

    ; cipher = plain ^ keystream
    movzx eax, byte [plain + edi]
    xor eax, ebx
    mov [cipher + edi], al

    ; Convert to hex
    mov al, [cipher + edi]
    mov ah, al
    shr al, 4
    and ah, 0x0F
    movzx ebx, al
    mov al, [hexDigits + ebx]
    mov [hexCipher + edi * 2], al
    movzx ebx, ah
    mov al, [hexDigits + ebx]
    mov [hexCipher + edi * 2 + 1], al

    inc edi
    cmp edi, [plainLen]
    jne .prga

    ; === Print result label ===
    push 0
    push lenResultMsg
    push resultMsg
    push dword [hOutput]
    call WriteConsoleA

    ; === Print encrypted text ===
    mov eax, [plainLen]
    add eax, eax
    push 0
    push eax
    push hexCipher
    push dword [hOutput]
    call WriteConsoleA

    ; === Exit ===
    push 0
    call ExitProcess
