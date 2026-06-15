.syntax unified
.cpu cortex-m4
.thumb

.equ GPIOA_IDR, 0x40020010

.equ S_VEHICLE_GREEN,		1
.equ S_LOW_ENERGY,			2
.equ S_VEHICLE_BLINK,		3
.equ S_VEHICLE_YELLOW,		4
.equ S_VEHICLE_RED,			5
.equ S_PEDESTRIAN_GREEN,	6
.equ S_PEDESTRIAN_BLINK,	7
.equ S_PEDESTRIAN_RED,		8
.equ S_VEHICLE_YELLOW_RED,	9

.section .data
.global pedestrian_button
.global pedestrian_button_latched

pedestrian_button:
    .word 0

pedestrian_button_latched:
    .word 0

.section .text
.global Button_Check
.global Button_Setup
.extern current_state

Button_Setup:
	push {r4, r5, r6, lr}
	
	ldr r4, =pedestrian_button
	mov r5, #0
	str r5, [r4]
	
	ldr r4, =pedestrian_button_latched
	mov r5, #0
	str r5, [r4]
	
	pop {r4, r5, r6, lr}
	bx lr

Button_Check:
    push {r4, r5, r6, lr}

    ldr r4, =current_state
    ldr r5, [r4]
    cmp r5, #S_VEHICLE_GREEN
    beq Button_Input

    cmp r5, #S_LOW_ENERGY
    beq Button_Input

    cmp r5, #S_PEDESTRIAN_RED
    beq Button_Input

    cmp r5, #S_VEHICLE_YELLOW_RED
    beq Button_Input

    b Button_End

Button_Input:
    ldr r4, =GPIOA_IDR
    ldr r5, [r4]
    and r5, r5, #0x00000100
    cmp r5, #0
    bne Button_Not_Pressed  //flag here for button logic

Button_Pressed:
    ldr r4, =pedestrian_button
    mov r5, #1
    str r5, [r4]

    ldr r4, =pedestrian_button_latched
    ldr r5, [r4]
    cmp r5, #1
    beq Button_End
    
    mov r5, #1
    str r5, [r4]
    b Button_End

Button_Not_Pressed:
    ldr r4, =pedestrian_button
    mov r5, #0
    str r5, [r4]

Button_End:
    pop {r4, r5, r6, lr}
    bx lr
