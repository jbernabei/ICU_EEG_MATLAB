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
    
    other_indx = 0;

    for i = 1:Num_Clusters
        if(sum(idx==i)<3)
            if(other_indx ~= 0)
                idx(find(idx==i)) = other_indx;
            else
                other_indx = i;
            end
        end
    end
    
    %This makes sure to correct the centroid of the outlier group;
    if (other_indx>0)
        Centroids(other_indx,:) = mean(normSampleStack(find(idx==other_indx),:));
    end
    
    Centroids(find(sum([1:1:Num_Clusters]== idx)==0),:) = 100;
    
    %justMeansStack = normSampleStack(:,find(mod([1:1:54],3)==2));
    %coeffs = pca(justMeansStack);
    % colorVec = ["r","b","k", "g", "c", "m","y"];
    %LoadingColOne = justMeansStack*coeffs(:,1);
    %LoadingColTwo = justMeansStack*coeffs(:,2);
    %colorVec = linspace(1,10,7)
    %cLabels = colorVec(idx);
    %scatter(LoadingColOne,LoadingColTwo,[],cLabels','filled');
    %xlabel('First Principal Component (Normalized Feature Means)')
    %ylabel('Second Principal Component (Normalized Feature Means)')
    %legend('Ground Truth Seizures','Data Reduction System Attention')
    %title('Patient Clusters by Normalized Feature Means')
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

