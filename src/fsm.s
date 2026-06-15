.syntax unified
.cpu cortex-m4
.thumb

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
.global current_state

current_state:
	.word S_LOW_ENERGY	//default to low energy state

.section .text
.global Check_State_Status
.extern cooldown_20s_done
.extern pedestrian_button_latched
.extern low_energy_timer_done
.extern timer_done_3s
.extern timer_done_1s
.extern last_10s_pedestrian
.extern pedestrian_30s_done
.extern timer_3s
.extern timer_1s
.extern pedestrian_30s
.extern cooldown_20s
.extern low_energy_timer
.extern	blink_counter_done
.extern	blink_counter

Check_State_Status:
	push {lr}
	ldr r0, =current_state
	ldr r1, [r0]

	cmp r1, #S_VEHICLE_GREEN
	beq FSM_VEHICLE_GREEN

	cmp r1, #S_LOW_ENERGY
	beq FSM_LOW_ENERGY

	cmp r1, #S_VEHICLE_BLINK
	beq FSM_VEHICLE_BLINK

	cmp r1, #S_VEHICLE_YELLOW
	beq FSM_VEHICLE_YELLOW

	cmp r1, #S_VEHICLE_RED
	beq FSM_VEHICLE_RED

	cmp r1, #S_PEDESTRIAN_GREEN
	beq FSM_PEDESTRIAN_GREEN

	cmp r1, #S_PEDESTRIAN_BLINK
	beq FSM_PEDESTRIAN_BLINK

	cmp r1, #S_PEDESTRIAN_RED
	beq FSM_PEDESTRIAN_RED

	cmp r1, #S_VEHICLE_YELLOW_RED
	beq FSM_VEHICLE_YELLOW_RED

	pop {lr}
	bx lr

FSM_VEHICLE_GREEN:
	ldr r0, =cooldown_20s_done
	ldr r1, [r0]
	cmp r1, #1
	bne STATE_GREEN

	ldr r0, =pedestrian_button_latched
	ldr r1, [r0]
	cmp r1, #1
	beq TRANSITION_VEHICLE_BLINK

	//check low energy mode
	ldr r0, =low_energy_timer_done
	ldr r1, [r0]
	cmp r1, #1
	beq TRANSITION_LOW_ENERGY

STATE_GREEN:
	pop {lr}
	bx lr
	
FSM_LOW_ENERGY:
	//check pedestrian button
	ldr r0, =pedestrian_button_latched
	ldr r1, [r0]
	cmp r1, #1
	beq TRANSITION_VEHICLE_BLINK

	pop {lr}
	bx lr

FSM_VEHICLE_BLINK:
	ldr r0, =blink_counter_done
	ldr r1, [r0]
	cmp r1, #1
	beq TRANSITION_VEHICLE_YELLOW

	pop {lr}
	bx lr

FSM_VEHICLE_YELLOW:
	ldr r0, =timer_done_3s
	ldr r1, [r0]
	cmp r1, #1
	beq TRANSITION_VEHICLE_RED

	pop {lr}
	bx lr

FSM_VEHICLE_RED:
	ldr r0, =timer_done_1s
	ldr r1, [r0]
	cmp r1, #1
	beq TRANSITION_PEDESTRIAN_GREEN

	pop {lr}
	bx lr

FSM_PEDESTRIAN_GREEN:
	ldr r0, =last_10s_pedestrian
	ldr r1, [r0]
	cmp r1, #1
	beq TRANSITION_PEDESTRIAN_BLINK

	pop {lr}
	bx lr

FSM_PEDESTRIAN_BLINK:
	ldr r0, =pedestrian_30s_done
	ldr r1, [r0]
	cmp r1, #1
	beq TRANSITION_PEDESTRIAN_RED

	pop {lr}
	bx lr

FSM_PEDESTRIAN_RED:
	ldr r0, =timer_done_1s
	ldr r1, [r0]
	cmp r1, #1
	beq TRANSITION_VEHICLE_YELLOW_RED

	pop {lr}
	bx lr

FSM_VEHICLE_YELLOW_RED:
	ldr r0, =timer_done_3s
	ldr r1, [r0]
	cmp r1, #1
	beq TRANSITION_VEHICLE_GREEN

	pop {lr}
	bx lr

TRANSITION_VEHICLE_BLINK:
	ldr r0, =current_state
	mov r1, #S_VEHICLE_BLINK
	str r1, [r0]

	ldr r0, =blink_counter
	mov r1, #0
	str r1, [r0]

	ldr r0, =blink_counter_done
	mov r1, #0
	str r1, [r0]

	pop {lr}
	bx lr

TRANSITION_LOW_ENERGY:
	ldr r0, =current_state
	mov r1, #S_LOW_ENERGY
	str r1, [r0]

	pop {lr}
	bx lr

TRANSITION_VEHICLE_YELLOW:
	ldr r0, =current_state
	mov r1, #S_VEHICLE_YELLOW
	str r1, [r0]

	ldr r0, =timer_3s
	mov r1, #0
	str r1, [r0]

	ldr r0, =timer_done_3s
	mov r1, #0
	str r1, [r0]

	pop {lr}
	bx lr

TRANSITION_VEHICLE_RED:
	ldr r0, =current_state
	mov r1, #S_VEHICLE_RED
	str r1, [r0]

	ldr r0, =timer_1s
	mov r1, #0
	str r1, [r0]

	ldr r0, =timer_done_1s
	mov r1, #0
	str r1, [r0]

	pop {lr}
	bx lr

TRANSITION_PEDESTRIAN_GREEN:
	ldr r0, =current_state
	mov r1, #S_PEDESTRIAN_GREEN
	str r1, [r0]

	ldr r0, =pedestrian_30s
	mov r1, #30
	str r1, [r0]

	ldr r0, =pedestrian_30s_done
	mov r1, #0
	str r1, [r0]

	ldr r0, =pedestrian_button_latched
	mov r1, #0
	str r1, [r0]

	pop {lr}
	bx lr

TRANSITION_PEDESTRIAN_BLINK:
	ldr r0, =current_state
	mov r1, #S_PEDESTRIAN_BLINK
	str r1, [r0]

	ldr r0, =last_10s_pedestrian
	mov r1, #0
	str r1, [r0]

	pop {lr}
	bx lr

TRANSITION_PEDESTRIAN_RED:
	ldr r0, =current_state
	mov r1, #S_PEDESTRIAN_RED
	str r1, [r0]

	ldr r0, =timer_1s
	mov r1, #0
	str r1, [r0]

	ldr r0, =timer_done_1s
	mov r1, #0
	str r1, [r0]

	pop {lr}
	bx lr

TRANSITION_VEHICLE_YELLOW_RED:
	ldr r0, =current_state
	mov r1, #S_VEHICLE_YELLOW_RED
	str r1, [r0]

	ldr r0, =timer_3s
	mov r1, #0
	str r1, [r0]

	ldr r0, =timer_done_3s
	mov r1, #0
	str r1, [r0]

	pop {lr}
	bx lr

TRANSITION_VEHICLE_GREEN:
	ldr r0, =current_state
	mov r1, #S_VEHICLE_GREEN
	str r1, [r0]

	ldr r0, =cooldown_20s
	mov r1, #0
	str r1, [r0]

	ldr r0, =cooldown_20s_done
	mov r1, #0
	str r1, [r0]

	ldr r0, =low_energy_timer
	mov r1, #0
	str r1, [r0]

	ldr r0, =low_energy_timer_done
	mov r1, #0
	str r1, [r0]

	pop {lr}
	bx lr
	
