<!-- :
:: textSubmitter.bat
@echo off

	for /f "tokens=1-7 delims=," %%a in ('mshta.exe "%~f0"') do (
	set "project=%~1"
    set "file_name=%%a"
    set "phenotype=%%b"
    set "output=%%c"
    set "ratio=%%d"
    set "data_type=%%e"
    set "code_type=%%f"
    set "matching_type=%%g"
)

cd /d %~dp0
cd /d ..\..\

.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\4.PGSCatlog\Step0.Prepare_folder.R %project%
.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\4.PGSCatlog\Step1.PatientID_to_PGScatlog.R %file_name% %phenotype% %output% %data_type% %code_type% %project%
.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\4.PGSCatlog\Step2.PGS_Data_Caculation.R %output% %ratio% %project% %matching_type%
.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\4.PGSCatlog\Step3.Check_PGS_SNPs.R %data_type% %project% 

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
            var phenotype = document.getElementById('phenotype').value;
            var output = document.getElementById('output').value;
            var ratio = document.getElementById('ratio').value;
            
            if (document.getElementById('30W').checked) {
    			var data_type = document.getElementById('30W').value;
  			} else if (document.getElementById('40W').checked) {
    			var data_type = document.getElementById('40W').value;
  			}
  			
            if (document.getElementById('PGS_Trait').checked) {
    			var code_type = document.getElementById('PGS_Trait').value;
  			} else if (document.getElementById('Phencode_Trait').checked) {
    			var code_type = document.getElementById('Phencode_Trait').value;
  			}
  			
            if (document.getElementById('Perform_Matching').checked) {
    			var matching_type = document.getElementById('Perform_Matching').value;
  			} else if (document.getElementById('Not_Perform_Matching').checked) {
    			var matching_type = document.getElementById('Not_Perform_Matching').value;
  			}
            var Batch = new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1);
            close(Batch.WriteLine(file_name+','+phenotype+','+output+','+ratio+','+data_type+','+code_type+','+matching_type));
      }
    </script>
    
    <br>Please input the Patient list:    <input type="file" id="myFile" name="myFile"/> 
    <br>
    <br>Please input Phenotype name you want to search:  <input type='text' value="stroke" id="phenotype" size='15'></input>
    <br>
    <br>Please specify output PGS file name:  <input type='text' value="Test-Output" id="output" size='15'></input>
    <br>
    <br>Please specify TPMI data type: <input type="radio" id="30W" name="datatype" value="1" checked><label for="30W">30W TPMI data</label>&nbsp;&nbsp;
    								   <input type="radio" id="40W" name="datatype" value="2"><label for="40W">40W TPMI data</label>&nbsp;&nbsp;
    <br>
    <br>Please specify interested code type: <input type="radio" id="PGS_Trait" name="codetype" value="1" checked><label for="PGS_Trait">PGS Trait</label>&nbsp;&nbsp;
    								         <input type="radio" id="Phencode_Trait" name="codetype" value="2"><label for="Phencode_Trait">Phencode Trait</label>&nbsp;&nbsp;
    <br>
    <br>Please input your matching ratio: <input type='text' id="ratio" value="5" size='5' max="10"></input>
    <br>
    <br>Please specify Plot data type : <input type="radio" id="Perform_Matching" name="matching_type" value="1" checked><label for="Perform_Matching">Perform Matching</label>&nbsp;&nbsp;
    								    <input type="radio" id="Not_Perform_Matching" name="matching_type" value="2"><label for="Not_Perform_Matching">Not Perform matching</label>&nbsp;&nbsp;
    <br>
    <hr>
    <button onclick='pipeText()'>Go</button>
  </body>
  
</html>

