function [ dsout ] = smoothBV( dsout, i, width )
%SMOOTH Summary of this function goes here
%   Detailed explanation goes here

    % moving average - kernel
    kernel = repmat( 1 / width, width, 1 );
    
    % moving average shortens at the beginning and ending
    % TODO: how far? is it width/2 or is it width
    dsout.Sensors.data( floor( width / 2 ) : end - round( width / 2 ), i ) = ...
        conv( dsout.Sensors.data( :, i ), kernel, 'valid' );
end
