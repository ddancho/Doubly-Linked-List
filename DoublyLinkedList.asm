format PE console 6.0
entry main
include 'win32ax.inc'

struct Node
	key		dd	?
	value	dd	?
	pNext	dd	?
	pPrev	dd	?
ends

struct List
	pFirst	dd	?	; ptr to Node
	pLast	dd	?	; ptr to Node
ends

section '.code' code readable executable
main:
	
	ccall Main
	invoke ExitProcess,eax
	
	proc Main c
	local list:List
	local adrList:DWORD
		
		lea eax,[list]
		mov dword[eax + List.pFirst],0
		mov dword[eax + List.pLast],0
		mov [adrList],eax
		
		cinvoke printf,<'insert some elements at front...',13,10,0>
		ccall insertFirst,[adrList],1,10
		ccall insertFirst,[adrList],2,20
		ccall insertFirst,[adrList],3,30
		ccall insertFirst,[adrList],4,40
		ccall insertFirst,[adrList],5,50
		
		ccall printForward,[adrList]
		
		ccall printBackward,[adrList]
		
		cinvoke printf,<'insert some elements at back...',13,10,0>
		ccall insertLast,[adrList],10,100
		ccall insertLast,[adrList],20,200
		
		ccall printForward,[adrList]
		
		ccall printBackward,[adrList]
		
		cinvoke printf,<'delete some keys...',13,10,0>
		ccall deleteKey,[adrList],10
		ccall deleteKey,[adrList],20
		
		ccall printForward,[adrList]
		
		ccall printBackward,[adrList]
		
		cinvoke printf,<'delete the list...',13,10,0>
		ccall deleteList,[adrList]
		
		cinvoke printf,<'exit...',13,10,0>
		xor eax,eax
		ret
	endp
	
	proc insertFirst c uses ebx edi,adrList,key,value
		cinvoke malloc,sizeof.Node
		; yea,yea, I know
		
		mov ecx,[value]
		mov edx,[key]
		mov dword[eax + Node.key],edx
		mov dword[eax + Node.value],ecx
		mov dword[eax + Node.pNext],0
		mov dword[eax + Node.pPrev],0
		
		mov ebx,[adrList]		
		.if dword[ebx + List.pFirst] = 0
			mov [ebx + List.pLast],eax
		.else
			mov edi,[ebx + List.pFirst]
			mov [edi + Node.pPrev],eax
		.endif
		
		mov edi,[ebx + List.pFirst]
		mov [eax + Node.pNext],edi
		
		mov [ebx + List.pFirst],eax
		
		xor eax,eax	
		ret
	endp
	
	proc insertLast c uses ebx edi,adrList,key,value
		cinvoke malloc,sizeof.Node
		; yea,yea, I know, here too...
		
		mov ecx,[value]
		mov edx,[key]
		mov dword[eax + Node.key],edx
		mov dword[eax + Node.value],ecx
		mov dword[eax + Node.pNext],0
		mov dword[eax + Node.pPrev],0
		
		mov ebx,[adrList]
		.if dword[ebx + List.pLast] = 0
			mov [ebx + List.pFirst],eax
		.else
			mov edi,[ebx + List.pLast]
			mov [edi + Node.pNext],eax
			mov [eax + Node.pPrev],edi
		.endif
		
		mov [ebx + List.pLast],eax
		
		xor eax,eax
		ret
	endp
	
	proc deleteKey c uses ebx esi edi,adrList,key
		mov ebx,[adrList]
		.if dword[ebx + List.pFirst] = 0
			cinvoke printf,<'The List is Empty...',13,10,0>
			jmp .out
		.endif
		
		mov edi,[key]
		mov esi,[ebx + List.pFirst]
		.while [esi + Node.key] <> edi
			.if esi = 0
				cinvoke printf,<'The Key is Not Found...',13,10,0>
				jmp .out
			.endif
			mov esi,[esi + Node.pNext]
		.endw
		
		cinvoke printf,<'Deleting Key %d',13,10,0>,edi
		
		.if esi = [ebx + List.pFirst]			
			mov edx,[esi + Node.pNext]
			mov [ebx + List.pFirst],edx
		.else			
			mov eax,[esi + Node.pNext]
			mov edx,[esi + Node.pPrev]
			mov [edx + Node.pNext],eax
		.endif
		
		.if esi = [ebx + List.pLast]			
			mov edx,[esi + Node.pPrev]
			mov [ebx + List.pLast],edx
		.else			
			mov eax,[esi + Node.pPrev]
			mov edx,[esi + Node.pNext]
			mov [edx + Node.pPrev],eax
		.endif
		
		cinvoke free,esi
		
	.out:
		xor eax,eax	
		ret
	endp
	
	proc deleteList c uses ebx esi edi,adrList
		mov ebx,[adrList]
		.if dword[ebx + List.pFirst] = 0
			cinvoke printf,<'The List is Empty...',13,10,0>
			jmp .out
		.endif
		
		mov esi,[ebx + List.pFirst]	
		.repeat
			mov edi,[esi + Node.pNext]
			cinvoke printf,<'Deleting Key %d',13,10,0>,dword[esi + Node.key]
			cinvoke free,esi
			mov esi,edi
		.until esi = 0
		
		mov dword[ebx + List.pFirst],0
		mov dword[ebx + List.pLast],0	
		
	.out:
		xor eax,eax	
		ret
	endp
	
	proc printForward c uses ebx esi,adrList
		mov ebx,[adrList]
		.if dword[ebx + List.pFirst] = 0
			cinvoke printf,<'The List is Empty...',13,10,0>
			jmp .out
		.endif
		
		cinvoke printf,<'Printing The List Forward...',13,10,0>
		
		mov esi,[ebx + List.pFirst]
		.repeat			
			cinvoke printf,<'Key %d Value %d',13,10,0>,dword[esi + Node.key],dword[esi + Node.value]
			mov esi,[esi + Node.pNext]
		.until esi = 0
		
	.out:
		xor eax,eax	
		ret
	endp
	
	proc printBackward c uses ebx esi,adrList
		mov ebx,[adrList]
		.if dword[ebx + List.pLast] = 0
			cinvoke printf,<'The List is Empty...',13,10,0>
			jmp .out
		.endif
		
		cinvoke printf,<'Printing The List Backward...',13,10,0>
		
		mov esi,[ebx + List.pLast]
		.repeat			
			cinvoke printf,<'Key %d Value %d',13,10,0>,dword[esi + Node.key],dword[esi + Node.value]
			mov esi,[esi + Node.pPrev]
		.until esi = 0
		
	.out:
		xor eax,eax	
		ret
	endp
	
section '.data' data readable writeable
	nop

section '.idata' data import readable
	library kernel32,'kernel32.dll',\
			msvcrt,'msvcrt.dll'

	import kernel32,\
			ExitProcess,'ExitProcess'

	import msvcrt,\	
			malloc,'malloc',\		
			free,'free',\
			printf,'printf'
			
