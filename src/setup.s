.syntax unified
.cpu cortex-m4
.thumb

.equ RCC_AHB1ENR, 	0x40023830	//Peripheral Clock Enable Reg 
.equ GPIOA_MODER, 	0x40020000	//GPIO Port A Mode Reg 
.equ GPIOA_BSRR, 	0x40020018		//GPIO Port A Bit Set/Reset Reg 
.equ GPIOA_ODR, 	0x40020014	 	//GPIO Port A Output Data Reg 
.equ GPIOA_PUPDR, 	0x4002000C	//gpip port a pull up pull down register

.equ GPIOB_MODER, 	0x40020400
.equ GPIOC_MODER,	0x40020800

//VEHICLE_GREEN = PA9
//VEHICLE_YELLOW = PA10
//VEHICLE_RED = PA4
//PEDESTRIAN_GREEN = PA5 
//PEDESTRIAN_YELLOW = PA6
//PEDESTRIAN_RED = PA7
//PEDESTRIAN_BUTTON = PA8

//7 SEG TENS - PB0 - PB6
//7 SEG ONES - PC0 - PC6

.equ S_VEHICLE_GREEN,		1
.equ S_LOW_ENERGY,			2
.equ S_VEHICLE_BLINK,		3
.equ S_VEHICLE_YELLOW,		4
.equ S_VEHICLE_RED,			5
.equ S_PEDESTRIAN_GREEN,	6
.equ S_PEDESTRIAN_BLINK,	7
.equ S_PEDESTRIAN_RED,		8
.equ S_VEHICLE_YELLOW_RED,	9

.section .text
.global Setup

Setup:
	push {r4, r5, r6, lr}
	
	//enable gpioa clock
	ldr r4, =RCC_AHB1ENR
	ldr r5, [r4]
	orr r5, r5, #1
	str r5, [r4]

	//enable GPIOB clock
	ldr r4, =RCC_AHB1ENR
	ldr r5, [r4]
	orr r5, r5, #0x02
	str r5, [r4]

	//enable GPIOC clock
	ldr r4, =RCC_AHB1ENR
	ldr r5, [r4]
	orr r5, r5, #0x04
	str r5, [r4]

	//setup PA9 - VEHICLE_GREEN
	ldr r4, =GPIOA_MODER
	ldr r5, [r4]
	bic r5, r5, #0x000C0000
	orr r5, r5, #0x00040000
	str r5, [r4]

	//setup PA10 - VEHICLE_YELLOW
	ldr r4, =GPIOA_MODER
	ldr r5, [r4]
	bic r5, r5, #0x00300000
	orr r5, r5, #0x00100000
	str r5, [r4]

	//setup PA4 - VEHICLE_RED
	ldr r4, =GPIOA_MODER
	ldr r5, [r4]
	bic r5, r5, #0x00000300
	orr r5, r5, #0x00000100
	str r5, [r4]

	//setup PA5 - PEDESTRIAN_GREEN
	ldr r4, =GPIOA_MODER
	ldr r5, [r4]
	bic r5, r5, #0x00000C00
	orr r5, r5, #0x00000400
	str r5, [r4]

	//setup PA6 - PEDESTRIAN_YELLOW
	ldr r4, =GPIOA_MODER
	ldr r5, [r4]
	bic r5, r5, #0x00003000
	orr r5, r5, #0x00001000
	str r5, [r4]

	//setup PA7 - PEDESTRIAN_RED
	ldr r4, =GPIOA_MODER
	ldr r5, [r4]
	bic r5, r5, #0x0000C000
	orr r5, r5, #0x00004000
	str r5, [r4]

	//setup PA8 - PEDESTRIAN BUTTON
	ldr r4, =GPIOA_MODER
	ldr r5, [r4]
	bic r5, r5, #0x00030000
	str r5, [r4]

	//setup pull up operation for pa8
	ldr r4, =GPIOA_PUPDR
	ldr r5, [r4]
	bic r5, r5, #0x00030000
	orr r5, r5, #0x00010000
	str r5, [r4]

	//configure pin B0 - B6 at once
	ldr r4, =GPIOB_MODER
	ldr r5, [r4]
	mov r6, #0x00003FFF
	bic r5, r5, r6
	orr r5, r5, #0x00001555
	str r5, [r4]

	//configure pin C0 - C6 at once
	ldr r4, =GPIOC_MODER
	ldr r5, [r4]
	mov r6, #0x00003FFF
	bic r5, r5, r6
	orr r5, r5, #0x00001555
	str r5, [r4]

	pop {r4, r5, r6, lr}
	bx lr
