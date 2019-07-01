%This function serves two purposes as currently written: It can take a body
%of patient training data and generate k-means clusters for those patients
%that it then stores in persistent variables, and it can take additional
%patients, with a "train=FALSE" input, and find which of the training set
%clusters that patient belongs in. It CANNOT update training set clusters
%with additional patients (if this was attempted the function would simply
%calculate new training set clusters from scratch) but this feature should
%be added.

function [idx] = Data2Cluster(patientFeats, Num_Clusters, train)

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

%The train=TRUE flag is looked for, and if there, meta-distribution
%statistics are found for each patient in the cell array input, and then added to a
%persistent variable called the "sampleStack".
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
    
    %The mean and variance of the Sample Stack is recorded so that it can
    %be used to calculate the z-score, for clustering, of test patients
    %that are given to this function later on.
    FeatureMeans = mean(sampleStack);
    FeatureVars = std(sampleStack);
    
    %The k-means algorithm is run on the z-score of the sampleStack
    %distribution features.
    normSampleStack = normalize(sampleStack);
    [idx,Centroids] = kmeans(normSampleStack,Num_Clusters);
    
    other_indx = 0;

    %Here we check if any clusters have fewer than 3 patients in them, and
    %combine all those that do, as they'll be given their own classifier.
    for i = 1:Num_Clusters
        if(sum(idx==i)<3)
            if(other_indx ~= 0)
                idx(find(idx==i)) = other_indx;
            else
                other_indx = i;
            end
        end
    end
    
    %This makes sure to correct the centroid of the outlier group. We need
    %to recalculate the centroid for this outlier cluster. NOTE: I just
    %noticed that this may actually present a serious bug, as the centroid
    %of the outlier group could be centrally located in the clustering
    %space, casuing patients that shouldn't be grouped into the outlier
    %group to be grouped into it.
    if (other_indx>0)
        Centroids(other_indx,:) = mean(normSampleStack(find(idx==other_indx),:));
    end
    
    Centroids(find(sum([1:1:Num_Clusters]== idx)==0),:) = 100;
    
else
    
    %This is the process for finding the cluster associated with a test
    %patient fed to this method.
    summary_statistic1 = median(patientFeats');
    summary_statistic2 = mean(patientFeats');
    summary_statistic3 = var(patientFeats');
    unNormFeatureVector = [summary_statistic1, summary_statistic2, summary_statistic3];
    
    %Z-score of the meta-distribution statistics is calculated for the
    %patient, such that they can be clustered.
    zscores = (unNormFeatureVector - FeatureMeans)./FeatureVars;
    distances = sqrt(sum(((Centroids - zscores).^2)'));
    [M,idx] = min(distances);
    idx






end

