function [ newLabels ] = spuriousFrameDetection( predictedLabels, likelihood )
%SPURIOUSFRAMEDETECTION Summary of this function goes here
%   Detailed explanation goes here

    tpm = ...
        [ 0.9500 0.0100 0.0400 0.0000 0.0000 0.0000 ; ...
          0.0200 0.8500 0.0900 0.0400 0.0000 0.0000 ; ...
          0.0100 0.1200 0.6300 0.1800 0.0300 0.0300 ; ...
          0.0001 0.0700 0.0700 0.8299 0.0200 0.0100 ; ...
          0.0001 0.0100 0.2200 0.3500 0.4099 0.0100 ; ...
          0.0001 0.0100 0.0500 0.0400 0.0000 0.8999 ];
      
    newLabels = predictedLabels;
    
    lMean = mean( likelihood );
    lStd = std( likelihood );
    l2Std = lMean - 2 * lStd;
    l3Std = lMean - 3 * lStd;
    
    rejctIdx = find( likelihood < l3Std );
    
    for i = rejctIdx'
        if ( i == 1 )
            newLabels( rejctIdx ) = 2;
        end
        
        newLabels( rejctIdx ) = newLabels( rejctIdx - 1 );
    end
    
    inspectIdx = find( ( likelihood > l3Std ) & ( likelihood < l2Std ) );
    
    previousState = 2;
    
    for i = inspectIdx'
        if ( i > 1 )
            previousState = newLabels( i - 1 );
        end
        
        newState = newLabels( i );
        transProb = tpm( previousState, newState );
        
        if ( transProb < 0.5 )
            newLabels( inspectIdx ) = previousState;
        end
    end
end
