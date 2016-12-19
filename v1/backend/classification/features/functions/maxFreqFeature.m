function [ scalar ] = maxFreqFeature( data, featureInfo )
%ENERGYFEATURE Summary of this function goes here
%   Detailed explanation goes here

    n = length( data{ 1 } );
    y = fft( data{ 1 } );
    nHalf = floor( n/2 );
    
    Fs = ( 1000 * n ) / featureInfo.windowTime;
    P2 = abs(y/n);
    P1 = P2(1:nHalf+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(n/2))/n;
    [v,idx] = max( P1 );

    scalar = f( idx );
end
