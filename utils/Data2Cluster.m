%This function serves two purposes as currently written: It can take a body
%of patient training data and generate k-means clusters for those patients
%that it then stores in persistent variables, and it can take additional
%patients, with a "train=FALSE" input, and find which of the training set
%clusters that patient belongs in. It also can take data with no
%annotations, since annotations aren't dealt with anywhere in the script.
%To add patients to enhance clustering, simply leave the "train" tag as
%"true".

function [idx] = Data2Cluster(patientFeats,FeatureMeans,FeatureVars,Centroids)

%persistent sampleStack
%persistent FeatureMeans
%persistent FeatureVars
%persistent Centroids

%The train=TRUE flag is looked for, and if there, meta-distribution
%statistics are found for each patient in the cell array input, and then added to a
%persistent variable called the "sampleStack".

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






end

