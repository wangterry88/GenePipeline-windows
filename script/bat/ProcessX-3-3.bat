<!-- :
:: textSubmitter.bat
@echo off

for /f "tokens=1-3 delims=," %%a in ('mshta.exe "%~f0"') do (
	set "project=%~1"
  set "gwas_filename=%%a"
  set "outname_plot=%%b"
	set "outname_sigt=%%c"
)

cd /d %~dp0
cd /d ..\..\

.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\3.GWAS+PRS\Step2.GWAS_plot.R %gwas_filename% %outname_plot% %outname_sigt% %project%

.\tools\plink.exe --annotate .\Result\%project%\GWAS\%outname_sigt%.PRS.Sig-0.05.txt prune minimal ranges=.\tools\annotation_file\glist-hg38 --out .\Result\%project%\GWAS\%outname_sigt%.txt

.\R\R-4.1.1\bin\Rscript.exe .\script\Rscript\3.GWAS+PRS\Step3.GWAS_Gene_plot.R .\Result\%project%\GWAS\%outname_sigt%.txt.annot %outname_sigt% %project%

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
        
            var gwas_filename = document.getElementById("myFile").value;
            var outname_plot=document.getElementById('outname_plot').value;
			var outname_sigt=document.getElementById('outname_sigt').value;
			
            var Batch = new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1);
            close(Batch.WriteLine(gwas_filename+','+outname_plot+','+outname_sigt));
      }
    </script>

    <br>Please input GWAS result file (Example_GWAS.glm.logistic): <input type="file" id="myFile" name="myFile"/> 
    <br>
    <br>Please input GWAS plot name (Short Name): <input value="GWAS-Plot"  type='text' id='outname_plot' size='15' ></input>
    <br>
    <br>Please input PRS summary Name (Short Name): <input value="GWAS-Sig"  type='text' id='outname_sigt' size='15' ></input>
    <br>
    <hr>
    <button onclick='pipeText()'>Go</button>
  </body>
</html>