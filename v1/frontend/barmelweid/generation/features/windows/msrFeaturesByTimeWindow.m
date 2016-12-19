function [ features ] = msrFeaturesByTimeWindow( msrMatFiles, windowLength )
%MSRFEATURESBYEVENT Summary of this function goes here
%   Detailed explanation goes here

%     featureFuncs = { @energyFeature, @entropyFeature, @maxFreqFeature, ...
%         @meanFeature, @rootMeanSquareFeature, @skewnessFeature, ...
%         @stdFeature, @sumFeature, @vecNormFeature };
    
    featureFuncs = { @energyFeature, @maxFreqFeature, ...
        @meanFeature, @rootMeanSquareFeature, @skewnessFeature, ...
        @stdFeature, @sumFeature, @vecNormFeature };    
    
    sensorsCount = size( msrMatFiles, 1 );
    featureCount = length( featureFuncs );
    
    features.channels = cell( sensorsCount * 3 * featureCount, 1 );

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
    
    features.raw = cell( sensorsCount, 1 );
    startTimes = zeros( sensorsCount, 1 );
    endTimes = zeros( sensorsCount, 1 );

    for i = 1 : sensorsCount
        msrFile = msrMatFiles{ i };
        features.raw{ i } = loadMSR( msrFile );
        
        startTimes( i ) = features.raw{ i }.time( 1 );
        endTimes( i ) = features.raw{ i }.time( end );
    end
    
    % take overlaping start-time
    features.startTime = floor( max( startTimes ) );
    % take overlaping end-time
    features.endTime = floor( min( endTimes ) );
    
     % windows in seconds
    features.windowLength = windowLength;

    samplesCount = floor( ( features.endTime - features.startTime ) / features.windowLength );
    features.data = zeros( samplesCount, sensorsCount * 3 * featureCount );
    features.time = zeros( samplesCount, 1 );
    
    metaInfo.windowTime = features.windowLength * 1000;

    % iterate over all windows (seconds)
    for i = 1 : samplesCount
        features.time( i ) = features.startTime + ( i - 1 );
        
        windowStartTime = features.startTime + ( i - 1 );
        windowEndTime = windowStartTime + features.windowLength;
        
        idx = 1;
        reachedEnd = false;
        
        % NOTE: assuming all sensors time to be synced (only differing
        % max 1 sec. )
        for j = 1 : sensorsCount
            % extract sensor-data indices for the duration of the event
            dataIdx = find( features.raw{ j }.time >= windowStartTime & features.raw{ j }.time < windowEndTime );
            if ( isempty( dataIdx ) )
                reachedEnd = true;
                break;
            end
            
            for k = 1 : 3
                sensorData = features.raw{ j }.data( k, dataIdx );

                for f = 1 : featureCount
                    func = featureFuncs{ f };

                    % NOTE: reusing Smart-Sleep handcrafted-features
                    scalar = func( { sensorData }, metaInfo );

                    features.data( i, idx ) = scalar;
                    idx = idx + 1;
                end
            end
        end
        
        if ( reachedEnd ) 
            break;
        end
    end
end
