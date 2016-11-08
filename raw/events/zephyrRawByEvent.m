function [ raw ] = zephyrRawByEvent( zephyrSummaryFile, events )
%ZEPHYRFEATURESBYEVENT Summary of this function goes here
%   Detailed explanation goes here
    
    % NO NEED FOR OVERSAMPLING, ZEPHYR SAMPLES WITH 1sec FIXED (no
    % deviation)
    OVERSAMPLING_HZ = 1;
    ASSUMED_EVENT_DURATION = 30;
    SAMPLES_PER_CHANNEL = OVERSAMPLING_HZ * ASSUMED_EVENT_DURATION;
    
%     selectedChannels = { 'HR', 'BR', 'SkinTemp', 'PeakAccel', ...
%         'BRAmplitude', 'BRNoise', 'BRConfidence', 'ECGAmplitude', ...
%         'ECGNoise', 'HRConfidence', 'HRV', 'VerticalMin', 'VerticalPeak', ...
%         'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };
    
    selectedChannels = { 'HR', 'BR', 'PeakAccel', ...
        'BRAmplitude', 'ECGAmplitude', 'VerticalMin', 'VerticalPeak', ...
        'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };
    
    % if this channels have 0 values, then the event(row) shall be skiped 
    zeroValueFilterChannels = { 'HR' 'BR'};
    features.skippedEvents = 0;    
    
    channelsCount = length( selectedChannels );
    eventCount = length( events.time );
    
    raw.data = zeros( eventCount, channelsCount * SAMPLES_PER_CHANNEL );
    raw.labels = zeros( eventCount, 1 );
    
    zephyr = loadZephyr( zephyrSummaryFile, selectedChannels );
    raw.startEventIdx = 0;
    raw.endEventIdx = eventCount;
   
    for i = 1 : eventCount
        eventStartTime = events.time( i );
        eventDuration = events.durations( i );
        eventEndTime = eventStartTime + eventDuration;
        
        eventName = events.names{ i };
        eventNameIdx = findStrInCell( events.classes, eventName );

        raw.labels( i ) = eventNameIdx;
        
        % extract sensor-data indices for the duration of the event
        dataIdx = find( zephyr.time >= eventStartTime & zephyr.time < eventEndTime );
        if ( isempty( dataIdx ) )
            % already ahead event-time
            if ( zephyr.time( end ) > eventEndTime )
                break;
            end
            
            continue;
        end

        if ( 0 == raw.startEventIdx )
            raw.startEventIdx = i;
        end
        
        raw.endEventIdx = i;

        columnFromIdx = 1;
        columnToIdx = 1;
        
        samplesCount = length( dataIdx );
        dataIdx = 1 : samplesCount;

        stepSize = samplesCount / SAMPLES_PER_CHANNEL;
        interpolationIdx = round( 1 : stepSize : samplesCount );
        delta = SAMPLES_PER_CHANNEL - length( interpolationIdx );
        if ( delta > 0 )
            interpolationIdx = [ interpolationIdx repmat( interpolationIdx( end ), 1, delta ) ];
        end
        
        for j = 1 : channelsCount
            columnToIdx = columnFromIdx + SAMPLES_PER_CHANNEL - 1;

            data = zephyr.data( dataIdx, j );
            
            if ( samplesCount ~= SAMPLES_PER_CHANNEL )
                data = interp1( dataIdx, data, interpolationIdx, 'linear' );
            end
            
            raw.data( i, columnFromIdx : columnToIdx ) = data;
   
            columnFromIdx = columnToIdx + 1;
        end
    end
    
    % Remove zeros
    for channel = zeroValueFilterChannels
        channelId = strmatch(channel, selectedChannels, 'exact');
        zerosIdx = ~any(raw.data(:,channelId),2);
        features.skippedEvents = features.skippedEvents + zerosIdx;
        raw.data( zerosIdx, : ) = [];
        raw.labels( zerosIdx, : ) = [];
    end

end

