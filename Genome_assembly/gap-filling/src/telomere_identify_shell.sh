if [[ $# != 4 ]] ; then
	echo "Usage : $0 id hap[Mat|Pat] genome version"
	exit 1
fi

wk=`pwd`
src=$(cd $(dirname $0);pwd)

id=$1
hap=$2
genome=$3
version=$4

source $src/init.conf

echo "date
source ${ACTIVATE} ${TIDK_ENV}
tidk search  --fasta ${genome} --string  TTAGGG --output ${id}_${hap}.${version}.tidk --dir ./ -w 200
python3 $src/../telomere/tidk2teloRegion.py ${id}_${hap}.${version}.tidk_telomeric_repeat_windows.csv 0.5 > ${id}_${hap}.${version}.telomere_200_0.5.bed
bedtools merge -i ${id}_${hap}.${version}.telomere_200_0.5.bed -d 300|sort -k1,1V -k2n > ${id}_${hap}.${version}.telomere.200_0.5_m300.bed
gzip ${id}_${hap}.${version}.tidk_telomeric_repeat_windows.csv 
date "
