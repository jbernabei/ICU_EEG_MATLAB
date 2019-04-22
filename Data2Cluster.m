function [idx] = Data2Cluster(patientFeats, Num_Clusters, train)

persistent IsClusterInstantiated
persistent sampleStack
persistent FeatureMeans
persistent FeatureVars
persistent Centroids

if isempty(sampleStack)
    IsClusterInstantiated = 0;
    sampleStack = [];
else
    IsClusterInstantiated = 1;
end

if (train)
    for i = 1:size(patientFeats,2)
        if (isempty(patientFeats{i}))
            continue
        end
        summary_statistic1 = median(patientFeats{i}');
        summary_statistic2 = mean(patientFeats{i}');
        summary_statistic3 = var(patientFeats{i}');
        sampleStack = [sampleStack; summary_statistic1, summary_statistic2, summary_statistic3];
    end
    FeatureMeans = mean(sampleStack);
    FeatureVars = std(sampleStack);
    normSampleStack = normalize(sampleStack);
    [idx,Centroids] = kmeans(normSampleStack,Num_Clusters);
else
    summary_statistic1 = median(patientFeats');
    summary_statistic2 = mean(patientFeats');
    summary_statistic3 = var(patientFeats');
    unNormFeatureVector = [summary_statistic1, summary_statistic2, summary_statistic3];
    zscores = (unNormFeatureVector - FeatureMeans)./FeatureVars;
    distances = sqrt(sum(((Centroids - zscores).^2)'));
    [M,idx] = min(distances);
    idx






end

