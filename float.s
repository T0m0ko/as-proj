// float.s
    .global fmult
    .text
fmult:  
    // Save link register
    sub     sp, sp, #16
    str     lr, [sp]
    
    // Extract signs (bit 31)
    and     x9, x0, #0x80000000     // Get sign of first number
    and     x10, x1, #0x80000000    // Get sign of second number
    eor     x9, x9, x10             // XOR signs to get result sign
    
    // Extract exponents (bits 30-23)
    ubfx    x10, x0, #23, #8        // Extract exponent from first number
    ubfx    x11, x1, #23, #8        // Extract exponent from second number
    
    // Handle exponents
    add     x10, x10, x11           // Add exponents
    sub     x10, x10, #127          // Subtract bias
    
    // Extract fractions and add implied 1
    and     x11, x0, #0x7FFFFF      // Get fraction of first number
    orr     x11, x11, #0x800000     // Add implied 1
    
    and     x12, x1, #0x7FFFFF      // Get fraction of second number
    orr     x12, x12, #0x800000     // Add implied 1
    
    // Multiply fractions
    mul     x13, x11, x12           // Multiply significands
    
    // Normalize and round
    lsr     x13, x13, #23           // Shift right to align
    and     x13, x13, #0x7FFFFF     // Keep only 23 bits
    
    // Check for overflow
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
