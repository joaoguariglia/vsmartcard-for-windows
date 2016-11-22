@echo off
bcdedit /set testsigning on
bcdedit.exe /set nointegritychecks on
shutdown -r -t 0