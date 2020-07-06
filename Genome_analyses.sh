##### Quality check
fastqc -t 20 -o ~/albert/Genome_Ass/FastQC/ *.fastq.gz


##### Trimming with Trimmomatic
#!/bin/bash
output=/home/abdul/albert/Genome_Ass/Trimmed
input=/home/abdul/albert/Genome_Ass/Raw
for i in $input/*_1.fastq.gz;
do
withpath="${i}" filename=${withpath##*/}
base="${filename%*_*.fastq.gz}"
sample_name=`echo "${base}" | awk -F ".fastq.gz" '{print $1}'` 
java -jar ~/tools/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 24 -trimlog $output/"${base}".log $input/"${base}"_1.fastq.gz $input/"${base}"_2.fastq.gz $output/"${base}"_1.trimmed_PE.fastq.gz $output/"${base}"_1.trimmed_SE.fastq.gz $output/"${base}"_2.trimmed_PE.fastq.gz $output/"${base}"_2.trimmed_SE.fastq.gz ILLUMINACLIP:NexteraPE-PE.fa:2:30:10:2:keepBothReads LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36
done

##### Quality check on trimmed data
nohup fastqc -t 20 -o ~/albert/Genome_Ass/FastQC/After *PE.fastq.gz

##### Genome Assembly with Spades
#!/bin/bash
input=/home/abdul/albert/Genome_Ass/Trimmed
for i in $input/*_1.trimmed_PE.fastq.gz;
do
withpath="${i}" filename=${withpath##*/}
base="${filename%*_*1.trimmed_PE.fastq.gz}"
sample_name=`echo "${base}" | awk -F "1.trimmed_PE.fastq.gz" '{print $1}'` 
~/Genome_Assembly/Tools/SPAdes-3.14.0-Linux/bin/./spades.py --threads 20 --careful -1 $input/"${base}"_1.trimmed_PE.fastq.gz -2 $input/"${base}"_2.trimmed_PE.fastq.gz -o /home/abdul/albert/Genome_Ass/Spades/"${base}"
done

#### Statistics with QUAST
/home/abdul/Genome_Assembly/Tools/quast-5.0.2/./quast.py --threads 24 --gene-finding /home/abdul/albert/Genome_Ass/Spades/NLmo22_scaffolds.fasta /home/abdul/albert/Genome_Ass/Spades/NLmo32_scaffolds.fasta -r ~/Genome_Assembly/References/SNP_database/GCF_000196035.1_ASM19603v1_genomic.fna -o ~/albert/Genome_Ass/Quast/


##### Genome Assembly with Skesa
#!/bin/bash
input=/home/abdul/albert/Genome_Ass/Trimmed
for i in $input/*_1.trimmed_PE.fastq.gz;
do
withpath="${i}" filename=${withpath##*/}
base="${filename%*_*1.trimmed_PE.fastq.gz}"
sample_name=`echo "${base}" | awk -F "1.trimmed_PE.fastq.gz" '{print $1}'` 
skesa --fastq $input/"${base}"_1.trimmed_PE.fastq.gz,$input/"${base}"_2.trimmed_PE.fastq.gz --cores 24 --memory 26 > "${base}".skesa.fa
done

#### Statistics with QUAST
/home/abdul/Genome_Assembly/Tools/quast-5.0.2/./quast.py --threads 24 --gene-finding /home/abdul/albert/Genome_Ass/Quast/22070_NLmo32.skesa.fa /home/abdul/albert/Genome_Ass/Quast/22063_NLmo22.skesa.fa -r ~/Genome_Assembly/References/SNP_database/GCF_000196035.1_ASM19603v1_genomic.fna -o /home/abdul/albert/Genome_Ass/Quast/SKESA_compare


##### Genome Annotation with Prokka
#!/bin/bash
input=/home/abdul/albert/Genome_Ass/Skesa
for i in $input/*.skesa.fa;
do
withpath="${i}" filename=${withpath##*/}
base="${filename%*.*skesa.fa}"
sample_name=`echo "${base}" | awk -F "skesa.fa" '{print $1}'` 
prokka --outdir /home/abdul/albert/Genome_Ass/Prokka/Skesa --prefix "${base}" --force --addmrna --addgenes --kingdom Bacteria --genus Listeria --species monocytogenes $input/"${base}".skesa.fa
done


##### Genome Annotation with Artemis 
/home/abdul/anaconda3/bin/art 22063_NLmo22.fsa +22063_NLmo22.gff
/home/abdul/anaconda3/bin/art 22070_NLmo32.fsa +22070_NLmo32.gff
