% DefaultRawDataAndLabelMerger is a base class for merging raw sensor data with labeled
% events which each cover a duration (time window).

classdef DefaultRawDataAndLabelMerger < AbstractDataAndLabelMerger
    
    properties
        assumedEventDuration = [];
    end

    methods
        
        %% Constructor
        %
        % param samplingFrequency is the sensors data recording frequence Hz (means how many samples per second and channels the sensor delivers)
        % param labeledEvents is a struct with 'time', 'durations', 'names'
        % param rawData is a struct with 'time', 'data', 'channelNames'
        % param mandatoryChannelsName array of channels not expected to be empty (0), otherwise the whole data vector is skipped.
        % param selectedClasses lists the considered event classes(labels). The others shall be skipped.
        % param assumedEventDuration defines the time window resp. durations of labeled events which shall be considered
        function obj = DefaultRawDataAndLabelMerger(samplingFrequency, labeledEvents, rawData, mandatoryChannelsName, selectedClasses, assumedEventDuration)
            obj = obj@AbstractDataAndLabelMerger(samplingFrequency, labeledEvents, rawData, mandatoryChannelsName, selectedClasses);
            obj.assumedEventDuration = assumedEventDuration;
        end
        
        %% The feature vector count resp. the amount of the components is
        % calculated based on the amount of channels, the sampling
        % frequency and the event time window duration.
        function featureVectorCount = getFeatureVectorCount(obj)
            channelsCount = length( obj.rawData.channelNames );
            featureVectorCount = channelsCount * obj.samplingFrequency * obj.assumedEventDuration;
        end
        
        %% Skip the labeled event window if the expected set of
        % matching raw data is not fully available (ex. at the beginning or if mandatory channels are "0").
        function filterdData = filterData(obj, eventWindowData)
            
                filterdData = eventWindowData;
                            
                % skip event if one value of required channels value is 0
                for channel = obj.mandatoryChannelsName
                    channelId = strmatch(channel, obj.rawData.channelNames, 'exact');
                    if( sum(~any(eventWindowData(:,channelId),2)) > 0)
                        filterdData = [];
                        return;
                    end
                end
                
                if(size(eventWindowData,1) ~= obj.samplingFrequency * obj.assumedEventDuration)
                    filterdData = [];
                end
        end
        
        %% Just create a feature vector of all data
        function featureVector = createFeatureVector(obj, eventWindowData)
            featureVector = eventWindowData(:).';
        end
    end
    
end

