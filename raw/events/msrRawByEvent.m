function [ raw ] = msrRawByEvent( msrMatFiles, events )
    %MSRFEATURESBYEVENT Summary of this function goes here
    %   Detailed explanation goes here

    ASSUMED_EVENT_DURATION = 30;
    OVERSAMPLING_HZ = 19.7; % MSR 145B frequency: ~19.7 Hz (512/26) -> 591 samples
    MSR_CHANNELS = 3;
    SAMPLES_PER_CHANNEL = OVERSAMPLING_HZ * ASSUMED_EVENT_DURATION;
    SAMPLES_PER_SENSOR = SAMPLES_PER_CHANNEL * MSR_CHANNELS;

    sensorsCount = size( msrMatFiles, 1 );
    eventCount = length( events.time );

    raw.data = zeros( eventCount, sensorsCount * MSR_CHANNELS * SAMPLES_PER_CHANNEL );
    raw.time = zeros( eventCount, 1 );
    raw.labels = zeros( eventCount, 1 );
    
    skippedEventIdx = [];

    msr = cell( sensorsCount, 1 );

    for i = 1 : sensorsCount
        msrFile = msrMatFiles{ i };
        msr{ i } = loadMSR( msrFile );
    end

    for i = 1 : eventCount
        eventStartTime = events.time( i );
        eventDuration = events.durations( i );
        eventEndTime = eventStartTime + eventDuration;

        for j = 1 : sensorsCount
            % extract sensor-data indices for the duration of the event
            dataIdx = find( msr{ j }.time >= eventStartTime & msr{ j }.time < eventEndTime );

            if ( isempty( dataIdx ) )
                % already ahead event-time
                if ( msr{ j }.time( end ) > eventEndTime )
                    skippedEventIdx = [skippedEventIdx i];
                    break;
                end
                skippedEventIdx = [skippedEventIdx i];
                continue;
            end

            % Time fraction correction. Just fill up with the last value
            % but not more than 2
            delta = SAMPLES_PER_CHANNEL - length( dataIdx );
            if ( delta > 0 )
                if(delta > 2)
                    skippedEventIdx = [skippedEventIdx i];
                    continue;
                end
                dataIdx = [dataIdx repmat(dataIdx(end), 1, delta)];
            end

            sensorData = msr{ j }.data( 1:MSR_CHANNELS, dataIdx );
            
            startColumn = (j-1)*SAMPLES_PER_SENSOR + 1;
            endColumn = j*SAMPLES_PER_SENSOR;
            raw.data(i,startColumn:endColumn) = sensorData(:).';
        end

        % add label index of event
        eventName = events.names{ i };
        eventNameIdx = findStrInCell( events.classes, eventName );
        raw.labels( i ) = eventNameIdx;

        % add time of event
        raw.time(i) = eventStartTime;
    end
    
    % remove skiped events
    raw.data(skippedEventIdx,:) = [];
    raw.time(skippedEventIdx,:) = [];
    raw.labels(skippedEventIdx,:) = [];
    
    %remove empty event rows
    raw.data( ~any(raw.data,2), : ) = [];
    raw.time( ~any(raw.time,2), : ) = [];
    raw.labels( ~any(raw.labels,2), : ) = [];
    
end
