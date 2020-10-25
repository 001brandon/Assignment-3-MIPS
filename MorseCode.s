.data
buffer: .space 1024
string0: .asciiz "Select Operation Mode [0=ASCII to MC, 1=MC to ASCII]:"
string1: .asciiz "Enter a Character: "
string2: .asciiz "Enter a Pattern: "
string3: .asciiz "Morse Code: "
string4: .asciiz "ASCII: "
string5: .asciiz "\nEnd of Program\n"
string6: .asciiz "[Error] no ASCII2MC!\n"
string7: .asciiz "[Error] no MC2ASCII!\n"
string8: .asciiz "[Error] Invalid combination!\n"
string9: .asciiz "Dot\n"
string10: .asciiz "Dash!\n"
string11: .asciiz "Compare\n"
string12: .asciiz "Space\n"
stringvals: .asciiz "-. "
endLine: .asciiz "\n"
decodedAscii: .space 128

dict: .word 0x55700030, 0x95700031, 0xA5700032, 0xA9700033, 0xAA700034, 0xAAB00035, 0x6AB00036, 0x5AB00037, 0x56B00038, 0x55B00039, 0x9C000041, 0x6AC00042, 0x66C00043, 0x6B000044, 0xB0000045, 0xA6C00046, 0x5B000047, 0xAAC00048, 0xAC000049, 0x95C0004A, 0x6700004B, 0x9AC0004C, 0x5C00004D, 0x6C00004E, 0x5700004F, 0x96C00050, 0x59C00051, 0x9B000052, 0xAB000053, 0x70000054, 0xA7000055, 0xA9C00056, 0x97000057, 0x69C00058, 0x65C00059, 0x5AC0005A
s_dsh: .byte '-'
s_dot: .byte '.'
s_spc: .byte ' '

.text
main:
  
  li $v0, 4                 # print "Select Operation Mode [0=ASCII to MC, 1=MC to ASCII]:"
  la $a0, string0  
  syscall                   # syscall print string0 

  li $v0, 5
  syscall                   # syscall Read int 

  bne $v0, $0, MC2A

A2MC:
  li $v0, 4                 # print "Enter a Letter:" 
  la $a0, string1
  syscall                   # syscall print string1

  li $t0, 1                 # Define length
  li $v0, 12                # Read character
  syscall                   # syscall Read character
  move $t0,$v0              # Transfer the char entered to the temporary value
  
  li $t2, 1                 # Define length
  li $v0, 12                # Read NULL character 
  syscall                   # syscall Read character

  la $t2, dict              # Load address of dir
  li $t3, 0                 # Initialize index
  li $t4, 36                # Initialize boundary

LoopA2MC:
  lb $t5, ($t2)             # Load value to be compared
  beq $t0, $t5, FndA2MC     # Compare values
  addi $t2, $t2, 4          # Next symbol
  addi $t3, $t3, 1          # Next index
  blt $t3, $t4, LoopA2MC    # Evaluate index condition
  j ErrorA2MC

FndA2MC:
  li $v0, 4                 # print "Enter a Letter:" 
  la $a0, string3
  syscall                   # syscall print string3

  lw $t3, ($t2)             # Load value to be printed
  li $t4, 0x80000000        # Load bitmask

snext:
  and $t5, $t3, $t4         # Apply bitmask
  beq $t5, $0, caseZ        # Zero Found

caseO:
  sll $t3, $t3, 1           # Shift Left
  and $t5, $t3, $t4         # Apply bitmask  
  sll $t3, $t3, 1           # Shift Left
  beq $t5, $0, pdot         # 10 Found

caseE:
  li $v0, 4                 # Print string code
  la $a0, endLine           # Print NewLine
  syscall                   # syscall print value
  j EXIT                    # End

caseZ:
  sll $t3, $t3, 1           # Shift Left
  and $t5, $t3, $t4         # Apply bitmask  
  sll $t3, $t3, 1           # Shift Left
  beq $t5, $0, caseN        # 00 Found

pdash:
  li $v0, 11                # Print char
  lb $a0, s_dsh             # Load value to be printed
  syscall                   # Print value
  j snext

pdot:
  li $v0, 11                # Print char
  lb $a0, s_dot             # Load value to be printed
  syscall                   # Print value
  j snext

caseN:
  li $v0, 4                 # print "Error, Invalid combination!" 
  la $a0, string8
  syscall                   # syscall print string
  j EXIT

ErrorA2MC:
  li $v0 , 4                # print "Error no ASCII2MC!" 
  la $a0 , string6
  syscall                   # syscall print string6

  j EXIT
  
MC2A:  #Here we get the buffer we want to read from and print some stuff
  li $v0 , 4
  la $a0 , string2        
  syscall
  li $v0, 8
  la $a0, buffer  #get user buffer
  li $a1, 1024
  syscall
  li $v0 , 4
  la $a0 , buffer  #print what they entered
  syscall 


li $s1, 0 #Global Counter
li $s2, 0 #End Flag if one no space quit
Restart:
  li $s0, 0 #value
  li $t4, 0 #counter
CheckDash:
  #This has to take in the dashes and dots, assign bit values based on input
  la $t0, buffer    #Load buffer into memory
  la $t1, stringvals #Load 3 options into memory
  add $t0, $t0, $s1  #Add counter to buffer address to get index
  lb $t2, 0($t0) #Load into memory
  lb $t3, 0($t1)
  bne $t2, $t3, CheckDot #If not equal see if it is dot
  li $v0, 4  
  la $a0, string10
  #syscall
  addi $t4, $t4, 1 #Increment counter
  addi $s1, $s1, 1
  sll $s0, $s0, 2  #shifts and adds the value of the dot
  addi $s0,$s0, 1
  j CheckDash #Recursion

CheckDot:
  lb $t3, 1($t1)  #Load second option into memory
  bne $t2, $t3, CheckSpace #If not equal check space
  li $v0, 4
  la $a0, string9
  #syscall
  addi $t4, $t4, 1  #Increment
  addi $s1, $s1, 1
  sll $s0, $s0, 2
  addi $s0,$s0, 2
  j CheckDash  #Recursion
  
CheckSpace:
  lb $t3, 2($t1)  #Load third option into memory
  bne $t2, $t3, SetFlag #If not equal exit
  li $v0, 4
  la $a0, string12
  #syscall
  #j CheckDash #Recursion


EndCode:
  sll $s0, $s0, 2  #shifts and adds the value of the endcode
  addi $s0,$s0, 3  #puts in endcode
  addi $t4,$t4,1
  addi, $s1, $s1, 1
  #HAVE TO SHIFT TO PUT THIS ALL THE WAY TO THE RIGHT
  li $t5, 8
  sub $t5, $t5, $t4  #8 inputs - used inputs = inputs left to shift by
  sll $t5, $t5, 1  #get in groups of 2 bit inputs
  sllv $s0, $s0, $t5 #shift by variable amount

GetValue:
  #shift dict value to the right by 8 then compare
  #can use t0 t1 t2 t3 do not use anymore
  la $t0, dict   #load address

Iterate:
  lw $t1, 0($t0)  # Load dictionary value **SHOULD PROBABLY ADD BOUNDARY CHECKS**
  srl $t1, $t1, 16 # Shift the value to the right by 16 to compare with $s0
  addi $t0, $t0, 4 # Increment Dictionary Counter
  bne $t1, $s0, Iterate  #Checks if it is a valid dictionary value **SHOULD PROBABLY HAVE BOUND CHECKS HERE**
  addi $t0, $t0, -4  #Decrements the dictionary to go to correct spot
  lw $t1, 0($t0)  # Reloads the value
  sll $s0, $s0, 16 # Shifts s0 to the left to be aligned with assignemnt
  andi $t1, $t1, 0x000000FF  # Gets ascii value from $t1
  add $s0, $s0, $t1 #Add ascii to s0
  li $v0, 11  #print char
  li $a0, 0 #load 0
  add $a0, $a0, $t1 #print t1 which is the ascii value for dictionary search that hit
  syscall
  bne $s2 ,$0, EXIT
  j Restart






#--------------------------------------------------------------#
#-------------------- Write your code Here --------------------#
#--------------------------------------------------------------#


#--------------------------------------------------------------#

  li $v0 , 4                # Print string code
  la $a0 , endLine          # Print NewLine
  syscall                   # syscall print value

ErrorMC2A:
  li $v0 , 4                # print "Error no MC2ASCII!" 
  la $a0 , string7
  syscall                   # syscall print string7

  j EXIT

EXIT:		 
  li $v0, 4
  la $a0, string5
  syscall

  li $a0, 0
  li $v0, 17              #exit
  syscall

  SetFlag:
    li $s2, 1
    j EndCode
