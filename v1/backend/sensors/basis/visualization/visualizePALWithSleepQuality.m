function [ output_args ] = visualizePALWithSleepQuality( data )
%VISUALIZEPALWITHSLEEPQUALITY Summary of this function goes here
%   Detailed explanation goes here

    sqTs = generateSleepingQualityTS( data );
    palTs = calcPALs( data );
    t = 1 : length( palTs );

    figure;
    plotyy( t, palTs, t, sqTs );
    title( 'PAL and Sleeping-Quality Ulrich Reimer' );
    legend( 'PAL', 'SQ' );
    
end

