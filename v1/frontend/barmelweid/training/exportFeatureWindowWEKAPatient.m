function [ patient ] = exportFeatureWindowWEKAPatient( patientPath, patientFolder, outputFolder, ...
    requiredEdfSignals, eventClasses, windowLength, ...
    processEDF, processMSR, processZephyr )
%PROCESSPATIENT Summary of this function goes here
%   Detailed explanation goes here

    patientFullPath = [ patientPath patientFolder '\' ];

    patient = [];
    patient.edf = [];
    patient.msr = [];
    patient.zephyr = [];
    patient.eventClasses = eventClasses;

    patient.path = patientPath;
    patient.folder = patientFolder;
    patient.rawDataPath = [ patientFullPath '1_raw\'] ;
    patient.preprocessedOutputFolder = [ patientFullPath '2_preprocessed\' outputFolder '\' ];
    patient.msrFiles = [];
    patient.zephyrFile = [];
    
    [ eventFile, events ] = getPatientLabels(patient.rawDataPath);
    
    combinedDataWindowTimes = []; % intersection over all data sources window start times
    
    if(isempty(events) || isempty(events.time))
        return; %no labels available, skip export !
    end
    
    patient.eventFile = eventFile;
    patient.events = events;
          
    % Search for the seconds part of the first event with full window
    % length. The second part is used for the merge/synchronization of the
    % data.
    firstWindowLengthEntryIdx = find(events.durations == windowLength);
    if(isempty(firstWindowLengthEntryIdx))
         return; %no labels available for full window length, skip export !
    end
    startSeconds = mod(events.time(firstWindowLengthEntryIdx(1)), 60); 
    
    if ( processEDF )
        edfDataFolder = [ patient.rawDataPath 'EDF\' ];
        
        if ( ~ exist( edfDataFolder, 'dir' ) )
           warning( 'Missing EDF-Data folder in %s but EDF-flag set', patient.rawDataPath );
           
        else
            edfFile = dir( [ edfDataFolder '*.edf' ] );
            patient.edfFile = [ edfDataFolder edfFile.name ];
            
            fprintf( 'Processing EDF %s ...', patient.edfFile );
            
            [ patient.edf ] = edfFeaturesByTimeWindow( patient.edfFile, ...
                requiredEdfSignals, windowLength );
            
            % merge labels to feature windows
            featureWindowLabels = addLabelsFromEventsToFeatureWindows(patient.edf, events, eventClasses);               
            patient.edf = featureWindowLabels;
            
            if(~isempty(patient.edf))
                if ( isempty( combinedDataWindowTimes ) )
                    combinedDataWindowTimes = patient.edf.time;
                else
                    combinedDataWindowTimes = intersect( patient.edf.includedEvents, combinedDataWindowTimes );
                end
            end
            
            fprintf( 'finished.\n' );
        end
    end
    
    if ( processMSR )
        msrDataFolder = [ patient.rawDataPath 'MSR\' ];
        
        if ( ~ exist( msrDataFolder, 'dir' ) )
           warning( 'Missing MSR-Data folder in %s but MSR-flag set', patient.rawDataPath );
           
        else
            msrHandFile = dir( [ msrDataFolder '*HAND.mat' ] );
            msrFootFile = dir( [ msrDataFolder '*FUSS.mat' ] );

            patient.msrFiles = { [ msrDataFolder msrHandFile.name ]; [ msrDataFolder msrFootFile.name ] };
            
            fprintf( 'Processing MSR %s ...', msrDataFolder );
            
            [ patient.msr ] = msrFeaturesByTimeWindow( patient.msrFiles, windowLength );
            
            % merge labels to feature windows
            featureWindowLabels = addLabelsFromEventsToFeatureWindows(patient.msr, events, eventClasses);            
            patient.msr = featureWindowLabels;
            
            if(~isempty(patient.msr))
                if ( isempty( combinedDataWindowTimes ) )
                    combinedDataWindowTimes = patient.msr.time;
                else
                    combinedDataWindowTimes = intersect( patient.msr.includedEvents, combinedDataWindowTimes );
                end            
            end
            
            fprintf( 'finished.\n' );
        end
    end
    
    if ( processZephyr )
        zephyrDataFolder = [ patient.rawDataPath 'Zephyr\' ];
        
        if ( ~ exist( zephyrDataFolder, 'dir' ) )
           warning( 'Missing Zephyr-Data folder in %s but Zephyr-flag set', patient.rawDataPath );
           
        else
            zephyrSummaryFile = dir( [ zephyrDataFolder '*Summary.csv' ] );
            patient.zephyrFile = [ zephyrDataFolder zephyrSummaryFile.name ];
            
            fprintf( 'Processing Zephyr %s ...', patient.zephyrFile );
            
            [ patient.zephyr ] = zephyrFeaturesByTimeWindow( patient.zephyrFile, windowLength, startSeconds);
            
            % merge labels to feature windows
            [ patient.zephyr ] = addLabelsFromEventsToFeatureWindows(patient.zephyr, events, eventClasses);
            
            if(~isempty(patient.zephyr))
                if ( isempty( combinedDataWindowTimes ) )
                    combinedDataWindowTimes = patient.zephyr.time;
                else
                    combinedDataWindowTimes = intersect( patient.zephyr.includedEvents, combinedDataWindowTimes );
                end              
            end
            fprintf( 'finished.\n' );
        end
    end
    
    patient.combinedData = [];
    patient.combinedChannels = [];
    patient.combinedLabels = [];

    relationName = [ patientFolder ' SmartSleep Barmelweid (Windows' ];
    relationName = sprintf( '%s %d) (', relationName, windowLength );
    combinedFileNamePrefix = [ patient.preprocessedOutputFolder patientFolder '_WINDOW'  ];
    
    if ( ~ isempty( patient.edf ) )
        dataIdx = find(ismember(patient.edf.time, combinedDataWindowTimes));
%         dataIdx = find( patient.edf.time >= combinedStartTime & patient.edf.time < combinedEndTime );
        
        patient.combinedData = [ patient.combinedData patient.edf.data( dataIdx, : ) ];
        patient.combinedChannels = [ patient.combinedChannels; patient.edf.channels ];
        patient.combinedLabels = [ patient.combinedLabels patient.edf.labels(dataIdx) ];
        
        relationName = [ relationName ' EEG ' ];
        combinedFileNamePrefix = [ combinedFileNamePrefix '_EEG' ];
    end
    
    if ( ~ isempty( patient.msr ) )
        dataIdx = find(ismember(patient.msr.time, combinedDataWindowTimes));
%         dataIdx = find( patient.msr.time >= combinedStartTime & patient.msr.time < combinedEndTime );
        
        patient.combinedData = [ patient.combinedData  patient.msr.data( dataIdx, : ) ];
        patient.combinedChannels = [ patient.combinedChannels; patient.msr.channels ];
         patient.combinedLabels = [ patient.combinedLabels patient.msr.labels(dataIdx) ];
        
        relationName = [ relationName ' MSR ' ];
        combinedFileNamePrefix = [ combinedFileNamePrefix '_MSR' ];
    end
    
    if ( ~ isempty( patient.zephyr ) )
        dataIdx = find(ismember(patient.zephyr.time, combinedDataWindowTimes));
%         dataIdx = find( patient.zephyr.time >= combinedStartTime & patient.zephyr.time < combinedEndTime );
        
        patient.combinedData = [ patient.combinedData  patient.zephyr.data( dataIdx, : ) ];
        patient.combinedChannels = [ patient.combinedChannels; patient.zephyr.channels ];
        patient.combinedLabels = [ patient.combinedLabels patient.zephyr.labels(dataIdx) ];

        relationName = [ relationName ' ZEPHYR ' ];
        combinedFileNamePrefix = [ combinedFileNamePrefix '_ZEPHYR' ];
    end

    mkdir( patient.preprocessedOutputFolder );
    
    save( [ combinedFileNamePrefix '.mat' ], 'patient' );

    relationName = [ relationName ')' ];
    combinedArffFile = [ combinedFileNamePrefix '.arff' ];

    exportGenericToWeka( patient.combinedData, patient.combinedLabels, eventClasses, ...
        relationName, combinedArffFile, patient.combinedChannels );
end

%--------------------------------
% Load persons labels
%--------------------------------
function [ eventFile, events ] = getPatientLabels(patientFolderPath)

    events = [];
    eventFile = [];
    
    % check if event-file exists
    file = dir( [ patientFolderPath '*.txt' ] );
    if ( isempty( file ) )
        warning( 'EVENTS:missing', 'Missing event-file in %s - ignoring patient', patientFolderPath ); 
        return;
    end
    
    eventFile = [ patientFolderPath file.name ];

    % event-file is a copy-paste from the word-docx - needs a different
    % parsing function
    if ( strfind( file.name, '_docx' ) )
        [ events ] = parseDocxEvents( eventFile ); 
        events.type = 2;
        
    else
        [ events ] = parseEvents( eventFile );
        events.type = 1;
        
    end
end
