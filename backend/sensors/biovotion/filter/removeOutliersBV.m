function [ dsout ] = removeOutliersBV( dsout, i )
%REMOVEOUTLIERS Summary of this function goes here
%   Detailed explanation goes here

    allIndices = 1 : size( dsout.Sensors.data( :, i ), 1 );
    
    outlierIndices = abs( dsout.Sensors.data( :, i ) - mean( dsout.Sensors.data( :, i ) ) ) > 3 * std( dsout.Sensors.data( :, i ) );
    dsout.Sensors.data( outlierIndices, i ) = interp1( allIndices( ~outlierIndices ), ...
        dsout.Sensors.data( ~outlierIndices, i ), allIndices( outlierIndices ), 'linear' );
end

