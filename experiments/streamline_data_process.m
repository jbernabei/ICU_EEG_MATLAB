
%% Set up workspace
clear all; % Clear all data structures
load all_annots.mat; % Annotations from all patients marked on portal
iEEGid = 'jbernabei'; % Change this for different user
iEEGpw = 'jbe_ieeglogin.bin'; % Change this for different user

% Set up channels
channels_original_patients = [3 4 5 9 10 11 12 13 14 16 20 21 23 24 31 32 33 34];
num_patients = size(all_annots,2); % Get number of patients

window_Length = 5; % 5 second windows
window_Disp = 5; % currently non overlapping b/c displacement is 5 seconds
pt_list = [1];

%% Get data for all specified patients
for i = pt_list
    % Display message for patient processing
    fprintf('Processing patient %s ',all_annots(i).patient)
    % Select channel indices based on which patient we are using
    if ~isempty(all_annots(i).sz_start)
        channels = channels_original_patients; %all patients with 'RID' ID on portal
        fprintf('in which there are %d seizures\n',length(all_annots(i).sz_start))
    else
        channels = channels_new_patients; %all patients with 'CNT' ID on portal
        fprintf('in which there are no seizures\n')
    end
    
    % Connect to the IEEG session, and find the number of seizures on the
    % associated dataset.
    session = IEEGSession(all_annots(i).patient, iEEGid, iEEGpw); % Initiate IEEG session
    sampleRate = session.data.sampleRate; % Sampling rate
    sz_num = length(all_annots(i).sz_start); % Get number of seizures
    dataset_length = session.data.rawChannels(1).get_tsdetails.getDuration*1e-06;
    
    % Get a vector of all times from 1 to the total number of seconds in
    % the recording
    all_intervals = [1:(dataset_length)];
    
    % Create patient-specific vectors of all times that contain seizures,
    % skipping this step if the patient is seizure free
    if ~isempty(all_annots(i).sz_start)
        % Get seizure interval times
        a = 0;
        augmentedlabelSeizureVector(i).data = [];
        for j = 1:sz_num
            a = a+1;
            int_length = length([all_annots(i).sz_start(j):all_annots(i).sz_stop(j)]);
            intervals_SZ(i).data(a:(a+int_length-1)) = [all_annots(i).sz_start(j):all_annots(i).sz_stop(j)];
            a = a+int_length-1;
        end

        % Get interictal interval times, including pre-seizure beginning data
        int_length = length([1:all_annots(i).sz_start(1)]);
        intervals_II(i).data = setdiff(all_intervals,intervals_SZ(i).data);
        fprintf('There are %d seconds worth of seizures in this patient\n',length(intervals_SZ(i).data))
    else
        % If the patient is seizure free the 'interictal' intervals are
        % simply that of the entire recording
        intervals_II(i).data = all_intervals;
    end
    fprintf('There are %d seconds worth of non-seizure data in this patient\n',length(intervals_II(i).data))
    
    
    % In this section, we find the duration of the dataset in terms of
    % number of samples, then we establish that we'd like to pull 1 hours
    % of data from the portal per call. We then make repeated calls to the
    % portal until there is less than one call of 1 hour's worth of data
    % left or we have 24 hours of total data. 
    durationInSamples = floor(session.data.rawChannels(1).get_tsdetails.getDuration*1e-06*sampleRate);
    chunk_size = 1;
    howMuchData = - chunk_size*60*60*sampleRate - 1;
    hourCount = 0;
    data_with_NaN(i).data = [];
    data_with_NaN(i).times = [];
    draw = 0;
    enough_data = 0;
    max_hours = 24;
    
    while (howMuchData < (durationInSamples - chunk_size*60*60*sampleRate)) && enough_data ==0
        draw = draw +1; % Update how many draws are being made from the data
        fprintf('Acquiring block %d of length %d hours\n',draw,chunk_size)
        % Check if greater than 8 hours of data are being pulled
        if ((draw*chunk_size)>=max_hours)
            enough_data = 1;
        end
        
        data_with_NaN(i).data = [data_with_NaN(i).data; session.data.getvalues((hourCount*chunk_size*60*60*sampleRate+1):((hourCount+1)*chunk_size*60*60*sampleRate),channels)];
        data_with_NaN(i).times = [data_with_NaN(i).times, (hourCount*chunk_size*60*60+1/sampleRate):1/sampleRate:((hourCount+1)*chunk_size*60*60)];
        
        hourCount = hourCount+1;
        howMuchData = max(howMuchData,0) + chunk_size*60*60*sampleRate;
    end
    
    fprintf('Pulled a total of %d hours of data\n',(howMuchData./(60*60*sampleRate)))
    fprintf('The raw data matrix has a size of %d by %d\n',size(data_with_NaN(i).data,1),size(data_with_NaN(i).data,2))
    fprintf('The raw time matrix has a size of %d by %d\n',size(data_with_NaN(i).times,1),size(data_with_NaN(i).times,2))
    

    % Establish feature vector. The size of this is
    % (sampleRate*dataset_time) x 1
    data_clip(i).labels = zeros(max(size(data_with_NaN(i).data)),1);
    
    % Assign seizure intervals 
    if ~isempty(all_annots(i).sz_start)
        % Find overlap of data with seizure intervals to assign labels
        % correctly - each data point will have a label associated
        [IB] = find(ismember(floor(data_with_NaN(i).times),(intervals_SZ(i).data))==1);
        data_clip(i).labels(IB) = 1;
    end
    
    

    % Remove NaNs from data
    [placeholder_data, indices] = rmmissing(data_with_NaN(i).data);
    data_clip(i).data = placeholder_data;
    if sum(data_clip(i).labels(indices))>0
         fprintf('WARNING: Seizure was incorrectly recognized as artifact! (from NaNs)\n')
    end
    data_clip(i).labels(indices) = []; % remove indices from labels for which data has NaNs
    data_clip(i).data(find(isnan(data_clip(i).data))) = 0;
    
    fprintf('After removing NaNs:\n')
    fprintf('The raw data matrix has a size of %d by %d\n',size(data_clip(i).data,1),size(data_clip(i).data,2))
    fprintf('The label matrix has a size of %d by %d\n',size(data_clip(i).labels,1),size(data_clip(i).labels,2))
    
    
    
    
    % Use moving window function to calculate features
    [chan_Feat, num_removed, processed_labels] =  moving_Window(data_clip(i).data, sampleRate, window_Length, data_clip(i).labels);
    
    feats{i} = chan_Feat;
    labelSeizureVector{i} = processed_labels;
    
    fprintf('After calculating features:\n')
    fprintf('The feature matrix has a size of %d by %d\n',size(chan_Feat,1),size(chan_Feat,2))
    fprintf('The label matrix has a size of %d by %d\n',size(processed_labels,1),size(processed_labels,2))

    
    
    
    figure(2*(i-1)+1);clf;
    for g = 1:16
        subplot(4,4,g)
        plot(chan_Feat(g,:),'ko')
    end
    figure(2*i);clf;
    plot(processed_labels,'ko')

end

feats;
labelSeizureVector;

%save(sprintf('feats_%d_%d.mat',first_patient,last_patient),'feats')
%save(sprintf('labels_%d_%d.mat',first_patient,last_patient),'labelSeizureVector')




