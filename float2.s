// float2.s
    .global fdiv
    .text
fdiv:  
    // Save link register
    sub     sp, sp, #16
    str     lr, [sp]
    
    // Extract signs (bit 31)
    and     x9, x0, #0x80000000     // Get sign of dividend
    and     x10, x1, #0x80000000    // Get sign of divisor
    eor     x9, x9, x10             // XOR signs to get result sign
    
    // Extract exponents
    ubfx    x10, x0, #23, #8        // Extract dividend exponent
    ubfx    x11, x1, #23, #8        // Extract divisor exponent
    
    // Handle exponents
    sub     x10, x10, x11           // Subtract exponents
    add     x10, x10, #127          // Add bias back
    
    // Extract fractions and add implied 1
    and     x11, x0, #0x7FFFFF      // Get dividend fraction
    orr     x11, x11, #0x800000     // Add implied 1
    lsl     x11, x11, #23           // Left shift for precision
    
    and     x12, x1, #0x7FFFFF      // Get divisor fraction
    orr     x12, x12, #0x800000     // Add implied 1
    
    // Perform division
    udiv    x13, x11, x12           // Divide fractions
    
    // Normalize and round
    and     x13, x13, #0x7FFFFF     // Keep 23 bits
    
    // Check for underflow/overflow
    lsr     x14, x13, #23
    cbz     x14, 1f
    lsr     x13, x13, #1
    add     x10, x10, #1

1:  // Combine final result
    and     x13, x13, #0x7FFFFF     // Ensure only 23 bits
    lsl     x10, x10, #23           // Position exponent
    orr     x0, x9, x10             // Add sign and exponent
    orr     x0, x0, x13             // Add fraction
    
    // Restore and return
    ldr     lr, [sp]
    add     sp, sp, #16
    ret
