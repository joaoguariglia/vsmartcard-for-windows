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
Global $credencial_ip = "" ; ip do servidor linux
Global $credencial_porta = "" ; porta do ssh

Global $porta_aleatoria = random(100, 999, 1)
; A variavel a cima "$porta_aleatoria = random(100, 999, 1)" serve para que que seja gerado um numero aleatorio de uma porta para conexao reversa que tem o prefico 63XXX
; Quando eu faço tunnelamento no plink aqui no windows eu sou obrigado a escolher uma porta la no linux ( criar uma porta ) que quando eu der o comando la
; esse comando vai sair por aquela porta " criada" e assim o windows recebe esse comando sempre na porta "35963", la no linux o comando sempre é feito em
; looping back, ou seja para ele mesmo, entao é mais facil trabalhar com portas do que com ip, mas quando se trabalha com porta, cada cliente windows que conecta
; tem que gerar sua propria porta no linux, por isso a porta tem que ser aleatoria, se for igual o smartcard fica bobo e acaba caindo para um dos clientes com a porta igual

Sleep($porta_aleatoria) ; este sleep é para dar um tempo do programa criar um numero aleatorio


; Pega os dados do arquivo credencial.ini, e joga nas variaveis para depois o plink executar os comandos
$credencial_usuario = IniRead("credencial.ini", "Dados", "usuario", "")
$credencial_senha = IniRead("credencial.ini", "Dados", "senha", "")
$credencial_ip = IniRead("credencial.ini", "Dados", "ip", "")
$credencial_porta = IniRead("credencial.ini", "Dados", "porta", "")

 ; Estas duas funções é para startar e stopar o driver smartcard porque as vezes ele trava
RunWait('devcon disable @"ROOT\SMARTCARDREADER\0000"',@ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)
Sleep(2000)
RunWait('devcon enable @"ROOT\SMARTCARDREADER\0000"',@ScriptDir, @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)

iniciar()
Func iniciar()

				  ; Ele vai criar a console de conexao a partir daqui
				  GUICreate("Console da Log:", 800, 560,-1,-1,$WS_POPUPWINDOW)

				  GUISetState(@SW_show)
				  $line = ""
				  $oldline = ""
				  $cidEdit = GUICtrlCreateEdit("", 0, 0, 800, 561, BitOR($ES_AUTOVSCROLL, $ES_READONLY, $WS_HSCROLL, $WS_VSCROLL))

					 GUICtrlSetData(-1,  "Console V0.1" & @CRLF & _
                                    "Conectando ao Servidor de Certificados")
					 GUICtrlSetFont(-1, 10, 600, 0, "Lucida Console")
					 GUICtrlSetColor(-1, 0xC0C0C0)
					 GUICtrlSetBkColor(-1, 0x000000)

						$comando_yes_plink = 'echo y | plink -ssh -P ' & $credencial_porta & ' -pw ' & $credencial_senha & ' ' & $credencial_usuario & '@'&$credencial_ip & ' exit' ; server para guardar as chaves de acesso dando yes automatico
						$pid = RunWait(@ComSpec & " /C " & $comando_yes_plink, @ScriptDir, @SW_HIDE,$STDIN_CHILD + $STDERR_MERGED) ; server para guardar as chaves de acesso dando yes automatico
						;$pid = run('plink -ssh -t -pw ' & $credencial_senha & ' ' & $credencial_usuario & '@'&$credencial_ip & ' ' & "bash -l -c 'vicc -vvvvv --type relay --hostname '" & @IPAddress1, @ScriptDir, @SW_HIDE,$STDIN_CHILD + $STDERR_MERGED)
						$pid = run('plink -P ' & $credencial_porta & ' -pw ' & $credencial_senha & ' -t ' & $credencial_usuario & '@'&$credencial_ip & ' -R :34'& $porta_aleatoria &':127.0.0.1:35963 vicc -vvvvv --type relay --hostname localhost --port 34' & $porta_aleatoria, @ScriptDir, @SW_HIDE,$STDIN_CHILD + $STDERR_MERGED)
						;$pid = run('plink -P 225 -pw ' & $credencial_senha & ' -t ' & $credencial_usuario & '@'&$credencial_ip & ' ' & "cat teste", @ScriptDir, @SW_HIDE,$STDIN_CHILD + $STDERR_MERGED)
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

						    ; Caso C - Conexao muito lenta para passar os dados
						   If stringinstr($line,'[ERROR] Error transmitting APDU:') > 0 then
						   MsgBox(16, 'Conexao lenta:', 'O servidor não consegue conectar no seu pc:' & @LF & 'Verifique se a sua conexao nao esta lenta em algum site' & @LF & 'Verifique se o seu wifi esta com bom sinal, esse serviço nao funciona adequeadamente no 3/4G')
						   ExitLoop
						endif

						 ; Caso D - Firewall barrando
						   If stringinstr($line,'firewall blocking') > 0 then
						   MsgBox(16, 'Serviço bloqueado:', 'O servidor não consegue conectar no seu pc:' & @LF & 'Verifique o firewall do seu windows se esta habilitado se sim, desabilite' & @LF & 'Verifique também se o firewall do seu antivirus ou roteador esta habilitado se sim, desabilite')
						   ExitLoop
						endif

						; Caso E - Conectou mais de uma vez
						   If stringinstr($line,'Too many logins for') > 0 then
						   MsgBox(16, 'Serviço bloqueado:', 'Você logou com o mesmo usuario 2 ou mais vezes:' & @LF & 'Seu usuario ainda esta logado no servidor ou alguem esta usando a sua conta alem de você.' & @LF & 'Se você fez um login recentemente aguarde um pouco para o servidor desconectar seu usuario e tente novamente em alguns minutos')
						   ExitLoop
						endif

						   If Not ProcessExists($pid) Then ExitLoop
					 Wend
						MsgBox(64, "Information", "Conexão Terminada!","")
						ProcessClose("cliente_vpcd.exe")

EndFunc