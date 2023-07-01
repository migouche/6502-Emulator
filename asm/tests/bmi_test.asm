.org $4000

LDA #$00
BMI no
LDA #$FF
BMI yes


yes: LDA #$02
JMP $FFFF
     

no: LDA #$04
JMP $FFFF

