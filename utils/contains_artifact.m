% A function that determines whether the given signal contains EEG artifact

% Inputs:
%   x - input signal, with dimensions (winLen*sampleRate = num rows, 
%   num_windows*num_channels = num cols)
%   fs - sampling frequency

% Outputs:
%   out - a boolean indicating whether the given signal contains EEG artifact

function [data_output, inds_removed] = contains_artifact(x, winLen, channel_num)
    % We want to analyze columns to reject specific electrodes and
    % ultimately segments made up of 18 channels that contain unacceptable
    % levels of artifact.
    
    % Set threshold
    amplitude_threshold = 500; %microvolts
    LL_threshold = 1000*winLen;
    
    % We begin by screening channels for amplitude abnormalities
    amplitude_high = max(abs(x))>amplitude_threshold;
    
    % We then screen channels for bandpower abnormalities
    Line_length = sum(abs(diff(x)));
    LL_high = Line_length>LL_threshold;
    
    % Add everything together
    all_bad_chs = find(amplitude_high+LL_high);
    
    % CHECK THIS
    data_output = x;
    
    inds_removed = all_bad_chs;
    
    data_output(:,inds_removed) = 0;
    
end