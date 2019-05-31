
clear all
load('NewOlLabels.mat')
load('NewOlFeats.mat')

TrainFeats = BigOlFeats;
TrainLabels = BigOlLabels;

%index = [randsample(32,6)]'; 

index = [15]';

%index = [10,    23,     3,    11,    29,    32]';

TestSize = size(index,2);

for i = 1:size(index,2)
TestFeats{index(i)} = TrainFeats{index(i)};
TestLabels{index(i)} = TrainLabels{index(i)};
end

for i = 1:length(index)
TrainFeats{index(i)} = [];
TrainLabels{index(i)} = [];
end

found_one = true;

while(found_one)
    for counter = 1:length(TrainFeats)
        found_one = false;
        if(isempty(TrainFeats{counter}))
             TrainFeats(counter) = [];
             TrainLabels(counter) = [];
             found_one = true;
             break;
        end
    end
end

[ModelArray, Precision_Vec, Recall_Vec, patient_in_quant, IsolateInstanceCount] = patient_Clustering(TrainFeats, TrainLabels)

avgPrec = 0;
avgIsolateInstances = 0;
avgRecall = 0;
avgF1 = 0;
avgAdRecall = 0;
SmoothMax = 3;

for i = 1:TestSize
[F1, Precision, Recall, IsolateInstances, Yhat] = patient_ClusteringTest(TestFeats{index(i)}, TestLabels{index(i)}, ModelArray);

Ysmooth = Yhat;
    for j = 3:SmoothMax
        [Ysmooth] = VoteFiltering(Ysmooth,j);
    end

[IsolateInstances,TPrate,TNrate,Precision,Recall,F1,AdvRecall] = JustMetrics(Ysmooth,TestLabels{index(i)})
avgPrec = Precision + avgPrec;
avgIsolateInstances = IsolateInstances + avgIsolateInstances;
avgRecall = Recall + avgRecall;
avgF1 = F1 + avgF1;
% AdvRecall = AdvancedRecallMeasure(Yhat,TestLabels{index(i)});
avgAdRecall = AdvRecall + avgAdRecall;
end

avgPrec = avgPrec/TestSize;
avgIsolateInstances = avgIsolateInstances/TestSize;
avgRecall = avgRecall/TestSize;
avgF1 = avgF1/TestSize;
avgAdRecall = avgAdRecall/TestSize;

% [Ysmooth] = VoteFiltering(Yhat,3);
% 
% [IsolateInstances,TPrate,TNrate,Precision,Recall,F1,AdvRecall] = JustMetrics(Yhat,TestLabels{index(i)}')

