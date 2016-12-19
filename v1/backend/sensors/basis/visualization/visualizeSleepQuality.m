function [ output_args ] = visualizeSleepQuality( data )
%VISUALIZESLEEPQUALITY Summary of this function goes here
%   Detailed explanation goes here

    sqTs = generateSleepingQualityTS( data );
    startTime = unixTimeToMatlabTime( data.metrics{ 1, 1 }.starttime );
    
    ts1 = timeseries( sqTs );
    ts1.Name = sprintf( ' Sleep-Quality Ulrich Reimer' );
    ts1.TimeInfo.Units = 'days';
    ts1.TimeInfo.StartDate = datenum( startTime );
    ts1.TimeInfo.Format = 'yyyy-mm-dd';   
    
    figure;
    plot( ts1 );
end

