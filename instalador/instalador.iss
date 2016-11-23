

[Setup]

;AppId={{142D9E12-074D-431F-9F59-0B7042586EF6}
AppName=vpcd-windows
AppVersion=1.0

;AppPublisher=frankmorgner/vsmartcard
;AppPublisherURL=https://github.com/frankmorgner/vsmartcard
;AppSupportURL=https://github.com/frankmorgner/vsmartcard
;AppUpdatesURL=https://github.com/frankmorgner/vsmartcard
DefaultDirName=C:\Program Files (x86)\vpcd-windows
DisableDirPage=yes
DisableProgramGroupPage=yes
OutputDir=C:\Users\suporte\Desktop\setup_compilado
OutputBaseFilename=setup
SetupIconFile=C:\Users\suporte\Desktop\instalacao\drivers\icon.ico
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";

[Files] 

Source: "C:\Users\suporte\Desktop\instalacao\drivers\starta_o_inst_reboot.lnk"; DestDir: "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\";
Source: "C:\Users\suporte\Desktop\instalacao\drivers\BixVReader.ini"; DestDir: "{win}";
Source: "C:\Users\suporte\Desktop\instalacao\executaveis\cliente_vpcd.exe"; DestDir: "{app}\executaveis\"; Flags: ignoreversion
Source: "C:\Users\suporte\Desktop\instalacao\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{commonprograms}\vpcd-windows"; Filename: "{app}\executaveis\cliente_vpcd.exe"
Name: "{commondesktop}\vpcd-windows"; Filename: "{app}\executaveis\cliente_vpcd.exe"; Tasks: desktopicon

[Code]

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
   if CurStep = ssPostInstall then
   begin
      if (msgbox('Precisamos reiniciar a maquina para instalar os Drivers no modo Teste do Windows, pode ser feito agora ?', mbConfirmation, MB_YESNO) = IDYES) then
        begin
           
           Exec(ExpandConstant('{app}\drivers\mode_driver_on.exe'), '', '', SW_SHOW, ewWaitUntilTerminated, ResultCode); 
            WizardForm.Close;
       end; 
   end;
end;