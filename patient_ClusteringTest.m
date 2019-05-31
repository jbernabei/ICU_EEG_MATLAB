function [F1, Precision, Recall, IsolateInstances, Yhat] = patient_ClusteringTest(patientFeats, patientLabels, ModelArray)

clustQuantity = 7;
[idx] = Data2Cluster(patientFeats,clustQuantity, false);

Mdl = ModelArray{idx};
Yguess_cell = Mdl.predict(patientFeats');

Yhat = str2num(cell2mat(Yguess_cell));

IsolateInstances = sum(Yhat')./size(patientLabels,2);

TPrate = sum((Yhat' + patientLabels)==2)./sum(patientLabels);

TNrate = sum((Yhat' + patientLabels)==0)./sum(patientLabels == 0);

Precision = sum((Yhat' + patientLabels)==2)./sum(Yhat');

Recall = sum((Yhat' + patientLabels)==2)./(sum((Yhat' + patientLabels)==2) + sum(((Yhat' == 0)+ (patientLabels==1))==2));

F1 = 2*Precision*Recall/(Recall + Precision);






end