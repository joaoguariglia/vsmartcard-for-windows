@echo on
REM este arquivo de DOS serve para chamar a aplicação [inst_reboot.exe]
REM o Windows nao aceita chamar direto a aplicação como RunOnce se ela estiver como Admin Elevado
REM Entao temos que fazer essa gambiarra para chamar a aplicacao após o start
inst_reboot.exe