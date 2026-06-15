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

.global main

.extern Setup
.extern Timer_Setup
.extern Button_Setup
.extern Light_Decoder_Setup
.extern Timer_Update
.extern Button_Check
.extern Check_State_Status
.extern Light_Decoder
.extern current_state
.extern seg7_setup
.extern seg7_update

.section .text
.type main, %function

main:
	bl Setup
	bl Timer_Setup
	bl Button_Setup
	bl Light_Decoder_Setup
	bl seg7_setup

	ldr r0, =current_state
	mov r1, #S_LOW_ENERGY
	str r1, [r0]

Main_Loop:
	bl Timer_Update
	bl Button_Check
	bl Check_State_Status
	bl Light_Decoder
	bl seg7_update
	b Main_Loop