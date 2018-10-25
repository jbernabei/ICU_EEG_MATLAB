function [feats] = get_Features(values)

%   get_Features.m
%   
%   Inputs:
%    
%       values:     Values for which features will be calculated.MxN where
%                   each of M rows is a channel of N samples of 
%                   electrophysiologic data.
%    
%   Output:
%    
%       feats:      Returns vector of features for chunk of data
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
%% Do initial data processing
% Get number of channels
channelNo = size(values,2);

% Recalculate a copy of data that has mean subtracted
no_offset_data = values - mean(values,2);

% Calculate root mean square of data 
valuesRms = no_offset_data./rms(no_offset_data,2);

%% Calculate features based on channel correlations
matrix = correlation_Matrix(valuesRms);
cVector = reshape(matrix, 1, []);
varCM = var(cVector);
avgCM = mean(cVector);
%upperCM = cVector(cVector>=(avgCM+sqrt(varCM)));
%lowerCM = cVector(cVector<=(avgCM-sqrt(varCM)));

%% Calculate features based on multitaper power spectral density
[PSD z] = pmtm(valuesRms,4,256,256);
meanmaxPSD = mean(max(PSD));
PSDVector = reshape(PSD, 1, []);
varPSD = var(PSDVector);
avgPSD = mean(PSDVector);
%upperPSD = PSDVector(PSDVector>=(avgPSD+sqrt(varPSD)));
%lowerPSD = PSDVector(PSDVector<=(avgPSD-sqrt(varPSD)));

%% Calculate features based on linelength
llfn = mean(line_Length(valuesRms));
meanmaxLL = max(llfn);
varLL = var(llfn);
avgLL = mean(llfn);
%upperLL = llfn(PSDVector>=(avgLL+sqrt(varLL)));
%lowerLL = llfn(PSDVector<=(avgLL-sqrt(varLL)));

%% Return vector of features
feats = [varCM avgCM  meanmaxPSD varPSD avgPSD meanmaxLL varLL avgLL];
end