KITT1:
set carry
rotate
delay
if 0xFF restart
check for bit 3

KITT2:
load 0x81
load a register with 0x80
other register with 0x01
shift right first register
shift left other register
store the first one in a temp
or both register
delay
load temp into first regster
check for kitt1