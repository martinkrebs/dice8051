;----------------------------------------------------------------
; Dice 8051
;----------------------------------------------------------------

; comment out TARGET_SIM line when compilation target is hardware.
TARGET_SIM	equ 1

PB1		equ P3.3
LED_PORT	equ P0
PATTERN_NUM	equ R5
DELAY		equ R6
REPEATS		equ R7

; Set up section
	mov	LED_PORT, #0ffh 	; Set all LEDS off.
	mov	P3, #0ffh		; Set port 3 to input mode
	mov	PATTERN_NUM, #06h			

; Main, endless loop
main:
	mov	DELAY, #01h
	mov	REPEATS, #020h	
pollPB1:
	acall	spin
	jnb 	PB1, go
	sjmp	pollPB1
go:
	acall 	display
	acall	slowTheRoll

	; IDE shows error when using DELAY, but not using R6. Both 
	; compile OK, so probably a funny with IDE error checking
	cjne   DELAY, #08h, go	
	
	sjmp	main

; Subroutines

spin:	
	djnz	PATTERN_NUM, spun	
	mov	PATTERN_NUM, #06h
spun:	
	ret

display:
	mov	A, REPEATS
	mov	R3, A
displayLoop:
	mov	A, PATTERN_NUM
	acall	getPattern
	mov	LED_PORT, A
	acall	delaySub
	acall	spin
	djnz	R3, displayLoop
	ret

slowTheRoll:
	mov	A, DELAY
	rl	A
	mov	DELAY, A
	mov	A, REPEATS
	rr	A
	mov	REPEATS, A
	ret

IFDEF TARGET_SIM
getPattern:
	; 7 seg, common anode, digits 1 to 6, MSB not used
	movc	A, @A+PC
	ret
	db	11111001b  
	db	10100100b
	db	10110000b
	db	10011001b
	db	10010010b
	db	10000010b	

delaySub:
	; Simple short delay suitable for use in simulator.
	mov	A, DELAY
	mov	R1, A
loop:
	mov 	R0, #040h ; #01h for animate, #040h for run
	djnz	R0, $
	djnz 	R1, loop
	ret
ELSE
getPattern:
	; dice face, com anode, 1 to 6, lsb not used.
	; LEDS:
	; a   b
	; c d e
	; f   g
	;
	movc	A, @A+PC
	ret
	; LEDS:	gfedcbax
	db	11101111b ; 1
	db	10111011b ; 2
	db	01101101b ; 3
	db	00111001b ; 4
	db	00101001b ; 5
	db	00010001b ; 6

delaySub:
	mov	A, DELAY
	mov	R2, A
delayLoop:
	mov	R1, #0ffh
inner:
	mov	R0, #0ffh
	djnz	R0, $
	djnz	R1, inner
	djnz	R2, delayLoop
	ret
ENDIF

	end
	

