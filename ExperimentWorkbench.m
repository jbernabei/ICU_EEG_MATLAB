
TrainFeats = BigOlFeats;
TrainLabels = BigOlLabels;

index = [7];

for i = 1:size(index,2)
TestFeats{index(i)} = TrainFeats{index};
TestLabels{index(i)} = TrainLabels{index};
TrainFeats(index(i)) = [];
TrainLabels(index(i)) = [];
end

[ModelArray, Precision_Vec, Recall_Vec, patient_in_quant, IsolateInstanceCount] = patient_Clustering(TrainFeats, TrainLabels)

for i = 1:size(index,2)
[F1, Precision, Recall, IsolateInstances] = patient_ClusteringTest(TestFeats{index(i)}, TestLabels{index(i)}, ModelArray)
end
