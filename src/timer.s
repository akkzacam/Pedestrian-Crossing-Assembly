.syntax unified
.cpu cortex-m4
.thumb

.equ RCC_APB1ENR,   0x40023840
.equ TIM2_CR1,      0x40000000
.equ TIM2_SR,       0x40000010
.equ TIM2_EGR,      0x40000014
.equ TIM2_CNT,      0x40000024
.equ TIM2_PSC,      0x40000028
.equ TIM2_ARR,      0x4000002C

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

.global on_1s
.global on_point5s
.global system_tick_ms
.global half_second_tick
.global cooldown_20s
.global cooldown_20s_done
.global pedestrian_30s
.global pedestrian_30s_done
.global last_10s_pedestrian
.global timer_1s
.global timer_done_1s
.global timer_3s
.global timer_done_3s
.global low_energy_timer
.global low_energy_timer_done
.global blink_counter
.global blink_counter_done

on_1s:
    .word 0

on_point5s:
    .word 0

system_tick_ms:
    .word 0

half_second_tick:
    .word 0

cooldown_20s:
    .word 0

cooldown_20s_done:
    .word 0
    
pedestrian_30s:
    .word 0

pedestrian_30s_done:
    .word 0

last_10s_pedestrian:
    .word 0

timer_1s:
    .word 0

timer_done_1s:
    .word 0

timer_3s:
    .word 0

timer_done_3s:
    .word 0

low_energy_timer:
    .word 0

low_energy_timer_done:
    .word 0

blink_counter:
    .word 0

blink_counter_done:
    .word 0

.section .text

.global Timer_Setup
.global Timer_Update
.extern current_state

Timer_Setup:
    push {r4, r5, r6, lr}

    ldr r4, =RCC_APB1ENR    //enable the TIM2 clock
    ldr r5, [r4]
    orr r5, r5, #1
    str r5, [r4]

    ldr r4, =TIM2_PSC    //set the prescaler to 16MHz
    ldr r5, =15999
    str r5, [r4]

    ldr r4, =TIM2_ARR   //overflow every 0.5s
    mov r5, #499
    str r5, [r4]

    ldr r4, =TIM2_EGR   //will force update
    mov r5, #1
    str r5, [r4]

    ldr r4, =TIM2_CNT   //clear timer counter
    mov r5, #0
    str r5, [r4]

    ldr r4, =TIM2_SR    //set status to 0 (clear)
    mov r5, #0
    str r5, [r4]

    ldr r4, =TIM2_CR1   //enable the timer
    ldr r5, [r4]
    orr r5, r5, #1
    str r5, [r4]

    ldr r0, =on_1s
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =on_point5s
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =timer_done_1s
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =timer_done_3s
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =cooldown_20s_done
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =pedestrian_30s_done
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =low_energy_timer_done
	mov r1, #0
	str r1, [r0]
	
	ldr r0, =blink_counter_done
	mov r1, #0
	str r1, [r0]

    ldr r0, =half_second_tick
    mov r1, #0
    str r1, [r0]
	
	ldr r0, =system_tick_ms
	mov r1, #0
	str r1, [r0]

    pop {r4, r5, r6, lr}
    bx lr

Timer_Update:
    push {r4, r5, r6, lr}

    ldr r4, =on_1s
    mov r5, #0
    str r5, [r4]

    ldr r4, =on_point5s
    mov r5, #0
    str r5, [r4]

    //after clearing flags, check update interval flag
	
	ldr r4, =TIM2_CNT
	ldr r5, [r4]
	ldr r6, =system_tick_ms
	str r5, [r6]

    ldr r4, =TIM2_SR
    ldr r5, [r4]
    tst r5, #1      
    beq.w Timer_End    //branch if uif is zero, no overflow and 0.5s has not occured

    ldr r4, =TIM2_SR
    mov r5, #0      //clear branch
    str r5, [r4]

    //if equal to 500ms, flag 0.5s has occured
    ldr r4, =on_point5s
    mov r5, #1
    str r5, [r4]

    ldr r4, =current_state
	ldr r5, [r4]
	cmp r5, #S_VEHICLE_BLINK    //if equal, alter blink_counter
	bne Test_Tick
	
	ldr r4, =blink_counter
	ldr r5, [r4]
	add r5, r5, #1
	str r5, [r4]
	
	cmp r5, #10
	blt Test_Tick
	
	ldr r4, =blink_counter_done
	mov r5, #1
	str r5, [r4]
    b Test_Tick

Test_Tick:
    ldr r4, =half_second_tick
    ldr r5, [r4]
    add r5, r5, #1
    str r5, [r4]
    tst r5, #1
    beq.w Update_One_Second    //if tst = 0, even, 1s. else, odd, 0.5s
    b Timer_End

Update_One_Second:
    ldr r4, =on_1s  //flag 1s has occured
    mov r5, #1
    str r5, [r4]

    ldr r4, =current_state
    ldr r5, [r4]
    cmp r5, #S_VEHICLE_GREEN
    beq Update_20s_Timer

    cmp r5, #S_PEDESTRIAN_GREEN
    beq Update_30s_Timer

    cmp r5, #S_PEDESTRIAN_BLINK
    beq Update_30s_Timer

    cmp r5, #S_VEHICLE_YELLOW
    beq Update_3s_Timer

    cmp r5, #S_VEHICLE_YELLOW_RED
    beq Update_3s_Timer

    cmp r5, #S_VEHICLE_RED
    beq Update_1s_Timer

    cmp r5, #S_PEDESTRIAN_RED
    beq Update_1s_Timer

    b.w Timer_End

Update_20s_Timer:
    ldr r4, =cooldown_20s
    ldr r5, [r4]
    add r5, r5, #1
    str r5, [r4]

    cmp r5, #20
    blt.w Timer_End

    ldr r4, =cooldown_20s_done
    mov r5, #1
    str r5, [r4]
    b Update_Low_Energy_Timer   //so once the 20s cooldown timer is done, the low energy timer will immediately start counting

Update_30s_Timer:
    ldr r4, =pedestrian_30s
    ldr r5, [r4]
    sub r5, r5, #1
    str r5, [r4]

    cmp r5, #10
    beq Update_Last_10s

    cmp r5, #0
    bgt.w Timer_End

    ldr r4, =pedestrian_30s_done
    mov r5, #1
    str r5, [r4]
    b.w Timer_End

Update_Last_10s:
    ldr r4, =last_10s_pedestrian
    mov r5, #1
    str r5, [r4]
    b.w Timer_End

Update_3s_Timer:
    ldr r4, =timer_3s
    ldr r5, [r4]
    add r5, r5, #1
    str r5, [r4]

    cmp r5, #3
    blt Timer_End

    ldr r4, =timer_done_3s
    mov r5, #1
    str r5, [r4]
    b.w Timer_End

Update_1s_Timer:
    ldr r4, =timer_1s
    ldr r5, [r4]
    add r5, r5, #1
    str r5, [r4]

    cmp r5, #1
    blt Timer_End

    ldr r4, =timer_done_1s
    mov r5, #1
    str r5, [r4]
    b.w Timer_End

Update_Low_Energy_Timer:
    ldr r4, =low_energy_timer
    ldr r5, [r4]
    add r5, r5, #1
    str r5, [r4]

    cmp r5, #60
    blt Timer_End

    ldr r4, =low_energy_timer_done
    mov r5, #1
    str r5, [r4]
    b.w Timer_End

Timer_End:
    pop {r4, r5, r6, lr}
    bx lr
