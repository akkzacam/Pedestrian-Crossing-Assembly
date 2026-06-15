.syntax unified
.cpu cortex-m4
.thumb

.equ GPIOB_ODR, 0x40020414
.equ GPIOC_ODR, 0x40020814

.equ S_VEHICLE_GREEN,		1
.equ S_LOW_ENERGY,			2
.equ S_VEHICLE_BLINK,		3
.equ S_VEHICLE_YELLOW,		4
.equ S_VEHICLE_RED,			5
.equ S_PEDESTRIAN_GREEN,	6
.equ S_PEDESTRIAN_BLINK,	7
.equ S_PEDESTRIAN_RED,		8
.equ S_VEHICLE_YELLOW_RED,	9

digit_table:
    .byte 0x3F      //0
    .byte 0x06      //1
    .byte 0x5B      //2
    .byte 0x4F      //3
    .byte 0x66      //4
    .byte 0x6D      //5
    .byte 0x7D      //6
    .byte 0x07      //7
    .byte 0x7F      //8
    .byte 0x6F      //9

.align 2
.section .text
.global seg7_setup
.global seg7_update
.extern pedestrian_30s
.extern current_state

seg7_setup:
    push {r4, r5, lr}

    ldr r4, =GPIOB_ODR
    mov r5, #0
    str r5, [r4]

    ldr r4, =GPIOC_ODR
    mov r5, #0
    str r5, [r4]

    pop {r4, r5, lr}
    bx lr

seg7_update:
    push {r4, r5, r6, r7, lr}

    
    ldr r4, =current_state
    ldr r5, [r4]
    cmp r5, #S_PEDESTRIAN_GREEN
    beq display_value

    cmp r5, #S_PEDESTRIAN_BLINK
    beq display_value

    b display_blank
    

display_value:
    ldr r4, =pedestrian_30s
    ldr r0, [r4]

    mov r1, #10 //divisor
    udiv r2, r0, r1

    mul r3, r2, r1
    sub r3, r0, r3

    ldr r4, =digit_table

    ldrb r5, [r4, r2]   //load tens in r5
    ldrb r6, [r4, r3]   //load ones in r6

    ldr r7, =GPIOB_ODR
    str r5, [r7]

    ldr r7, =GPIOC_ODR
    str r6, [r7]
    b seg7_end

display_blank:
    ldr r7, =GPIOB_ODR
    mov r5, #0
    str r5, [r7]

    ldr r6, =GPIOC_ODR
    mov r5, #0
    str r5, [r6]

seg7_end:

    pop {r4, r5, r6, r7, lr}
    bx lr
