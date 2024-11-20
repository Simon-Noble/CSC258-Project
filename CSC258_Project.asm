.data
Board: .half 0:128      # array of 128 half words (8 bits) used for storing the board. X,Y position 0,0 
                        # is element 0. Y incemets every 8 words (8*8 = 64 bits). The top left part of the 
                        # board is 0,0
                        
                        # Piece Reference:  (RGB order and NSEW order with Y replacing G)
                        #   0 - Empty space
                        #   1 - Red Virus
                        #   2 - Yellow Virus
                        #   3 - Blue virus
                        
                        #   4 - Red Pill No connection
                        #   5 - Red Pill Connected Up
                        #   6 - Red Pill Connected Left
                        #   7 - Red Pill Connected Down
                        #   8 - Red Pill Connected Right
                        
                        #   9 - Yellow Pill No connection
                        #   10 - Yellow Pill Connected Up
                        #   11 - Yellow Pill Connected Left
                        #   12 - Yellow Pill Connected Down
                        #   13 - Yellow Pill Connected Right
                        
                        #   14 - Blue Pill No connection
                        #   15 - Blue Pill Connected Up
                        #   16 - Blue Pill Connected Left
                        #   17 - Blue Pill Connected Down
                        #   18 - Blue Pill Connected Right
                        
                        #   Higher Values should not be expected 
                        
State: .byte 0:1        # This byte tracks whether the next check should be for player controled movement (0),
                        # deleting pieces(1), gravity movement (2),  generate a new piece (3)
.text
main:
addi $t0 $zero 1 # Temporary testing
la $t1 Board
addi $t0, $zero, 5

sll $t2, $t0, 1     # Update the offset to be correct

add $t2, $t2, $t1 
addi $t3, $zero, 4
sh $t3, 0($t1)
sh $t3 , 0($t2)

Start_Main_Loop:
la $a0, Gravity
jal Access_All
j Start_Main_Loop


# ========= Plans For The Main Loop =======


# Initialize
# Start of Loop / Delay?
# Get Player Input
# Update Piece Positions
# Check if the game is over and exit
# Draw the new board
# Play secion of Music?
# Restart Loop
# Start a new game?
Exit:
li $v0 , 10             # Exit
syscall



Movement_Determiner:    # Reads the state and determines what function should be called
                        # Either calling gravity, player control, clearing rows, or 
                        # generating a new piece.



Access_All:         # Calls the given function on each element on the board. The function should take
                    # at most a single argument that is the location of the element it is being
                    # called on. Argument should come in $a0
                    # Elements are called from bottom to top
addi $sp, $sp, -4                    # Store Return Address on the stack
sw $ra, 0($sp)

addi $t0, $zero, 15      # Initialize the loop varable
addi $t1, $zero, -1   # Set Stop 
Access_All_Loop:
ble $t0, $t1, End_Access_All       # Begin Loop
sll $t2, $t0, 4        # Adjust position for the function
la $t3, Board

add $a1, $t2, $t3       # Set Parameter for the function     

# Store Varables
addi $sp, $sp, -4 # Store all important registers

sw $t0, 0($sp)
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)

addi $sp, $sp, -4
sw $a0, 0($sp)


jal Access_Row      # Call function
                    
                    # Load Variables
lw $a0, 0($sp) 
addi $sp, $sp, 4
lw $t3, 0($sp) 
addi $sp, $sp, 4
lw $t2, 0($sp) 
addi $sp, $sp, 4
lw $t1, 0($sp) 
addi $sp, $sp, 4
lw $t0, 0($sp) 
addi $sp, $sp, 4

addi $t0, $t0, -1           # Increment loop variable
j Access_All_Loop               # Loop
                    

End_Access_All:
lw $ra, 0($sp)      # Read return address from the stack
addi $sp, $sp, 4
jr $ra              # Exit function


Access_Row:         # Calls the function given on each elemen in the given row
                    # $a1 should be the address of the row to call a function on,
                    # and $a0 should be the addres of the function to call. The function should take 
                    # a single argument from $a0, which is the position to call the function on
addi $sp, $sp, -4                    # Store Return Address on the stack
sw $ra, 0($sp)

addi $t8, $a1, 0    # Load the board position into t8
addi $t0 $zero 0    # Set loop variable
addi $t1 $zero 8                # Set Stop Vairable
Access_Row_Loop_Start:
bge $t0, $t1, Access_Row_Exit   # Begin loop and check loop condition
sll $t2, $t0, 1     # Update the offset to be correct
add $t2, $t2, $t8   # Set position to read

addi $a1, $t2, 0

addi $sp, $sp, -4 # Store all important registers
sw $t0, 0($sp)
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4
sw $t2, 0($sp)
addi $sp, $sp, -4
sw $t3, 0($sp)
addi $sp, $sp, -4
sw $t8, 0($sp)
addi $sp, $sp, -4
sw $a0, 0($sp)
addi $sp, $sp, -4
sw $a1, 0($sp)


jalr $a0
#lh $t3, 0($t2)      # Read value from memory
#addi $t3, $t3, 1    # Increment value in memory
#sh $t3, 0($t2)      # Save to memory

lw $a1, 0($sp)      # Load all registers
addi $sp, $sp, 4 
lw $a0, 0($sp) 
addi $sp, $sp, 4
lw $t8, 0($sp) 
addi $sp, $sp, 4
lw $t3, 0($sp) 
addi $sp, $sp, 4
lw $t2, 0($sp) 
addi $sp, $sp, 4
lw $t1, 0($sp) 
addi $sp, $sp, 4
lw $t0, 0($sp) 
addi $sp, $sp, 4

addi $t0, $t0, 1    #Increment Loop Variable
j Access_Row_Loop_Start # Restart loop
Access_Row_Exit:
lw $ra, 0($sp)      # Read return address from the stack
addi $sp, $sp, 4
jr $ra # Exit function

Add:
# Add one to the value in the memory address in $a1

la $t0, Board
sub $t1, $a1, $t0   
addi $t2, $zero, 0xf0 # Does something different to the bottom row
bge $t1, $t2, Skip


lh $t3, 0($a1) 
addi $t3, $t3, 3
sh $t3, 0($a1) 
Skip:
jr $ra


Gravity:                # Single argument $a1. Determine if the piece at the position should move down
                       # and move it if it should be.
addi $sp, $sp, -4                    # Store Return Address on the stack
sw $ra, 0($sp)

la $t0, Board
sub $t1, $a1, $t0   
addi $t2, $zero, 0xf0   # Check if we are in the bottom row, if so, return
bge $t1, $t2, Gravity_Return




lh $t0, 0($a1)              # $t0 is the value at the position we care about
addi $t1, $zero, 3

ble $t0, $t1, Gravity_Return    # Check if the value at the position is <= 3, if so, return
addi $t8, $zero, 1
sll $t8, $t8, 4
add $t8, $t8, $a1           # $t8 is the position of the piece below
lh $t9, 0($t8)              # $t9 is The value of the position below
bgtz $t9, Gravity_Return    # Check if the value at the position below it is > 0, if so, return.
# Check if the value is 6, 8, 11, 13, 16, 18
addi $t2, $zero, 6
beq $t0, $t2, Gravity_Right
addi $t2, $zero, 11
beq $t0, $t2, Gravity_Right
addi $t2, $zero, 16
beq $t0, $t2, Gravity_Right
addi $t2, $zero, 8
beq $t0, $t2, Gravity_Left
addi $t2, $zero, 13
beq $t0, $t2, Gravity_Left
addi $t2, $zero, 18
beq $t0, $t2, Gravity_Left
j Shift_Down
# If the value is 6, 11, 16, check the position to the right and down. If it is >0, return
Gravity_Right:
addi $t5, $zero, 1
sll $t5, $t5, 4
addi $t5,$t5, 2
add $t3, $t5, $a1 # $t3 is the position we care about
lh $t4, 0($t3)      # $t4 is the value we care about
bgtz $t4, Gravity_Return
j Shift_Down
# If the value is 8, 13, 18, check the value at the position tot he left and down, if >0, return
Gravity_Left:
addi $t5, $zero, 1
sll $t5, $t5, 4
addi $t6, $zero, 2
sub $t5,$t5, $t6
add $t3, $t5, $a1   # $t3 is the position we care about
lh $t4, 0($t3)      # $t4 is the value we care about
bgtz $t4, Gravity_Return
j Shift_Down

Shift_Down:
sh $t0, 0($t8)      # Set the piece at the position below to the same as the current piece.
sh $zero, 0($a1)       # Set the piece at the current position to 0
# Return
Gravity_Return:
lw $ra, 0($sp)      # Read return address from the stack
addi $sp, $sp, 4
jr $ra              # Exit function

