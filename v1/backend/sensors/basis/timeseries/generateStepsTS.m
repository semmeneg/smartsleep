function [ stepsTs, stepsDaysTs ] = generateStepsTS( userData )
%GENERATESTEPSTIMESERIES Summary of this function goes here
%   Detailed explanation goes here
    dayCount = length( userData.metrics );
    stepsTs = [];
    index = 1;
    
    for i = 1 : dayCount
        steps = userData.metrics( i ).metrics.steps.values;
        
        for j = 1 : length( steps )
            stepsTs( index ) = steps( j );
            index = index + 1;
        end
        
        stepsDaysTs( i ) = sum( steps );
    end
end
