 ; Bibliotecas usadas
#include <Constants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#RequireAdmin

   ;Variaveis usadas
Global $credencial_usuario = ""
Global $credencial_senha = ""
Global $credencial_ip = ""

; Pega os dados do arquivo credencial.ini, e joga nas variaveis para depois o plink executar os comandos
$credencial_usuario = IniRead("credencial.ini", "Dados", "usuario", "")
$credencial_senha = IniRead("credencial.ini", "Dados", "senha", "")
$credencial_ip = IniRead("credencial.ini", "Dados", "ip", "")

 ; Estas duas funções é para startar e stopar o driver smartcard porque as vezes ele trava
RunWait('devcon disable @"ROOT\SMARTCARDREADER\0000"',@ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)
RunWait('devcon enable @"ROOT\SMARTCARDREADER\0000"',@ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)

iniciar()
Func iniciar()

				  ; Ele vai criar a console de conexao a partir daqui
				  GUICreate("Console da Log:", 800, 560,-1,-1,$WS_POPUPWINDOW)

				  GUISetState(@SW_HIDE)
				  $line = ""
				  $oldline = ""
				  $cidEdit = GUICtrlCreateEdit("", 0, 0, 800, 561, BitOR($ES_AUTOVSCROLL, $ES_READONLY, $WS_HSCROLL, $WS_VSCROLL))

					 GUICtrlSetData(-1,  "Console V0.1" & @CRLF & _
                                    "Conectando ao Servidor de Certificados")
					 GUICtrlSetFont(-1, 10, 600, 0, "Lucida Console")
					 GUICtrlSetColor(-1, 0xC0C0C0)
					 GUICtrlSetBkColor(-1, 0x000000)

						$comando_yes_plink = 'echo y | plink -ssh -pw ' & $credencial_senha & ' ' & $credencial_usuario & '@'&$credencial_ip & ' exit' ; server para guardar as chaves de acesso dando yes automatico
						$pid = RunWait(@ComSpec & " /C " & $comando_yes_plink, @ScriptDir, @SW_HIDE,$STDIN_CHILD + $STDERR_MERGED) ; server para guardar as chaves de acesso dando yes automatico
						$pid = run('plink -ssh -t -pw ' & $credencial_senha & ' ' & $credencial_usuario & '@'&$credencial_ip & ' ' & "bash -l -c 'vicc -vvvvv --type relay --hostname '" & @IPAddress1, @ScriptDir, @SW_HIDE,$STDIN_CHILD + $STDERR_MERGED)

						;$pid = run('plink -ssh -t -pw ' & $credencial_senha & ' ' & $credencial_usuario & '@'&$credencial_ip & ' ' & "bash -l -c 'top'", @ScriptDir, @SW_HIDE,$STDIN_CHILD + $STDERR_MERGED)
						;$pid = run('ping terra.com.br', @ScriptDir, @SW_HIDE,$STDIN_CHILD + $STDERR_MERGED)
						_GUICtrlEdit_AppendText($cidEdit, @CRLF)


					 ; Esta estrutura de repetição é o que manda as logs do plink ao vivo para a console_conexao
					 While Sleep(50)


						   $line = StdoutRead($pid) & @LF

						   ; Console onde aparece as logs
						   If $oldline <> $line Then
						   _GUICtrlEdit_AppendText($cidEdit, $line)
						   $oldline = $line
						   EndIf


						   ;Caso A - Erro de Conexao negada porta ssh stop
						   If stringinstr($line,'FATAL ERROR: Network error: Connection refused') > 0 then
						   MsgBox(16, 'Falha na conexão', 'Falha na Conexão:' & @LF & 'Houve um erro ao tentar se conectar no servidor ' & $credencial_ip & @LF & 'Por favor cheque o serviço de SSH do Linux')
						   ExitLoop
						   endif

						   ; Caso B - Senha/IP/Usuario em branco
						   If stringinstr($line,'Plink: command-line connection utility') > 0 then
						   MsgBox(16, 'Dados em branco', 'Dados em branco:' & @LF & 'Um ou mais dados estão em branco')
						   ExitLoop
						   endif

						   ; Caso C - Senha/Usuario errada
						   If stringinstr($line,'password:') > 0 then
						   MsgBox(16, 'Usuario ou senha incorreta', 'Usuario ou senha incorreta:' & @LF & 'Por favor reveja seu usuario ou senha!')
						   ExitLoop
						   endif

						   ; Erros do VPCD

						   ; Conectado com sucesso!
						   If stringinstr($line,'Connected to virtual PCD at') > 0 then
						   TrayTip("Conectado","Conectado com sucesso!",2,1)
						   endif

						   ; Caso A - Cartao indisponivel
						   If stringinstr($line,'[ERROR] Invalid number of reader') > 0 then
						   MsgBox(16, 'Cartão Indisponivel', 'O cartão ou token não esta inserido corretamente:' & @LF & 'Por favor verifique seu cartão ou token no servidor pois o mesmo não esta lendo corretamente!')
						   ExitLoop
						   endif

						   ; Caso B - Serviço pcsc
						   If stringinstr($line,"'Failure to establish context: Service not available.'") > 0 then
						   MsgBox(16, 'Leitor do servidor:', 'O serviço PCSC certamente deve esta stop:' & @LF & 'No servidor de o comando "service start pcsc"' & @LF & 'e tente conectar novamente')
						   ExitLoop
						   endif

						    ; Caso C - Firewall barrando
						   If stringinstr($line,'firewall blocking') > 0 then
						   MsgBox(16, 'Serviço bloqueado:', 'O servidor não consegue conectar no seu pc:' & @LF & 'Verifique o firewall do seu windows se esta habilitado se sim, desabilite' & @LF & 'Verifique também se o firewall do seu antivirus ou roteador esta habilitado se sim, desabilite')
						   ExitLoop
						endif


						   If Not ProcessExists($pid) Then ExitLoop
					 Wend
						MsgBox(64, "Information", "Conexão Terminada!","")
						ProcessClose("cliente_vpcd.exe")

EndFunc