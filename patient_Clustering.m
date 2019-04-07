function [patientClusterindices] = patient_Clustering(patientFeats)


for i = 1:size(patientFeats,2)
    summary_statistic1 = mean(patientFeats{i}');
    summary_statistic2 = median(patientFeats{i}');
end

end