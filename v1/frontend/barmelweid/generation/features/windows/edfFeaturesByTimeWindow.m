function [ features ] = edfFeaturesByTimeWindow( edfFile, ...
    requiredEdfSignals, windowLength )
%FEATURESBYEVENT Summary of this function goes here
%   Detailed explanation goes here

    features = [];
    
    edfData = BlockEdfLoadClass( edfFile );
    edfData = edfData.blockEdfLoad();
    
    signalCount = length( requiredEdfSignals );
    selectedSignals = zeros( signalCount, 1 );
    
    % NOTE: this ensures that all required edf-channels are available in the
    % given order and using indirect indexing (see below) it is enusred
    % that all data is then assembled in the required order.
    for i = 1 : signalCount
        signalLabel = requiredEdfSignals{ i };
        signalIdx = findStrInCell( edfData.signal_labels, signalLabel );
        if ( isempty( signalIdx ) )
            warning( 'EDF:missing', 'In EDF-File %s signal %s not found in global configuration - ignoring EDF-file', edfData.edfFN, signalLabel );
            return;
        end
        
        selectedSignals( i ) = signalIdx;
    end

    EDF_TIMEFORMAT = 'dd.mm.yy HH.MM.SS';

%     featureFuncs = { @energyFeature, @entropyFeature, @maxFreqFeature, ...
%         @meanFeature, @rootMeanSquareFeature, @skewnessFeature, ...
%         @stdFeature, @sumFeature, @vecNormFeature };
    
    featureFuncs = { @energyFeature, @maxFreqFeature, ...
        @meanFeature, @rootMeanSquareFeature, @skewnessFeature, ...
        @stdFeature, @sumFeature, @vecNormFeature };    
    
    featureCount = length( featureFuncs );
    features.channels = cell( signalCount * featureCount, 1 );

    for i = 1 : featureCount
        featureLabel = func2str( featureFuncs{ i } );
        
        for j = 1 : signalCount
            % NOTE: remove white-spaces from signal-label
            signalLabel = edfData.signal_labels{ selectedSignals( j ) };
            signalLabel( ismember( signalLabel, ' ' ) ) = [];

            features.channels{ ( i - 1 ) * signalCount + j  } = [ signalLabel '_' featureLabel ] ;
        end
    end
   
    edfStartDateStr = [ edfData.edf.header.recording_startdate ... 
        ' ' edfData.edf.header.recording_starttime ];
    
    features.startTime = matlabTimeToUnixTime( ...
        datenum( edfStartDateStr, EDF_TIMEFORMAT ) );
    features.endTime = features.startTime + edfData.signalDurationSec;
    
    % windows in seconds
    features.windowLength = windowLength;

    samplesCount = floor( ( features.endTime - features.startTime ) / features.windowLength );
    features.data = zeros( samplesCount, signalCount * featureCount );
    features.time = zeros( samplesCount, 1 );
    
    edfDataWindow = cell( signalCount, 1 );
    metaInfo.windowTime = features.windowLength * 1000;
    metaInfoCells = cell( signalCount, 1 );
    metaInfoCells( : ) = { metaInfo };

    % iterate over all windows (seconds)
    for i = 1 : samplesCount
        features.time( i ) = features.startTime + ( i - 1 );

        for j = 1 : signalCount
            % NOTE: use indirect indexing on the selected signals because
            % need correct global ordering of EDF-signals
            idx = selectedSignals( j );
            sampleRate = edfData.sample_rate( idx );

            edfDataFromIdx = ( ( i - 1 ) * sampleRate ) + 1;
            edfDataToIdx = ( i + features.windowLength - 1 ) * sampleRate;
            
            if ( edfDataToIdx > length( edfData.edf.signalCell{ idx } ) ) 
                edfDataToIdx = length( edfData.edf.signalCell{ idx } );
            end
            
            edfDataWindow{ j } = { edfData.edf.signalCell{ idx }( edfDataFromIdx : edfDataToIdx ) };
        end
        
        for j = 1 : featureCount
            scalars = cellfun( featureFuncs{ j }, edfDataWindow, metaInfoCells );
            scalars( isnan( scalars ) ) = 0;
            features.data( i, ( ( j - 1 ) * signalCount ) + 1 : ( j * signalCount ) ) = scalars;
        end
    end
end
