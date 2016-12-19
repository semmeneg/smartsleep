function output = myupsample(data,factor)
% SYNTAX: output = myupsample(data,factor)
% Upsamples rows in DATA by an integer FACTOR. Elements are copied instead 
% of inserting zeros (like matlab's function upsample.m).
%
% INPUTS: 
%       DATA - vector or matrix.
%       FACTOR - integer
%
% OUTPUT: 
%       OUTPUT - upsampled data. 
%
% Created by Martin Längkvist, 2012

output = reshape(repmat(data,1,factor)',size(data,2),size(data,1)*factor)';

end