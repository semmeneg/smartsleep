function [ features ] = zephyrFeaturesByEvent( zephyrSummaryFile, events )
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
    eventCount = length( events.time );
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
        eventStartTime = events.time( i );
        eventDuration = events.durations( i );
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
       
        % ignore HR = 0
        if ( 0 == sum( features.raw.data( dataIdx, 1 ) ) )
            continue;
        end
        
        features.includedEvents( end + 1 ) = i;
       
        eventName = events.names{ i };
        eventNameIdx = findStrInCell( events.classes, eventName );
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
