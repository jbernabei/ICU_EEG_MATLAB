function [processed_features, processed_labels] = feature_post_process(raw_feats, num_feats, channel_num, inds_removed, winLen, left_channels, right_channels, raw_labels)

% raw_feats -> dimensions of rows: num_feats*channel_num
%                            cols: num_windows
% The rows are grouped by feature so all channels corresponding to feature
% one are grouped together first

% num_feats -> simply the number of different features that were calculated

% channel_num -> simply the number of channels

% inds_removed -> the indices of which columns of the original feature
% vector that were removed 

% num_windows -> the number of segments we are calculating

%%
% First we must convert the removed indices to the segment and channel to
% figure out which parts of the raw feature matrix to remove because of
% noise
channel_inds = mod(inds_removed,channel_num);
channel_inds(find(channel_inds==0))=18
segment_inds = ceil(inds_removed./channel_num)

% Check if there is a segment with at least 4 channels missing
% Find seg where there are at least one channel bad
seg_with_bad_ch = unique(segment_inds);

valCount = hist([segment_inds],seg_with_bad_ch);

seg_to_leave_out = seg_with_bad_ch(valCount>4);

% Now we have channel inds and segment inds that we should get rid of, now
% we must propagate this to all features

reduced_feat_matrix = [];

for q = 1:num_feats
    % Get raw features into a chunk for one individual feature
    feature_chunk = raw_feats([((q-1)*channel_num+1):(q*channel_num)],:);
    
    size(feature_chunk)
    
    % Get rid of channel and segment inds
    if ~isempty(channel_inds)
        feature_chunk(channel_inds,segment_inds) = NaN;
    end
    
    % Right and left brain
    right_feat = nanmean(feature_chunk(right_channels,:));
    left_feat = nanmean(feature_chunk(left_channels,:));
    
    reduced_feat_matrix = [reduced_feat_matrix;right_feat;left_feat];
    size(reduced_feat_matrix)
end

reduced_feat_matrix(:,seg_to_leave_out) = [];
processed_labels = raw_labels;

sz_artifact_inds = find(processed_labels(:,seg_to_leave_out)==1);
if ~isempty(sz_artifact_inds)
    for z = 1:length(sz_artifact_inds)
    fprintf('Warning, seizure segment identified as artifact at times %d',sz_artifact_inds(z).*winLen)
    end
end

processed_labels(:,seg_to_leave_out) = [];

processed_features = reduced_feat_matrix;

size(reduced_feat_matrix)
size(processed_labels)

end