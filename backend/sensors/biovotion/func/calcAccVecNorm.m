function [ x, norm, outlierIndices ] = calcAccVecNorm( dsout )
%CALCACCVECNORM Summary of this function goes here
%   Detailed explanation goes here

    x( :, 1 ) = dsout.Sensors.data( :, 3 );
    x( :, 2 ) = dsout.Sensors.data( :, 4 );
    x( :, 3 ) = dsout.Sensors.data( :, 5 );
    
    norm = sqrt( sum( x .^2, 2 ) );
    
    outlierIndices = abs( norm - mean( norm ) ) > 3 * std( norm );
end
