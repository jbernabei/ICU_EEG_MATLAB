
%% Set up workspace
clear all; % Clear all data structures
load all_annots_32.mat; % Annotations from all patients marked on portal
iEEGid = 'jbernabei'; % Change this for different user
iEEGpw = 'jbe_ieeglogin.bin'; % Change this for different user
channels = [3 4 5 9 10 11 12 13 14 20 21 23 24 27 31 32 33 34];
num_patients = size(all_annots,2); % Get number of patients

%% Get intervals for all patients 
for i = 1:num_patients
    session = IEEGSession(all_annots(i).patient, iEEGid, iEEGpw); % Initiate IEEG session
    sampleRate = session.data.sampleRate; % Sampling rate
    sz_num = length(all_annots(i).sz_start); % Get number of seizures
    
    % Get seizure interval times
    a = 0;
    for j = 1:sz_num
        a = a+1;
        int_length = length([all_annots(i).sz_start(j):all_annots(i).sz_stop(j)]);
        intervals_SZ(i).data(a:(a+int_length-1)) = [all_annots(i).sz_start(j):all_annots(i).sz_stop(j)];
        a = a+int_length-1;
    end
    
    % Get interictal interval times
    b = 0;
    for j = 1:(sz_num-1)
        b = b+1;
        int_length = length([all_annots(i).sz_stop(j):all_annots(i).sz_start(j+1)]);
        intervals_II(i).data(b:(b+int_length-1)) = [all_annots(i).sz_stop(j):all_annots(i).sz_start(j+1)];
        b = b+int_length-1;
    end
    
end

%% Get initial (15 minute) segments of data

for i = 1:num_patients
    session = IEEGSession(all_annots(i).patient, iEEGid, iEEGpw); % Initiate IEEG session
    sampleRate = session.data.sampleRate; % Sampling rate
    data_clip(i).data = session.data.getvalues(1:(15*60*sampleRate),channels);
end

%% Calculate features
for i = 1:num_patients
    if sum(sum(isnan(data_clip(i).data)))<36000
        data_clip_rm = rmmissing(data_clip(i).data);
        for j = 1:(15*60)
            baseline_features(i).data(j,:) = get_Features(data_clip_rm(((j-1)*sampleRate+1):(sampleRate*j)), sampleRate);
        end
            base_feats_zs =  zscore(baseline_features(i).data(j,:),2);
    end
    i
end

%% Cluster