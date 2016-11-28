% ZephyrAggregatedDataAndLabelMerger merges aggregated (feature function) sensor data from the Zephyr with labeled
% events which each cover a duration (time window).

classdef ZephyrAggregatedDataAndLabelMerger < DefaultAggregatedDataAndLabelMerger

    methods
        
        %% Constructor
        %
        % param labeledEvents is a struct with 'time', 'durations', 'names'
        % param rawData is a struct with 'time', 'data', 'channelNames'
        % param mandatoryChannelsName array of channels not expected to be empty (0), otherwise the whole data vector is skipped.
        % param selectedClasses lists the considered event classes(labels). The others shall be skipped.
        % param aggregationFunctions list references to data aggregation functions which are applied to each channel and over the data covered by the labeled event time window
        function obj = ZephyrAggregatedDataAndLabelMerger(labeledEvents, rawData, mandatoryChannelsName, selectedClasses, aggregationFunctions)
            
            %Zephyr samples with 1sec fixed (no deviation)
            obj = obj@DefaultAggregatedDataAndLabelMerger(1, labeledEvents, rawData, mandatoryChannelsName, selectedClasses, aggregationFunctions);
        end
        
        %% Call super class default raw data and labels merger.
        function [ data, time, labels, channelNames ] = run(obj)
            [ data, time, labels, channelNames ] = run@DefaultAggregatedDataAndLabelMerger(obj);
        end
    end
    
end

