.org $4000

label1: LDA #$01
STA $0200
LDA #$05
STA $0201 ; doing stuff
; hey
LDA #$08
STA $0202
NOP
JMP label1
