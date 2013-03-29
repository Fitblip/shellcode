# Author: @Fitblip
#
# Takes in a string, and turns it into pushable DWORDs,
# a method for pushing and refrencing strings on the stack
#
# A python implemention of CorelanCoder's PVEPushString.pl

# Usage :
# => python stringPush.py "This is a test"
# String length : 14
# Opcodes to push this string onto the stack :
# "\x68\x73\x74\x20\x00" # PUSH 0x00207473 ; (st  )
# "\x68\x61\x20\x74\x65" # PUSH 0x65742061 ; (a te)
# "\x68\x20\x69\x73\x20" # PUSH 0x20736920 ; ( is )
# "\x68\x54\x68\x69\x73" # PUSH 0x73696854 ; (This)

import sys

string = sys.argv[-1]
lines = []

print "String length : %d" % len(string)
print "Opcodes to push this string onto the stack :"

for i in range(0,len(string),4):
	line = string[:4]
	if len(string) == 4:
		a = "\"\\x31\\xC0\\x50\""
		a += " # XOR EAX,EAX; PUSH EAX"
		a += " ; (NULL)"
		print a
	if len(line) == 4:
		a = "\"\\x68"
		a += "".join(['\\x' + hex(ord(x)).replace('0x','') for x in line]) + "\""
		a += " # PUSH 0x" + "".join([hex(ord(x)).replace('0x','') for x in line[::-1]])
		a += " ; (" + "".join([x for x in line]) + ")"
		lines.append(a)
		string = string[4:]
	if len(line) == 3:
		a = "\"\\x68"
		a += "".join(['\\x' + hex(ord(x)).replace('0x','') for x in line])		
		a += "\\x00"
		a += " # PUSH 0x00" + "".join([hex(ord(x)).replace('0x','') for x in line[::-1]])
		a += "\""
		a += " ; (" + "".join([x for x in line]) + " )"
		lines.append(a)

	if len(line) == 2:
		a = "\"\\x68"
		a += "".join(['\\x' + hex(ord(x)).replace('0x','') for x in line])
		a += "\\x20"
		a += "\\x00"
		a += "\""
		a += " # PUSH 0x0020" + "".join([hex(ord(x)).replace('0x','') for x in line[::-1]])
		a += " ; (" + "".join([x for x in line]) + "  )"
		lines.append(a)
	if len(line) == 1:
		a = "\"\\x68"
		a += "".join(['\\x' + hex(ord(x)).replace('0x','') for x in line]) 
		a += "\\x20" * 2
		a += "\\x00"
		a += "\""
		a += " # PUSH 0x002020" + "".join([hex(ord(x)).replace('0x','') for x in line[::-1]])
		a += " ; (" + "".join([x for x in line]) + "   )"		
		lines.append(a)

for line in lines[::-1]:
	print line

