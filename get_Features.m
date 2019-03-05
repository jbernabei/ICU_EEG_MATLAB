function [feats] = get_Features(values,sampleRate)

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

% Do filtering
[b,a] = besself(5,[0.5 40],'bandpass');
[bz, az] = impinvar(b,a,256);
values=filter(bz,az,values);

order = 4;
low1 = 0.5;
high = 50;
sampling = 256;
fs = 256;

% Recalculate a copy of data that has mean subtracted
no_offset_data = values - mean(values,2);

% Calculate root mean square of data 
valuesRms = no_offset_data./rms(no_offset_data,2);

%% Filter for theta band
fcutlow1=4;   %low cut frequency in kHz
fcuthigh1=8;   %high cut frequency in kHz
p1 = bandpower(valuesRms,sampleRate,[fcutlow1 fcuthigh1]);

%% Filter for alpha band
fcutlow2=8;   %low cut frequency in kHz    
fcuthigh2=12;
p2 = bandpower(valuesRms,sampleRate,[fcutlow2 fcuthigh2]);

%% Filter for beta band
fcutlow3=12;   %low cut frequency in kHz
fcuthigh3=25;   %high cut frequency in kHz
p3 = bandpower(valuesRms,sampleRate,[fcutlow3 fcuthigh3]);

%% Filter for 25-40 band
fcutlow4=25;   %low cut frequency in kHz
fcuthigh4=40;   %high cut frequency in kHz
p4 = bandpower(valuesRms,sampleRate,[fcutlow4 fcuthigh4]);

%% Calculate features based on channel correlations
% matrix = correlation_Matrix(valuesRms);
% cVector = reshape(matrix, 1, []);
% varCM = var(cVector);
% avgCM = mean(cVector);
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

%% Calculate wavelet entropy
Entropy = wentropy(valuesRms,'shannon');

%% Return vector of features
feats = [p1 p2 p3 p4 meanmaxLL varLL avgLL Entropy];
end