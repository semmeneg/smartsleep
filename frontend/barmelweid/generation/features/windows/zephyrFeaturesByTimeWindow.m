function [ features ] = zephyrFeaturesByTimeWindow( zephyrSummaryFile, windowLength )
%ZEPHYRFEATURESBYEVENT Summary of this function goes here
%   Detailed explanation goes here

    featureFuncs = { @energyFeature, @entropyFeature, @maxFreqFeature, ...
        @meanFeature, @rootMeanSquareFeature, @skewnessFeature, ...
        @stdFeature, @sumFeature, @vecNormFeature };
    
    selectedChannels = { 'HR', 'BR', 'SkinTemp', 'PeakAccel', ...
        'BRAmplitude', 'BRNoise', 'BRConfidence', 'ECGAmplitude', ...
        'ECGNoise', 'HRConfidence', 'HRV', 'VerticalMin', 'VerticalPeak', ...
        'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };
    
    channelsCount = length( selectedChannels );
    featureCount = length( featureFuncs );
    
    features.channels = cell( channelsCount * featureCount, 1 );
    
    features.raw = loadZephyr( zephyrSummaryFile, selectedChannels );
    
    for i = 1 : featureCount
        featureLabel = func2str( featureFuncs{ i } );

        for j = 1 : channelsCount
            channelLabel = selectedChannels{ j };
        
            features.channels{ ( i - 1 ) * channelsCount + j  } = [ channelLabel '_' featureLabel ] ;
        end
    end

    features.startTime = floor( features.raw.time( 1 ) );
    features.endTime = floor( features.raw.time( end ) );
    
    % windows in seconds
    features.windowLength = windowLength;
    
    samplesCount = floor( ( features.endTime - features.startTime ) / features.windowLength );
    features.data = zeros( samplesCount, channelsCount * featureCount );
    features.time = zeros( samplesCount, 1 );
    
    channelsData = cell( channelsCount, 1 );
    metaInfoCells = cell( channelsCount, 1 );
    
    metaInfo.windowTime = features.windowLength * 1000;
    metaInfoCells( : ) = { metaInfo };
    
    % iterate over all windows (seconds)
    for i = 1 : samplesCount
        features.time( i ) = features.startTime + ( i - 1 );
        
        windowStartTime = features.startTime + ( i - 1 );
        windowEndTime = windowStartTime + features.windowLength;
        
        % extract sensor-data indices for the duration of the event
        dataIdx = find( features.raw.time >= windowStartTime & features.raw.time < windowEndTime );
        if ( isempty( dataIdx ) )
            break;
        end
        
        for j = 1 : channelsCount
            channelsData{ j } = { features.raw.data( dataIdx, j ) };
        end
        
        for j = 1 : featureCount
            scalars = cellfun( featureFuncs{ j }, channelsData, metaInfoCells );
            scalars( isnan( scalars ) ) = 0;
            features.data( i, ( ( j - 1 ) * channelsCount ) + 1 : ( j * channelsCount ) ) = scalars;
        end
    end
end
