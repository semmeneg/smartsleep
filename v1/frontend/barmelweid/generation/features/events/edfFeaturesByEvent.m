function [ features ] = edfFeaturesByEvent( edfFile, requiredEdfSignals, events )
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

    featureFuncs = { @energyFeature, @entropyFeature, @maxFreqFeature, ...
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
