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
        % param mandatoryChannelsName array of channels not expected to be empty (0), otherwise the whole data vector is skipped.
        % param selectedClasses lists the considered event classes(labels). The others shall be skipped.
        % param aggregationFunctions list references to data aggregation functions which are applied to each channel and over the data covered by the labeled event time window
        % param assumedEventDuration defines the time window resp. durations of labeled events which shall be considered                
        function obj = DefaultAggregatedDataAndLabelMerger(samplingFrequency, mandatoryChannelsName, selectedClasses, aggregationFunctions, assumedEventDuration)
            obj = obj@AbstractDataAndLabelMerger(samplingFrequency, mandatoryChannelsName, selectedClasses, assumedEventDuration);
            obj.aggregationFunctions = aggregationFunctions;
        end
        
        % interpolation not required for aggregation function (handcrafted
        % features)
        function interpolatedData = interpolateSamples(~, eventWindowData, ~)
            interpolatedData = eventWindowData;
        end
        
        %% The feature vector count resp. the amount of the components is
        % calculated based on the amount of channels and the aggregation functions (feature functions).
        function featureVectorCount = getFeatureVectorCount(obj)
            featureVectorCount = length( obj.rawData.channelNames ) * length(obj.aggregationFunctions);
        end
        
        %% Skip the labeled event window if the expected set of
        % matching raw data is not fully available (ex. at the beginning or if mandatory channels are "0").
        function filterdData = filterData(obj, eventWindowData, mandatoryColumnsIds)
            
                filterdData = eventWindowData;
                            
                % skip event if one value of required channels value is 0
                for channelId = mandatoryColumnsIds
                    if( sum(~any(eventWindowData(:,channelId),2)) > 0)
                        filterdData = [];
                        return;
                    end
                end
                
                %skip event if less than half of the expected samples per
                %window are available.
                if(size(eventWindowData,1) < (obj.samplingFrequency * obj.assumedEventDuration)/2)
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

