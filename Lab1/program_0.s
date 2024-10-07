            .data
v1:         .byte 2, 6, -3, 11, 9, 18, -13, 16, 5, 1
v2:         .byte 4, 2, -13, 3, 9, 9, 7, 16, 4, 7
            ;variables
v3:         .space 10          ;[f4 ee 0e 0f 7b][-12, -18, 14, 15, 123] 
flag1:      .byte 0            ;is v3 empty?
flag2:      .byte 1            ;is v3 ascending monothonic?
flag3:      .byte 1            ;is v3 descending monothonic?
    
            .text
            ; OFFSETS DEFINITION
            daddi r3, r0, 0     ;offset on v1
            daddi r4, r0, 0     ;offset on v2
            daddi r5, r0, 0     ;offset on v3
            daddi r10, r0, 10   ;offset on v3

            ; COMPOSE v3
loop1:      lb r1, v1(r3)       ;loading v1 into r1
            lb r2, v2(r4)       ;loading v2 into r2
            bne r1, r2, v2incr  
            sb r1, v3(r5)
            daddi r5, r5, 1
            j v1incr            ;if I find an equal I go on
 
v2incr:     daddi r4, r4, 1
            beq r4, r10, v1incr
            j loop1

v1incr:     daddi r3, r3, 1
            daddi r4, r0, 0
            bne r3, r10, loop1

            ;v3 EMPTY
            bnez r5, v3_not_empty   ;if r5 hasn'increment
            daddi r1, r0, 1
            daddi r3, r0, 0
            daddi r4, r0, 0
            sb r1, flag1(r0)
            j end
            ;if r5 has incremented, v3 is not empty
v3_not_empty: daddi r1, r0, 0
            sb r1, flag1(r0)

            daddi r3, r0, 1     ;flag2
            daddi r4, r0, 1     ;flag1

            ;if both flags resets stop cycle
loop2:      bnez r3, increment
            bnez r4, increment
            j end

increment:  daddi r1, r5, -1    ;i
            beqz r1, end        ;if i=0 endloop
            daddi r2, r5, -2    ;i-1
            lb r7, v3(r1)       ;v3[i]
            lb r8, v3(r2)       ;v3[i-1]
            daddi r5, r5, -1    ;v3 index
            
            slt r9, r7, r8      ;check v3[i] < v3[i-1]

check_not_ASC: beqz r3, check_not_DESC     ;if flag 2 is false, skip
            beqz r9, check_not_DESC     ;if v[i] > v3[i-1]
            ;store flag2 -> NOT ASC
            daddi r3, r0, 0

check_not_DESC: beqz r4, loop2              ;if flag 3 is false, skip
            bnez r9, loop2              ;if v[i] < v3[i-1]
            ;store flag3 -> NOT DESC
            daddi r4, r0, 0
            j loop2

end:        sb r3, flag2(r0)
            sb r4, flag3(r0)
        HALT