DST_ARB_22=DST_ARB_22_LIGHT_0P1HZ_2MW_00001;
DST_ARB_22=CM_Change_STRUCTARRAY_field (DST_ARB_22,'ThresholdRatio',5);
DST_ARB_22=CM_Change_STRUCTARRAY_field (DST_ARB_22,'DiaTypeAnalysis','From center');

a='R:\CM_DISK_9\DATA_RIG28\CM_234_D15_THY_1_CHR2_CONTRASTIM\ARB_21_NO_LIGHT_00001'
DST_ARB_21=CM_Change_STRUCTARRAY_field (DST_ARB_22,'fullFileNameMpd',a);

a='R:\CM_DISK_9\DATA_RIG28\CM_234_D15_THY_1_CHR2_CONTRASTIM\ARB_22_LIGHT_0P1HZ_2MW_00001'
DST_ARB_22=CM_Change_STRUCTARRAY_field (DST_ARB_22,'fullFileNameMpd',a);

a='R:\CM_DISK_9\DATA_RIG28\CM_234_D15_THY_1_CHR2_CONTRASTIM\ARB_23_LIGHT_0P1HZ_2MW_00002'
DST_ARB_23=CM_Change_STRUCTARRAY_field (DST_ARB_22,'fullFileNameMpd',a);

a='R:\CM_DISK_9\DATA_RIG28\CM_234_D15_THY_1_CHR2_CONTRASTIM\ARB_24_LIGHT_0P1HZ_2MW_00001'   
DST_ARB_24=CM_Change_STRUCTARRAY_field (DST_ARB_22,'fullFileNameMpd',a);

a='R:\CM_DISK_9\DATA_RIG28\CM_234_D15_THY_1_CHR2_CONTRASTIM\ARB_26_LIGHT_anterior_0P1HZ_2MW_00001'                           
DST_ARB_26=CM_Change_STRUCTARRAY_field (DST_ARB_22,'fullFileNameMpd',a);

a='R:\CM_DISK_9\DATA_RIG28\CM_234_D15_THY_1_CHR2_CONTRASTIM\ARB_28_LIGHT_anterior_0P1HZ_2MW_00001'
DST_ARB_28=CM_Change_STRUCTARRAY_field (DST_ARB_22,'fullFileNameMpd',a);
a='R:\CM_DISK_9\DATA_RIG28\CM_234_D15_THY_1_CHR2_CONTRASTIM\ARB_29_LIGHT_2x_anterior_0P1HZ_2MW_00001'
DST_ARB_29=CM_Change_STRUCTARRAY_field (DST_ARB_22,'fullFileNameMpd',a);


pathAnalysisHelper_SCANIMAGE (DST_ARB_21);
pathAnalysisHelper_SCANIMAGE (DST_ARB_22);
pathAnalysisHelper_SCANIMAGE (DST_ARB_23);
pathAnalysisHelper_SCANIMAGE (DST_ARB_24);
pathAnalysisHelper_SCANIMAGE (DST_ARB_26);
pathAnalysisHelper_SCANIMAGE (DST_ARB_28);
pathAnalysisHelper_SCANIMAGE (DST_ARB_29);