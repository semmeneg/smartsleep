% ZephyrAggregatedDataAndLabelMerger merges aggregated (feature function) sensor data from the Zephyr with labeled
% events which each cover a duration (time window).

classdef ZephyrAggregatedDataAndLabelMerger < DefaultAggregatedDataAndLabelMerger

    methods
        
        %% Constructor
        %
        % param mandatoryChannelsName array of channels not expected to be empty (0), otherwise the whole data vector is skipped.
        % param selectedClasses lists the considered event classes(labels). The others shall be skipped.
        % param aggregationFunctions list references to data aggregation functions which are applied to each channel and over the data covered by the labeled event time window
        % param assumedEventDuration defines the time window resp. durations of labeled events which shall be considered        
        function obj = ZephyrAggregatedDataAndLabelMerger(mandatoryChannelsName, selectedClasses, aggregationFunctions, assumedEventDuration)
            
            %Zephyr samples with 1sec fixed (no deviation)
            obj = obj@DefaultAggregatedDataAndLabelMerger(1, mandatoryChannelsName, selectedClasses, aggregationFunctions, assumedEventDuration);
        end
    end
    
end

