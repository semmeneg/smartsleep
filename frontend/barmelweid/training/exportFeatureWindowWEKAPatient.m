function [ patient ] = exportFeatureWindowWEKAPatient( patientPath, patientFolder, ...
    requiredEdfSignals, eventClasses, windowLength, ...
    processEDF, processMSR, processZephyr )
%PROCESSPATIENT Summary of this function goes here
%   Detailed explanation goes here

    patientFullPath = [ patientPath patientFolder '\' ];

    patient = [];
    patient.edf = [];
    patient.msr = [];
    patient.zephyr = [];

    patient.path = patientPath;
    patient.folder = patientFolder;
    patient.fullPath = patientFullPath;
    patient.smartSleepPath = [ patient.fullPath 'SmartSleep\' ];
    patient.msrFiles = [];
    patient.zephyrFile = [];

    if ( processEDF )
        edfDataFolder = [ patient.fullPath 'EDF\' ];
        
        if ( ~ exist( edfDataFolder, 'dir' ) )
           warning( 'Missing EDF-Data folder in %s but EDF-flag set', patient.fullPath );
           
        else
            edfFile = dir( [ edfDataFolder '*.edf' ] );
            patient.edfFile = [ edfDataFolder edfFile.name ];
            
            fprintf( 'Processing EDF %s ...', patient.edfFile );
            
            [ patient.edf ] = edfFeaturesByTimeWindow( patient.edfFile, ...
                requiredEdfSignals, windowLength );
            
            fprintf( 'finished.\n' );
        end
    end
    
    if ( processMSR )
        msrDataFolder = [ patient.fullPath 'MSR\' ];
        
        if ( ~ exist( msrDataFolder, 'dir' ) )
           warning( 'Missing MSR-Data folder in %s but MSR-flag set', patient.fullPath );
           
        else
            msrHandFile = dir( [ msrDataFolder '*HAND.mat' ] );
            msrFootFile = dir( [ msrDataFolder '*FUSS.mat' ] );

            patient.msrFiles = { [ msrDataFolder msrHandFile.name ]; [ msrDataFolder msrFootFile.name ] };
            
            fprintf( 'Processing MSR %s ...', msrDataFolder );
            
            [ patient.msr ] = msrFeaturesByTimeWindow( patient.msrFiles, windowLength );
            
            fprintf( 'finished.\n' );
        end
    end
    
    if ( processZephyr )
        zephyrDataFolder = [ patient.fullPath 'Zephyr\' ];
        
        if ( ~ exist( zephyrDataFolder, 'dir' ) )
           warning( 'Missing Zephyr-Data folder in %s but Zephyr-flag set', patient.fullPath );
           
        else
            zephyrSummaryFile = dir( [ zephyrDataFolder '*Summary.csv' ] );
            patient.zephyrFile = [ zephyrDataFolder zephyrSummaryFile.name ];
            
            fprintf( 'Processing Zephyr %s ...', patient.zephyrFile );
            
            [ patient.zephyr ] = zephyrFeaturesByTimeWindow( patient.zephyrFile, windowLength );
            
            fprintf( 'finished.\n' );
        end
    end

    startTime = [];
    endTime = [];
  
    patient.combinedData = [];
    patient.combinedChannels = [];
    
    if ( ~ isempty( patient.edf ) )
        startTime( end + 1 ) = patient.edf.startTime;
        endTime( end + 1 ) = patient.edf.endTime;
    end
    
    if ( ~ isempty( patient.msr ) )
        startTime( end + 1 ) = patient.msr.startTime;
        endTime( end + 1 ) = patient.msr.endTime;
    end
    
    if ( ~ isempty( patient.zephyr ) )
        startTime( end + 1 ) = patient.zephyr.startTime;
        endTime( end + 1 ) = patient.zephyr.endTime;
    end
    
    if ( isempty( startTime ) );
        warning( 'PATIENT:nodata', 'Patient has no relevant data (EDF, MSR or ZEPHYR) - ignoring patient %s', patientFolder );
        return;
    end
    
    combinedStartTime = max( startTime );
    combinedEndTime = min( endTime );

    relationName = [ patientFolder ' SmartSleep Barmelweid (Windows' ];
    relationName = sprintf( '%s %d) (', relationName, windowLength );
    combinedFileNamePrefix = [ patient.smartSleepPath patientFolder '_WINDOWS'  ];
    combinedFileNamePrefix = sprintf( '%s_%d', combinedFileNamePrefix, windowLength );
    
    if ( ~ isempty( patient.edf ) )
        dataIdx = find( patient.edf.time >= combinedStartTime & patient.edf.time < combinedEndTime );
        
        patient.combinedData = [ patient.combinedData patient.edf.data( dataIdx, : ) ];
        patient.combinedChannels = [ patient.combinedChannels; patient.edf.channels ];
        
        relationName = [ relationName ' EEG ' ];
        combinedFileNamePrefix = [ combinedFileNamePrefix '_EEG' ];
    end
    
    if ( ~ isempty( patient.msr ) )
        dataIdx = find( patient.msr.time >= combinedStartTime & patient.msr.time < combinedEndTime );
        
        patient.combinedData = [ patient.combinedData  patient.msr.data( dataIdx, : ) ];
        patient.combinedChannels = [ patient.combinedChannels; patient.msr.channels ];
        
        relationName = [ relationName ' MSR ' ];
        combinedFileNamePrefix = [ combinedFileNamePrefix '_MSR' ];
    end
    
    if ( ~ isempty( patient.zephyr ) )
        dataIdx = find( patient.zephyr.time >= combinedStartTime & patient.zephyr.time < combinedEndTime );
        
        patient.combinedData = [ patient.combinedData  patient.zephyr.data( dataIdx, : ) ];
        patient.combinedChannels = [ patient.combinedChannels; patient.zephyr.channels ];

        relationName = [ relationName ' ZEPHYR ' ];
        combinedFileNamePrefix = [ combinedFileNamePrefix '_ZEPHYR' ];
    end

    mkdir( patient.smartSleepPath );
    
    save( [ combinedFileNamePrefix '.mat' ], 'patient' );

    relationName = [ relationName ')' ];
    combinedArffFile = [ combinedFileNamePrefix '.arff' ];

    exportGenericToWeka( patient.combinedData, [], eventClasses, ...
        relationName, combinedArffFile, patient.combinedChannels );
end
