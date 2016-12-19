function [ patient ] = trainFeatureEventsWEKAPatient( patientPath, patientFolder, ...
    wekaPath, eventClasses, requiredEdfSignals, deletePreviousOutput, ...
    includeEDF, includeMSR, includeZephyr )
%PROCESSPATIENT Summary of this function goes here
%   Detailed explanation goes here

    patient = initPatientWithEvents( patientPath, patientFolder, deletePreviousOutput );
    if ( isempty( patient.events ) )
        return;
    end
    
    patient.filteredEvents = filterEvents( patient.events, eventClasses );
    patient.filteredEvents.classes = eventClasses;
    
    patient.combinedData = [];
    patient.combinedLabels = [];
    patient.combinedChannels = [];
    
    includedEventsIntersection = [];
    
    % NOTE: FIRST CHECKING IF ALL DATA IS AVAILABLE
    
    if ( includeEDF )
        edfDataFolder = [ patient.fullPath 'EDF\' ];
        
        if ( ~ exist( edfDataFolder, 'dir' ) )
           warning( 'Missing EDF-Data folder in %s but EDF-flag set', patient.fullPath );
           return;
        end
    end
    
    if ( includeMSR )
        msrDataFolder = [ patient.fullPath 'MSR\' ];
        
        if ( ~ exist( msrDataFolder, 'dir' ) )
           warning( 'Missing MSR-Data folder in %s but MSR-flag set', patient.fullPath );
           return;
        end 
    end
    
    if ( includeZephyr )
        zephyrDataFolder = [ patient.fullPath 'Zephyr\' ];
        
        if ( ~ exist( zephyrDataFolder, 'dir' ) )
           warning( 'Missing Zephyr-Data folder in %s but Zephyr-flag set', patient.fullPath );
           return;
        end
    end
    
    % NOTE: AFTER ALL DATA VAILABLE => PROCESSING
    
    if ( includeEDF )
        edfFile = dir( [ edfDataFolder '*.edf' ] );
        patient.edfFile = [ edfDataFolder edfFile.name ];

        fprintf( 'Processing EDF %s ...', patient.edfFile );

        [ patient.edf ] = edfFeaturesByEvent( patient.edfFile, ...
            requiredEdfSignals, patient.filteredEvents );

        fprintf( 'finished.\n' );
        
        if ( isempty( patient.edf ) || isempty( patient.edf.includedEvents ) ) 
            warning( 'PATIENT:nodata', 'Patient has no EDF data - ignoring patient %s', patientFolder );
            return;
        end
        
        if ( isempty( includedEventsIntersection ) )
            includedEventsIntersection = patient.edf.includedEvents;
        else
            includedEventsIntersection = intersect( patient.edf.includedEvents, includedEventsIntersection );
        end
    end
    
    if ( includeMSR )
        msrHandFile = dir( [ msrDataFolder '*HAND.mat' ] );
        msrFootFile = dir( [ msrDataFolder '*FUSS.mat' ] );

        fprintf( 'Processing MSR %s ...', msrDataFolder );

        patient.msrFiles = { [ msrDataFolder msrHandFile.name ]; [ msrDataFolder msrFootFile.name ] };

        [ patient.msr ] = msrFeaturesByEvent( patient.msrFiles, patient.filteredEvents );

        fprintf( 'finished.\n' );
        
        if ( isempty( patient.msr ) || isempty( patient.msr.includedEvents ) )
            warning( 'PATIENT:nodata', 'Patient has no MSR data - ignoring patient %s', patientFolder );
            return;
        end
        
        if ( isempty( includedEventsIntersection ) )
            includedEventsIntersection = patient.msr.includedEvents;
        else
            includedEventsIntersection = intersect( patient.msr.includedEvents, includedEventsIntersection );
        end
    end
    
    if ( includeZephyr )
        zephyrSummaryFile = dir( [ zephyrDataFolder '*Summary.csv' ] );
        patient.zephyrFile = [ zephyrDataFolder zephyrSummaryFile.name ];

        fprintf( 'Processing Zephyr %s ...', patient.zephyrFile );

        [ patient.zephyr ] = zephyrFeaturesByEvent( patient.zephyrFile, patient.filteredEvents );

        fprintf( 'finished.\n' );
        
        if ( isempty( patient.zephyr ) || isempty( patient.zephyr.includedEvents ) )
            warning( 'PATIENT:nodata', 'Patient has no ZEPHYR data - ignoring patient %s', patientFolder );
            return;
        end
        
        if ( isempty( includedEventsIntersection ) )
            includedEventsIntersection = patient.zephyr.includedEvents;
        else
            includedEventsIntersection = intersect( patient.zephyr.includedEvents, includedEventsIntersection );
        end
    end

    if ( isempty( includedEventsIntersection ) );
        warning( 'PATIENT:nodata', 'Patient has no relevant data (EDF, MSR or ZEPHYR) - ignoring patient %s', patientFolder );
        return;
    end

    eventsRelationName = [ patientFolder ' SmartSleep Barmelweid (Events ' ];
    eventsCombinedFileNamePrefix = [ patient.smartSleepPath patientFolder '_EVENTS' ];
     
    if ( ~ isempty( patient.edf ) )
        patient.combinedData = [ patient.combinedData  patient.edf.data( includedEventsIntersection, : ) ];
        patient.combinedChannels = [ patient.combinedChannels; patient.edf.channels ];
        if ( isempty( patient.combinedLabels ) )
            patient.combinedLabels = patient.edf.labels( includedEventsIntersection );
        end
        eventsRelationName = [ eventsRelationName ' EEG ' ];
        eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_EEG' ];
    end
    
    if ( ~ isempty( patient.msr ) )
        patient.combinedData = [ patient.combinedData  patient.msr.data( includedEventsIntersection, : ) ];
        patient.combinedChannels = [ patient.combinedChannels; patient.msr.channels ]; 
        if ( isempty( patient.combinedLabels ) )
            patient.combinedLabels = patient.msr.labels( includedEventsIntersection );
        end
        eventsRelationName = [ eventsRelationName ' MSR ' ];
        eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_MSR' ];
    end
    
    if ( ~ isempty( patient.zephyr ) )
        patient.combinedData = [ patient.combinedData patient.zephyr.data( includedEventsIntersection, : ) ];
        patient.combinedChannels = [ patient.combinedChannels; patient.zephyr.channels ];
        if ( isempty( patient.combinedLabels ) )
            patient.combinedLabels = patient.zephyr.labels( includedEventsIntersection );
        end
        eventsRelationName = [ eventsRelationName ' ZEPHYR ' ];
        eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_ZEPHYR' ];
    end

    mkdir( patient.smartSleepPath );

    save( [ eventsCombinedFileNamePrefix '.mat' ], 'patient' );

    if ( false == isempty( wekaPath ) )
        eventsRelationName = [ eventsRelationName ') Barmelweid' ];
        combinedArffFile = [ eventsCombinedFileNamePrefix '.arff' ];
        combinedModelFile = [ eventsCombinedFileNamePrefix '.model' ];
        combinedResultFile = [ eventsCombinedFileNamePrefix '_WEKARESULT.txt' ];

        exportGenericToWeka( patient.combinedData, ...
            patient.combinedLabels, eventClasses, ...
            eventsRelationName, combinedArffFile, patient.combinedChannels );
        trainWEKAModel( wekaPath, combinedArffFile, combinedModelFile, ...
            combinedResultFile );
    end
end
