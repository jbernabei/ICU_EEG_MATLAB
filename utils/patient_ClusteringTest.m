%This function takes in a specific patient, figures out which of the
%training set clusters they belong in using Data2Cluster, and then uses the
%model from the ModelArray that corresponds to that cluster's index. Note
%that this method needs to be handed an array that included all of the
%pretrained models, and that makes use of a function, Data2Cluster, that
%deals largely with persistent variables, and thus has implicitly been run
%on training data before this function is called.

function [F1, Precision, Recall, IsolateInstances, Yhat, idx, score_vals] = patient_ClusteringTest(patientFeats, patientLabels, ModelArray, FeatureMeans,FeatureVars,Centroids)

%The third input to Data2Cluster here proscribes whether or not the patient
%that's being put into Data2Cluster should affect the cluster definitions.
%We set this to false, because we want the test patient to be sorted into
%the pre-existing clusters.
clear idx
[idx] = Data2Cluster(patientFeats,FeatureMeans,FeatureVars,Centroids);

%The relevant cluster-specific classifier is accessed in ModelArray
Mdl = ModelArray{idx}

if isempty(Mdl)
    for i = 1:length(ModelArray)
        modelabsence(i) = isempty(ModelArray{i});
    end
    Mdl = ModelArray{min(find(modelabsence==0))};
end

%Predictions are generated
[Yguess_cell, score_vals] = predict(Mdl,patientFeats');

Yhat = str2num(cell2mat(Yguess_cell));

%Performance statistics are collected for reporting.

IsolateInstances = sum(Yhat')./size(patientLabels,2);

TPrate = sum((Yhat' + patientLabels)==2)./sum(patientLabels);

TNrate = sum((Yhat' + patientLabels)==0)./sum(patientLabels == 0);

Precision = sum((Yhat' + patientLabels)==2)./sum(Yhat');

Recall = sum((Yhat' + patientLabels)==2)./(sum((Yhat' + patientLabels)==2) + sum(((Yhat' == 0)+ (patientLabels==1))==2));

F1 = 2*Precision*Recall/(Recall + Precision);



end