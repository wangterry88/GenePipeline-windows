# GenePipeline_ver1.0

### Demo of this program: `Demo.md`

Version (ver1.0):

Release date: 2023/07/14


# 1. Basic instructions

###  This software is the analysis process for calculating the gene chip in the affiliated hospital of China

###  This software uses R (ver4.1.1) and Batch shell operating environment.

###  This software analysis uses the following software:

##      A. plink (PLINK v1.90b7 64-bit (16 Jan 2023))

##      B. plink2 (PLINK v2.00a5 64-bit (21 Jun 2023))

##      C. PRSice-2 (PRSice-2 2021-09-20 (v2.3.5))

## - Minimum system requirements:

     -OS: Windows/7/8/10/11

     -Processor: Intel Core i5-4460 / AMD FX-8320

     - RAM: 8GB

     - Hard disk space: 10 GB

     -Internet: Internet connection

     -Resolution: 1024*768



# 2. Main functions

### - 1. TPMI Chip Check: Calculate the number of gene chips corresponding to the patient list input by the user.

### - 2. GWAS : Execute the GWAS analysis process.

### - 3. GWAS + PRS : Execute the GWAS + PRS analysis process.

### - 4. PGS Catalog : Execute and confirm the PGS Catalog PRS model.

# 3. Additional files

### - 0. `.\tools` Folder: All analysis related software and files.

### - 1. `\tools\annotation_file\glist-hg38` : SNP mapping to gene file (genome build 38).

### - 2. `\tools\zip\` : The source executable file (zip compressed file) of the computing software.

### - 3. `\tools\plink.exe` : The executable file of plink software.

### - 4. `\tools\plink2.exe` : The executable file of plink2 software.

### - 5. `\tools\PRSice.R` : R file of PRSice-2 software.

### - 6. `\tools\PRSice_win64.exe` : The executable file of PRSice-2 software.

# 4. How to execute 

- Click the shortcut: `GenePipeline_ver1.0` in the root directory to execute it.
