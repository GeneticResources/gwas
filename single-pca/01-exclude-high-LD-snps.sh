/usr/lib/plink/plink \
        --noweb \
        --bfile ${SOURCE_FILE} \
	--exclude ${SCRIPT_DIR}/high-LD-regions.txt \
	--range --indep-pairwise 50 5 0.2 \
	--out ${OUTPUT_DIR}/02-${PREFIX}-exclude-high-LD-snps