function [szModel] = train_Model(patients, model_type, iEEGid, iEEGpw, interval, channels, annots, plot_bool)
% train_Model.m
%   
%   Inputs:
%    
%       patients:   Patient ID #s from the appropriate iEEG.org portal base
%       model:      What type of training algorithm will be used
%       iEEGid:     iEEG.org portal login information
%       iEEGpw:     Pw file
%       interval:   time length interval
%       channels:   which channels are used
%       annots:     sz start and end markings on portal for each patient
%    
%   Output:
%    
%       szModel:    Returns model as a .mat file
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
%    Last Revised:  October 2018
% 
%% Start iEEG.org session
params.datasetID = patients; % Change this for different datasets
params.IEEGid = iEEGid;
params.IEEGpwd = iEEGpw;
params.seizure_start_names = annots(1,:); % Change this for different seizure onset labels
params.seizure_end_names = annots(2,:); % Change this for different seizure end labels
params.interval = interval; %seconds, Change this for different desired analysis windows
params.channels = channels; % Change this for different desired channels


session = startSession(params)

% Get other basic params
studyNo = numel(params.datasetID);
channelNo = length(params.channels);
Fs = session.data.sampleRate;

%% Get seizure start, end times, dataset durations
for i = 1:studyNo
    ann_struct(i).data = getEvents(session.data.annLayer,0); 
end

for i = 1:studyNo
    for j = 1:size(ann_struct(i).data,2)
        sz_starts(i).data(j) = strcmp(ann_struct(i).data(j).type,'szo');
        sz_stops(i).data(j) = strcmp(ann_struct(i).data(j).type,'sze');
    end
    sz_start_times(i).data(j) = ann_struct(i).data(sz_starts(i).data==1).start
    sz_stop_times(i).data(j) = ann_struct(i).data(sz_stops(i).data==1).start
end


%% Reshape and reformat seizure start & end data
for i = 1:studyNo
    for j = 1:size(ann_struct(i).data,2)
        sz_starts(i).data(j) = strcmp(ann_struct(i).data(j).type,'szo');
        sz_stops(i).data(j) = strcmp(ann_struct(i).data(j).type,'sze');
    end
end

count_s = 0;
count_e = 0;

for i = 1:studyNo
    for j = 1:size(ann_struct(i).data,2)
        if sz_starts(i).data(j)==1
            count_s = count_s+1;
            start_time(i).data(count_s) = ann_struct(i).data(j).start;
        end
        if sz_stops(i).data(j)==1
            count_e = count_e+1;
            stop_time(i).data(count_e) = ann_struct(i).data(j).start;
        end
    end
end

%% Get all interval times for analysis

% this is a hack change it
ii_offset = -2000;

for i = 1:studyNo
    eventNo(i).data = length(start_time(i).data)
    intervalTimesSZ(i).data = []
    intervalTimesII(i).data = []
    for j = 1:eventNo(i).data
        a(j) = floor(start_time(i).data(j))/(10e5);
        b(j) = floor(stop_time(i).data(j))/(10e5)-interval;
        intervals_SZ = [a(j):interval:b(j)];
        intervals_II = intervals_SZ+ii_offset;
        intervalTimesSZ(i).data = [intervalTimesSZ(i).data, intervals_SZ];
        intervalTimesII(i).data = [intervalTimesII(i).data, intervals_II];
    end
end

%% Get FEATURES
numFeats = 8

% Pre allocate space
for i = 1:studyNo
     featMatrixSZ(i).data = zeros(length(intervalTimesSZ(i).data),numFeats);
     featMatrixII(i).data = zeros(length(intervalTimesII(i).data),numFeats); %just a placeholder
end

% Calculate features
for i = 1:studyNo
    for j = 1:length(intervalTimesSZ(i).data)
        featMatrixSZ(i).data(j,:) = get_Features(session.data(i).getvalues((ceil(intervalTimesSZ(i).data(j)*Fs)):(ceil((intervalTimesSZ(i).data(j)+params.interval)*Fs)-1), params.channels)); 
    end
    for j = 1:length(intervalTimesII(i).data)
        featMatrixII(i).data(j,:) = get_Features(session.data(i).getvalues((ceil(intervalTimesII(i).data(j)*Fs)):(ceil((intervalTimesII(i).data(j)+params.interval)*Fs)-1), params.channels)); 
    end
end

newfeatMatrixSZ = [];
newfeatMatrixII = [];
    
for i = 1:studyNo
    newfeatMatrixSZ = [newfeatMatrixSZ; featMatrixSZ(i).data];
    newfeatMatrixII = [newfeatMatrixII; featMatrixII(i).data];
end

%% Process calculated features into Xtrain and Ytrain
Xtrain = [newfeatMatrixSZ; newfeatMatrixII];
Ytrain = [ones(size(newfeatMatrixSZ,1),1); zeros(size(newfeatMatrixII,1),1)];
%% Train model
if model_type==1
    mdl = TreeBagger(500,Xtrain,Ytrain,'oobpred','On','Method','classification','OOBVarImp','on','cost',[0 1; 1 0]);
end
% Return output 
szModel = mdl

%% Generate plots
if plot_bool == 1
    % plot here
    for i = 1:numFeats
        figure(i);clf
        hold on
        plot(newfeatMatrixSZ(:,i),'rx')
        plot(newfeatMatrixII(:,i),'bo')
    end
end
end