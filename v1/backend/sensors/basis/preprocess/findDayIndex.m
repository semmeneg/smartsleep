function [ dayIndex ] = findDayIndex( data, dayStr )
%FINDMETRICSBYDAY Summary of this function goes here
%   Detailed explanation goes here

    dayIndex = 0;
    
    for i = 1 : length( data.metrics )
        timeOffset = data.userDetails.tzoffset;
        startTimeLocalUnix = data.metrics{ 1, i }.starttime + timeOffset * 3600;

        startTime = unixTimeToMatlabTime( startTimeLocalUnix );
        startTimeStr = datestr( startTime, 'yyyy-mm-dd' );
    
        if ( true == strcmp( startTimeStr, dayStr ) )
            dayIndex = i;
            break;
        end
    end
end

