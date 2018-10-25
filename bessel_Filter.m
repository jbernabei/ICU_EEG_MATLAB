function [f_Data] = bessel_Filter(order,low,high,sampling,data)

%   bessel_Filter.m
%   
%   Inputs:
%    
%       order:       Number of poles in the filter
%       low:         Lower frequency bound in Hz
%       high:        Upper frequency bound in Hz
%       sampling:    Sampling frequency in Hz
%       data:        Input data as a numeric vector
%    
%   Output:
%    
%       f_Data:      Filtered data output as a vector 
%    
%    License:        MIT License
%
%    Author:         John Bernabei
%    Affiliation:    Center for Neuroengineering & Therapeutics
%                    University of Pennsylvania
%                    
%    Website:        www.littlab.seas.upenn.edu
%    Repository:     http://github.com/jbernabei
%    Email:          johnbe@seas.upenn.edu
%
%    Version:        1.0
%    Last Revised:   October 2018
% 


%%  Create lowpass filter

%   Zeros, poles and gain. 'z' is empty since there are no zeros.
[z,p,k] = besselap(order);

%   Convert to transfer function form
[A,B,C,D] = zp2ss(z,p,k);

%%  Bandpass filter calculations

%   Lower and upper bounds for bandpass filter
wlow = low*2*pi;
whigh = high*2*pi;

%   Bandpass filter parameters
Bw = whigh-wlow;
Wo = sqrt(wlow*whigh);

%%  Convert lowpass filter to bandpass filter

%   Convert a lowpass filter to bandpass filter, in statespace form
[At,Bt,Ct,Dt] = lp2bp(A,B,C,D,Wo,Bw);

%   Convert statespace form to transfer function form
[b,a] = ss2tf(At,Bt,Ct,Dt);

%   Create transfer function parameters for bandpass filter
[Ad,Bd,Cd,Dd] = bilinear (At,Bt,Ct,Dt,sampling,low);
[bz,az] = ss2tf(Ad,Bd,Cd,Dd);

%%  Get the data

for i = 1:length(data)
    
    f_Data(i)=b(1)*data(i);
    for j = 1:length(b)-1
        if (i-j)>0
            y(i)=y(i)+b(j+1)*data(i-j)-a(j+1)*y(i-j);
        end
    end

end