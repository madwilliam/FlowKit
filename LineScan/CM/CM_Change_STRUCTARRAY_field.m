function STAtochange=CM_Change_STRUCTARRAY_field (STAtochange,fieldtochange,newvalue)
countermax=size(STAtochange,2);

for counter=1:1:countermax
    STAtochange{1,counter}.(fieldtochange)=newvalue;
end


% DST_ARB_22_LIGHT_0P1HZ_2MW_00001{1,1}.ThresholdRatio=0.1;
% DST_ARB_22_LIGHT_0P1HZ_2MW_00001{1,2}.ThresholdRatio=0.1;
% DST_ARB_22_LIGHT_0P1HZ_2MW_00001{1,3}.ThresholdRatio=0.1;
% DST_ARB_22_LIGHT_0P1HZ_2MW_00001{1,4}.ThresholdRatio=0.1;
% DST_ARB_22_LIGHT_0P1HZ_2MW_00001{1,5}.ThresholdRatio=0.1;
% DST_ARB_22_LIGHT_0P1HZ_2MW_00001{1,6}.ThresholdRatio=0.1;
% DST_ARB_22_LIGHT_0P1HZ_2MW_00001{1,7}.ThresholdRatio=0.1;
% DST_ARB_22_LIGHT_0P1HZ_2MW_00001{1,8}.ThresholdRatio=0.1;
% DST_ARB_22_LIGHT_0P1HZ_2MW_00001{1,9}.ThresholdRatio=0.1;
% DST_ARB_22_LIGHT_0P1HZ_2MW_00001{1,10}.ThresholdRatio=0.1;
% DST_ARB_22_LIGHT_0P1HZ_2MW_00001{1,11}.ThresholdRatio=0.1;
