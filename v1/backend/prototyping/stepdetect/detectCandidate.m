function [ Sc ] = detectCandidate( anPre, an, anNext, muA, sigmaA, alpha )
%DETECTCANDIDATE Summary of this function goes here
%   Detailed explanation goes here

    Sc = 0;    % set to intermediate (neither peak or valley)
    
    magnitudeCurrentSample = norm( an );
    magnitudePreviousSample = norm( anPre );
    magnitudeNextSample = norm( anNext );
    
    % NOTE: these are the thresholds that 
    peakThreshold = muA + ( sigmaA / alpha );
    valleyThreshold = muA - ( sigmaA / alpha );
    
    % current samples magnituded has reached the threshold to become a
    % potential peak
    if ( magnitudeCurrentSample >= peakThreshold )
        % current sample is a peak if it is magnitude is larger than the 
        % previous and next sample
        if ( magnitudeCurrentSample > max( [ magnitudePreviousSample, magnitudeNextSample ] ) )
            Sc = 1;
        end
        
    % current samples magnituded has reached the threshold to become a
    % potential valley
    elseif ( magnitudeCurrentSample <= valleyThreshold ) 
        % current sample is a valley if it is magnitude is smaller than the 
        % previous and next sample
        if ( magnitudeCurrentSample < min( [ magnitudePreviousSample, magnitudeNextSample ] ) )
            Sc = -1;
        end
    end
end
