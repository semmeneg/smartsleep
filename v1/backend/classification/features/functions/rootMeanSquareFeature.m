function [ scalar ] = rootMeanSquareFeature( data, featureInfo )
%ROOTMEANSQUAREFEATURE Summary of this function goes here
%   Detailed explanation goes here

    % !!!!!! rms function requires Signal Processing Toolbox
%     scalar = rms( str2double(data{ 1 }) );
    
    % Try to use this function
    scalar = sqrt(mean(data{ 1 }.^2)) ;
end

