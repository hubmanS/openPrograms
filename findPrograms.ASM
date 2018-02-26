; -------------------------------------------------------------------------------------

 format PE GUI 4.0

 entry start

include 'c:\FASM\INCLUDE\win32a.inc'
; -------------------------------------------------------------------------------------

 IDD_BIG_HEX_CALC_DIALOG = 102
 IDC_PARAM_1		 = 1000


 IDC_BTN_EJECUTAR	 = 1005
 IDC_BTN_RESET		 = 1006
 ID_LISTBOX2		 = 103

 IDC_RADIO_ONE		 = 1009
 IDC_RADIO_DOS		 = 1010
 IDC_RADIO_TRES 	 = 1011

 ID_GBOX		 = 109
 ID_COMBOBOX		 = 110

; -------------------------------------------------------------------------------------

 section '.code' code readable executable

  start:

    invoke GetModuleHandle,0
    invoke DialogBoxParam,eax,IDD_BIG_HEX_CALC_DIALOG,0,DialogProc,0
  exit:

 invoke  ExitProcess,0

; -------------------------------------------------------------------------------------

proc DialogProc uses esi edi ebx,hwnddlg,msg,wparam,lparam


  cmp [msg],WM_INITDIALOG
  je .wminitdialog

  cmp [msg],WM_COMMAND
  je .wmcommand

  cmp [msg],WM_CLOSE
  je .wmclose

  xor eax,eax
  jmp .quit

  .wminitdialog:
	    stdcall CreateControls,[hwnddlg]
	    invoke IsDlgButtonChecked,[hwnddlg],IDC_RADIO_ONE
	    invoke IsDlgButtonChecked,[hwnddlg],IDC_RADIO_DOS
	    invoke IsDlgButtonChecked,[hwnddlg],IDC_RADIO_TRES
    invoke SetDlgItemText,[hwnddlg],IDC_PARAM_1,NoTexto
    stdcall Dlg,tam,etiqueta,[hwnddlg],70,134,260,36,-1,0,0

    jmp .done

  .wmcommand:

    cmp [wparam], BN_CLICKED shl 16 + IDC_BTN_EJECUTAR
    je .PROCESO

    cmp  [wparam], BN_CLICKED shl 16 + IDC_BTN_RESET
    je .CLEARDATA

    jmp .done

  .PROCESO:
  stdcall Dlg,ListBox,NoTexto,[hwnddlg],110,150,560,250,ID_LISTBOX2,WS_VSCROLL+WS_BORDER+\
			      LBS_HASSTRINGS+LBS_NOINTEGRALHEIGHT+LBS_DISABLENOSCROLL,\
							       WS_EX_OVERLAPPEDWINDOW
    invoke IsDlgButtonChecked,[hwnddlg],IDC_RADIO_ONE
    cmp    eax,0
    jne   .MARCOIMAGENES
    invoke IsDlgButtonChecked,[hwnddlg],IDC_RADIO_DOS
    cmp    eax,0
    jne   .MARCOVIDEOS
    invoke IsDlgButtonChecked,[hwnddlg],IDC_RADIO_TRES
    cmp    eax,0
    jne   .MARCODOCUMENTOS
    jmp   .COMPUTE

    .MARCOIMAGENES:
	    invoke  GetDlgItemText,[hwnddlg],ID_COMBOBOX,Buffer,256
	    invoke  GetDlgItemText,[hwnddlg],IDC_PARAM_1,parametro,100h
	    invoke  lstrcat, parametro,I
	    jmp    .Despliegue

     .MARCOVIDEOS:
      invoke  GetDlgItemText,[hwnddlg],ID_COMBOBOX,Buffer,256
      invoke  GetDlgItemText,[hwnddlg],IDC_PARAM_1,parametro,100h
	    invoke  lstrcat, parametro,V
	    jmp    .Despliegue

    .MARCODOCUMENTOS:
     invoke  GetDlgItemText,[hwnddlg],ID_COMBOBOX,Buffer,256
     invoke  GetDlgItemText,[hwnddlg],IDC_PARAM_1,parametro,100h
	    invoke  lstrcat, parametro,D
	    jmp     .Despliegue
    .Despliegue:


	invoke	lstrcpy ,buscadoCopy,Buffer	      ;Buffer es del contenido de combobox
	invoke	lstrcat ,buscadoCopy,todo
	invoke	GetStdHandle, STD_OUTPUT_HANDLE
	mov	[_outhandle], eax
	invoke	FindFirstFile,buscadoCopy,wfd
	cmp	eax,INVALID_HANDLE_VALUE
	je	.wmclose
	mov	[handle],eax
	mov	[encontrado],wfd.cFileName
	invoke	lstrlen,wfd.cFileName
	invoke	lstrcmp,formatIma,wfd.cFileName
	je	.visualizarU
	jmp	.bucleU
    .visualizarU:
	invoke	SendMessage,ebx,LB_ADDSTRING,0,parametro

    .bucleU:

	invoke	FindNextFile,[handle],wfd
	cmp	eax,0
	je	.done
	mov	[encontrado],wfd.cFileName
	invoke	lstrlen,wfd.cFileName
	invoke	lstrcmp,parametro,[encontrado]
	je	.visualizarU2
	cmp	[wfd.dwFileAttributes],FILE_ATTRIBUTE_DIRECTORY
	je	.entrarU

	jmp	.bucleU

     .entrarU:
	invoke	lstrcpy, buscado,Buffer

	mov	[directorio],wfd.cFileName
	invoke	lstrcat ,buscado,[directorio]
	invoke	lstrcat ,buscado,slash

	invoke	lstrcat ,buscado,parametro
		invoke	FindFirstFile,buscado,wfd
		cmp	eax,INVALID_HANDLE_VALUE
		je	.bucleU
		mov	[handleIn],eax
		mov	[encontrado],wfd.cFileName
		invoke SendMessage,ebx,LB_ADDSTRING,0,buscado

       .bucleAdentroU:

	invoke	FindNextFile,[handleIn],wfd
	cmp	eax,0
	je	.bucleU
	mov	[encontrado],wfd.cFileName
	invoke	lstrlen,wfd.cFileName
       ; invoke  MessageBox,0,buscado,[directorio],0
	invoke	SendMessage,ebx,LB_ADDSTRING,0,buscado
	jmp	.bucleAdentroU


     .visualizarU2:
	 invoke  lstrcpy ,respuestaRuta,Buffer
	 invoke  lstrcat ,respuestaRuta,[encontrado]
	 invoke  SendMessage,ebx,LB_ADDSTRING,0,respuestaRuta
	 jmp .bucleU






   .COMPUTE:


    stdcall Dlg,ListBox,NoTexto,[hwnddlg],110,150,560,250,ID_LISTBOX2,WS_VSCROLL+WS_BORDER+\
			      LBS_HASSTRINGS+LBS_NOINTEGRALHEIGHT+LBS_DISABLENOSCROLL,\
							       WS_EX_OVERLAPPEDWINDOW
    invoke GetDlgItemText,[hwnddlg],ID_COMBOBOX,Buffer,256
    invoke  lstrcpy, buscadoCopy,Buffer

    invoke GetDlgItemText,[hwnddlg],IDC_PARAM_1,parametro,100h
    invoke lstrcmp,parametro,NoTexto
    je .MostrarF


	invoke	lstrcat ,buscadoCopy,todo
	invoke	GetStdHandle, STD_OUTPUT_HANDLE
	mov	[_outhandle], eax
	invoke	FindFirstFile,buscadoCopy,wfd
	cmp	eax,INVALID_HANDLE_VALUE
	je	.wmclose
	mov	[handle],eax
	mov	[encontrado],wfd.cFileName
	invoke	lstrlen,wfd.cFileName
	invoke	lstrcmp,parametro,wfd.cFileName
	je	.visualizar
	jmp	.bucle
    .visualizar:
	invoke	SendMessage,ebx,LB_ADDSTRING,0,[encontrado]

    .bucle:
	invoke	FindNextFile,[handle],wfd
	cmp	eax,0
	je	.done
	mov	[encontrado],wfd.cFileName
	invoke	lstrlen,wfd.cFileName
	invoke	lstrcmp,parametro,[encontrado]
	je	.visualizar2
	cmp	[wfd.dwFileAttributes],FILE_ATTRIBUTE_DIRECTORY
	je	.entrar

	jmp	.bucle

     .entrar:
	invoke	lstrcpy, buscado,Buffer

	mov	[directorio],wfd.cFileName
	invoke	lstrcat ,buscado,[directorio]
	invoke	lstrcpy ,direcCopy,[directorio]

	invoke	lstrcat ,buscado,slash
	invoke	GetDlgItemText,[hwnddlg],IDC_PARAM_1,parametro,100h
	invoke	lstrcat ,buscado,parametro
		invoke	FindFirstFile,buscado,wfd
		cmp	eax,INVALID_HANDLE_VALUE
		je	.bucle
		mov	[handleIn],eax
		mov	[encontrado],wfd.cFileName
		invoke	lstrcpy ,respuestaRuta,Buffer
		invoke	lstrcat ,respuestaRuta,direcCopy
		invoke	lstrcat ,respuestaRuta,slash
		invoke	lstrcat ,respuestaRuta,[encontrado]
		invoke	SendMessage,ebx,LB_ADDSTRING,0,respuestaRuta

       .bucleAdentro:

	invoke	FindNextFile,[handleIn],wfd
	cmp	eax,0
	je	.bucle
	mov	[encontrado],wfd.cFileName
	invoke	lstrlen,wfd.cFileName

	invoke	SendMessage,ebx,LB_ADDSTRING,0,[encontrado]
	jmp	.bucleAdentro
	invoke	lstrcpy, buscado,Buffer

	jmp .bucle

  .MostrarF:

	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov [_outhandle], eax
	invoke	lstrcpy, buscado,Buffer
	invoke	lstrcat ,buscado,todo
	invoke	FindFirstFile,buscado,wfd
	cmp	eax,INVALID_HANDLE_VALUE
	je	.wmclose
	mov	[handle],eax
	mov	[encontrado],wfd.cFileName
	invoke	lstrlen,wfd.cFileName

    invoke SendMessage,ebx,LB_ADDSTRING,0,[encontrado]
    .bucleMostrarF:

	invoke	FindNextFile,[handle],wfd
	cmp	eax,0
	je	.done
	mov	[encontrado],wfd.cFileName
	invoke	lstrlen,wfd.cFileName
	invoke	SendMessage,ebx,LB_ADDSTRING,0,[encontrado]
	jmp	.bucleMostrarF

     .visualizar2:
	 invoke  lstrcpy ,respuestaRuta,Buffer
	 invoke  lstrcat ,respuestaRuta,[encontrado]
	 invoke  SendMessage,ebx,LB_ADDSTRING,0,respuestaRuta
      jmp .bucle




  .CLEARDATA:

    invoke SetDlgItemText,[hwnddlg],IDC_PARAM_1,NoTexto
	    invoke CheckDlgButton,[hwnddlg],IDC_RADIO_ONE,BST_UNCHECKED
	    invoke CheckDlgButton,[hwnddlg],IDC_RADIO_DOS,BST_UNCHECKED
	    invoke CheckDlgButton,[hwnddlg],IDC_RADIO_TRES,BST_UNCHECKED

    jmp .done

  .wmclose:

   invoke  lstrcpy, parametro  ,NoTexto
   invoke  EndDialog,[hwnddlg],0



  .done:

    mov eax,1

  .quit:

  ret	    

endp



proc CreateControls @hWnd

    stdcall Dlg,Static,StaticTxt,[@hWnd],30,25,160,16,-1,0,0


    stdcall Dlg,ComboBox,NoText,[@hWnd],30,45,160,140,ID_COMBOBOX,CBS_DROPDOWN,0
    mov ebx,eax


    invoke SetDlgItemText,[@hWnd],ID_COMBOBOX,itemUnidadC

    invoke SendMessage,ebx,CB_ADDSTRING,0,itemUnidadC
    invoke SendMessage,ebx,CB_ADDSTRING,0,itemUnidadD
    invoke SendMessage,ebx,CB_ADDSTRING,0,itemUnidadE
    invoke SendMessage,ebx,CB_ADDSTRING,0,itemUnidadF
    invoke SendMessage,ebx,CB_ADDSTRING,0,itemUnidadG
    invoke SendMessage,ebx,CB_ADDSTRING,0,itemUnidadH
    invoke SendMessage,ebx,CB_ADDSTRING,0,itemUnidadI
    invoke SendMessage,ebx,CB_ADDSTRING,0,itemUnidadJ


    ret
endp

proc Dlg @Class, @AddrText, @hParent, @X, @Y, @Xw, @Yh, @Id, @Style, @ExStyle

    mov eax,WS_CHILD+WS_VISIBLE
    add eax,[@Style]
    invoke CreateWindowEx,[@ExStyle],[@Class],[@AddrText],eax,[@X],[@Y],[@Xw],[@Yh],\
			  [@hParent],[@Id],[wc.hInstance],NULL
    mov ebx,eax


    invoke SendMessage,ebx,WM_SETFONT,[visualizadorFuente],NULL
    mov eax,ebx

    ret
endp
; -------------------------------------------------------------------------------------

section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
	    user32,'USER32.DLL',\
	     gdi32,'GDI32.DLL'

  include 'c:\FASM\INCLUDE\api\kernel32.inc'
  include 'c:\FASM\INCLUDE\api\user32.inc'
  include 'c:\FASM\INCLUDE\api\gdi32.inc'



; -------------------------------------------------------------------------------------

section '.text' readable writeable

  I	db '.jpg',0
  D	db '.txt',0
  V	db '.mp4',0

  buscado	   db '',0
  StaticTxt	   db 'Unidad',0
  Static	   db 'STATIC',0
  NoText	   db '',0
  ComboBox	   db 'COMBOBOX',0
  ComboBoxTxt	   db 'SELECCIONE',0
  itemUnidadC	   db 'C:\',0
  itemUnidadD	   db 'D:\',0
  itemUnidadE	   db 'E:\',0
  itemUnidadF	   db 'F:\',0
  itemUnidadG	   db 'G:\',0
  itemUnidadH	   db 'H:\',0
  itemUnidadI	   db 'I:\',0
  itemUnidadJ	   db 'J:\',0
  Buffer	   rb 256

  formato	db '*.jpg',0
  respuestaRuta db '',0

  formatIma	db '*.jpg',0
  formatVideo	db '*.mp4',0
  formatDoc	db '*.pdf',0
  slash 	db '\',0
  todo		db '*.*',0
  _outhandle	dd   ?
   parametro	dd   ?
  _written	dd   ?
  directorio	dd   ?

  buscadoCopy	db '',0

  wfd		WIN32_FIND_DATA
  handle	dd   ?
  handleIn	dd   ?
  encontrado	dd   ?
  mostrar	db   ?
  etiqueta	db 'RESULTADO DE BUSQUEDA',0
  tam		db 'STATIC',0
  NoTexto	db '',0
  ListBox	db 'LISTBOX',0
  visualizadorFuente   dd ?
  wc	      WNDCLASS	 0, DialogProc, 0, 0, 0, 0, 0, COLOR_BTNFACE+1, 0, ClassName
  ClassName   db 'LISTADOR DE ARCHIVOS',0
  direcCopy	   db '',0
; -------------------------------------------------------------------------------------

section '.rc' resource data readable

  directory RT_DIALOG,dialogs

  resource dialogs,IDD_BIG_HEX_CALC_DIALOG,LANG_ENGLISH+SUBLANG_DEFAULT,mod_exp_dialog

  dialog mod_exp_dialog,\
  'LISTADOR DE ARCHIVOS',100,50,360,296,\
  DS_MODALFRAME+WS_MINIMIZEBOX+WS_POPUP+WS_VISIBLE+WS_CAPTION+WS_SYSMENU,\
  0,0,"Lucida Console",11

  dialogitem 'BUTTON','LISTADOR DE ARCHIVOS 5.0.1',-1,7,5,346,224,BS_GROUPBOX+WS_VISIBLE,0

  dialogitem 'EDIT',0,IDC_PARAM_1,13,50,335,20,ES_MULTILINE+ES_AUTOVSCROLL+ES_WANTRETURN+WS_VSCROLL+WS_BORDER+WS_VISIBLE,0

  dialogitem 'BUTTON',"EJECUTAR",IDC_BTN_EJECUTAR,186,248,80,14,BS_PUSHBUTTON+WS_VISIBLE,0
  dialogitem 'BUTTON',"LIMPIAR",IDC_BTN_RESET,267,248,80,14,BS_PUSHBUTTON+WS_VISIBLE,0
      dialogitem 'BUTTON',"Imagenes",IDC_RADIO_ONE,60,40,80,10,BS_AUTORADIOBUTTON+WS_TABSTOP+WS_VISIBLE,0
      dialogitem 'BUTTON',"videos",IDC_RADIO_DOS,170,40,80,10,BS_AUTORADIOBUTTON+WS_TABSTOP+WS_VISIBLE,0
      dialogitem 'BUTTON',"documentos",IDC_RADIO_TRES,260,40,80,10,BS_AUTORADIOBUTTON+WS_TABSTOP+WS_VISIBLE,0

   enddialog
