function [ scalar ] = energyFeature( data, featureInfo )
%ENERGYFEATURE Summary of this function goes here
%   Detailed explanation goes here

    y = fft( data{ 1 } );  

    scalar = sum( y .* conj( y ) / length( data{ 1 } ) ); 
end

