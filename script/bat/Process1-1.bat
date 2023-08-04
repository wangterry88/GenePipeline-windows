<!-- :
:: textSubmitter.bat
@echo off

	for /f "tokens=1-2 delims=," %%a in ('mshta.exe "%~f0"') do (
	set "project=%~1"
    set "name=%%a"
    set "output=%%b"
)

cd /d %~dp0
cd /d ..\..\

.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\1.TPMI-ChipCheck\Step1.PatientID_to_TPMI.R %name% %output% %project%

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
        
        	var name = document.getElementById("myFile").value;
            var output = document.getElementById('output').value;
            
            var Batch = new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1);
            close(Batch.WriteLine(name+','+output));
      }
    </script>
    
    <br>Please input the Patient list: <input type="file" id="myFile" name="myFile"/> 
    <br>
    <br>Please specify output file name: <input type='text' id="output" value="Test-output" size='15'></input>
    <br>
    <br>
    <hr>
    <button onclick='pipeText()'>Go</button>
  </body>
  
</html>

