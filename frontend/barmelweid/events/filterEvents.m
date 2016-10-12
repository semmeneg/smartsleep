function [ filteredEvents ] = filterEvents( events, filterEventClasses )
%FILTEREVENTS Summary of this function goes here
%   Detailed explanation goes here

    filteredEvents = events; 
    eventCount = length( events.time );

    removeIndices = [];
    
    for i = 1 : eventCount
        eventName = events.names{ i };
        eventNameIdx = findStrInCell( filterEventClasses, eventName );
        
        if ( isempty( eventNameIdx ) )
            removeIndices( end + 1 ) = i;
        end
    end
    
    filteredEvents.names( removeIndices ) = [];
    filteredEvents.time( removeIndices ) = [];
    filteredEvents.durations( removeIndices ) = [];
end
