% ZephyrRawDataAndLabelMerger merges raw sensor data from the Zephyr with labeled
% events which each cover a duration (time window).

classdef ZephyrRawDataAndLabelMerger < DefaultRawDataAndLabelMerger

    methods
        
        %% Constructor
        %
        % param labeledEvents is a struct with 'time', 'durations', 'names'
        % param rawData is a struct with 'time', 'data', 'channelNames'
        % param mandatoryChannelsName array of channels not expected to be empty (0), otherwise the whole data vector is skipped.
        % param selectedClasses lists the considered event classes(labels). The others shall be skipped.
        % param assumedEventDuration defines the time window resp. durations of labeled events which shall be considered
        function obj = ZephyrRawDataAndLabelMerger(labeledEvents, rawData, mandatoryChannelsName, selectedClasses, assumedEventDuration)
            
            %Zephyr samples with 1sec fixed (no deviation)
            obj = obj@DefaultRawDataAndLabelMerger(1, labeledEvents, rawData, mandatoryChannelsName, selectedClasses, assumedEventDuration);
        end
        
        %% Call super class default raw data and labels merger.
        function [ data, time, labels, channelNames ] = run(obj)
            [ data, time, labels, channelNames ] = run@DefaultRawDataAndLabelMerger(obj);
        end
    end
    
end

