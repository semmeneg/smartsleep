function [ raw ] = msrRawByEvent( msrMatFiles, events )
%MSRFEATURESBYEVENT Summary of this function goes here
%   Detailed explanation goes here

    ASSUMED_EVENT_DURATION = 30;
    OVERSAMPLING_HZ = 50;
    MSR_CHANNELS = 3;
    SAMPLES_PER_CHANNEL = OVERSAMPLING_HZ * ASSUMED_EVENT_DURATION;
    
    sensorsCount = size( msrMatFiles, 1 );
    eventCount = length( events.time );

    raw.data = zeros( eventCount, sensorsCount * MSR_CHANNELS * SAMPLES_PER_CHANNEL );
    raw.labels = zeros( eventCount, 1 );

    raw.startEventIdx = 0;
    raw.endEventIdx = eventCount;

    msr = cell( sensorsCount, 1 );
    
    for i = 1 : sensorsCount
        msrFile = msrMatFiles{ i };
        msr{ i } = loadMSR( msrFile );
    end
    
    for i = 1 : eventCount
        eventStartTime = events.time( i );
        eventDuration = events.durations( i );
        eventEndTime = eventStartTime + eventDuration;
        
        if ( 0 == raw.startEventIdx )
            raw.startEventIdx = i;
        end

        columnFromIdx = 1;
        columnToIdx = 1;
        reachedEnd = false;
        
        % NOTE: assuming all sensors time to be synced (only differing
        % max 1 sec. )
        for j = 1 : sensorsCount
            % extract sensor-data indices for the duration of the event
            dataIdx = find( msr{ j }.time >= eventStartTime & msr{ j }.time < eventEndTime );
            if ( isempty( dataIdx ) )
                % already ahead event-time
                if ( msr{ j }.time( end ) > eventEndTime )
                    reachedEnd = true;
                    break;
                end
            
                continue;
            end
            
            samplesCount = length( dataIdx );
            dataIdx = 1 : samplesCount;
            
            stepSize = samplesCount / SAMPLES_PER_CHANNEL;
            interpolationIdx = round( 1 : stepSize : samplesCount );
            delta = SAMPLES_PER_CHANNEL - length( interpolationIdx );
            if ( delta > 0 )
                interpolationIdx = [ interpolationIdx repmat( interpolationIdx( end ), 1, delta ) ];
            end
            
            for k = 1 : MSR_CHANNELS
                sensorData = msr{ j }.data( k, dataIdx );
                
                d = interp1( dataIdx, sensorData, interpolationIdx, 'linear' );
                
                columnToIdx = columnFromIdx + SAMPLES_PER_CHANNEL - 1;
                
                raw.data( i, columnFromIdx : columnToIdx ) = d;
                
                columnFromIdx = columnToIdx + 1;
            end
        end
        
        if ( false == reachedEnd ) 
            raw.endEventIdx = i;
            eventName = events.names{ i };
            eventNameIdx = findStrInCell( events.classes, eventName );

            raw.labels( i ) = eventNameIdx;
        
        else
            break;
        end
    end
    
    invalidLabelsIdx = find( raw.labels == 0 );
    raw.labels( invalidLabelsIdx ) = [];
    raw.data( invalidLabelsIdx, : ) = [];
end
