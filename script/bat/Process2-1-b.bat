<!-- :
:: textSubmitter.bat
@echo off

	for /f "tokens=1 delims=" %%a in ('mshta.exe "%~f0"') do (
	set "project=%~1"
    set "select_name=%%a"
)

cd /d %~dp0
cd /d ..\..

echo "%select_name%"

.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\0.Phencode\Step0-2.Phencode_Selection.R "%select_name%" %project%

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
        
        	var select_name = document.getElementById('select').value;
            var Batch = new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1);
            close(Batch.WriteLine(select_name));
      }
    </script>
    
    <br>Select ONE of your disease name from the search output: <input type='text' id='select' size='30'></input>
    <br>
    <hr>
    <button onclick='pipeText()'>Go</button>
  </body>
</html>