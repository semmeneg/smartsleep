function [ features ] = msrFeaturesByEvent( msrMatFiles, events )
%MSRFEATURESBYEVENT Summary of this function goes here
%   Detailed explanation goes here

    featureFuncs = { @energyFeature, @entropyFeature, @maxFreqFeature, ...
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
