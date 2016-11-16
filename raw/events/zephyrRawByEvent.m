function [ raw ] = zephyrRawByEvent( zephyrSummaryFile, events )
%zephyrRawByEvent Extracts for each labeled event and its time frame (time
%window) the raw date of the selected channels and creates a single raw
%data vector for each event.
    
    % NO NEED FOR OVERSAMPLING, ZEPHYR SAMPLES WITH 1sec FIXED (no deviation)
    OVERSAMPLING_HZ = 1;
    ASSUMED_EVENT_DURATION = 30;
    SAMPLES_PER_CHANNEL = OVERSAMPLING_HZ * ASSUMED_EVENT_DURATION;
    
%     selectedChannels = { 'HR', 'BR', 'SkinTemp', 'PeakAccel', ...
%         'BRAmplitude', 'BRNoise', 'BRConfidence', 'ECGAmplitude', ...
%         'ECGNoise', 'HRConfidence', 'HRV', 'VerticalMin', 'VerticalPeak', ...
%         'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };
    
    selectedChannels = { 'HR', 'BR', 'PeakAccel', ...
        'BRAmplitude', 'ECGAmplitude', ...
        'VerticalMin', 'VerticalPeak', ...
        'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };
    
    % if this channels have 0 values, then the event(row) shall be skiped 
    zeroValueFilterChannels = { 'HR' 'BR'};
    raw.skippedEvents = 0;    
    
    channelsCount = length( selectedChannels );
    eventCount = length( events.time );
    
    raw.data = zeros( eventCount, channelsCount * SAMPLES_PER_CHANNEL );
    raw.time = zeros( eventCount, 1 );
    raw.labels = zeros( eventCount, 1 );
    
    zephyr = loadZephyr( zephyrSummaryFile, selectedChannels );
       
    for i = 1 : eventCount
        eventStartTime = events.time( i );
        eventDuration = events.durations( i );
        eventEndTime = eventStartTime + eventDuration;
        
        if(eventDuration ~= ASSUMED_EVENT_DURATION)
            raw.skippedEvents = raw.skippedEvents + 1;
            continue;
        end
        
        % extract sensor-data indices for the duration of the event. 
        % Round() function is required to avoid fraction problems when
        % comparing doubles in find() (ex. eventEndTime might be sliglty
        % smaller than zephyr.time on same second!
        dataIdx = find( round(zephyr.time) >= round(eventStartTime) & round(zephyr.time) < round(eventEndTime) );
        if ( isempty( dataIdx ) )
            % already ahead event-time
            if ( zephyr.time( end ) > eventEndTime )
                break;
            end
            
            raw.skippedEvents = raw.skippedEvents + 1;
            continue;
        end
        
        eventData = zephyr.data(dataIdx, : );
        
        % skip event if one value of required channels value is 0
        skipEventWindow = false;
        for channel = zeroValueFilterChannels
            channelId = strmatch(channel, selectedChannels, 'exact');
            if( sum(~any(eventData(:,channelId),2)) > 0) 
                skipEventWindow = true;
                break;
            end
        end
        
        if(skipEventWindow)
            raw.skippedEvents = raw.skippedEvents + 1;
            continue;
        end
        
        if(size(eventData,1) ~= SAMPLES_PER_CHANNEL)
            raw.skippedEvents = raw.skippedEvents + 1;
            continue;
        end
        
        raw.data(i,:) = eventData(:).';
                
        % add label index of event
        eventName = events.names{ i };
        eventNameIdx = findStrInCell( events.classes, eventName );
        raw.labels( i ) = eventNameIdx;
        
        % add time of event
        raw.time(i) = eventStartTime;
    end
    
    %remove empty entries (0 - value rows for data and labels and 0 - value columns for the time)
    raw.data( ~any(raw.data,2), : ) = [];
    raw.time( ~any(raw.time,2), : ) = [];
    raw.labels( ~any(raw.labels,2), : ) = [];
end

