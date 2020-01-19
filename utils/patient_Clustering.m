%This method takes in the full training set of patients, uses Data2Cluster
%to find their clusters, trains cluster-specific random forest classifiers
%for each cluster using the random_Forest function, and then returns a
%ModelArray of trained classifiers for each cluster, as well as the
%quantity of patients in each training cluster, among other things.

function [ModelArray, Precision_Vec, Recall_Vec, patient_in_quant, IsolateInstanceCount, idx,sampleStack,FeatureMeans,FeatureVars,Centroids] = patient_Clustering(patientFeats, patientLabels, clustQuantity)

%This executes the cluster training process described much more thoroughly
%in Data2Cluster.
clear idx
[idx, sampleStack,FeatureMeans,FeatureVars,Centroids] = Data2Cluster_train(patientFeats,clustQuantity);

F1_Vec = [];
Precision_Vec = [];
Recall_Vec = [];
patient_in_quant = [];
IsolateInstanceCount = [];

ModelArray{1}.data = [];

for cluster = 1:clustQuantity
    if (sum(idx==cluster)==0)
        
        %Below is the recording of summary information, like the number of
        %patients in a given new cluster, that will be reported at the end.
        F1_Vec = [F1_Vec; NaN];
        Precision_Vec = [Precision_Vec; NaN];
        Recall_Vec = [Recall_Vec; NaN];
        patient_in_quant = [patient_in_quant; NaN];
        IsolateInstanceCount = [IsolateInstanceCount; NaN];
        ModelArray{cluster} = [];
        continue
    end
    clusterData{1} = [];
    clusterLabels{1} = [];
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
    cut = 0.02;
    [F1, Precision, Recall, IsolateInstances, Mdl] = random_Forest(clusterData, clusterLabels, counter, cut);
    F1_Vec = [F1_Vec; F1];
    Precision_Vec = [Precision_Vec; Precision];
    Recall_Vec = [Recall_Vec; Recall];
    patient_in_quant = [patient_in_quant; counter];
    IsolateInstanceCount = [IsolateInstanceCount; IsolateInstances];
    ModelArray{cluster} = Mdl;
end

end