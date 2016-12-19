function [ basisSensor ] = preprocessBASIS( basisSensor, dayStr )
%PREPROCESSBASIS Summary of this function goes here
%   Detailed explanation goes here

    load( basisSensor.fileName );
    
    for i = 1 : length( basisSensor.channels.names )
        dayIndex = findDayIndex( basisPeakData, dayStr );
        metrics = getfield( basisPeakData.metrics{ 1, dayIndex }, 'metrics' );
        channel = getfield( metrics, basisSensor.channels.names{ i } );

        basisSensor.data( i, : ) = removeNan( channel.values );
    end
    
    starttime = basisPeakData.metrics{ 1, dayIndex }.starttime;
    timezoneOffset = basisPeakData.metrics{ 1, dayIndex }.timezone_history{1,1}.offset;
    
    % note: start-time of basis-peak is in unix-time and does not account
    % for the local timezone => add offset which is given in hours.
    % multiply by 1000 to get milliseconds
    startTimeInMs = ( starttime + ( timezoneOffset * 3600 ) ) * 1000;
    % each entry in the metrics amounts to a 1 minute sample => to
    % transform to milliseconds multiply by 60 to transform to seconds and
    % multiply by 1000 to transform to millseconds
    basisSensor.time = ( 1 : length( basisSensor.data( end, : ) ) ) * 60 * 1000 + startTimeInMs - 3600000; % subtract 1hour to transform to UTC
end