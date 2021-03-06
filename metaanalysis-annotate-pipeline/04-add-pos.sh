ADJS="adjusted unadjusted"
if [ "${SKIP_UNADJUSTED}" == "1" ]
then
        ADJS="adjusted"
fi

for PHENO in ${PHENOTYPE_NAMES}
do


for GROUP in ${METAANALYSIS_GROUPS}
do

for ADJ in ${ADJS}
do

        echo "Add Pos: ${PHENO} ${GROUP} ${ADJ}"
        INFN="${DATA_DIR}/filtered/${PHENO}/gwama-${GROUP}-${ADJ}.out"
        OUT_DIR="${DATA_DIR}/filtered-with-pos/${PHENO}"
        OUT_FN="${OUT_DIR}/gwama-${GROUP}-${ADJ}.out"
        mkdir -p ${OUT_DIR}
        cat ${INFN} | perl ${SCRIPT_DIR}/add-pos-2.pl >> ${OUT_FN} &

        ${SCRIPT_DIR}/wait-perl.sh

done
done
done

echo Waiting for last jobs
wait
