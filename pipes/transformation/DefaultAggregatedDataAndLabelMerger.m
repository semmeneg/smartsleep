% DefaultAggregatedDataAndLabelMerger is a base class for aggregating and merging raw sensor data with labeled
% events. For each labeled event and its time window the corresponding
% sensor raw data is aggregated. The given list of aggregation functions
% are applied to all channels of the sensor and lead to handcrafted
% features (outcome of the applied functions).

classdef DefaultAggregatedDataAndLabelMerger < AbstractDataAndLabelMerger
    properties
        aggregationFunctions = [];
    end
    
    methods
        
        %% Constructor
        %
        % param samplingFrequency is the sensors data recording frequence Hz (means how many samples per second and channels the sensor delivers)
        % param labeledEvents is a struct with 'time', 'durations', 'names'
        % param rawData is a struct with 'time', 'data', 'channelNames'
        % param mandatoryChannelsName array of channels not expected to be empty (0), otherwise the whole data vector is skipped.
        % param selectedClasses lists the considered event classes(labels). The others shall be skipped.
        % param aggregationFunctions list references to data aggregation functions which are applied to each channel and over the data covered by the labeled event time window
        function obj = DefaultAggregatedDataAndLabelMerger(samplingFrequency, labeledEvents, rawData, mandatoryChannelsName, selectedClasses, aggregationFunctions)
            obj = obj@AbstractDataAndLabelMerger(samplingFrequency, labeledEvents, rawData, mandatoryChannelsName, selectedClasses);
            obj.aggregationFunctions = aggregationFunctions;
        end
        
        %% The feature vector count resp. the amount of the components is
        % calculated based on the amount of channels and the aggregation functions (feature functions).
        function featureVectorCount = getFeatureVectorCount(obj)
            featureVectorCount = length( obj.rawData.channelNames ) * length(obj.aggregationFunctions);
        end
        
        %% Remove data samples where at least one of the non zero channels is "0".
        % Skip whole window data set if less than 50% of the event window
        % data is left after filtering
        function filterdData = filterData(obj, eventWindowData)
            
            filterdData = eventWindowData;
            samplesPerWindow = size(eventWindowData,1);
            
            % remove events where at least one of the not zero channels has a 0 value
            for channel = obj.mandatoryChannelsName
                channelId = strmatch(channel, obj.rawData.channelNames, 'exact');
                filterdData(~any(filterdData(:,channelId),2),:) = [];
            end
            
            % skip if less than 50% of the event window data is left
            if ( length(filterdData) < samplesPerWindow/2 )
                filterdData = [];
            end
        end
        
        %% Just create a feature vector of all data
        function featureVector = createFeatureVector(obj, eventWindowData)
            
            featureVector = zeros(1, obj.getFeatureVectorCount);
            channelsCount = length( obj.rawData.channelNames );
            channelsData = cell( channelsCount, 1 );
            
            for j = 1 : channelsCount
                channelsData{ j } = { eventWindowData( :, j ) };
            end
            
            for functionIdx = 1 : length(obj.aggregationFunctions)
                scalars = cellfun( obj.aggregationFunctions{ functionIdx }, channelsData);
                scalars( isnan( scalars ) ) = 0;
                featureVector(1, ( ( functionIdx - 1 ) * channelsCount ) + 1 : ( functionIdx * channelsCount ) ) = scalars;
            end
            
        end
    end
    
end

