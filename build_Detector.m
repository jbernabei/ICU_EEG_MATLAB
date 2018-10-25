% build_Detector.m
%   
%   Inputs:
%    
%       None
%    
%   Output:
%    
%       None
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

clear all
%% Set up basic params
patients_train = {'RID0060','RID0062'};
patients_test = {};
channels = [3 4 5 9 10 11 12 13 14 20 21 23 24 27 31 32 33 34];
interval = 1;
iEEGid = 'jbernabei';
iEEGpw = 'jbe_ieeglogin.bin';
model_type = 1; % If 1 use random forest

% Annotations of seizure onset, seizure offset, for each patient
% Row number corresponds to patient number in patients_train
annots_train = ['szo', 'sze';
                'szo', 'sze'];
            
annots_test = ['szo', 'sze'];

% Train model?
train_bool = 1; % Change to zero to skip

% Test model?
test_bool = 0; % Change to zero to skip

% Generate plots?
plot_bool = 1; % Change to zero to skip

%% Train model
if train_bool==1
    train_Model(patients_train, model_type, iEEGid, iEEGpw, interval, channels, annots_train, plot_bool);
end
%% Test model
if test_bool==1
    test_Model(variables);  
end
%% Perform data reduction

%% Gather statistics

%% Create plots

%% Save analyses 
