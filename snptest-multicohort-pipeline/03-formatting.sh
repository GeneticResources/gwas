ADJS="adjusted unadjusted"
CHRS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X_nonPAR"

for FN in ${COHORTS}
do
for ADJ in ${ADJS}
do
for CHR in ${CHRS}
do
	echo Format ${FN} ${CHR} ${ADJ}
	${SCRIPT_DIR}/formatting.pl -i ${DATA_DIR}/${ADJ}/${FN}-chr${CHR}.out -c ${CHR} -o ${DATA_DIR}/${ADJ}/${FN}-chr${CHR}.gwas &
	${SCRIPT_DIR}/wait-perl.sh
done
done
done

echo "Waiting for remaining formatting jobs"
wait

for FN in ${COHORTS}
do
for ADJ in ${ADJS}
do

echo "Combine ${FN} ${ADJ}"
cat ${DATA_DIR}/${ADJ}/${FN}-chr1.gwas >${DATA_DIR}/${ADJ}/${FN}.gwas
CHRS="2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X_nonPAR"
for CHR in ${CHRS}
do
	sed -e '1d' ${DATA_DIR}/${ADJ}/${FN}-chr${CHR}.gwas >>${ADJ}/${FN}.gwas
done
rm ${DATA_DIR}/${ADJ}/${FN}-chr*.gwas

done
done