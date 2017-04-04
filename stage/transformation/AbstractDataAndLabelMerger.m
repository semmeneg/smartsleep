% AbstractDataAndLabelMerger is a base class for merging sensor data with labeled
% events which each cover a duration (time window).

classdef (Abstract) AbstractDataAndLabelMerger
    properties
        samplingFrequency = [];
        mandatoryChannelsName = [];
        selectedClasses = [];
        assumedEventDuration = [];
        samplesPerEvent = [];
        interpolate = true;
    end
    
    methods
        
        %% Constructor
        %
        % param samplingFrequency is the sensors data recording frequence Hz (means how many samples per second and channels the sensor delivers)
        % param mandatoryChannelsName array of channels not expected to be empty (0). Skips whole data vector if one of this channels is null.
        % param selectedClasses lists the considered event classes(labels). The others shall be skipped.
        % param assumedEventDuration defines the time window resp. durations of labeled events which shall be considered
        function obj = AbstractDataAndLabelMerger(samplingFrequency, mandatoryChannelsName, selectedClasses, assumedEventDuration, interpolate)
            obj.samplingFrequency = samplingFrequency;
            obj.mandatoryChannelsName = mandatoryChannelsName;
            obj.selectedClasses = selectedClasses;
            obj.assumedEventDuration = assumedEventDuration;
            obj.samplesPerEvent = ceil(obj.samplingFrequency * obj.assumedEventDuration); %rounded up
            
            if(nargin > 4)
                obj.interpolate = interpolate;
            end
            
            obj.validateInput();
        end
        
        %% Extracts for each labeled event and its time frame (time
        % window) the raw data of the selected channels and creates a single raw
        % data vector for each event.
        %
        % param labeledEvents is a struct with 'time', 'durations', 'names'
        % param rawData is a struct with 'time', 'data', 'channelNames'        
        function [ data, time, labels, channelNames ] = run(obj, labeledEvents, rawData)
            
            LOG = Log.getLogger();
            LOG.infoStart(class(obj), 'run');
            
            channelNames = rawData.channelNames;
            eventCount = length( labeledEvents.time );
            
            componentsCount = obj.samplesPerEvent * length(rawData.channelNames);
            data = zeros( eventCount, componentsCount);
            time = zeros( eventCount, 1 );
            labels = zeros( eventCount, 1 );
            
            for i = 1 : eventCount
                
                % consider only defined classes
                eventName = labeledEvents.names{ i };
                eventNameIdx = findStrInCell( obj.selectedClasses, eventName );
                if(isempty(eventNameIdx))
                    continue;
                end
                                
                eventStartTime = labeledEvents.time( i );
                eventDuration = labeledEvents.durations( i );
                eventEndTime = eventStartTime + eventDuration;
                
                if(isfield(obj, 'assumedEventDuration') && ~isempty(obj.assumedEventDuration))
                    if(eventDuration ~= obj.assumedEventDuration)
                        continue;
                    end
                end
                
                dataIdx = find( rawData.time >= eventStartTime & rawData.time < eventEndTime );
                if ( isempty( dataIdx ) )
                    % already ahead event-time
                    if ( eventEndTime > rawData.time( end ) )
                        break;
                    end
                    continue;
                end

                % filter data
                mandatoryColumnsIds = [];
                for channel = obj.mandatoryChannelsName
                    channelId = strmatch(channel, channelNames, 'exact');
                    mandatoryColumnsIds = [mandatoryColumnsIds; channelId];
                end
                    
                eventWindowData = obj.filterData(rawData.data(dataIdx, : ), mandatoryColumnsIds);                
                if(isempty(eventWindowData))
                    LOG.info('data filter', 'window skiped');
                    continue;
                end
                
                if(obj.interpolate)
                    % interpolate (add/remove samples in window to match target
                    % samples per window given by samples frequency x windowTime
                    nextWindowsFirstSample = [];
                    if (size(rawData.data,1)> dataIdx(end))
                        nextWindowsFirstSample = rawData.data(dataIdx(end)+1, :);
                    end

                    eventWindowData = obj.interpolateSamples(eventWindowData, nextWindowsFirstSample);                
                    if(isempty(eventWindowData))
                        continue;
                    end
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
            
            LOG.infoEnd(class(obj), 'run');
        end
        
        function validateInput(obj)
%             obj.validateField(labeledEvents, 'time', @isnumeric);
%             obj.validateField(labeledEvents, 'durations', @isnumeric);
%             obj.validateField(labeledEvents, 'names', @iscellstr);
%             
%             obj.validateField(rawData, 'time', @isnumeric);
%             obj.validateField(rawData, 'data', @isnumeric);
%             obj.validateField(rawData, 'channelNames', @iscellstr);
            
            obj.validateCellArray(obj.selectedClasses, @iscellstr);
            
        end
        
        function validateOutput(obj)
            
        end
    end
    
    methods(Abstract)
        filteredData = filterData(obj, eventWindowData, mandatoryColumnsIds)
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

