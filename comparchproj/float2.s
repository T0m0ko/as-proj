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
    
    // Extract exponents (bits 30-23)
    lsr     x10, x0, #23            // Right shift dividend
    and     x10, x10, #0xFF         // Mask to get exponent
    sub     x10, x10, #127          // Unbias dividend exponent
    
    lsr     x11, x1, #23            // Right shift divisor
    and     x11, x11, #0xFF         // Mask to get exponent
    sub     x11, x11, #127          // Unbias divisor exponent
    
    // Subtract exponents
    sub     x10, x10, x11           // Subtract exponents
    add     x10, x10, #127          // Re-bias result exponent
    
    // Extract fractions and add implied 1
    and     x11, x0, #0x7FFFFF      // Get fraction of dividend
    orr     x11, x11, #0x800000     // Add implied 1
    lsl     x11, x11, #23           // Left shift for division
    
    and     x12, x1, #0x7FFFFF      // Get fraction of divisor
    orr     x12, x12, #0x800000     // Add implied 1
    
    // Perform division
    udiv    x13, x11, x12           // Divide fractions
    
    // Check for rounding (guard, round, sticky bits)
    mul     x14, x13, x12           // Multiply back to check remainder
    sub     x14, x11, x14           // Get remainder
    lsl     x14, x14, #1            // Left shift for guard bit
    cmp     x14, x12                // Compare with divisor
    b.lo    1f
    add     x13, x13, #1            // Round up if needed

1:  // Normalize if needed
    and     x14, x13, #0x1000000    // Check bit 24
    cbz     x14, 2f
    lsr     x13, x13, #1            // Right shift fraction
    add     x10, x10, #1            // Increment exponent

2:  // Final result
    and     x13, x13, #0x7FFFFF     // Mask to 23 bits
    
    // Combine sign, exponent, and fraction
    lsl     x10, x10, #23           // Shift exponent to position
    orr     x0, x9, x10             // Combine sign and exponent
    orr     x0, x0, x13             // Add in fraction
    
    // Restore link register and return
    ldr     lr, [sp]
    add     sp, sp, #16
    ret
