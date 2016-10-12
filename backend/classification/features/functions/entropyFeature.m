function [ scalar ] = entropyFeature( data, featureInfo )
%ENTROPYFEATURE Summary of this function goes here
%   Detailed explanation goes here

    scalar = entropy( data{ 1 } );
end

