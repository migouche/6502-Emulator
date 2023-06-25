.org $4000
.brk break

LDY #$03
BRK
LDA #$01
JMP $FFFF


break: LDX #$02
RTI






