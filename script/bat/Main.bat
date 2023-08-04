<!-- :
:: textSubmitter.bat
@echo off

	for /f "delims=." %%i in ('wmic.exe OS get LocalDateTime ^| find "."') do (
	set "DateTime=%%i"
)	
	for /f "tokens=1-3 delims=," %%a in ('mshta.exe "%~f0"') do (
    set "project=%DateTime:~0,4%%DateTime:~4,2%%DateTime:~6,2%_%DateTime:~8,2%%DateTime:~10,2%_%%a"
    set "data_type=%%b"
    set "work_type=%%c"
)

cd /d %~dp0
cd /d ..\..\

.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\Prepare\Step0.PrepareEnvironment.R
.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\Prepare\Step1.ProjectName.R %project%

if "%data_type%"=="1" if "%work_type%"=="1" goto Process1-1
if "%data_type%"=="1" if "%work_type%"=="2" goto Process1-2
if "%data_type%"=="1" if "%work_type%"=="3" goto Process1-3
if "%data_type%"=="1" if "%work_type%"=="4" goto Process1-4

if "%data_type%"=="2" if "%work_type%"=="1" goto Process2-1
if "%data_type%"=="2" if "%work_type%"=="2" goto Process2-2
if "%data_type%"=="2" if "%work_type%"=="3" goto Process2-3
if "%data_type%"=="2" if "%work_type%"=="4" goto Process2-4

:Process1-1
start .\script\bat\Process1-1.bat %project%
pause
goto: EOF

:Process1-2
start /wait .\script\bat\ProcessX-2-1.bat %project% &^
start /wait .\script\bat\ProcessX-2-2.bat %project% &^
start /wait .\script\bat\ProcessX-2-3.bat %project% &^
pause
goto: EOF

:Process1-3
start /wait .\script\bat\ProcessX-3-1.bat %project% &^
start /wait .\script\bat\ProcessX-3-2.bat %project% &^
start /wait .\script\bat\ProcessX-3-3.bat %project% &^
start /wait .\script\bat\ProcessX-3-4.bat %project% &^
pause
goto: EOF

:Process1-4
start /wait .\script\bat\ProcessX-4.bat %project% &^
pause
goto: EOF

:Process2-1
start /wait .\script\bat\Process2-1-a.bat %project% &^
start /wait .\script\bat\Process2-1-b.bat %project% &^
start /wait .\script\bat\Process1-1.bat %project% &^
pause
goto: EOF

:Process2-2
start /wait .\script\bat\Process2-1-a.bat %project% &^
start /wait .\script\bat\Process2-1-b.bat %project% &^
start /wait .\script\bat\ProcessX-2-1.bat %project% &^
start /wait .\script\bat\ProcessX-2-2.bat %project% &^
start /wait .\script\bat\ProcessX-2-3.bat %project% &^
pause
goto: EOF

:Process2-3
start /wait .\script\bat\Process2-1-a.bat %project% &^
start /wait .\script\bat\Process2-1-b.bat %project% &^
start /wait .\script\bat\ProcessX-3-1.bat %project% &^
start /wait .\script\bat\ProcessX-3-2.bat %project% &^
start /wait .\script\bat\ProcessX-3-3.bat %project% &^
start /wait .\script\bat\ProcessX-3-4.bat %project% &^
pause
goto: EOF

:Process2-4
start /wait .\script\bat\Process2-1-a.bat %project% &^
start /wait .\script\bat\Process2-1-b.bat %project% &^
start /wait .\script\bat\ProcessX-4.bat %project% &^
pause
goto: EOF

-->

<html>
  <head>
    <title>Gene Pipeline(ver1.0)</title>
      Gene Pipeline(ver1.0)<br>
  </head>
  
  <body>
  
    <script language='javascript' >
        function pipeText() {
        
            var proj=document.getElementById('proj').value;
            
            if (document.getElementById('User').checked) {
    			var data_type = document.getElementById('User').value;
  			} else if (document.getElementById('Phencode').checked) {
    			var data_type = document.getElementById('Phencode').value;
  			}

			if (document.getElementById('ChipCheck').checked) {
    			var work_type = document.getElementById('ChipCheck').value;
  			} else if (document.getElementById('GWAS').checked) {
    			var work_type = document.getElementById('GWAS').value;
  			} else if (document.getElementById('GWASPRS').checked) {
    			var work_type = document.getElementById('GWASPRS').value;
  			} else if (document.getElementById('PGSCatalog').checked) {
    			var work_type = document.getElementById('PGSCatalog').value;
  			}
            var Batch = new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1);
            close(Batch.WriteLine(proj+','+data_type+','+work_type));
      }
    </script>
    
    <br>Please input the Project Name: <input type='text' name='proj' value="Test-Project" size='15'></input>
    <br>
    <br>Please specify input data mode: <input type="radio" id="User" name="datatype" value="1" checked><label for="User">User input</label>&nbsp;&nbsp;
    									<input type="radio" id="Phencode" name="datatype" value="2"><label for="Phencode">Phencode selection</label>&nbsp;&nbsp;
    <br>
    <br>Please specify Work type: <input type="radio" id="ChipCheck" name="worktype" value="1" checked><label for="ChipCheck">TPMI Chip Check</label>&nbsp;&nbsp;
    							  <input type="radio" id="GWAS" name="worktype" value="2"><label for="GWAS">GWAS</label>&nbsp;&nbsp;
    							  <input type="radio" id="GWASPRS" name="worktype" value="3"><label for="GWASPRS">GWAS + PRS</label>&nbsp;&nbsp;
    							  <input type="radio" id="PGSCatalog" name="worktype" value="4"><label for="PGSCatalog">PGS Catalog</label>&nbsp;&nbsp;
    <hr>
    <button onclick='pipeText()'>Go</button>
  </body>
  
</html>

