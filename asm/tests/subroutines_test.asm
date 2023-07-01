.org $4000

LDY #$03
JSR goto
LDA #$01
JMP $FFFF


goto: LDX #$02
RTS
