function [ModelArray, Precision_Vec, Recall_Vec, patient_in_quant, IsolateInstanceCount] = patient_Clustering(patientFeats, patientLabels)

clustQuantity = 7;

[idx] = Data2Cluster(patientFeats,clustQuantity, true);

F1_Vec = [];
Precision_Vec = [];
Recall_Vec = [];
patient_in_quant = [];
IsolateInstanceCount = [];

other_indx = 0;

for i = 1:clustQuantity
    if(sum(idx==i)<3)
        if(other_indx ~= 0)
            idx(find(idx==i)) = other_indx;
        else
            other_indx = i;
        end
    end
end

ModelArray{1}.data = [];

for cluster = 1:clustQuantity
    if (sum(idx==cluster)==0)
        F1_Vec = [F1_Vec; NaN];
        Precision_Vec = [Precision_Vec; NaN];
        Recall_Vec = [Recall_Vec; NaN];
        patient_in_quant = [patient_in_quant; NaN];
        IsolateInstanceCount = [IsolateInstanceCount; NaN];
        ModelArray{cluster} = [];
        continue
    end
    clusterData{1}.data = [];
    clusterLabels{1}.data = [];
    counter = 0;
    for patient = 1:size(patientFeats,2)
        if isempty(patientFeats{patient})
            continue
        end
        if idx(patient) == cluster
            counter = counter + 1;
            clusterData{counter} = patientFeats{patient};
            clusterLabels{counter} = patientLabels{patient};
        end
    end
    cut = 0.05;
    [F1, Precision, Recall, IsolateInstances, Mdl] = random_Forest(clusterData, clusterLabels, counter, cut);
    F1_Vec = [F1_Vec; F1];
    Precision_Vec = [Precision_Vec; Precision];
    Recall_Vec = [Recall_Vec; Recall];
    patient_in_quant = [patient_in_quant; counter];
    IsolateInstanceCount = [IsolateInstanceCount; IsolateInstances];
    ModelArray{cluster} = Mdl;
    clear clusterData clusterLabels
end

end