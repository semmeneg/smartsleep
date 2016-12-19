function [ featureWindows ] = addLabelsFromEventsToFeatureWindows( featureWindows, events, wantedEventClasses )
%LABELSTOWINDOWSBYEVENTS Summary of this function goes here
%   Detailed explanation goes here

    windowLength = 30;
    windowsCount = length( featureWindows.time );
    labels = nan( windowsCount, 1 );
    
    for i = 1 : windowsCount
        windowStart = featureWindows.time( i );
        windowEnd = windowStart + windowLength;
        
        eventIdx = find( events.time >= windowStart & events.time < windowEnd );
        if ( isempty( eventIdx ) ) 
            continue;
        end
        
        % IMPORTANT: could return more than one index
        eventNames = events.names( eventIdx );
        
        for j = 1 : length( eventNames )
            classIdx = findStrInCell( wantedEventClasses, eventNames{ j } );
            if ( false == isempty( classIdx ) )
                labels( i ) = classIdx;
                break;
            end
        end
    end
    
    featureWindows.labels = labels;
    
    outOfEventIndices = find( isnan( labels ) );
    
    featureWindows.labels( outOfEventIndices ) = [];
    featureWindows.data( outOfEventIndices, : ) = [];
    featureWindows.time( outOfEventIndices ) = [];
    
    if(~isempty(featureWindows.time))
        featureWindows.startTime = featureWindows.time( 1 );
        featureWindows.endTime = featureWindows.time( end );
    else 
        featureWindows = []; % empty, now labeled windows left after timed merge
    end
end
