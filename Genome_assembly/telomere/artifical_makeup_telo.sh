# detect missing telomere and make it up
echo "[INFO]: detect missing telomere and make it up..."
echo "source /slurm/home/zju/zhanglab/yangchentao/miniconda3/bin/activate tidk
tidk search  --fasta ${id}.v3.fasta --string  TTAGGG --output ${id}.v3.telomere.search --dir ./ -w 100
python3 $src/tidk2teloRegion.py ${id}.v3.telomere.search_telomeric_repeat_windows.csv 0.6 > ${id}.v3.telomere_100_0.6.bed
bedtools merge -i ${id}.v3.telomere_100_0.6.bed -d 300|sort -k1,1V -k2n > ${id}.v3.telomere.100_0.6_m300.bed
gzip ${id}.v3.telomere.search_telomeric_repeat_windows.csv " > telomere_search.v3.sh
if [ ! -e ${id}.v3.telomere.100_0.6_m300.bed  ]; then
		sh telomere_search.v3.sh && echo "telomere search done!"
	else
			echo "[INFO]: telomere searching already done, nothing to do"
		fi
		samtools faidx ${id}.v3.fasta
		python3 $src/makeChrEndBed.py ${id}.v3.fasta.fai 1000 > ${id}.v3.fasta.end.bed
		# if the telomere sequence coverage less than 0.6, set it as missing
		bedtools coverage -a ${id}.v3.fasta.end.bed -b ${id}.v3.telomere_100_0.6.bed |awk '$8<0.6' |cut -f 1,4 |sort -k1,1V -k2n > ${id}.v3.fasta.teloMiss.txt
		# extend 5kb telomere sequences; && remove short contigs
		python3 $src/makeupMissedTelo.py ${id}.v3.fasta.teloMiss.txt  ${id}.v3.fasta ${id}.v3
		cd ..
