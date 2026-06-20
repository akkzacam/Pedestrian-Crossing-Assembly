Zebra Crossing Light Controller

Overview

This project implements a Zebra Crossing Light Controller using ARM Assembly Language on the STM32F446RE microcontroller. The system was developed as part of the KIE2010 Microprocessors and Microcontrollers course at Universiti Malaya.

The controller manages vehicle and pedestrian traffic through a finite state machine (FSM) architecture. In addition to the basic assignment requirements, several safety, accessibility and usability features were incorporated, including a pedestrian countdown display, audible crossing assistance, pedestrian request acknowledgement and a low-energy operating mode.

⸻

Hardware Platform

* STM32F446RE Nucleo-64 Development Board
* LEDs for vehicle traffic lights
* LEDs for pedestrian traffic lights
* Push button pedestrian request input
* Dual seven-segment display
* Piezo buzzer

⸻

Features

Core Functionality

* Pedestrian crossing request using push button
* Vehicle and pedestrian traffic light control
* Finite State Machine (FSM) based operation
* Hardware timer driven timing system

Additional Features

* Seven-segment countdown display
* Pedestrian request acknowledgement indicator
* Pedestrian crossing buzzer
* Vehicle green cooldown period
* Vehicle green blinking warning state
* Safety buffer state
* Vehicle red and yellow transition state
* Low-energy operating mode

⸻

Finite State Machine

The controller operates using the following states:

1. VEHICLE_GREEN
2. VEHICLE_BLINK
3. VEHICLE_YELLOW
4. VEHICLE_RED
5. PEDESTRIAN_GREEN
6. PEDESTRIAN_BLINK
7. PEDESTRIAN_RED
8. VEHICLE_RED_YELLOW
9. LOW_ENERGY

The FSM ensures safe transitions between pedestrian and vehicle traffic phases while providing warning and safety intervals.

⸻

Software Architecture

The project is divided into several modules:

File	Description
main.s	Main execution loop
setup.s	GPIO and peripheral initialization
timer.s	TIM2 configuration and timing services
button.s	Pedestrian button handling
fsm.s	Finite state machine implementation
light_decoder.s	Traffic light output generation
seven_segment.s	Seven-segment countdown display
constant.inc	Shared constants and definitions

⸻

Demonstration Video

https://www.youtube.com/watch?v=w2_xZwWasWE

⸻

Repository Structure

src
- main.s
- setup.s
- timer.s
- button.s
- fsm.s
- light_decoder.s
- seven_segment.s
- constant.inc

⸻

Course Information
Course: KIE2010 Microprocessors and Microcontrollers
Assignment: Assignment 2 – Zebra Crossing Light Controller
Institution: Universiti Malaya
Academic Session: 2025/2026

⸻

Author:
Aydan Khairin Bin Khairul Zaman
Bachelor of Electrical Engineering
Universiti Malaya
