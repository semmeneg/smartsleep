function [ output_args ] = visualizePAL( data )
%VISUALIZEPAL Summary of this function goes here
%   Detailed explanation goes here

    palTs = calcPALs( data );
    startTime = unixTimeToMatlabTime( data.metrics{ 1, 1 }.starttime );
    
    ts1 = timeseries( palTs );
    ts1.Name = sprintf( ' PAL Ulrich Reimer' );
    ts1.TimeInfo.Units = 'days';
    ts1.TimeInfo.StartDate = datenum( startTime );
    ts1.TimeInfo.Format = 'yyyy-mm-dd';   
    
    figure;
    plot( ts1 );
end

