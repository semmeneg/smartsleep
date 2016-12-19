function [ seq ] = calculateSEQ_Mean( x, windowWidth )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    numSamples = length( x );

    % vector of tokens observed in each window
    % 1 ... zero 
    % 2 ... low
    % 3 ... medium
    % 4 ... high
    % 5 ... very high
    seq = ones( 1, numSamples );
    
    meanValue = mean( x );
    stdValue = std( x );

    for i = 1 : numSamples
        if ( i + windowWidth - 1 > numSamples )
            break;
        end
        
        observation = 1;
        meanWindow = mean( x( i : i + windowWidth - 1 ) );

        if ( meanWindow < meanValue - stdValue )
            observation = 1;
        elseif ( meanWindow >= meanValue - stdValue ) && ( meanWindow < meanValue + stdValue )
            observation = 2;
        elseif ( meanWindow >= meanValue + stdValue )
            observation = 3;
        end
        
        seq( i ) = observation;
    end
end
