#include <Constants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <Security.au3>
#include <FontConstants.au3>
#AutoIt3Wrapper_UseX64=y

#RequireAdmin

Opt("GUIOnEventMode", 1)


instalando_devcon()
Func instalando_devcon()
   GUICreate("Instalando os drivers...", 300, 55,-1,-1,$WS_POPUPWINDOW)
   LOCAL $guimsg = GUICtrlCreateLabel("Por favor aguarde a instalação dos drivers...", 0, 0, 300, 55, $SS_CENTER) ; Dimensionando a caixa do label para ficar
																												  ; Do mesmo tamanha do form toda vermelha
   GUICtrlSetFont(-1, 14, 20, 0, "Arial Black") ; inserindo a font e o tamanho
   GUICtrlSetColor ($guimsg, $COLOR_WHITE) ; cor da fonte
   GUICtrlSetBkColor($guimsg, $COLOR_RED) ; cor do fundo do Label vermelho


   WinActivate("Instalando os drivers...")              											; isso garante que quando eu abrir a console o programa
   WinSetState("Instalando os drivers...", "", @SW_SHOW)											; principal fica sempre em cima
   WinSetOnTop("Instalando os drivers...", "", 1)

   ShellExecute("devcon.exe", 'install BixVReader.inf root\BixVirtualReader', "", "", @SW_HIDE) 	;Rodando o Devcon em modo discreto

   Local $hWnd = WinWait("[Class:#32770]") 									; Vamos setar a janela de adivertencia do Windows para deixar ela invisivel
   WinSetState($hWnd, "", @SW_HIDE) 										; Na hora que aparecer a tela ela fica invisivel
   WinActivate("[Class:#32770]") 											; Vamos focar nessa tela para na linha de baixo dar o " instalar mesmo assim os drivers nao assinados "
   ControlClick("[Class:#32770]", "","[CLASS:Button; INSTANCE:2]")			; clicando no botao "instalando mesmo assim os drivers nao assinados"
   WinSetState("Instalando os drivers...","",@SW_HIDE) 						; Terminado de instalar o aviso fica oculto e cai para o proximo aviso
   instalando_remove_modo_teste()
EndFunc

Func instalando_remove_modo_teste()
   GUICreate("Removendo modo teste do Windows...", 300, 55,-1,-1,$WS_POPUPWINDOW)
   LOCAL $guimsg = GUICtrlCreateLabel("Removendo modo de teste dos Drivers no Windows...", 0, 0, 300, 55, $SS_CENTER) ; Dimensionando a caixa do label para ficar
																												  ; Do mesmo tamanha do form toda vermelha 10, 10)

   GUICtrlSetFont(-1, 14, 20, 0, "Arial Black") ; inserindo a font e o tamanho
   GUICtrlSetColor ($guimsg, $COLOR_WHITE) ; cor da fonte
   GUICtrlSetBkColor($guimsg, $COLOR_RED) ; cor do fundo do Label vermelho

   WinActivate("Removendo modo teste do Windows...")              			; isso garante que quando eu abrir a console o programa
   WinSetState("Removendo modo teste do Windows...", "", @SW_SHOW)			; principal fica sempre em cima no foco
   WinSetOnTop("Removendo modo teste do Windows...", "", 1)

   RunWait(@ComSpec & ' /c mode_driver_off.exe', "", @SW_HIDE) 				;Rodando o bcedit em modo discreto

   WinSetState("Removendo modo teste do Windows...","",@SW_HIDE)			; Terminado de apagar o aviso fica oculto e cai para o proximo aviso
   instalando_remove_registro()
EndFunc

Func instalando_remove_registro()
   GUICreate("Limpando...", 300, 55,-1,-1,$WS_POPUPWINDOW)
   LOCAL $guimsg = GUICtrlCreateLabel("Limpando a instalação...", 0, 0, 300, 55, $SS_CENTER) ; Dimensionando a caixa do label para ficar
																												  ; Do mesmo tamanha do form toda vermelha

   GUICtrlSetFont(-1, 14, 20, 0, "Arial Black") ; inserindo a font e o tamanho
   GUICtrlSetColor ($guimsg, $COLOR_WHITE) ; cor da fonte
   GUICtrlSetBkColor($guimsg, $COLOR_RED) ; cor do fundo do Label vermelho

   WinActivate("Limpando...")              												; isso garante que quando eu abrir a console o programa
   WinSetState("Limpando...", "", @SW_SHOW)												; principal fica sempre em cima no foco
   WinSetOnTop("Limpando...", "", 1)

   filedelete("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\starta_o_inst_reboot.lnk")	; Apagando o arquivo da pasta iniciar que fez esse script inteiro rodar pós reboot

   WinSetState("Removendo chaves...","",@SW_HIDE)										; Terminado de apagar o aviso fica oculto e cai para o proximo aviso
   reiniciar()
EndFunc


Func reiniciar()

   GUICreate("Concluido:", 300, 55,-1,-1,$WS_POPUPWINDOW)
   LOCAL $guimsg = GUICtrlCreateLabel("Instalação concluida reiniciando o windows",  0, 0, 300, 55, $SS_CENTER) ; Dimensionando a caixa do label para ficar
																												  ; Do mesmo tamanha do form toda vermelha
   GUICtrlSetFont(-1, 14, 20, 0, "Arial Black") ; inserindo a font e o tamanho
   GUICtrlSetColor ($guimsg, $COLOR_WHITE) ; cor da fonte
   GUICtrlSetBkColor($guimsg, $COLOR_RED) ; cor do fundo do Label vermelho

   WinActivate("Concluido:")              	; isso garante que quando eu abrir a console o programa
   WinSetState("Concluido:", "", @SW_SHOW)	; principal fica sempre em cima
   WinSetOnTop("Concluido:", "", 1)

	  Sleep(3000)
	  sair()
EndFunc


Func sair()
   Shutdown(2)
EndFunc