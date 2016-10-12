function [ scalar ] = corrCoefMeanFeature( data, featureInfo )
%CROSSCORRFEATURE Summary of this function goes here
%   Detailed explanation goes here

    wrist = data{ 1 };
    ankle = data{ 2 };
 
    x = mean( wrist, 2 );
    y = mean( ankle, 2 );
    
    c = corrcoef( [ x y ] );
    
    scalar = c( 2, 1 );
end

