<!-- :
:: textSubmitter.bat
@echo off

	for /f "tokens=1-3 delims=," %%a in ('mshta.exe "%~f0"') do (
	set "project=%~1"
    set "file_name=%%a"
    set "output=%%b"
    set "ratio=%%c"
)

cd /d %~dp0
cd /d ..\..\

.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\2.GWAS\Step0.Prepare_folder.R %project%
.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\2.GWAS\Step1.PatientID_to_TPMI.R %file_name% %output% %ratio% %project%

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
        
        	var file_name = document.getElementById("myFile").value;
            var output = document.getElementById('output').value;
            var ratio = document.getElementById('ratio').value;
            
            var Batch = new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1);
            close(Batch.WriteLine(file_name+','+output+','+ratio));
      }
    </script>
    
    <br>Please input the Patient list:    <input type="file" id="myFile" name="myFile"/> 
    <br>
    <br>Please specify output file name:  <input type='text' id="output" value="Test-output" size='15'></input>
    <br>
    <br>Please input your matching ratio: <input type='text' id="ratio" value="5" size='5' max="10"></input>
    <br>
    <hr>
    <button onclick='pipeText()'>Go</button>
  </body>
  
</html>

