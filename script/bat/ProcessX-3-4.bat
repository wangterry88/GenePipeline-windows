<!-- :
:: textSubmitter.bat
@echo off

for /f "tokens=1-4 delims=," %%a in ('mshta.exe "%~f0"') do (
	set "project=%~1"
  set "gwas_filename=%%a"
  set "prs_filename=%%b"
  set "prs_pheno_filename=%%c"
	set "output_name=%%d"

)

cd /d %~dp0
cd /d ..\..\

set prs_filename_process=%prs_filename:~0,-4%

.\R\R-4.1.1\bin\Rscript.exe .\tools\PRSice.R --prsice .\tools\PRSice_win64.exe --base %gwas_filename% --target %prs_filename_process% --binary-target T --pheno %prs_pheno_filename% --pheno-col Pheno --cov %prs_pheno_filename% --cov-col Age,Sex --bar-levels 5e-06,5e-05,0.0001,0.001,0.05,0.1,0.2,0.3,0.4,0.5,1 --stat OR --or --A1 A1 --pvalue P --score std --thread 64 --print-snp --seed 123456789 --quantile 10 --no-default --snp SNP --clump-r2 0.1 --out ./Result/%project%/PRS/result/%output_name%

.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\3.GWAS+PRS\Step4.PRS_plot.R ./Result/%project%/PRS/result/%output_name%.best %prs_pheno_filename% %output_name% %project%

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
        
            var gwas_filename = document.getElementById("myFile_gwas").value;
            var prs_filename = document.getElementById("myFile_prs").value;
            var prs_pheno_filename = document.getElementById("myFile_prs_pheno").value;
			      var output_name=document.getElementById("output").value;
			
            var Batch = new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1);
            close(Batch.WriteLine(gwas_filename+','+prs_filename+','+prs_pheno_filename+','+output_name));
      }
    </script>

    <br>Please input PRS Significant file (Test_PRS.Sig-0.05.txt): <input type="file" id="myFile_gwas" name="myFile"/> 
    <br>
    <br>Please input PRS Target file (Test.bed): <input type="file" id="myFile_prs" name="myFile"/> 
    <br>
    <br>Please input PRS Phenotype file : <input type="file" id="myFile_prs_pheno" name="myFile"/> 
    <br>
    <br>Please input PRS output file name : <input type="text" value="Test-Output" id="output"/> 
    <br>
    <hr>
    <button onclick='pipeText()'>Go</button>
  </body>
</html>