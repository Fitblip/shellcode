# Author: @Fitblip
#
# Opens a binary file (.bin from nasm) and outputs 
# the bytes of the file ready to paste for shellcode
#

import sys

blob = ""
byteCount = 0
with open(sys.argv[-1]) as f:
	a = f.read()
	
for byte in a:
	byteCount += 1
	blob += "\\x%0.2x" % ord(byte)

byte_str = ""
while len(blob) > 0:
	byte_str += "\""
	byte_str += blob[:48] 
	byte_str += "\"\n"
	blob = blob[48:]	
print "\nByte count => %d\n" % byteCount
print byte_str