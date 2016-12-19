function [ seq ] = calculateSEQ_Max( x, windowWidth )
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
    
    maxSteps = max( x );
    halfMax = maxSteps / 2;
    
    for i = 1 : numSamples
        if ( i + windowWidth - 1 > numSamples )
            break;
        end
        
        observation = 1;
        featureValue = sum( x( i : i + windowWidth - 1 ) );

        if 0 == featureValue ;
            observation = 1;
        elseif ( featureValue > 0 ) && ( featureValue < halfMax )
            observation = 2;
        elseif ( featureValue > halfMax )
            observation = 3;
        end
       
        seq( i ) = observation;
    end
end
