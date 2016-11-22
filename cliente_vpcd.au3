;-----------------------------------------Bibliotecas usadas------------------------------------------
#include <Constants.au3>																			;|
#include <EditConstants.au3>																		;|
#include <GUIConstantsEx.au3>																		;|
#include <GuiEdit.au3>																				;|
#include <WindowsConstants.au3>																		;|
#include <ButtonConstants.au3>																		;|
#include <StaticConstants.au3>																		;|
#include <TrayConstants.au3>																		;|
#RequireAdmin																						;|
;-----------------------------------------Bibliotecas usadas------------------------------------------
;-----------------------------------------Variaveis usadas--------------------------------------------
Global $campo_usuario = ""																			;|
Global $campo_senha = ""																			;|
Global $campo_ip = ""																				;|
Global $credencial_usuario = ""																		;|
Global $credencial_senha = ""																		;|
Global $credencial_ip = ""																			;|
Global $visivel_invisivel = True																	;|
;-----------------------------------------Variaveis usadas-------------------------------------------
;--------------------------------------Controle do Tray Menu -----------------------------------------
Opt("TrayOnEventMode", 1)																			;|
Opt("TrayMenuMode", 3)																				;|
$hTray_Show_Item = TrayCreateItem("Esconder")														;|
TrayItemSetOnEvent(-1, "To_Tray")																	;|
TrayCreateItem("")																					;|
TrayCreateItem("Sair")																				;|
TrayItemSetOnEvent(-1, "On_Exit")																	;|
;--------------------------------------Controle do Tray Menu ----------------------------------------



;--------------------------------------Controle do Tray Menu ---------------------------------------------------------------------------------------------
   ;Quadro Principal																																	;|
Local $guiprincipal = GUICreate("Console de Conex�o:", 400, 100)																						;|
GUISetState()																			; Controle do Tray Menu											;|
   ;Campo usuario																																		;|
$label_usuario = GUICtrlCreateLabel("Usuario:", 15, 15, 100, 20)																						;|
$campo_usuario = GUICtrlCreateInput("", 15, 30, 90, 20)																									;|
GUICtrlSetData($campo_usuario, IniRead("credencial.ini", "Dados", "usuario", "")) 		; ler o arquivo credencial.ini e buscar o ultimo login salvo	;|
   ;Campo senha																																			;|
$label_senha = GUICtrlCreateLabel("Senha:", 110, 15, 159, 20)																							;|
$campo_senha = GUICtrlCreateInput("", 110, 30, 90, 20,$ES_PASSWORD) 					; ler o arquivo credencial.ini e buscar o ultimo login salvo	;|
GUICtrlSetData($campo_senha, IniRead("credencial.ini", "Dados", "senha", ""))																			;|
   ;Campo IP																																			;|
$label_ip = GUICtrlCreateLabel("IP:", 205, 15, 159, 20)																									;|
$campo_ip = GUICtrlCreateInput("", 205, 30, 90, 20)																										;|
GUICtrlSetData($campo_ip, IniRead("credencial.ini", "Dados", "ip", "")) 				; ler o arquivo credencial.ini e buscar o ultimo login salvo	;|
   ;Botao Conectar																																		;|
$bto_conectar = GUICtrlCreateButton("Conectar", 300, 27, 90, 25)																						;|
   ;Botao Ver Log																																		;|
$bto_log = GUICtrlCreateButton("Ver Log", 300, 55, 90, 25)																								;|
GUICtrlSetState($bto_log, $GUI_DISABLE)																													;|
;--------------------------------------Controle do Tray Menu ---------------------------------------------------------------------------------------------



While 1 ;<<<<<<< Entrando no While

   $MSG = GUIGetMsg()
   Local $loop_conecta 		; esta variavel fica checando se o servidor linux esta pingando
   Local $msg_conectando	; esta variavel � para setar a primeira vez que vc clicar em [conectar] para aparecer a telinha de conectando... depois o valor muda para nao entrar mais neste looping
   Local $gui_conectando	; isso � um form, ele � o que muda, para ficar escondido, na verdade a GUI � deletada,s� cria quando clica no botao conectar

	  if $loop_conecta = 1 Then
						   ; Essa fun��o $loop_conecta fica o tempo todo testando a conex�o com o servidor linux
						   ; Pingando o servidor, se o ping cair ele cai para o ELSE logo mais abaixo e mostra " Falha de Conex�o "
						   ; O caminho padrao depois de conectado � -> [if $loop_conecta] ->  If Ping($credencial_ip, 3000)
						   ; Mas a primeira vez que vc clica em conectar ele vai cair na fun��o $msg_conectando = que vai mudar o valor para 1
						   ; Ai segue a descri��o dessa fun��o logo abaixo

		 If Ping($credencial_ip, 3000) Then
																	 ; Acionado apenas se o botao [conectar] for clicado
																	 if $msg_conectando = 1 then																								; o $msg_conectando s� fica 1 quando o botao [conectar] � acionado ai cai neste [if $msg_conectando] ...
																		To_Tray()																												; Ao conectar o GUI ja fica no Tray Menu
																		GUICtrlSetState($bto_log, $GUI_ENABLE)																					; o bot�o da Log fica habilitado pq ate entao ele esta disable
																		$gui_conectando = GUICreate("Conectando...", 300, 55,-1,-1,$WS_POPUPWINDOW)												; Abre aquela janelinha em preto falando "Fazendo a conexao com o servidor aguarde..."
																		GUISetState(@SW_SHOW)																									; Da atribui��o de aparecer
																		LOCAL $gui_conectando1 = GUICtrlCreateLabel("Fazendo a conexao com o servidor aguarde...", 0, 0, 300, 55, $SS_CENTER)	; Aqui ele acerta o Label para ficar bem no dentro do Form
																		GUICtrlSetFont(-1, 14, 20, 0, "Arial Black") 																			; inserindo a font e o tamanho
																		GUICtrlSetColor ($gui_conectando1, $COLOR_WHITE) 																		; cor da fonte
																		GUICtrlSetBkColor($gui_conectando1, $COLOR_BLACK) 																		; cor do fundo do Label vermelho
																		Sleep(3000)																												; Ele espera um pouco, e depois abre a console_vpcd.exe
																		run("console_vpcd.exe")

																	 EndIf

			$msg_conectando = 2         ; este � o looping de condi��o normal depois que o console_vpcd � conectado
			GuiDelete($gui_conectando )	; case a conex�o caia vai para a condi��o abaixo de "Falha de conex�o"

			Else 														; se falhar a conex�o
			GUICtrlSetState($bto_log, $GUI_DISABLE)
			MsgBox(16, "Falha de conex�o", "Falha tentando logar em " & $credencial_ip)
			WinActivate("Falha de conex�o")              				;
			WinSetState("Falha de conex�o", "", @SW_RESTORE)			; isso garante que quando eu abrir a console o programa principal fica sempre em cima no foco
			WinSetOnTop("Falha de conex�o", "", 1)						;
			GUICtrlSetState($bto_conectar, $GUI_ENABLE)					; Se a conex�o cair vai aparecer um popup com Falha na conexao, o usuario vai da ok, vai habilitar o botao conectar e sair do $loop_conecta
			ProcessClose("console_vpcd.exe")
			$loop_conecta = 2 											; dando o valor 2 ele sai do [loop_conecta], quando ele clicar em conectar o valor do looping fica 1 de novo e tudo voltar ao normal
			GUISetState(@SW_SHOW, $guiprincipal)		 		        ;
			GUISetState(@SW_RESTORE, $guiprincipal)						; O GuiPrincipal que esta minimizado no Tray � chamado para o usuario ver restaurando o GUI
			TrayItemSetText($hTray_Show_Item, "Esconder")				;


        	EndIf
		EndIf

			Select ; <<<<<<<<
;---------------------------------------------------------------- Entrando nos CASES ------------------------------------------------------------------------------------;


			Case $MSG = $GUI_EVENT_CLOSE 								; Se eu fechar a Janela Principal o Programa fecha
			ProcessClose("console_vpcd.exe") 							; Se o programa fecha o processo console_vpcd.exe tambem fecha
            Exit

			Case $MSG = $GUI_EVENT_MINIMIZE								; Se eu minimizar o programa ele vai para o Tray Menu
            To_Tray()													; Na verdade ele vai chamar uma fun��o que faz isso


			Case $MSG = $bto_conectar 									; Caso eu clique no bot�o [Conectar]


			   GUICtrlSetState($bto_conectar, $GUI_DISABLE)								; Ele vai desabilitar o botao [conectar]
			   $credencial_usuario = GUICtrlRead($campo_usuario) 						; ele le a variavel $campo_usuario e depois passa para a variavel $credencial_usuario
			   $credencial_senha = GUICtrlRead($campo_senha)							; ele le a variavel $campo_senha e depois passa para a variavel $credencial_senha
			   $credencial_ip = GUICtrlRead($campo_ip)									; ele le a variavel $campo_ip e depois passa para a variavel $credencial_ip
			   IniWrite("credencial.ini", "Dados", "usuario", $credencial_usuario)		; ele le a variavel $campo_usuario e salva no arquivo credencial.ini as informa��es passadas
			   IniWrite("credencial.ini", "Dados", "senha", $credencial_senha) 			; ele le a variavel $campo_senha e salva no arquivo credencial.ini as informa��es passadas
			   IniWrite("credencial.ini", "Dados", "ip", $credencial_ip) 				; ele le a variavel $campo_ip e salva no arquivo credencial.ini as informa��es passadas
			   $loop_conecta = 1														; Com essa condi��o ele vai habilitar o [ $loop_conecta ], que fica testando o ping no servidor linux pra sempre..
			   $msg_conectando = 1														; Com essa condi��o ele vai habilitar o if $msg_conectando para aparecer a mensagem " Conectando no servidor... "



			Case $MSG = $bto_log										; Este case faz o botao $bto_log deixar a console da log visivel e invisivel
			   If $visivel_invisivel Then
			   WinActivate("Console de Conex�o:")              	;
			   WinSetState("Console de Conex�o:", "", @SW_SHOW)	; isso garante que quando eu abrir a console o programa principal fica sempre em cima
			   WinSetOnTop("Console de Conex�o:", "", 1)        ;
			   WinWait("Console da Log:")
			   WinSetState("Console da Log:","",@SW_SHOW)		; abre a console de log
			Else
			   WinActivate("Console de Conex�o:")              	;
			   WinSetState("Console de Conex�o:", "", @SW_SHOW)	; isso garante que quando eu abrir a console o programa principal fica sempre em cima
			   WinSetOnTop("Console de Conex�o:", "", 1)        ;
			   WinWait("Console da Log:")
			   WinSetState("Console da Log:","",@SW_HIDE)		; esconda a console de log
            EndIf
            $visivel_invisivel = Not $visivel_invisivel

;---------------------------------------------------------------- Saindo dos CASES ------------------------------------------------------------------------------------;
			EndSelect ;<<<<<<<<<
		 WEnd ;<<<<<<<<< Saindo do While
;-------------------------------------------------------------------- Fun��es -----------------------------------------------------------------------------------------;

Func On_Exit() ; Esta fun��o � acionada quando eu clico no Tray Menu na op��o [sair]
   ProcessClose("console_vpcd.exe")
    Exit
 EndFunc

 ; Esta fun��o � acionada quando eu clico no Tray Menu na op��o [Maximizar]
Func To_Tray()

    If TrayItemGetText($hTray_Show_Item) = "Esconder" Then
        GUISetState(@SW_HIDE, $guiprincipal)
        TrayItemSetText($hTray_Show_Item, "Maximizar")
    Else
        GUISetState(@SW_SHOW, $guiprincipal)
        GUISetState(@SW_RESTORE, $guiprincipal)
        TrayItemSetText($hTray_Show_Item, "Esconder")
    EndIf

EndFunc
