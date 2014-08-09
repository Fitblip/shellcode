@echo off

REM This batch file automatically compiles shellcode via NASM to output a binary
REM NOTE: you must have nasm, python, and GCC in your PATH

set NAME=xp_scicalc

if not exist build mkdir build
if exist %NAME%.exe del %NAME%.exe

echo Compiling asm to bytecode...
nasm -f bin -O3 -o build\%NAME%.bin %NAME%.asm

echo Creating bytecode runner...
python nasm_to_c.py %NAME%

echo Compiling bytecode runner to %NAME%.exe
gcc build\run_shellcode.c -o %NAME%.exe

echo Cleaning up
rmdir /s /q build\

echo Running shellcode
call %NAME%.exe