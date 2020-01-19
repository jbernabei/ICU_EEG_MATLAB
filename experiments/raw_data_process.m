clear all
load all_annots_131.mat; % Annotations from all patients marked on portal

all_annots_old = all_annots;
clear all_annots

 % Get number of patients

unique_sz_free_pts = sort([694,684,686,710,726,748,689,700,782,706,751,774,...
    702,773,705,690,740,741,765,717,775,715,698,733,743,695,750,687,...
    716,724,776,722,691,734,757,723,729,737,720,685,730,711,701,732,...
    688,725,692,708,713,742,731,758,778]); %CNT numbers

AMS = {'CNT782', 'CNT706', 'CNT698', 'CNT733', 'CNT734', 'CNT757', 'CNT737','RID0069','RID242_fad1c900','RID0074','RID255_1d400f18'};
ICH = {'CNT751', 'CNT702', 'CNT773', 'CNT690', 'CNT740', 'CNT741', 'CNT765', 'CNT717', 'CNT750', 'CNT708', 'CNT742', 'CNT731', 'CNT778','RID0068','RID0073'};
Convulsion_seizure = {'CNT710', 'CNT700', 'CNT715', 'CNT691', 'CNT720','RID0061','RID0062','RID0063','RID0064','RID0066','RID0067','RID0070','RID0071','RID0072','RID0075','RID235_1d807e48','RID236_1243a44a','RID237_e831bb2a','RID238_02958e77','RID239_cab4097d','RID240_68002bbe','RID241_76a88289','RID243_22697f2e','RID245_62fa9ed1','RID246_05b914d1','RID247_20aaf43e','RID257_5e2a16b8'};
Other = {'CNT694', 'CNT726', 'CNT705', 'CNT724', 'CNT776', 'CNT729', 'CNT685', 'CNT730', 'CNT732', 'CNT713','RID244_2aa72934','CNT689', 'CNT774', 'CNT775', 'CNT695', 'CNT687', 'CNT723', 'CNT701', 'CNT688', 'CNT758','CNT684', 'CNT686', 'CNT748', 'CNT722', 'CNT692','CNT743', 'CNT716', 'CNT711', 'CNT725'};

for i = 1:32
    all_annots(i) = all_annots_old(i);
end

for i = 1:32
    if sum(strcmp(AMS,all_annots(i).patient))>0
        all_annots(i).type = 1;
    elseif sum(strcmp(ICH,all_annots(i).patient))>0
        all_annots(i).type = 2;
    elseif sum(strcmp(Convulsion_seizure,all_annots(i).patient))>0
        all_annots(i).type = 3;
    else
        all_annots(i).type = 4;
    end
end

a = 32;

for i = 33:131
    for j = 1:length(unique_sz_free_pts)
    if strcmp(sprintf('CNT%d',unique_sz_free_pts(j)),all_annots_old(i).patient)
        a = a+1
        all_annots_placehold = all_annots_old(i);
        if sum(strcmp(AMS,all_annots_old(i).patient))>0
            all_annots_placehold.type = 1;
            all_annots(a) = all_annots_placehold;
        elseif sum(strcmp(ICH,all_annots_old(i).patient))>0
            all_annots_placehold.type = 2;
            all_annots(a) = all_annots_placehold;
        elseif sum(strcmp(Convulsion_seizure,all_annots_old(i).patient))>0
            all_annots_placehold.type = 3;
            all_annots(a) = all_annots_placehold;
        else
            all_annots_placehold.type = 4;
            all_annots(a) = all_annots_placehold;
        end
    end
    end
end

save('all_annots_85.mat','all_annots')