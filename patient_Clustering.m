function [F1_Vec, Precision_Vec, Recall_Vec, patient_in_quant, IsolateInstanceCount] = patient_Clustering(patientFeats, patientLabels)

sampleStack = [];
clustQuantity = 7;

for i = 1:size(patientFeats,2)
    summary_statistic1 = median(patientFeats{i}');
    summary_statistic2 = mean(patientFeats{i}');
    summary_statistic3 = var(patientFeats{i}');
    sampleStack = [sampleStack; summary_statistic1, summary_statistic2, summary_statistic3];
end


normSampleStack = normalize(sampleStack);
norm_Components = pca(normSampleStack);
PCAdStack = sampleStack*norm_Components(:,1:10);
idx = kmeans(normSampleStack,clustQuantity);

F1_Vec = [];
Precision_Vec = [];
Recall_Vec = [];
patient_in_quant = [];
IsolateInstanceCount = [];

for cluster = 1:clustQuantity
    clusterData{1}.data = [];
    clusterLabels{1}.data = [];
    counter = 0;
    for patient = 1:size(patientFeats,2)
        if idx(patient) == cluster
            counter = counter + 1;
            clusterData{counter} = patientFeats{patient};
            clusterLabels{counter} = patientLabels{patient};
        end
    end
    [F1, Precision, Recall, IsolateInstances] = random_Forest(clusterData, clusterLabels, counter);
    F1_Vec = [F1_Vec; F1];
    Precision_Vec = [Precision_Vec; Precision];
    Recall_Vec = [Recall_Vec; Recall];
    patient_in_quant = [patient_in_quant; counter];
    IsolateInstanceCount = [IsolateInstanceCount; IsolateInstances];
    clear clusterData clusterLabels
end

end