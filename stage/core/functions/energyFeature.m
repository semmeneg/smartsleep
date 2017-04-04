function [ scalar ] = energyFeature( data, featureInfo )
%ENERGYFEATURE Summary of this function goes here
%   Detailed explanation goes here

    y = fft( data );  

    scalar = sum( y .* conj( y ) / length( data ) ); 
end

