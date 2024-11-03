// main.s
    .data
msg_mult:   .ascii  "Mult Result: "
msg_div:    .ascii  "Div Result:  "
hex:        .ascii  "0123456789ABCDEF"
newline:    .ascii  "\n"

    .global _start
    .text
_start:
    sub     sp, sp, #32
    str     x30, [sp]
    
    bl      main
    
    mov     x0, #0          // Return code 0
    mov     x8, #93         // Exit syscall
    svc     #0

    .global main
main:
    // Save registers
    str     x30, [sp, #16]
    str     x19, [sp, #24]
    
    // First test multiplication
    // -8.0546875 (C1 00 E8 00)
    movz    x0, #0xC100, lsl #16
    movk    x0, #0xE800
    // -0.179931640625 (BE 38 00 00)
    movz    x1, #0xBE38, lsl #16
    
    // Call fmult
    bl      fmult
    
    // Save multiplication result
    mov     x19, x0

    // Print "Mult Result: "
    mov     x8, #64         // write syscall
    mov     x0, #1          // stdout
    adr     x1, msg_mult    // address of message
    mov     x2, #12         // length
    svc     #0

    // Print multiplication result
    bl      print_hex

    // Now test division
    // 8.625 × 10^1 = 86.25 (42090000)
    movz    x0, #0x4209, lsl #16
    // -4.875 × 10^0 = -4.875 (C09C0000)
    movz    x1, #0xC09C, lsl #16
    
    // Call fdiv
    bl      fdiv
    
    // Save division result
    mov     x19, x0

    // Print "Div Result: "
    mov     x8, #64         // write syscall
    mov     x0, #1          // stdout
    adr     x1, msg_div     // address of message
    mov     x2, #12         // length
    svc     #0

    // Print division result
    bl      print_hex
    
    // Move result to return value
    mov     x0, x19
    
    // Restore registers
    ldr     x30, [sp, #16]
    ldr     x19, [sp, #24]
    ret

// Subroutine to print hex number
print_hex:
    // Print each hex digit
    mov     x9, x19         // Copy result to work with
    mov     x10, #8         // Count of digits to print

1:  // Print loop
    // Get top 4 bits
    ror     x9, x9, #4
    and     x11, x9, #0xF
    
    // Get corresponding hex char
    adr     x12, hex
    ldrb    w13, [x12, x11]
    
    // Print the char
    str     w13, [sp]
    mov     x8, #64         // write syscall
    mov     x0, #1          // stdout
    mov     x1, sp          // address of char
    mov     x2, #1          // length
    svc     #0
    
    subs    x10, x10, #1    // Decrement counter
    b.ne    1b              // Loop if not done

    // Print newline
    mov     x8, #64         // write syscall
    mov     x0, #1          // stdout
    adr     x1, newline
    mov     x2, #1
    svc     #0
    
    ret
