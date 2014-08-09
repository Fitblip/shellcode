# Author: @Fitblip
#
# Opens a binary file (.bin from nasm) and outputs 
# a shellcode tester
#

import sys

PREFIX        = "build\\"
SHELLCODE_BIN = PREFIX + "%s.bin" % sys.argv[-1]
SHELLCODE_C   = PREFIX + "run_shellcode.c"
blob = ""
byte_count = 0

with open(SHELLCODE_BIN) as f:
	a = f.read()
	
for byte in a:
	byte_count += 1
	blob += "\\x%0.2x" % ord(byte)

byte_str = ""
while len(blob) > 0:
	bytes = blob[:48]
	if len(bytes) == 48:
		byte_str += '"%s"\n' % bytes
	else:
		# Last line
		byte_str += '"%s"' % bytes
	blob = blob[48:]	

code = """#include<stdio.h>
#include<string.h>

// Shellcode length %d bytes
unsigned char code[] = 
%s;

main()
{
    int (*ret)() = (int(*)())code;

    ret();
}
""" % (byte_count, byte_str)

with open(SHELLCODE_C, 'w') as f:
	f.write(code)