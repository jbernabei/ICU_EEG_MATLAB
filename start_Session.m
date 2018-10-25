function session = start_Session(params)
% train_Model.m
%   
%   Inputs:
%    
%       params
%    
%   Output:
%    
%       session
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
%% Start the IEEG session
session = IEEGSession(params.datasetID, params.IEEGid, params.IEEGpwd);

end
