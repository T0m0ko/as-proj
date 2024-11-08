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
    lsr     x10, x0, #23            // Right shift first number
    and     x10, x10, #0xFF         // Mask to get exponent
    sub     x10, x10, #127          // Unbias first exponent
    
    lsr     x11, x1, #23            // Right shift second number
    and     x11, x11, #0xFF         // Mask to get exponent
    sub     x11, x11, #127          // Unbias second exponent
    
    // Add exponents
    add     x10, x10, x11           // Add unbiased exponents
    add     x10, x10, #127          // Re-bias result exponent
    
    // Extract fractions and add implied 1
    and     x11, x0, #0x7FFFFF      // Get fraction of first number
    orr     x11, x11, #0x800000     // Add implied 1
    
    and     x12, x1, #0x7FFFFF      // Get fraction of second number
    orr     x12, x12, #0x800000     // Add implied 1
    
    // Multiply fractions (48-bit result)
    mul     x13, x11, x12           // Multiply fractions
    
    // Normalize result if necessary
    lsr     x14, x13, #47           // Check if normalization needed
    cbz     x14, 1f
    
    lsr     x13, x13, #1            // Right shift fraction
    add     x10, x10, #1            // Increment exponent

1:  // Round to nearest even
    lsr     x13, x13, #23           // Shift to get final 23 bits
    and     x13, x13, #0x7FFFFF     // Mask to 23 bits
    
    // Combine sign, exponent, and fraction
    lsl     x10, x10, #23           // Shift exponent to position
    orr     x0, x9, x10             // Combine sign and exponent
    orr     x0, x0, x13             // Add in fraction
    
    // Restore link register and return
    ldr     lr, [sp]
    add     sp, sp, #16
    ret
