NAME fil_rouge

PILE	SEGMENT STACK
	db      20 dup ('LA PILE ')
PILE	ENDS

DONNEE SEGMENT

Tableau  DB 0ah,00,0,1,2,3,4,5,6,7,8,9
alpha	 DB '0',' $'
Flag     DB 0

DONNEE ENDS

PROGRAMME SEGMENT
assume CS:PROGRAMME,DS:donnee,SS:PILE

debut:
	call InitInt ; interruption clavier simule top horloge

	mov ax,DONNEE
	mov ds,ax
	mov dx,2
debtab:
	mov cx,word ptr[Tableau]
	mov di, offset Tableau
boucle:
        cmp [flag],1
        jnz boucle
	mov [Flag], 0
        mov al,[DI+2]
	call SimuCan ; simule out 20h,al vers le CNA
	inc di
	dec cx
	jnz boucle

	dec dx
        jnz debtab

	call ResetInt
; fin et retour au DOS par le biais d'un appel � une routine DOS
	mov ah,4ch
	int 21h

Routine_IT	PROC	FAR
	sti
 	push ds
	push ax
	mov ax,DONNEE
	mov ds,ax
	mov [flag],1
	pop ax
	pop ds
;        iret
	jmp CS:[int9_ptr]
Routine_IT	ENDP

; ##################  routine de simulation de la sortie sur le CNA

SimuCAN		PROC
	push di
	push cx
	push dx
	add al,'0'
	mov [alpha],AL
	mov ah,9
	mov dx,OFFSET Alpha
	int 21h
	pop dx
	pop cx
	pop di
	ret
SimuCAN		ENDP

; gestion des interruptions

Ad_IT9 equ 9*4; l'adresse 0:Ad_IT9 correspond � l'IT n�9

InitInt		PROC
; interdiction temporaire des IT
	cli
;lecture du vecteur d'IT clavier (IT n�9) et sauvegarde
	mov ax,3509h 	;fonction 35, IT 09
	int 21h		;int DOS, r�sultat dans es:bx
	mov CS:int9_seg,es
	mov CS:int9_offs,bx
; detournement du vecteur d'IT n�9, sans appel � une routine
	mov ax,0
	mov ds,ax
	mov bx, Ad_IT9
	mov word ptr[bx],offset Routine_IT
	mov word ptr[bx+2],seg Routine_IT
; autorisation des IT
	sti
	ret
InitInt ENDP

ResetInt PROC
	; On retablit l'ancien vecteur d'IT � l'aide d'une routine DOS
	mov dx,CS:int9_offs
	mov ds,CS:int9_seg
	mov ax,2509h
	int 21h
	ret
ResetInt ENDP

; z�ne de donn�es faisant partie du segment de programme!
int9_ptr   EQU this dword
int9_offs  DW 0
int9_seg   DW 0
PROGRAMME ENDS
	END debut
