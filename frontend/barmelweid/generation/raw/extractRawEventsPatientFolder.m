function [ allPatients ] = extractRawEventsPatientFolder( allPatientsPath, ...
    requiredEdfSignals, eventClasses, processEdf, processMsr, processZephyr )
%PROCESSPATIENTS Summary of this function goes here
%   Detailed explanation goes here

    files = dir( [ allPatientsPath 'Patient*' ] );
    dirFlags = [ files.isdir ];
    allPatientFolders = files( dirFlags );

    patientCount = length( allPatientFolders );

    allData = [];
    allLabels = [];
    allPatients = [];

    for i = 1 : patientCount
        patient = extractRawEventsPatient( allPatientsPath, ...
            allPatientFolders( i ).name, ...
            eventClasses, requiredEdfSignals, ...
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

        allPatients{ end + 1 } = patient;
        allLabels = [ allLabels; patient.combinedLabels ];
        allData = [ allData; patient.combinedData ];
    end

    smartSleepPath = [ allPatientsPath 'SmartSleep\Events\' ];
    
    mkdir( smartSleepPath );
    
    eventsCombinedFileNamePrefix = [ smartSleepPath 'allpatients_RAWEVENTS' ];
    matFileName = [ smartSleepPath 'allpatients_RAWEVENTS' ];
    
    if ( processEdf )
        eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_EEG' ];
        matFileName = [ matFileName '_EEG' ];
    end

    if ( processMsr )
        eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_MSR' ];
        matFileName = [ matFileName '_MSR' ];
    end

    if ( processZephyr )
        eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_ZEPHYR' ];
        matFileName = [ matFileName '_ZEPHYR' ];
    end

    matFileName = [ matFileName '.mat' ];
    save( matFileName, 'allPatients' );
end
