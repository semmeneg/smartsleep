function [ scalar ] = vecNormFeature( vecData, featureInfo )
%ACCVECNORM Summary of this function goes here
%   Detailed explanation goes here

    scalar = mean( sqrt(sum(vecData{ 1 }.^2,1)) );
end

