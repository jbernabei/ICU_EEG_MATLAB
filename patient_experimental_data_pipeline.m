
% WARNING: This file is deprecated in favor of "patient_clustering_pipeline".

%% Set up workspace
clear all; % Clear all data structures
load all_annots_32.mat; % Annotations from all patients marked on portal
iEEGid = 'cpainter'; % Change this for different user
iEEGpw = 'cpa_ieeglogin.bin'; % Change this for different user
channels = [3 4 5 9 10 11 12 13 14 20 21 23 24 27 31 32 33 34];
num_patients = size(all_annots,2); % Get number of patients

window_Length = 10;
window_Disp = 5;
Num_patients = 1;

%% Get intervals for all patients 
for i = 1:30
    i
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
    
    % Get interictal interval times, including pre-seizure beginning data
    b = 1;
    int_length = length([1:all_annots(i).sz_start(1)]);
    intervals_II(i).data(b:(b+int_length-1)) = [1:all_annots(i).sz_start(1)];
    for j = 1:(sz_num-1)
        b = b+1;
        int_length = length([all_annots(i).sz_stop(j):all_annots(i).sz_start(j+1)]);
        intervals_II(i).data(b:(b+int_length-1)) = [all_annots(i).sz_stop(j):all_annots(i).sz_start(j+1)];
        b = b+int_length-1;
    end
    
    durationInSamples = floor(session.data.rawChannels(1).get_tsdetails.getDuration*1e-06*sampleRate);
    howMuchData = 0;
    hourCount = 0;
    data_with_NaN(i).data = [];
    while (howMuchData < (durationInSamples - 4*60*60*sampleRate))
        data_with_NaN(i).data = [data_with_NaN(i).data; session.data.getvalues((hourCount*4*60*60*sampleRate+1):((hourCount+1)*4*60*60*sampleRate),channels)];
        hourCount = hourCount+1;
        howMuchData = howMuchData + 4*60*60*sampleRate;
    end
    data_with_NaN(i).data = [data_with_NaN(i).data; session.data.getvalues((hourCount*4*60*60*sampleRate+1):durationInSamples, channels)];
        
    sample_counter = 0;
    start_ind{i} = 1;
    ind = 1;
    found_full_15 = 0;
    bad_count = 0;
    while (found_full_15 == 0)
        sample_counter = sample_counter + 1;
        if (sum(isnan(data_with_NaN(i).data(ind,:)))>0)
            bad_count = bad_count + sum(isnan(data_with_NaN(i).data(ind,:)));
            if (bad_count>32)
                sample_counter = 0;
                start_ind{i} = ind + 1;
            end
        end
        if (sample_counter == 15*60*sampleRate)
            found_full_15 = 1;
        end
        ind = ind + 1;
    end
    
    chan_Feat = [];
    data_clip(i).data = data_with_NaN(i).data((start_ind{i} + 0.5*sampleRate*60):end - 10*window_Length,:);
    data_clip(i).data = rmmissing(data_clip(i).data);
    for chan = 1:18
        chan
        chan_Feat(chan,:,:) =  MovingWinFeats(data_clip(i).data(:,chan), sampleRate, window_Length, window_Disp, @get_Features);
    end
    feats{i} = [squeeze(median(chan_Feat)); squeeze(var(chan_Feat)); squeeze(mean(chan_Feat))];
    
    labelSeizureVector{i} = zeros([1,size(feats{i},2)]);
    for k = 1:size(labelSeizureVector{i},2)
        if(sum(intervals_SZ(i).data == (floor(start_ind{i}./sampleRate) + window_Disp*k+floor(window_Length/2))) > 0)
            labelSeizureVector{i}(k) = 1;
        end
    end
    
end

feats
labelSeizureVector






