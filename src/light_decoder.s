.syntax unified
.cpu cortex-m4
.thumb

.equ GPIOA_ODR, 0x40020014	//GPIO Port A Output Data Reg

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
.global vehicle_green_blink
.global pedestrian_green_blink
.global yellow_blink

vehicle_green_blink:
	.word 0

pedestrian_green_blink:
	.word 0

yellow_blink:
	.word 0

.section .text
.global Light_Decoder
.global Light_Decoder_Setup
.extern current_state
.extern pedestrian_button_latched
.extern on_1s
.extern on_point5s

//VEHICLE_GREEN		PA9 - #0x00000200
//VEHICLE_YELLOW	PA10 - #0x00000400
//VEHICLE_RED		PA4 - #0x00000010
//PEDESTRIAN_GREEN	PA5 - #0x00000020
//PEDESTRIAN_YELLOW	PA6 - #0x00000040
//PEDESTRIAN_RED	PA7 - #0x00000080

Light_Decoder_Setup:
	push {r4, r5, r6, lr}
	
	ldr r4, =pedestrian_green_blink
	mov r5, #0
	str r5, [r4]
	
	ldr r4, =yellow_blink
	mov r5, #1
	str r5, [r4]
	
	ldr r4, =vehicle_green_blink
	mov r5, #0
	str r5, [r4]
	
	pop {r4, r5, r6, lr}
	bx lr

Light_Decoder:
	push {lr}

	ldr r0, =current_state
	ldr r1, [r0]

	cmp r1, #S_VEHICLE_GREEN
	beq LIGHT_FSM_VEHICLE_GREEN

	cmp r1, #S_LOW_ENERGY
	beq LIGHT_FSM_LOW_ENERGY

	cmp r1, #S_VEHICLE_BLINK
	beq LIGHT_FSM_VEHICLE_BLINK

	cmp r1, #S_VEHICLE_YELLOW
	beq LIGHT_FSM_VEHICLE_YELLOW

	cmp r1, #S_VEHICLE_RED
	beq LIGHT_FSM_VEHICLE_RED

	cmp r1, #S_PEDESTRIAN_GREEN
	beq LIGHT_FSM_PEDESTRIAN_GREEN

	cmp r1, #S_PEDESTRIAN_BLINK
	beq LIGHT_FSM_PEDESTRIAN_BLINK

	cmp r1, #S_PEDESTRIAN_RED
	beq LIGHT_FSM_PEDESTRIAN_RED

	cmp r1, #S_VEHICLE_YELLOW_RED
	beq LIGHT_FSM_VEHICLE_YELLOW_RED

	pop {lr}
	bx lr

LIGHT_FSM_VEHICLE_GREEN:
	ldr r0, =pedestrian_button_latched
	ldr r1, [r0]
	cmp r1, #1
	beq PED_YELLOW_VEH_GREEN
	b VEH_GREEN_ONLY

PED_YELLOW_VEH_GREEN:
	ldr r0, =GPIOA_ODR
	mov r1, #0x000002C0
	str r1, [r0]
	b VEHICLE_GREEN_END

VEH_GREEN_ONLY:
	ldr r0, =GPIOA_ODR
	mov r1, #0x00000280
	str r1, [r0]

VEHICLE_GREEN_END:
	pop {lr}
	bx lr

LIGHT_FSM_LOW_ENERGY:
	ldr r0, =on_1s	//EXAMPLE
	ldr r1, [r0]
	cmp r1, #1
	bne RENDER_YELLOW_BLINK

	ldr r0, =yellow_blink
	ldr r1, [r0]
	eor r1, r1, #1
	str r1, [r0]

	cmp r1, #1
	beq VEHICLE_YELLOW_ON	//if 1 on
	b VEHICLE_YELLOW_OFF	//if 0 off

RENDER_YELLOW_BLINK:
	ldr r0, =yellow_blink
	ldr r1, [r0]

	cmp r1, #1
	beq VEHICLE_YELLOW_ON	//if 1 on
	b VEHICLE_YELLOW_OFF	//if 0 off

VEHICLE_YELLOW_ON:
	ldr r0, =GPIOA_ODR
	mov r1, #0x00000400
	str r1, [r0]

	pop {lr}
	bx lr
	
VEHICLE_YELLOW_OFF:
	ldr r0, =GPIOA_ODR
	mov r1, #0x00000000
	str r1, [r0]

	pop {lr}
	bx lr

LIGHT_FSM_VEHICLE_BLINK:
	ldr r0, =on_point5s
	ldr r1, [r0]
	cmp r1, #1
	bne RENDER_VEHICLE_BLINK

	ldr r0, =vehicle_green_blink
	ldr r1, [r0]
	eor r1, r1, #1	//toggle between on and off
	str r1, [r0]
	cmp r1, #1
	beq VEHICLE_GREEN_ON	//if 1 on
	b VEHICLE_GREEN_OFF		//if 0 off

RENDER_VEHICLE_BLINK:
	ldr r0, =vehicle_green_blink
	ldr r1, [r0]
	cmp r1, #1
	beq VEHICLE_GREEN_ON
	b VEHICLE_GREEN_OFF

VEHICLE_GREEN_ON:
	ldr r0, =GPIOA_ODR
	mov r1, #0x000002C0
	str r1, [r0]

	pop {lr}
	bx lr
	
VEHICLE_GREEN_OFF:
	ldr r0, =GPIOA_ODR
	mov r1, #0x000000C0
	str r1, [r0]

	pop {lr}
	bx lr

LIGHT_FSM_VEHICLE_YELLOW:
	ldr r0, =GPIOA_ODR
	mov r1, #0x000004C0
	str r1, [r0]

	pop {lr}
	bx lr

LIGHT_FSM_VEHICLE_RED:
	ldr r0, =GPIOA_ODR
	mov r1, #0x000000D0
	str r1, [r0]

	pop {lr}
	bx lr

LIGHT_FSM_PEDESTRIAN_GREEN:
	ldr r0, =GPIOA_ODR
	mov r1, #0x00000030
	str r1, [r0]

	pop {lr}
	bx lr

LIGHT_FSM_PEDESTRIAN_BLINK:
	ldr r0, =on_point5s
	ldr r1, [r0]
	cmp r1, #1
	bne RENDER_PEDESTRIAN_BLINK

	ldr r0, =pedestrian_green_blink
	ldr r1, [r0]
	eor r1, r1, #1
	str r1, [r0]

	cmp r1, #1
	beq PEDESTRIAN_GREEN_ON
	b PEDESTRIAN_GREEN_OFF

RENDER_PEDESTRIAN_BLINK:
	ldr r0, =pedestrian_green_blink
	ldr r1, [r0]
	cmp r1, #1
	beq PEDESTRIAN_GREEN_ON
	b PEDESTRIAN_GREEN_OFF

PEDESTRIAN_GREEN_ON:
	ldr r0, =GPIOA_ODR
	mov r1, #0x00000030
	str r1, [r0]

	pop {lr}
	bx lr
	
PEDESTRIAN_GREEN_OFF:
	ldr r0, =GPIOA_ODR
	mov r1, #0x00000010
	str r1, [r0]

	pop {lr}
	bx lr

LIGHT_FSM_PEDESTRIAN_RED:
	ldr r0, =pedestrian_button_latched
	ldr r1, [r0]
	cmp r1, #1
	beq PED_YELLOW_PED_RED
	b PED_RED_ONLY

PED_YELLOW_PED_RED:
	ldr r0, =GPIOA_ODR
	mov r1, #0x000000D0
	str r1, [r0]
	b PED_RED_END

PED_RED_ONLY:
	ldr r0, =GPIOA_ODR
	mov r1, #0x00000090
	str r1, [r0]

PED_RED_END:
	pop {lr}
	bx lr

LIGHT_FSM_VEHICLE_YELLOW_RED:
	ldr r0, =pedestrian_button_latched
	ldr r1, [r0]
	cmp r1, #1
	beq PED_YELLOW_VEH_YELLOW_RED
	b VEH_YELLOW_RED_ONLY

PED_YELLOW_VEH_YELLOW_RED:
	ldr r0, =GPIOA_ODR
	mov r1, #0x000004D0
	str r1, [r0]
	b VEHICLE_YELLOW_RED_END

VEH_YELLOW_RED_ONLY:
	ldr r0, =GPIOA_ODR
	mov r1, #0x00000490
	str r1, [r0]

VEHICLE_YELLOW_RED_END:
	pop {lr}
	bx lr
	
