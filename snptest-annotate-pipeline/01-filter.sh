#SNP     chr     position        coded_all       noncoded_all    strand_genome   beta    SE      pval    AF_coded_all    HWE_pval        callrate        n_total imputed used_for_imp    oevar_imp
#  danach: cases_hwe controls_hwe wenn moeglich

ADJS="adjusted unadjusted"
if [ "${SKIP_UNADJUSTED}" == 1 ]
then
	ADJS="adjusted"
fi

for PHENO in ${PHENOTYPE_NAMES}
do

for FN in ${ALL_COHORTS}
do

for ADJ in ${ADJS}
do

	echo "Filter ${PHENO} ${FN} ${ADJ}, min p ${MINP}"
	INFN=`echo ${SNPTEST_OUTPUT_FILE} | sed s/%ADJ%/${ADJ}/g | sed s/%PHEN%/${PHENO}/g | sed s/%COHORT%/${FN}/g`
	OUT_DIR="${DATA_DIR}"
	OUT_FN="${OUT_DIR}/filtered-${FN}-${PHENO}-${ADJ}.gwas"
	mkdir -p ${OUT_DIR}
	head -n 1 ${INFN} > ${OUT_FN}
	export P_BORDER HWE_BORDER MAF_BORDER
	echo "Infile: ${INFN}, Outfile: ${OUT_FN}"
	cat ${INFN} | perl ${SCRIPT_DIR}/filter.pl >> ${OUT_FN} &

	${SCRIPT_DIR}/wait-perl.sh

done
done
done

echo Waiting for last jobs
wait
RC=$?
if [ "$RC" != "0" ];
then
	echo "Error filtering files!"
	exit 9
fi



for PHENO in ${PHENOTYPE_NAMES}
do

for FN in ${ALL_COHORTS}
do

for ADJ in ${ADJS}
do

	echo "Find independent SNPs for ${PHENO} ${FN} ${ADJ}"
	INFN="${OUT_DIR}/filtered-${FN}-${PHENO}-${ADJ}.gwas"
	OUTFN="${OUT_DIR}/independent-${FN}-${PHENO}-${ADJ}.txt"
	Rscript ${SCRIPT_DIR}/myindep.R ${INFN} ${OUTFN} ${SCRIPT_DIR} 2>&1 | tee ${LOG_DIR}/indep-${FN}-${PHENO}-${ADJ}.log

	LZDIR="${OUT_DIR}/locuszoom/${PHENO}/${FN}_${ADJ}"
	mkdir -p "${LZDIR}"
        GWAS_FILE=`echo ${SNPTEST_OUTPUT_FILE} | sed s/%ADJ%/${ADJ}/g | sed s/%PHEN%/${PHENO}/g | sed s/%COHORT%/${FN}/g`
	HITSPEC="${OUTFN}.hitspec"
	FILTER_FILE="${LZDIR}/result_maf_5.gwas"
	echo "LZ Dir: $LZDIR, Input file: ${FILTER_FILE}, Hitspec: ${HITSPEC}"


	echo "Before MAF 5% filter"
	wc -l $GWAS_FILE

#SNP	chr	position	coded_all	noncoded_all	strand_genome	beta	SE	pval	AF_coded_all	HWE_pval	callrate	n_total	imputed	used_for_imp	oevar_imp

	echo "#CHROM	BEGIN	END	MARKER_ID	NS	AC	CALLRATE	MAF	PVALUE	SCORE" > ${FILTER_FILE} 
	cat ${GWAS_FILE} | \
        awk '{ if ($10 > 0.05 && $10 < 0.95) { print $2, "\t", $3, "\t", $3+length(4)-1, "\t", $1, "\t\t\t", $12, "\t", $10, "\t", $9, "\t" } }' \
        >> ${FILTER_FILE}

	echo "After MAF 5% filter and EPACTS conversion"
	wc -l $FILTER_FILE

	echo "Plotting"
	LZ=/data/gwas/bin/locuszoom/bin/locuszoom

	SAVEDIR=`pwd`
	cd $LZDIR
	${LZ}   --epacts ${FILTER_FILE} \
        	--hitspec ${HITSPEC} \
        	--pop EUR \
        	--build hg19 \
        	--source 1000G_March2012 \
        	--gwas-cat whole-cat_significant-only \
        	--plotonly \
        	metalRug=SNPs 2>&1 | tee ${LOG_DIR}/locuszoom-${FN}-${PHENO}-${ADJ}.log

	PDFS=`ls *.pdf`
	PDF_FNS=""
	for PDF in $PDFS
	do	
		PDF_FNS="${PDF_FNS}${PDF} 1 "
	done
	echo "Jam PDFs: ${PDF_FNS}"
	pdfjam -o ${FN}-${PHENO}-${ADJ}_LocusZoom.pdf ${PDF_FNS}

	cd $SAVEDIR	
done
done
done
