% AbstractDataAndLabelMerger is a base class for merging sensor data with labeled
% events which each cover a duration (time window).

classdef (Abstract) AbstractDataAndLabelMerger
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
            
            Log.getLogger().infoStart(class(obj), 'run');
            
            channelNames = obj.rawData.channelNames;
            eventCount = length( obj.labeledEvents.time );
            
            data = zeros( eventCount, obj.getFeatureVectorCount());
            time = zeros( eventCount, 1 );
            labels = zeros( eventCount, 1 );
            
            for i = 1 : eventCount
                
                % consider only defined classes
                eventName = obj.labeledEvents.names{ i };
                eventNameIdx = findStrInCell( obj.selectedClasses, eventName );
                if(isempty(eventNameIdx))
                    continue;
                end
                                
                eventStartTime = obj.labeledEvents.time( i );
                eventDuration = obj.labeledEvents.durations( i );
                eventEndTime = eventStartTime + eventDuration;
                
                if(isfield(obj, 'assumedEventDuration') && ~isempty(obj.assumedEventDuration))
                    if(eventDuration ~= obj.assumedEventDuration)
                        continue;
                    end
                end
                
                dataIdx = find( obj.rawData.time >= eventStartTime & obj.rawData.time < eventEndTime );
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
                
                % interpolate (add/remove samples in window to match target
                % samples per window given by samples frequency x windowTime
                nextWindowsFirstSample = [];
                if (size(obj.rawData.data,1)> dataIdx(end))
                    nextWindowsFirstSample = obj.rawData.data(dataIdx(end)+1, :);
                end
                
                eventWindowData = obj.interpolateSamples(eventWindowData, nextWindowsFirstSample);                
                if(isempty(eventWindowData))
                    continue;
                end
                
                % add data, time and labels
                data(i,:) = obj.createFeatureVector(eventWindowData);
                time(i) = eventStartTime;
                labels( i ) = eventNameIdx;
            end
            
            %remove empty entries (0 - value rows for data and labels and 0 - value columns for the time)
            data( ~any(data,2), : ) = [];
            time( ~any(time,2), : ) = [];
            labels( ~any(labels,2), : ) = [];
            
            Log.getLogger().infoEnd(class(obj), 'run');
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
        eventWindowData = interpolateSamples(eventWindowData, nextWindowsFirstSample)
        featureVector = createFeatureVector(obj, eventWindowData)
    end
    
    methods(Access = protected)
        function validateField(obj, variable, name, typeCheckFunction)
            
            msg = [class(obj) ': Input validation failed for struct field: ' name ];
            
            if(~isstruct(variable))
                error([msg ' -> struct variable is empty.']);
            end
            
            if(~isfield(variable, name))
                error([msg ' -> field is missing.']);
            end
            
            if(~typeCheckFunction(getfield(variable, name)))
                error([msg ' -> value does not fit type.']);
            end
        end
        
        function validateCellArray(obj, variable, typeCheckFunction)
            
            msg = [class(obj) ': Input validation failed for cell array of single type ' ];
            
            if(isempty(variable))
                error([msg ' -> variable is empty.']);
            end
            
            if(~typeCheckFunction(variable))
                error([msg ' -> values do not fit type.']);
            end
        end
        
    end
    
end

