% Merges raw sensor data with labeled
% events which each cover a duration (time window).
% The filter for this sensor skips event data if less as half of the samples have 0
% values on each channel. 

classdef BiovotionRawDataAndLabelMerger < DefaultRawDataAndLabelMerger
    
    methods
        
        %% Constructor
        %
        % param samplingFrequency is the sensors data recording frequence Hz (means how many samples per second and channels the sensor delivers)
        % param mandatoryChannelsName array of channels not expected to be empty (0), otherwise the whole data vector is skipped.
        % param selectedClasses lists the considered event classes(labels). The others shall be skipped.
        % param assumedEventDuration defines the time window resp. durations of labeled events which shall be considered
        function obj = BiovotionRawDataAndLabelMerger(samplingFrequency, mandatoryChannelsName, selectedClasses, assumedEventDuration)
            obj = obj@DefaultRawDataAndLabelMerger(samplingFrequency, mandatoryChannelsName, selectedClasses, assumedEventDuration);
        end
        
        %% Skips event data if less as half of the samples have 0
        % values on each channel. 
        function filterdData = filterData(obj, eventWindowData, ~)
            
                filterdData = eventWindowData;
                            
                % skip sample if all channels are 0
               filterdData( ~any(filterdData,2), : ) = [];
                
                %skip event if less than half of the expected samples per
                %window are available.
                if(size(filterdData,1) < (obj.samplingFrequency * obj.assumedEventDuration)/2)
                    filterdData = [];
                end
        end

    end
    
end

