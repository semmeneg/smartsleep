function [ sqTs ] = generateSleepingQualityTS( data )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    daysCount = length( data.sleepDetails );
    sqTs = zeros( 1, daysCount );
    index = 1;
    
    for i = 1 : daysCount
        if ( 0 == length( data.sleepDetails{ 1, i }.content.activities ) )
            sqTs( index ) = NaN;
            continue;
        end
        
        longestSleepIndex = 1;
        
        % search for longest sleeping-phase
        for j = 1 : length( data.sleepDetails{ 1, i }.content.activities ); 
            if ( data.sleepDetails{ 1, i }.content.activities{ 1, j }.actual_seconds > ...
                    data.sleepDetails{ 1, i }.content.activities{ 1, longestSleepIndex }.actual_seconds )
                longestSleepIndex = j;
            end
        end
        
        sqTs( index ) = data.sleepDetails{ 1, i }.content.activities{ 1, longestSleepIndex }.sleep.quality / 100;
        index = index + 1;
    end
end

