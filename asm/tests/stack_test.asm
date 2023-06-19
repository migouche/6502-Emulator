.org $4200

; Initialize stack pointer
LDX #$ff
TXS

; Push value onto stack
LDA #$01
PHA

; Pop processor status from stack
PLP

; should have transferred Accumulator to Processor Status