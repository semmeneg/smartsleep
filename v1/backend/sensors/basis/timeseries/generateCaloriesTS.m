function [ calTs, calDaysTs ] = generateCaloriesTS( userData )
%GENERATECALORIESTIMESERIES Summary of this function goes here
%   Detailed explanation goes here

    dayCount = length( userData.metrics );
    calTs = [];
    index = 1;
    
    for i = 1 : dayCount
        cal = userData.metrics( i ).metrics.calories.values;
        
        for j = 1 : length( cal )
            calTs( index ) = cal( j );
            index = index + 1;
        end
        
        calDaysTs( i ) = sum( cal );
    end
end

