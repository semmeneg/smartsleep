function [ combinedArffFile, combinedModelFile, combinedResultFile ] = ...
    trainCombinedData( data, labels, eventClasses, channels, ...
    prefix, outputPath, wekaPath, hasEdf, hasMsr, hasZephyr )
%TRAINCROSSVA Summary of this function goes here
%   Detailed explanation goes here

    eventsRelationName = [ prefix ' Patients SmartSleep (Events ' ];
    eventsCombinedFileNamePrefix = [ outputPath prefix '_EVENTS' ];
    
    if ( hasEdf )
        eventsRelationName = [ eventsRelationName ' EEG ' ];
        eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_EEG' ];
    end

    if ( hasMsr )
        eventsRelationName = [ eventsRelationName ' MSR ' ];
        eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_MSR' ];
    end

    if ( hasZephyr )
        eventsRelationName = [ eventsRelationName ' ZEPHYR ' ];
        eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_ZEPHYR' ];
    end
    
    eventsRelationName = [ eventsRelationName ') Barmelweid' ];
    combinedArffFile = [ eventsCombinedFileNamePrefix '.arff' ];
    combinedModelFile = [ eventsCombinedFileNamePrefix '.model' ];
    combinedResultFile = [ eventsCombinedFileNamePrefix '_WEKARESULT.txt' ];
    
    exportGenericToWeka( data, labels, eventClasses, ...
        eventsRelationName, combinedArffFile, channels );
    trainWEKAModel( wekaPath, combinedArffFile, combinedModelFile, ...
        combinedResultFile );
end
