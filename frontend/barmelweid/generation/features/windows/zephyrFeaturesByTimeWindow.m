function [ features ] = zephyrFeaturesByTimeWindow( zephyrSummaryFile, windowLength, startSeconds )
%zephyrFeaturesByTimeWindow Applies defined aggregation functions over
%events in each time window. All functions are applied to the data of all
%channels.

%     featureFuncs = { @energyFeature, @entropyFeature, @maxFreqFeature, ...
%         @meanFeature, @rootMeanSquareFeature, @skewnessFeature, ...
%         @stdFeature, @sumFeature, @vecNormFeature };    
%     
%     selectedChannels = { 'HR', 'BR', 'SkinTemp', 'PeakAccel', ...
%         'BRAmplitude', 'BRNoise', 'BRConfidence', 'ECGAmplitude', ...
%         'ECGNoise', 'HRConfidence', 'HRV', 'VerticalMin', 'VerticalPeak', ...
%         'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };
    
    featureFuncs = { @energyFeature, @meanFeature, @rootMeanSquareFeature, ... 
        @skewnessFeature, @stdFeature, @sumFeature, @vecNormFeature };    
    
    selectedChannels = { 'HR', 'BR', 'PeakAccel', ...
        'BRAmplitude', 'ECGAmplitude', ...
        'VerticalMin', 'VerticalPeak', ...
        'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };    
    
    % if this channels have 0 values, then the event(row) shall be skiped 
    zeroValueFilterChannels = { 'HR', 'BR' };
    features.skippedWindows = 0;
        
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

    startTime = floor( features.raw.time( 1 ) );
    features.startTime = TimeUtils.getNextTimeWithSameSeconds(startTime, startSeconds); % prepare for better labeled window synchronization. 
    endTime = floor( features.raw.time( end ) );
    features.endTime = TimeUtils.getPreviousTimeWithSameSeconds(endTime, startSeconds); % previous time with same seconds
    
    % windows in seconds
    features.windowLength = windowLength;
    
    windowsCount = floor( ( features.endTime - features.startTime ) / features.windowLength );
    
    features.time = zeros( windowsCount, 1 );
    features.data = zeros( windowsCount, channelsCount * featureCount );
    
    channelsData = cell( channelsCount, 1 );
    metaInfoCells = cell( channelsCount, 1 );
    
    metaInfo.windowTime = features.windowLength * 1000;
    metaInfoCells( : ) = { metaInfo };

    index = 1;
    % iterate over all windows (seconds)
    for i = 1 : windowsCount
        
        windowStartTime = features.startTime + windowLength*( i - 1 );
        windowEndTime = windowStartTime + features.windowLength;
        
        % extract sensor-data indices for the duration of the event
        dataIdx = find( features.raw.time >= windowStartTime & features.raw.time < windowEndTime );
        if ( isempty( dataIdx ) )
            break;
        end
        
        windowData = features.raw.data(dataIdx, :);
        
        % remove events where at least one of the not zero channels has a 0 value
        for channel = zeroValueFilterChannels
            channelId = strmatch(channel, selectedChannels, 'exact');
            windowData( ~any(windowData(:,channelId),2), : ) = []; 
        end
        
        % skip window if less than 50% of the events(rows) in window are
        % left
        [m,n] = size(windowData);
        if ( m < features.windowLength/2 )
            features.skippedWindows = features.skippedWindows + 1;
            continue;
        end        
        
        for j = 1 : channelsCount
            channelsData{ j } = { windowData(:,j) };
        end        
        
        for j = 1 : featureCount
            scalars = cellfun( featureFuncs{ j }, channelsData, metaInfoCells );
            if(j==1 && scalars(1) == 0)
                disp('0 HR energy found. ');
            end
            scalars( isnan( scalars ) ) = 0;
            features.data( index, ( ( j - 1 ) * channelsCount ) + 1 : ( j * channelsCount ) ) = scalars;
        end
        
        %set the window start time
        features.time( index ) = features.startTime + windowLength*( i - 1 );
        
        index = index + 1;
    end
    
   % remove empty rows (having only zeros)
   features.data( ~any(features.data,2), : ) = []; 
   features.time( ~any(features.time,2), : ) = []; 
   
end

