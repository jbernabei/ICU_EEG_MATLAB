function [Ypredict, Ytest] = test_Model(patients, szModel, iEEGid, iEEGpw, interval, channels, annots)
% test_Model.m
%   
%   Inputs:
%    
%       patients:   Patient ID #s from the appropriate iEEG.org portal base
%       szModel:    The actual model used
%       iEEGid:     iEEG.org portal login information
%       iEEGpw:     Pw file
%       interval:   time length interval
%       channels:   which channels are used
%       annots:     sz start and end markings on portal for each patient
%    
%   Output:
%    
%       Ypredict:   Predicted labels
%       Ytest:      Real labels
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
params.seizure_start_name = 'szo'; % Change this for different seizure onset labels
params.seizure_end_name = 'sze'; % Change this for different seizure end labels
params.interval = interval; %seconds, Change this for different desired analysis windows
params.channels = channels; % Change this for different desired channels

% Get other basic params
studyNo = numel(params.datasetID);
channelNo = length(params.channels);
Fs = session.data.sampleRate;

%% Get seizure start, end times, dataset durations
for i = 1:studyNo
    [allEvents(i).data, timesUSec(i).data, channels(i).data] = getAnnotations(session.data(i),'Imported Natus annotations'); %timesUSec is structured as [start time; stop time} in row for for each annotation
    [dataset_id(i).data, dataset_duration(i).data] = getAllDurations(session.data(i));
end

%% Reshape and reformat seizure start & end data


%% Get all interval times for analysis

%% Get FEATURES
% Pre allocate space
for i = 1:studyNo
     featMatrix(i).data = zeros(1000,params.numFeats); %just a placeholder
end

% Calculate features
for i = 1:studyNo
    for j = 1:1000 %1:length(intervalTimesII(i).data)
        featMatrix(i).data(j,:) = get_Features(session.data(i).getvalues((ceil(intervalTimesII(i).data(j)*Fs)):(ceil((intervalTimesII(i).data(j)+params.interval)*Fs)-1), params.channels)); 
    end
end

%% Process calculated features into Xtest and Ytest
Xtest = [newfeatMatrixSZ; newfeatMatrixII];
Ytest = [ones(size(newfeatMatrixSZ,1),1); zeros(size(newfeatMatrixII,1),1)];
%% Test model
Ypredict = str2num(cell2mat(predict(mdl,Xtest)))
end