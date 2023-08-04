<!-- :
:: textSubmitter.bat
@echo off

	for /f "tokens=1-2 delims=," %%a in ('mshta.exe "%~f0"') do (
	set "project=%~1"
    set "icd_name=%%a"
    set "output=%%b"
)

cd /d %~dp0
cd /d ..\..

.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\0.Phencode\Step0-1.ICD_Selection.R "%icd_name%" %output% %project%

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
        
        	var icd_name = document.getElementById('icd').value;
            var output = document.getElementById('output').value;
            
            var Batch = new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1);
            close(Batch.WriteLine(icd_name+','+output));
      }
    </script>
    
    <br>Please input the ICD name(Ex: 434.91|G45.4): <input type='text' id='icd' size='15'></input>
    <br>
    <br>Please specify output file name: <input type='text' id='output' value="Test-output" size='15'></input>
    <br>
    <hr>
    <button onclick='pipeText()'>Go</button>
  </body>
</html>
<br>