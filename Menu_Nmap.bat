@echo off
title NMAP TEST by: Gabriel Fagundes

:menu
cls
echo ========= NMAP TEST =========
echo 0 - Sair
echo 1 - Descobrir hosts ativos (relatorio simples)
echo 2 - Verificar portas abertas
echo 3 - Detectar servicos e versoes
echo 4 - Scan avancado (OS+vulnerabilidades)
echo =============================
set /p opcao=Escolha uma opcao: 

if "%opcao%"=="0" goto sair
if "%opcao%"=="1" goto descobrir_host_simples
if "%opcao%"=="2" goto verificar_portas
if "%opcao%"=="3" goto detectar_servicos
if "%opcao%"=="4" goto scan_avancado

echo Opcao invalida.
pause
goto menu

:descobrir_host_simples
cls
echo --- DESCOBRIR HOSTS (RELATORIO SIMPLES) ---
echo Digite o inicio do IP (ex: 192.168.1): 
set /p ip_base=IP Base: 
for /f "tokens=3 delims=." %%a in ("%ip_base%") do set vlan=%%a

echo Escaneando hosts em %ip_base%.0/24...
nmap -sn %ip_base%.0/24 > Vlan%vlan%.txt

cls
echo Relatorio gerado em:
echo %cd%\Vlan%vlan%.txt
echo.
echo Conteudo:
type Vlan%vlan%.txt
pause
goto menu

:verificar_portas
cls
echo --- VERIFICAR PORTAS ABERTAS ---
echo Digite o IP completo do dispositivo (ex: 192.168.1.1): 
set /p ip_alvo=IP Alvo: 
echo Escaneando portas 1-1000 em %ip_alvo%...
nmap -p 1-1000 %ip_alvo%
pause
goto menu

:detectar_servicos
cls
echo --- DETECTAR SERVICOS E VERSoES ---
echo Digite o IP completo do dispositivo (ex: 192.168.1.1): 
set /p ip_alvo=IP Alvo: 
echo Detectando servicos em %ip_alvo%...
nmap -sV %ip_alvo%
pause
goto menu

:scan_avancado
cls
echo --- SCAN AVANCADO (OS + VULNERABILIDADES) ---
echo Digite o IP completo do dispositivo (ex: 192.168.1.1): 
set /p ip_alvo=IP Alvo: 

:: Substitui pontos por underlines no nome do arquivo
set ip_arquivo=%ip_alvo:.=_%

:: Cria nome do arquivo com timestamp
set timestamp=%date:~6,4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%
set output_file=ScanAvancado_%ip_arquivo%_%timestamp%.txt

echo Executando scan avancado em %ip_alvo%...
echo Resultados serao salvos em: %output_file%
echo.

:: Comando Nmap otimizado
nmap -A --script vuln --script-timeout 30s --max-retries 1 %ip_alvo% > %output_file%

:: Exibe as ultimas linhas SEM usar tail (compativel com Windows puro)
if exist %output_file% (
    echo Scan concluido! Ultimas 15 linhas:
    echo ================================
    for /f "skip=%lines% tokens=*" %%a in ('type %output_file% ^| find /v /c ""') do set /a lines=%%a-15
    more +%lines% %output_file%
    echo.
    echo Relatorio completo em: %cd%\%output_file%
) else (
    echo ERRO: Scan nao concluido. Verifique o alvo.
)

pause
goto menu

:sair
echo Finalizando...
timeout /t 2 /nobreak >nul
exit