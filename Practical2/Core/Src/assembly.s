/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:
	@ Read buttons in
	LDR  R3, GPIOA_BASE
	LDR R3, [R3, #0x10]		@ location of buttons


    @ =============================================================================

	 @ Check if SW1 is pressed
    LDR R5, =1
    MOVS R7, R3				@ Store location of buttons in R7
    ANDS R7, R5				@ Checks last bit
    CMP R7, #0				@ Checks if last bit was 0 or 1

    @ if not 1 (was 0) skip long delay and go to else portion
    BEQ else_SW1

    @ =============================================================================
    @ Check if SW0 is pressed
    LDR R5, =2
    MOVS R7, R3				@ Store location of buttons in R7
    ANDS R7, R5				@ Checks last bit
    CMP R7, #0				@ Checks if last bit was 0 or 1

    @ if not 1 (was 0) skip long delay and go to else portion
    BEQ else_SW0

	@ =============================================================================
    @ Check if SW2 is pressed
    LDR R5, =4
    MOVS R7, R3				@ Store location of buttons in R7
    ANDS R7, R5				@ Checks last bit
    CMP R7, #0				@ Checks if last bit was 0 or 1

    @ if not 1 (was 0) skip long delay and go to else portion
    BEQ else_SW2

    @ =============================================================================

    @ Check if SW3 is pressed
    LDR R5, =8
    MOVS R7, R3				@ Store location of buttons in R7
    ANDS R7, R5				@ Checks if bits are 1110
    CMP R7, #0				@ Checks if last bit was 0 or 1

    @ if not 1 (was 0) skip long delay and go to SW3
    BEQ main_loop


@ If not of the buttons were pressed, this function gets run
delay_long:
    PUSH {LR}
    LDR  R3, LONG_DELAY_CNT		@ Long delay
	B delay_loop

@ else
else_SW0:
    BL delay_short			@ Call short delay

write_leds:
    ADDS R2, R2, #1
	STR R2, [R1, #0x14]
	B main_loop				@ Restart main loop

@ Delay loops
delay_short:
    PUSH {LR}
    LDR  R3, SHORT_DELAY_CNT	@ Short delay
delay_loop:
    SUBS R3, R3, #1
    BNE  delay_loop
    B write_leds

else_SW1:
	ADDS R2, R2, #1			@ First addition before second one

	LDR  R3, GPIOA_BASE
	LDR R3, [R3, #0x10]		@ location of buttons

	@ Check if SW1 is pressed
    LDR R5, =2
    MOVS R7, R3				@ Store location of buttons in R7
    ANDS R7, R5				@ Checks last bit
    CMP R7, #0				@ Checks if last bit was 0 or 1

    @ if not 1 (was 0) skip long delay and go to else portion
    BEQ else_SW0			@ If SW0 pressed, go to it
    B delay_long			@ else

else_SW2:
	MOVS R2, #0xAA			@ set pattern
	STR R2, [R1, #0x14]		@ Have to set here otherwise write_leds will add one
	B main_loop				@ Restart main loop


@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 1300000
SHORT_DELAY_CNT: 	.word 560000
