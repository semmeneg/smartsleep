function [ dsout ] = normalizeBV( dsout, i )
%NORMALIZE Summary of this function goes here
%   Detailed explanation goes here

    % transforms data => mean will be 0 (or very close to e.g. 5.6536e-16)
    % and std will be 1.0
    dsout.Sensors.data( :, i ) = ( dsout.Sensors.data( :, i ) - mean( dsout.Sensors.data( :, i ) ) ) / std( dsout.Sensors.data( :, i ) );
end

