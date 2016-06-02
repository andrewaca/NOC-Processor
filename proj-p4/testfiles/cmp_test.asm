 ; Processor Code for gather test-bench

VLD $1, 1		; 0 - load packet 1
VLD $2, 2		; 4 - load packet 2
VLD $3, 3		; 8 - load packet 3

VLD $4, C001	; C - load output channel status register 
VBNEZ $4, C		; 10 - repeat last step if OCSR = 1
VSD $1, C000	; 14 - send packet 1 to output channel buffer

VLD $5, C001	; 18 - load output channel status register 
VBNEZ $5, 18	; 1C - repeat last step if OCSR = 1
VSD $2, C000	; 20 - send packet 2 to output channel buffer

VLD $6, C001	; 24 - load output channel status register 
VBNEZ $6, 24	; 28 - repeat last step if OCSR = 1
VSD $3, C000	; 2C - send packet 3 to output channel buffer

VLD $7, C003	; 30 - load input channel status register
VBEZ $7, 30		; 34 - poll till packet 1 is available
VLD $8, C002	; 38 - load input channel buffer

VLD $9, C003	; 3C - load input channel status register
VBEZ $9, 3C		; 40 - poll till packet 2 is available
VLD $10, C002	; 44 - load input channel buffer

VLD $11, C003	; 48 - load input channel status register
VBEZ $11, 48	; 4C - poll till packet 3 is available
VLD $12, C002	; 50 - load input channel buffer

VSD $8, A		; 54 - store packet 1 into data memory
VSD $10, B		; 58 - store packet 2 into data memory
VSD $12, C 		; 5C - store packet 3 into data memory

VNOP 			; 60 - for good luck