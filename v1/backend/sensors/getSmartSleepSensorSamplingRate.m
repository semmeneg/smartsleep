function [ samplingRate ] = getSmartSleepSensorSamplingRate( sensor )
%GETMSRSAMPLINGRATE Summary of this function goes here
%   Detailed explanation goes here

    startTime = sensor.time( 1 );
    endTime = sensor.time( end );
    samplingRate = ( endTime - startTime ) / length( sensor.time );
    % MEDIAN_OVER_SECONDS = 10;
    % timeAfterTenSec = startTime + ( 1000 * MEDIAN_OVER_SECONDS );
    % idx = find( sensor.time >= timeAfterTenSec, 1 );
    % samplingRate = idx / MEDIAN_OVER_SECONDS;
end
