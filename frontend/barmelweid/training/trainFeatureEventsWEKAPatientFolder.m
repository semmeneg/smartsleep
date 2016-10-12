function [ allPatients ] = trainFeatureEventsWEKAPatientFolder( allPatientsPath, ...
    wekaPath, deletePreviousOutput, requiredEdfSignals, eventClasses, ...
    arffForEachPatient, processEdf, processMsr, processZephyr )
%PROCESSPATIENTS Summary of this function goes here
%   Detailed explanation goes here

    files = dir( [ allPatientsPath 'Patient*' ] );
    dirFlags = [ files.isdir ];
    allPatientFolders = files( dirFlags );

    patientCount = length( allPatientFolders );

    allData = [];
    allLabels = [];
    allChannels = [];
    allPatients = [];

    if ( arffForEachPatient )
        wekaPathPatients = wekaPath;
    else
        wekaPathPatients = [];
    end

    for i = 1 : patientCount
        patient = trainFeatureEventsWEKAPatient( allPatientsPath, ...
            allPatientFolders( i ).name, wekaPathPatients, ...
            eventClasses, requiredEdfSignals, deletePreviousOutput, ...
            processEdf, processMsr, processZephyr );
       
        % EDF required but patient has no edf-data
        if ( processEdf && isempty( patient.edf ) )
            continue;
        end

        % MSR required but patient has no msr-data
        if ( processMsr && isempty( patient.msr ) )
            continue;
        end

        % ZEPHYR required but patient has no zephyr-data
        if ( processZephyr && isempty( patient.zephyr ) )
            continue;
        end

        % patient has no data at all(e.g. no event-file found), ignore completely 
        if ( isempty( patient.combinedData ) )
            continue;
        end

        if ( isempty( allChannels ) )
            allChannels = patient.combinedChannels;
        end

        allPatients{ end + 1 } = patient;
        allLabels = [ allLabels; patient.combinedLabels ];
        allData = [ allData; patient.combinedData ];
    end

    smartSleepPath = [ allPatientsPath 'SmartSleep\Events\' ];
    
    mkdir( smartSleepPath );
    
    eventsRelationName = 'All Patients SmartSleep (Events ';
    eventsCombinedFileNamePrefix = [ smartSleepPath 'allpatients_EVENTS' ];
    matFileName = [ smartSleepPath 'allpatients_EVENTS' ];
    
    if ( processEdf )
        eventsRelationName = [ eventsRelationName ' EEG ' ];
        eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_EEG' ];
        
        matFileName = [ matFileName '_EEG' ];
    end

    if ( processMsr )
        eventsRelationName = [ eventsRelationName ' MSR ' ];
        eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_MSR' ];

        matFileName = [ matFileName '_MSR' ];
    end

    if ( processZephyr )
        eventsRelationName = [ eventsRelationName ' ZEPHYR ' ];
        eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_ZEPHYR' ];

        matFileName = [ matFileName '_ZEPHYR' ];
    end

    matFileName = [ matFileName '.mat' ];
    save( matFileName, 'allPatients' );
    
    eventsRelationName = [ eventsRelationName ') Barmelweid' ];
    combinedArffFile = [ eventsCombinedFileNamePrefix '.arff' ];
    combinedModelFile = [ eventsCombinedFileNamePrefix '.model' ];
    combinedResultFile = [ eventsCombinedFileNamePrefix '_WEKARESULT.txt' ];
    
    exportGenericToWeka( allData, allLabels, eventClasses, ...
        eventsRelationName, combinedArffFile, allChannels );
    trainWEKAModel( wekaPath, combinedArffFile, combinedModelFile, ...
        combinedResultFile );
end
