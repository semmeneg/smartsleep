classdef PatientLablesAndDataMerger
    %PATIENTLABLESANDDATAMERGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = PatientLablesAndDataMerger()
        end
        
        % exportFeatureWindowWEKAPatient read raw data events file(s) and
        % labeled events file. Calculate features over the raw data
        % matching the labeled time windows.
        function [ patient ] = exportFeatureWindowWEKAPatient(obj, patientPath, patientFolder, outputFolder, ...
                requiredEdfSignals, eventClasses, ...
                processEDF, processMSR, processZephyr )
            
            patient = obj.initPatientWithEvents( patientPath, patientFolder, outputFolder, eventClasses);
            if ( isempty( patient.events ) )
                return;
            end
            
            includedEventsIntersection = []; % intersection of labeled events covered by all combined data sources
            
            if ( processEDF )
                edfDataFolder = [ patient.rawDataPath 'EDF\' ];
                
                if ( ~ exist( edfDataFolder, 'dir' ) )
                    warning( 'Missing EDF-Data folder in %s but EDF-flag set', patient.rawDataPath );
                    return;
                end
                edfFile = dir( [ edfDataFolder '*.edf' ] );
                patient.edfFile = [ edfDataFolder edfFile.name ];
                
                fprintf( 'Processing EDF %s ...', patient.edfFile );
                
                [ patient.edf ] = obj.edfFeaturesByEvent( patient.edfFile, requiredEdfSignals, patient.filteredEvents );
                
                if(~isempty(patient.edf))
                    if ( isempty( includedEventsIntersection ) )
                        includedEventsIntersection = patient.edf.includedEvents;
                    else
                        includedEventsIntersection = intersect( patient.edf.includedEvents, includedEventsIntersection );
                    end
                end
                
                fprintf( 'finished.\n' );
            end
            
            if ( processMSR )
                msrDataFolder = [ patient.rawDataPath 'MSR\' ];
                
                if ( ~ exist( msrDataFolder, 'dir' ) )
                    warning( 'Missing MSR-Data folder in %s but MSR-flag set', patient.rawDataPath );
                    return;
                end
                msrHandFile = dir( [ msrDataFolder '*HAND.mat' ] );
                msrFootFile = dir( [ msrDataFolder '*FUSS.mat' ] );
                
                patient.msrFiles = { [ msrDataFolder msrHandFile.name ]; [ msrDataFolder msrFootFile.name ] };
                
                fprintf( 'Processing MSR %s ...', msrDataFolder );
                
                [ patient.msr ] = obj.msrFeaturesByEvent( patient.msrFiles, patient.filteredEvents );
                
                if(~isempty(patient.msr))
                    if ( isempty( includedEventsIntersection ) )
                        includedEventsIntersection = patient.msr.includedEvents;
                    else
                        includedEventsIntersection = intersect( patient.msr.includedEvents, includedEventsIntersection );
                    end
                end
                
                fprintf( 'finished.\n' );
            end
            
            if ( processZephyr )
                zephyrDataFolder = [ patient.rawDataPath 'Zephyr\' ];
                
                if ( ~ exist( zephyrDataFolder, 'dir' ) )
                    warning( 'Missing Zephyr-Data folder in %s but Zephyr-flag set', patient.rawDataPath );
                    return;
                end
                zephyrSummaryFile = dir( [ zephyrDataFolder '*Summary.csv' ] );
                patient.zephyrFile = [ zephyrDataFolder zephyrSummaryFile.name ];
                
                fprintf( 'Processing Zephyr %s ...', patient.zephyrFile );
                
                [ patient.zephyr ] = obj.zephyrFeaturesByEvent( patient.zephyrFile, patient.filteredEvents );
                
                if(~isempty(patient.zephyr))
                    if ( isempty( includedEventsIntersection ) )
                        includedEventsIntersection = patient.zephyr.includedEvents;
                    else
                        includedEventsIntersection = intersect( patient.zephyr.includedEvents, includedEventsIntersection );
                    end
                end
                
                fprintf( 'finished.\n' );
            end
            
            if ( isempty( includedEventsIntersection ) );
                warning( 'PATIENT:nodata', 'Patient has no relevant data (EDF, MSR or ZEPHYR) - ignoring patient %s', patientFolder );
                return;
            end
            
            % checks if for all required sources combined data is available
            if (processEDF && (isempty(patient.edf) || isempty(patient.edf.data( includedEventsIntersection, : ))))
                return;
            end
            if (processMSR && (isempty(patient.msr) || isempty(patient.msr.data( includedEventsIntersection, : ))))
                return;
            end
            if (processZephyr && (isempty(patient.zephyr) || isempty(patient.zephyr.data( includedEventsIntersection, : ))))
                return;
            end

            eventsRelationName = [ patientFolder ' SmartSleep Barmelweid (Events ' ];
            eventsCombinedFileNamePrefix = [ patient.preprocessedOutputFolder patientFolder '_EVENTS' ];
            
            if ( ~ isempty( patient.edf ) )
                patient.combinedData = [ patient.combinedData  patient.edf.data( includedEventsIntersection, : ) ];
                patient.combinedLabels = [ patient.combinedLabels  patient.edf.labels( includedEventsIntersection, : ) ];
                patient.combinedChannels = [ patient.combinedChannels; patient.edf.channels ];
                
                eventsRelationName = [ eventsRelationName ' EEG ' ];
                eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_EEG' ];
            end
            
            if ( ~ isempty( patient.msr ) )
                patient.combinedData = [ patient.combinedData  patient.msr.data( includedEventsIntersection, : ) ];
                patient.combinedLabels = [ patient.combinedLabels  patient.msr.labels( includedEventsIntersection, : ) ];
                patient.combinedChannels = [ patient.combinedChannels; patient.msr.channels ];
                
                eventsRelationName = [ eventsRelationName ' MSR ' ];
                eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_MSR' ];
            end
            
            if ( ~ isempty( patient.zephyr ) )
                patient.combinedData = [ patient.combinedData patient.zephyr.data( includedEventsIntersection, : ) ];
                patient.combinedLabels = [ patient.combinedLabels  patient.zephyr.labels( includedEventsIntersection, : ) ];
                patient.combinedChannels = [ patient.combinedChannels; patient.zephyr.channels ];
                
                eventsRelationName = [ eventsRelationName ' ZEPHYR ' ];
                eventsCombinedFileNamePrefix = [ eventsCombinedFileNamePrefix '_ZEPHYR' ];
            end
            
            mkdir( patient.preprocessedOutputFolder );
            
            save( [ eventsCombinedFileNamePrefix '.mat' ], 'patient' );
            
            eventsRelationName = [ eventsRelationName ') Barmelweid' ];
            combinedArffFile = [ eventsCombinedFileNamePrefix '.arff' ];
            
            % Create ARFF file for Weka
            exportGenericToWeka( patient.combinedData, patient.combinedLabels, eventClasses, ...
                eventsRelationName, combinedArffFile, patient.combinedChannels );
        end
        % ----------------- end of function ----------------------------------
        
        function [ patient ] = initPatientWithEvents(obj,  patientPath, patientFolder, ...
                outputFolder, eventClasses )
            %initPatientWithEvents Construct patient struct with labeled events.
            
            patient = [];
            patient.edf = [];
            patient.msr = [];
            patient.zephyr = [];
            patient.events = [];
            patient.eventClasses = eventClasses;
            
            patient.combinedData = [];
            patient.combinedLabels = [];
            patient.combinedChannels = [];
            
            patient.msrFiles = [];
            patient.zephyrFile = [];
            
            patient.path = patientPath;
            patient.folder = patientFolder;
            patient.fullPath = [ patientPath patientFolder '\' ];
            patient.rawDataPath = [ patient.fullPath '1_raw\'] ;
            patient.preprocessedOutputFolder = [ patient.fullPath '2_preprocessed\' outputFolder '\' ];
            
            %     if ( deletePreviousOutput )
            %         [ st, msg ] = cmd_rmdir( patient.smartSleepPath );
            %     end
            
            % check if event-file exists
            eventFile = dir( [ patient.rawDataPath '*.txt' ] );
            if ( isempty( eventFile ) )
                warning( 'EVENTS:missing', 'Missing event-file in %s - ignoring patient', patient.fullPath );
                return;
            end
            
            patient.eventFile = [ patient.rawDataPath eventFile.name ];
            
            % event-file is a copy-paste from the word-docx - needs a different
            % parsing function
            if ( strfind( eventFile.name, '_docx' ) )
                [ patient.events ] = parseDocxEvents( patient.eventFile );
                patient.events.type = 2;
                
            else
                [ patient.events ] = parseEvents( patient.eventFile );
                patient.events.type = 1;
                
            end
            
            % filter events not belonging to defined eventClasses
            patient.filteredEvents = obj.filterEvents( patient.events, eventClasses );
            patient.filteredEvents.classes = eventClasses;
        end
        % ----------------- end of function ----------------------------------
        
        function [ filteredEvents ] = filterEvents(obj,  events, filterEventClasses )
            %filterEvents Filter events according given list of event classes.
            
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
        % ----------------- end of function ----------------------------------
        
        
        
        function [ features ] = edfFeaturesByEvent(obj,  edfFile, requiredEdfSignals, events )
            %FEATURESBYEVENT Summary of this function goes here
            %   Detailed explanation goes here
            
            features = [];
            
            edfData = BlockEdfLoadClass( edfFile );
            edfData = edfData.blockEdfLoad();
            
            signalCount = length( requiredEdfSignals{ 1 } );
            selectedSignals = zeros( signalCount, 1 );
            
            % NOTE: this ensures that all required edf-channels are available in the
            % given order and using indirect indexing (see below) it is enusred
            % that all data is then assembled in the required order.
            for i = 1 : signalCount
                signalLabel = requiredEdfSignals{ events.type }{ i };
                signalIdx = findStrInCell( edfData.signal_labels, signalLabel );
                if ( isempty( signalIdx ) )
                    warning( 'EDF:missing', 'In EDF-File %s signal %s not found in global configuration - ignoring EDF-file', edfFile, signalLabel );
                    return;
                end
                
                selectedSignals( i ) = signalIdx;
            end
            
            EDF_TIMEFORMAT = 'dd.mm.yy HH.MM.SS';
            %
            %             featureFuncs = { @energyFeature, @entropyFeature, @maxFreqFeature, ...
            %                 @meanFeature, @rootMeanSquareFeature, @skewnessFeature, ...
            %                 @stdFeature, @sumFeature, @vecNormFeature };
            
            featureFuncs = { @energyFeature, @maxFreqFeature, ...
                @meanFeature, @rootMeanSquareFeature, @skewnessFeature, ...
                @stdFeature, @sumFeature, @vecNormFeature };
            
            eventCount = length( events.time );
            featureCount = length( featureFuncs );
            
            features.data = zeros( eventCount, signalCount * featureCount );
            features.labels = zeros( eventCount, 1 );
            features.channels = cell( signalCount * featureCount, 1 );
            features.includedEvents = [];
            
            for i = 1 : featureCount
                featureLabel = func2str( featureFuncs{ i } );
                
                for j = 1 : signalCount
                    % NOTE: remove white-spaces from signal-label
                    signalLabel = requiredEdfSignals{ 1 }{ j }; % NOTE: always use type-1 mappings!
                    signalLabel( ismember( signalLabel, ' ' ) ) = [];
                    
                    features.channels{ ( i - 1 ) * signalCount + j  } = [ signalLabel '_' featureLabel ] ;
                end
            end
            
            edfStartDateStr = [ edfData.edf.header.recording_startdate ...
                ' ' edfData.edf.header.recording_starttime ];
            
            edfStartTime = matlabTimeToUnixTime( ...
                datenum( edfStartDateStr, EDF_TIMEFORMAT ) );
            edfEndTime = edfStartTime + edfData.signalDurationSec;
            
            edfDataWindow = cell( signalCount, 1 );
            metaInfoCells = cell( signalCount, 1 );
            
            for i = 1 : eventCount
                eventTime = events.time( i );
                
                % stop feature-calculation when reached end of elf-data
                if ( eventTime > edfEndTime )
                    break;
                end
                
                % ignoring events which occured BEFORE start of data-recording
                if ( eventTime < edfStartTime )
                    continue;
                end
                
                features.includedEvents( end + 1 ) = i;
                
                eventName = events.names{ i };
                eventNameIdx = findStrInCell( events.classes, eventName );
                features.labels( i ) = eventNameIdx;
                
                eventDuration = events.durations( i );
                tDelta = eventTime - edfStartTime;
                
                for j = 1 : signalCount
                    % NOTE: use indirect indexing on the selected signals because
                    % need correct global ordering of EDF-signals
                    idx = selectedSignals( j );
                    sampleRate = edfData.sample_rate( idx );
                    
                    edfDataFromIdx = tDelta * sampleRate;
                    edfDataToIdx = edfDataFromIdx + ( eventDuration * sampleRate ) - 1;
                    
                    if ( edfDataToIdx > length( edfData.edf.signalCell{ idx } ) )
                        edfDataToIdx = length( edfData.edf.signalCell{ idx } );
                    end
                    
                    edfDataWindow{ j } = { edfData.edf.signalCell{ idx }( edfDataFromIdx : edfDataToIdx ) };
                end
                
                metaInfo.windowTime = eventDuration * 1000;
                metaInfoCells( : ) = { metaInfo };
                
                for j = 1 : featureCount
                    scalars = cellfun( featureFuncs{ j }, edfDataWindow, metaInfoCells );
                    scalars( isnan( scalars ) ) = 0;
                    features.data( i, ( ( j - 1 ) * signalCount ) + 1 : ( j * signalCount ) ) = scalars;
                end
            end
        end
        % ----------------- end of function ----------------------------------
        
        function [ features ] = msrFeaturesByEvent(obj,  msrMatFiles, events )
            %MSRFEATURESBYEVENT Summary of this function goes here
            %   Detailed explanation goes here
            
            %             featureFuncs = { @energyFeature, @entropyFeature, @maxFreqFeature, ...
            %                 @meanFeature, @rootMeanSquareFeature, @skewnessFeature, ...
            %                 @stdFeature, @sumFeature, @vecNormFeature };
            
            featureFuncs = { @energyFeature, @maxFreqFeature, ...
                @meanFeature, @rootMeanSquareFeature, @skewnessFeature, ...
                @stdFeature, @sumFeature, @vecNormFeature };
            
            sensorsCount = size( msrMatFiles, 1 );
            eventCount = length( events.time );
            featureCount = length( featureFuncs );
            
            features.data = zeros( eventCount, sensorsCount * 3 * featureCount );
            features.labels = zeros( eventCount, 1 );
            features.channels = cell( sensorsCount * 3 * featureCount, 1 );
            features.includedEvents = [];
            
            channelNames = { 'ACC_x', 'ACC_y', 'ACC_z' };
            
            idx = 1;
            
            for i = 1 : sensorsCount
                sensorLabel = sprintf( 'MSR_%d', i );
                
                for j = 1 : 3
                    % NOTE: remove white-spaces from signal-label
                    channelLabel = channelNames{ j };
                    
                    for k = 1 : featureCount
                        featureLabel = func2str( featureFuncs{ k } );
                        
                        features.channels{ idx  } = ...
                            [ sensorLabel '_' channelLabel '_' featureLabel ] ;
                        
                        idx = idx + 1;
                    end
                end
            end
            
            features.raw = [];
            
            for i = 1 : sensorsCount
                msrFile = msrMatFiles{ i };
                features.raw{ i } = loadMSR( msrFile );
            end
            
            for i = 1 : eventCount
                eventStartTime = events.time( i );
                eventDuration = events.durations( i );
                eventEndTime = eventStartTime + eventDuration;
                
                metaInfo.windowTime = eventDuration * 1000;
                
                idx = 1;
                reachedEnd = false;
                
                % NOTE: assuming all sensors time to be synced (only differing
                % max 1 sec. )
                for j = 1 : sensorsCount
                    % extract sensor-data indices for the duration of the event
                    dataIdx = find( features.raw{ j }.time >= eventStartTime & features.raw{ j }.time < eventEndTime );
                    if ( isempty( dataIdx ) )
                        % already ahead event-time
                        if ( features.raw{ j }.time( end ) > eventEndTime )
                            reachedEnd = true;
                            break;
                        end
                        
                        continue;
                    end
                    
                    for k = 1 : 3
                        sensorData = features.raw{ j }.data( k, dataIdx );
                        
                        for f = 1 : featureCount
                            func = featureFuncs{ f };
                            
                            % NOTE: reusing Smart-Sleep handcrafted-features
                            scalar = func( { sensorData }, metaInfo );
                            if ( isnan( scalar ) )
                                scalar = 0;
                            end
                            
                            features.data( i, idx ) = scalar;
                            idx = idx + 1;
                        end
                    end
                end
                
                if ( reachedEnd )
                    break;
                    
                else
                    eventName = events.names{ i };
                    eventNameIdx = findStrInCell( events.classes, eventName );
                    features.labels( i ) = eventNameIdx;
                    
                    features.includedEvents( end + 1 ) = i;
                end
            end
        end
        % ----------------- end of function ----------------------------------
        
        
        function [ features ] = zephyrFeaturesByEvent(obj,  zephyrSummaryFile, labeledEvents )
            %zephyrFeaturesByEvent Applies defined aggregation functions over
            %events in each time window. All functions are applied to the data of all
            %channels.
            
            
            %     featureFuncs = { @energyFeature, @entropyFeature, @maxFreqFeature, ...
            %         @meanFeature, @rootMeanSquareFeature, @skewnessFeature, ...
            %         @stdFeature, @sumFeature, @vecNormFeature };
            %
            %     selectedChannels = { 'HR', 'BR', 'SkinTemp', 'PeakAccel', ...
            %         'BRAmplitude', 'BRNoise', 'BRConfidence', 'ECGAmplitude', ...
            %         'ECGNoise', 'HRConfidence', 'HRV', 'VerticalMin', 'VerticalPeak', ...
            %         'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };
            
            featureFuncs = { @energyFeature, @meanFeature, @rootMeanSquareFeature, ...
                @skewnessFeature, @stdFeature, @sumFeature, @vecNormFeature };
            
            selectedChannels = { 'HR', 'BR', 'PeakAccel', ...
                'BRAmplitude', 'ECGAmplitude', ...
                'VerticalMin', 'VerticalPeak', ...
                'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };
            
            % if this channels have 0 values, then the event(row) shall be skiped
            zeroValueFilterChannels = { 'HR', 'BR' };
            features.skippedLabeledEventWindows = 0;
            
            channelsCount = length( selectedChannels );
            eventCount = length( labeledEvents.time );
            featureCount = length( featureFuncs );
            
            features.data = zeros( eventCount, channelsCount * featureCount );
            features.labels = zeros( eventCount, 1 );
            features.channels = cell( channelsCount * featureCount, 1 );
            
            features.raw = loadZephyr( zephyrSummaryFile, selectedChannels );
            features.includedEvents = [];
            
            for i = 1 : featureCount
                featureLabel = func2str( featureFuncs{ i } );
                
                for j = 1 : channelsCount
                    channelLabel = selectedChannels{ j };
                    
                    features.channels{ ( i - 1 ) * channelsCount + j  } = [ channelLabel '_' featureLabel ] ;
                end
            end
            
            channelsData = cell( channelsCount, 1 );
            metaInfoCells = cell( channelsCount, 1 );
            
            for i = 1 : eventCount
                eventStartTime = labeledEvents.time( i );
                eventDuration = labeledEvents.durations( i );
                eventEndTime = eventStartTime + eventDuration;
                
                % extract sensor-data indices for the duration of the event
                dataIdx = find( features.raw.time >= eventStartTime & features.raw.time < eventEndTime );
                if ( isempty( dataIdx ) )
                    % already ahead event-time
                    if ( features.raw.time( end ) > eventEndTime )
                        break;
                    end
                    
                    continue;
                end
                
                dataIdxOriginalLength = length(dataIdx);
                
                % remove events where at least one of the not zero channels has a 0 value
                for channel = zeroValueFilterChannels
                    channelId = strmatch(channel, selectedChannels, 'exact');
                    dataIdx = dataIdx(any(features.raw.data(dataIdx,channelId),2));
                end
                
                % skip if less than 50% of the event window data is left
                if ( length(dataIdx) < dataIdxOriginalLength/2 )
                    features.skippedLabeledEventWindows = features.skippedLabeledEventWindows + 1;
                    continue;
                end
                
                features.includedEvents( end + 1 ) = i;
                
                eventName = labeledEvents.names{ i };
                eventNameIdx = findStrInCell( labeledEvents.classes, eventName );
                features.labels( i ) = eventNameIdx;
                
                for j = 1 : channelsCount
                    channelsData{ j } = { features.raw.data( dataIdx, j ) };
                end
                
                metaInfo.windowTime = eventDuration * 1000;
                metaInfoCells( : ) = { metaInfo };
                
                for j = 1 : featureCount
                    scalars = cellfun( featureFuncs{ j }, channelsData, metaInfoCells );
                    scalars( isnan( scalars ) ) = 0;
                    features.data( i, ( ( j - 1 ) * channelsCount ) + 1 : ( j * channelsCount ) ) = scalars;
                end
            end
        end
        % ----------------- end of function ----------------------------------
        
    end % end of methods
end

