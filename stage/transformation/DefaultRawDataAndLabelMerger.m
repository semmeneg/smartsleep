% DefaultRawDataAndLabelMerger is a base class for merging raw sensor data with labeled
% events which each cover a duration (time window).

classdef DefaultRawDataAndLabelMerger < AbstractDataAndLabelMerger
    
    methods
        
        %% Constructor
        %
        % param samplingFrequency is the sensors data recording frequence Hz (means how many samples per second and channels the sensor delivers)
        % param mandatoryChannelsName array of channels not expected to be empty (0), otherwise the whole data vector is skipped.
        % param selectedClasses lists the considered event classes(labels). The others shall be skipped.
        % param assumedEventDuration defines the time window resp. durations of labeled events which shall be considered
        function obj = DefaultRawDataAndLabelMerger(samplingFrequency, mandatoryChannelsName, selectedClasses, assumedEventDuration)
            obj = obj@AbstractDataAndLabelMerger(samplingFrequency, mandatoryChannelsName, selectedClasses, assumedEventDuration);
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
        
        %% The expected samples (records) in a event window is given by the multiplication of 
        % the sampling frequency (sensors samples per second) and the event
        % duration in seconds. This function interpolates missing samples
        % based on the last sample in the window and the next windows first
        % sample. 
        function interpolatedData = interpolateSamples(obj, eventWindowData, nextWindowsFirstSample)
            
            interpolatedData = [];
            samplesCount = size(eventWindowData,1);
            
            if(samplesCount == obj.samplesPerEvent)
                interpolatedData = eventWindowData;
                return; %nothing to interpolate/decimate
            end
            
            if(isempty(nextWindowsFirstSample))
                return; %last event, no next dataset for interpolation available.
            end
            
            % decimate
            if(samplesCount > obj.samplesPerEvent) % skip last samples
                delta = samplesCount - obj.samplesPerEvent;
                interpolatedData = eventWindowData(1:end-delta,:);
                return;
            end
            
            %interpolate
            lastAndNextSampleVector = [eventWindowData(end,:);nextWindowsFirstSample];
            missingSamples = obj.samplesPerEvent - samplesCount;
            stepSize = 1/(missingSamples+1);
            interpolatedDataBlock = interp1(1:2, lastAndNextSampleVector, 1:stepSize:2);
            
            %in case of only one value (column) the array orientation must
            %be switched after interpolation (Matlab magic)
            if(size(eventWindowData,2) == 1)
                interpolatedNewData = interpolatedDataBlock(:, 2:end-1)';
            else
                interpolatedNewData = interpolatedDataBlock(2:end-1,:);
            end
            interpolatedData = [ eventWindowData ; interpolatedNewData ];
        end
        
        %% Just create a feature vector of all data
        function featureVector = createFeatureVector(obj, eventWindowData)
            featureVector = eventWindowData(:).';
        end
    end
    
end

