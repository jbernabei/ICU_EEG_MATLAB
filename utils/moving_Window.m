function [features, num_removed, labels] = moving_Window(values, fs, winLen, label_vec)

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
[num_samples, channel_num] = size(values)

num_seconds = num_samples./fs;
num_windows = floor((num_seconds-winLen)./winLen+1);

data_truncate = values([1:num_windows*fs*(winLen)],:);

size(data_truncate)

label_truncate = label_vec([1:num_windows*fs*(winLen)]);

size(label_truncate)

% Then reshape into matrix where each column is data from one channel from
% one segment. This way we can vectorize everything. The shape should be
% winLen*sampleRate = num rows, num_windows*num_channels = num cols
chunked_data = reshape(data_truncate,[winLen.*fs, num_windows.*channel_num]);
chunked_labels = reshape(label_truncate,[winLen.*fs,num_windows]);

processed_chunked_labels = ceil(sum(chunked_labels));

size(processed_chunked_labels)

size(chunked_data)

% We will filter data in a separate function
f_low = 1;
f_high = 20;
filter_chunk_data = filter_channels(chunked_data,fs, f_low, f_high);
size(filter_chunk_data)
find(sum(filter_chunk_data)==0)
%% We then want to check whether each channel contains unacceptable artifact

% We then want to check whether an entire data segment contains
% unacceptable artifact
[processed_chunk_data, inds_removed] = contains_artifact(filter_chunk_data, fs, channel_num);

%% We then want to calculate features
% Call the feature calculation function. Should return a 1 x
% ch*segments*feats vector
raw_feats = single_ch_features(processed_chunk_data,fs);
size(raw_feats)

num_feats = size(raw_feats,2)./(channel_num.*num_windows)

% Reshape into a features x segments shape
reshaped_feats = reshape(raw_feats, num_feats.*channel_num, num_windows);

size(reshaped_feats)

% Post process everything including labels

% Calculate right / left brain average signals
left_channels = [1,4,6,8,11,13,15,17];
right_channels = [2,5,7,9,12,14,16,18];

[processed_features, processed_labels] = feature_post_process(reshaped_feats, num_feats, channel_num, inds_removed, winLen, left_channels, right_channels, processed_chunked_labels);

features = processed_features;
labels = processed_labels;

num_removed = length(inds_removed);
end