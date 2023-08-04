<!-- :
:: textSubmitter.bat
@echo off

for /f "tokens=1-3 delims=," %%a in ('mshta.exe "%~f0"') do (
	set "project=%~1"
  set "filename_gwas=%%a"
  set "filename_prs=%%b"
  set "outname=%%c"
)

cd /d %~dp0
cd /d ..\..\

.\tools\plink2.exe --bfile \\10.23.215.31\new_storage_1\bioinfo\TPMI_Array\TPMI_40W_imputed\TPMI_40W_version1 --maf 0.01 --make-bed --keep %filename_prs% --memory 500000 --threads 120 --no-pheno --out .\Result\%project%\PRS\data\%outname%

.\tools\plink2.exe --bfile \\10.23.215.31\new_storage_1\bioinfo\TPMI_Array\TPMI_40W_imputed\TPMI_40W_version1 --maf 0.01 --covar-name Sex,Age --geno 0.05 --glm firth-fallback hide-covar --hwe 0.00001 --mind 0.1 --ci 0.95 --memory 500000 --threads 120 --pheno-name Pheno --covar %filename_gwas% --pheno %filename_gwas% --out .\Result\%project%\GWAS\%outname%

timeout 1 > nul

exit

-->

<html>
  <head>
    <title>Gene Pipeline(ver1.0)</title>
      Gene Pipeline(ver1.0)<br>
  </head>
  <body>

    <script language='javascript' >
        function pipeText() {
        
            var filename_gwas = document.getElementById("myFile_GWAS").value;
            var filename_prs = document.getElementById("myFile_PRS").value;
            var outname=document.getElementById('outname').value;

            var Batch = new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1);
            close(Batch.WriteLine(filename_gwas+','+filename_prs+','+outname));
      }
    </script>

    <br>Please input GWAS phenotype file (test.GWAS.pheno.txt): <input type="file" id="myFile_GWAS" name="myFile"/> 
    <br>
    <br>Please input PRS phenotype file (test.PRS.pheno.txt): <input type="file" id="myFile_PRS" name="myFile"/> 
    <br>
    <br>Please input GWAS/PRS output Name (Short Name): <input value="Test-output"  type='text' id='outname' size='15' ></input>
    <br>
    <hr>
    <button onclick='pipeText()'>Go</button>
  </body>
</html>