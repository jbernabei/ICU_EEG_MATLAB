
%% Set up workspace
clear all; % Clear all data structures
load all_annots_91.mat; % Annotations from all patients marked on portal
iEEGid = 'jbernabei'; % Change this for different user
iEEGpw = 'jbe_ieeglogin.bin'; % Change this for different user

% Set up channels
channels_original_patients = [3 4 5 9 10 11 12 13 14 16 20 21 23 24 31 32 33 34];
% ekg_channels = [7,8]; % might use this eventually
num_patients = size(all_annots,2); % Get number of patients

window_Length = 5; % 5 second windows
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

    end
    
    a = 0
    
    % In this section, we find the duration of the dataset in terms of
    % number of samples, then we establish that we'd like to pull 1 hours
    % of data from the portal per call. We then make repeated calls to the
    % portal until there is less than one call of 1 hour's worth of data
    % left or we have 24 hours of total data. 
   sz_data_with_NaN(i).data = []
    
    for qq = 1:sz_num 
        
        fprintf('pulling data from sz %d',qq)
        data_chunk = all_annots(i).sz_start
        
        sz_data_with_NaN(i).data = [sz_data_with_NaN(i).data; session.data.getvalues((all_annots(i).sz_start(qq)*sampleRate):(all_annots(i).sz_stop(qq)*sampleRate),channels)];
        

    end

    fprintf('The raw data matrix has a size of %d by %d\n',size(sz_data_with_NaN(i).data,1),size(sz_data_with_NaN(i).data,2)) 

    % Remove NaNs from data
    [placeholder_sz_data, indices] = rmmissing(sz_data_with_NaN(i).data);
    sz_data_clip(i).data = placeholder_sz_data;

    sz_data_clip(i).data(find(isnan(sz_data_clip(i).data))) = 0;
    
    fprintf('After removing NaNs:\n')
    fprintf('The raw data matrix has a size of %d by %d\n',size(sz_data_clip(i).data,1),size(sz_data_clip(i).data,2))
    
    % Use moving window function to calculate features
    [chan_Feat,num_removed] =  moving_window_test(sz_data_clip(i).data, sampleRate, window_Length);
    
    %fprintf('Removed %d sub-windows because z score was > 6\n',num_removed)
    feats{i} = chan_Feat;
    labelSeizureVector{i} = ones(size(chan_Feat,2),1);
    
    fprintf('After calculating features:\n')
    fprintf('The feature matrix has a size of %d by %d\n',size(chan_Feat,1),size(chan_Feat,2))
    %fprintf('The label matrix has a size of %d by %d\n',size(processed_labels,1),size(processed_labels,2))

    
    
    
    figure(i);clf;
    subplot(3,3,1)
    plot(chan_Feat(1,:),'ko')
    title('Delta power')
    subplot(3,3,2)
    plot(chan_Feat(2,:),'ko')
    title('Theta power')
    subplot(3,3,3)
    plot(chan_Feat(3,:),'ko')
    title('Alpha power')
    subplot(3,3,4)
    plot(chan_Feat(4,:),'ko')
    title('Beta power')
    subplot(3,3,5)
    plot(chan_Feat(5,:),'ko')
    title('Line length')
    subplot(3,3,6) 
    plot(chan_Feat(6,:),'ko')
    title('Signal envelope')
    subplot(3,3,7)
    plot(chan_Feat(7,:),'ko')
    title('Skewness')
    subplot(3,3,8) 
    plot(chan_Feat(8,:),'ko')
    title('Kurtosis')
    subplot(3,3,9)
    plot(chan_Feat(9,:),'ko')
    title('Synch')
end

feats;
labelSeizureVector;

%save(sprintf('feats_%d_%d.mat',first_patient,last_patient),'feats')
%save(sprintf('labels_%d_%d.mat',first_patient,last_patient),'labelSeizureVector')




