function [features, num_removed, new_labels] = moving_window(values, fs, winLen, winDisp, label_vec)

%   moving_Window.m
%   
%   Inputs:
%    
%       values:     Values for which features will be calculated MxN where
%                   each of M rows is a sample of electrophysiologic data
%                   and N are the columns
%           fs:     Sampling rate
%       winLen:     Length of window
%      winDisp:     Displacement from one window to next
%       featFn:     Handle of function to calculate features
%    
%   Output:
%    
%     features:     Features calculated for use in classifier
%    
%    License:       MIT License
%
%    Author:        John Bernabei
%    Affiliation:   Center for Neuroengineering & Therapeutics
%                   University of Pennsylvania
%                    
%    Website:       www.littlab.seas.upenn.edu
%    Repository:    http://github.com/jbernabei
%    Email:         johnbe@seas.upenn.edu
%
%    Version:       1.0
%    Last Revised:  January 2020

%% Prepare data by chunking into segments and filter
% First find how many segments go into full
function [features, num_removed] = moving_window_test(values, fs, winLen,label_vec)

%   moving_Window.m
%   
%   Inputs:
%    
%       values:     Values for which features will be calculated MxN where
%                   each of M rows is a sample of electrophysiologic data
%                   and N are the channels
%           fs:     Sampling rate
%       winLen:     Length of window
%      winDisp:     Displacement from one window to next
%       featFn:     Handle of function to calculate features
%    
%   Output:
%    
%     features:     Features calculated for use in classifier
%    
%    License:       MIT License
%
%    Author:        John Bernabei
%    Affiliation:   Center for Neuroengineering & Therapeutics
%                   University of Pennsylvania
%                    
%    Website:       www.littlab.seas.upenn.edu
%    Repository:    http://github.com/jbernabei
%    Email:         johnbe@seas.upenn.edu
%
%    Version:       1.0
%    Last Revised:  January 2020

%% Prepare data by chunking into segments and filter
% First find how many segments go into full
[num_samples, num_channels] = size(values);

num_seconds = num_samples./fs;
num_windows = floor((num_seconds-winLen)./winLen+1);

data_truncate = values([1:num_windows*fs*(winLen)],:);

size(data_truncate);

% Then reshape into matrix where each column is data from one channel from
% one segment. This way we can vectorize everything. The shape should be
% winLen*sampleRate = num rows, num_windows*num_channels = num cols
chunked_data = reshape(data_truncate,[winLen.*fs, num_windows.*num_channels]);

% We will filter data in a separate function
f_low = 1;
f_high = 20;
filter_chunk_data = filter_channels_streamline(chunked_data,fs, f_low, f_high);

%% We then want to check whether each channel contains unacceptable artifact

% We then want to check whether an entire data segment contains
% unacceptable artifact
[processed_chunk_data, inds_removed] = contains_artifact_streamline(x, fs, channel_num);


%% We then want to calculate features
% Call the feature calculation function. Should return a 1 x
% ch*segments*feats vector
size(filter_chunk_data)
raw_feats = single_ch_features(processed_chunk_data,fs);
size(raw_feats)

% Reshape into a channel_num x features shape
reshaped_feats = reshape(raw_feats, 18, num_windows);

% Calculate right / left brain average signals
left_channels = [1,4,6,8,11,13,15,17];
right_channels = [2,5,7,9,12,14,16,18];

num_removed = [];
features = reshaped_feats;
end