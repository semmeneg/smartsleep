function [ allPatients ] = exportFeatureWindowWEKAPatientFolder( allPatientsPath, outputFolder, ...
    requiredEdfSignals, eventClasses, windowLength, combineAll, ...
    processEdf, processMsr, processZephyr )
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
    
    for i = 1 : patientCount
        labelAndDataMerger = PatientLablesAndDataMerger();
        patient = labelAndDataMerger.exportFeatureWindowWEKAPatient( allPatientsPath, ...
            allPatientFolders( i ).name, outputFolder, ...
            requiredEdfSignals, eventClasses, ...
            processEdf, processMsr, processZephyr );

        if ( false == combineAll )
            continue;
        end
        
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
        else
            % NOTE: test if patient.combinedChannels match current allChannels
            % should not differ from patient to patient at this point
            if ( false == matchStringCells( allChannels, patient.combinedChannels ) )
                warning( 'PATIENT:channelsMissmatch', ...
                    'Patient %s channels do not match global channels', patient.folder );
            end
        end
        
        allPatients{ end + 1 } = patient;
        allData = [ allData; patient.combinedData ];
        allLabels = [ allLabels; patient.combinedLabels ];
    end

    if ( combineAll )
        
        allCombinedOutputFolder = [ allPatientsPath 'all\2_preprocessed\' outputFolder '\' ];

        mkdir( allCombinedOutputFolder );

        relationName = 'All Patients SmartSleep Barmelweid (Events';
        relationName = sprintf( '%s %d) (', relationName, windowLength );
        combinedFileNamePrefix = [ allCombinedOutputFolder 'allpatients_EVENTS' ];
%         combinedFileNamePrefix = sprintf( '%s_%d', combinedFileNamePrefix, windowLength );

        if ( processEdf )
            relationName = [ relationName ' EEG ' ];
            combinedFileNamePrefix = [ combinedFileNamePrefix '_EEG' ];
        end

        if ( processMsr )
            relationName = [ relationName ' MSR ' ];
            combinedFileNamePrefix = [ combinedFileNamePrefix '_MSR' ];
        end

        if ( processZephyr )
            relationName = [ relationName ' ZEPHYR ' ];
            combinedFileNamePrefix = [ combinedFileNamePrefix '_ZEPHYR' ];
        end

        matFileName = [ combinedFileNamePrefix '.mat' ];
        relationName = [ relationName ') Barmelweid' ];
        combinedArffFile = [ combinedFileNamePrefix '.arff' ];

        save( matFileName, 'allPatients' );

        exportGenericToWeka( allData, allLabels, eventClasses, ...
        relationName, combinedArffFile, allChannels );
    end
end
