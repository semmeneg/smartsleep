% AbstractDataAndLabelMerger is a base class for merging sensor data with labeled
% events which each cover a duration (time window).

classdef (Abstract) AbstractDataAndLabelMerger < Stage
    properties
        samplingFrequency = [];
        labeledEvents = [];
        rawData = [];
        mandatoryChannelsName = [];
        selectedClasses = [];
    end
    
    methods
        
        %% Constructor
        %
        % param samplingFrequency is the sensors data recording frequence Hz (means how many samples per second and channels the sensor delivers)
        % param labeledEvents is a struct with 'time', 'durations', 'names'
        % param rawData is a struct with 'time', 'data', 'channelNames'
        % param mandatoryChannelsName array of channels not expected to be empty (0). Skips whole data vector if one of this channels is null.
        % param selectedClasses lists the considered event classes(labels). The others shall be skipped.
        function obj = AbstractDataAndLabelMerger(samplingFrequency, labeledEvents, rawData, mandatoryChannelsName, selectedClasses)
            obj.samplingFrequency = samplingFrequency;
            obj.labeledEvents = labeledEvents;
            obj.rawData = rawData;
            obj.mandatoryChannelsName = mandatoryChannelsName;
            obj.selectedClasses = selectedClasses;
            
            obj.validateInput();
        end
        
        %% Extracts for each labeled event and its time frame (time
        % window) the raw data of the selected channels and creates a single raw
        % data vector for each event.
        function [ data, time, labels, channelNames ] = run(obj)
            
            channelNames = obj.rawData.channelNames;
            eventCount = length( obj.labeledEvents.time );
            
            data = zeros( eventCount, obj.getFeatureVectorCount());
            time = zeros( eventCount, 1 );
            labels = zeros( eventCount, 1 );
            
            for i = 1 : eventCount
                eventStartTime = obj.labeledEvents.time( i );
                eventDuration = obj.labeledEvents.durations( i );
                eventEndTime = eventStartTime + eventDuration;
                
                if(isfield(obj, 'assumedEventDuration') && ~isempty(obj.assumedEventDuration))
                    if(eventDuration ~= obj.assumedEventDuration)
                        continue;
                    end
                end
                
                % extract sensor-data indices for the duration of the event.
                % Round() function is required to avoid fraction problems when
                % comparing doubles in find() (ex. eventEndTime might be sliglty
                % smaller than obj.rawData.time on same second!
                dataIdx = find( round(obj.rawData.time) >= round(eventStartTime) & round(obj.rawData.time) < round(eventEndTime) );
                if ( isempty( dataIdx ) )
                    % already ahead event-time
                    if ( eventEndTime > obj.rawData.time( end ) )
                        break;
                    end
                    continue;
                end
                
                % filter data
                eventWindowData = obj.filterData(obj.rawData.data(dataIdx, : ));
                
                if(isempty(eventWindowData))
                    continue;
                end
                
                % add label index of event
                eventName = obj.labeledEvents.names{ i };
                eventNameIdx = findStrInCell( obj.selectedClasses, eventName );
                if(isempty(eventNameIdx))
                    continue;
                end
                labels( i ) = eventNameIdx;
                
                data(i,:) = obj.createFeatureVector(eventWindowData);
                
                % add time of event
                time(i) = eventStartTime;
            end
            
            %remove empty entries (0 - value rows for data and labels and 0 - value columns for the time)
            data( ~any(data,2), : ) = [];
            time( ~any(time,2), : ) = [];
            labels( ~any(labels,2), : ) = [];
        end
        
        function validateInput(obj)
            obj.validateField(obj.labeledEvents, 'time', @isnumeric);
            obj.validateField(obj.labeledEvents, 'durations', @isnumeric);
            obj.validateField(obj.labeledEvents, 'names', @iscellstr);
            
            obj.validateField(obj.rawData, 'time', @isnumeric);
            obj.validateField(obj.rawData, 'data', @isnumeric);
            obj.validateField(obj.rawData, 'channelNames', @iscellstr);
            
            obj.validateCellArray(obj.selectedClasses, @iscellstr);
            
        end
        
        function validateOutput(obj)
            
        end
    end
    
    methods(Abstract)
        featureVectorCount = getFeatureVectorCount(obj)
        filteredData = filterData(obj, eventWindowData)
        featureVector = createFeatureVector(obj, eventWindowData)
    end
    
end

