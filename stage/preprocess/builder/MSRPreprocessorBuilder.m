% Encapsulates the default properties for the preprocessing of MSR device data. 
% Provides an instance of the DataSetsPreprocessor class.
%
classdef MSRPreprocessorBuilder < handle
    
    properties(Access=public)
        selectedRawDataChannels = { 'ACC x', 'ACC y', 'ACC z' };
        mandatoryChannelsName = {};
        samplingFrequency = 19.7; % MSR 145B frequency: ~19.7 Hz (512/26) leads to 591 samples per 30s window
        assumedEventDuration = 30; % seconds
        dataSource = 'MSR';
        sensorsRawDataFilePatterns = {'*HAND.mat', '*FUSS.mat'};
        print = false;
        dataAndLabelMerger = [];
        
        dataPreprocessingFunction = @(values, minValue, maxValue)normalizeToRangeWithMinMax(values,-5,5, minValue, maxValue);
        channelsToApplyNormalizationFunction = {};
        
        sensorChannelDataTransformers = {};
        
        selectedClasses = {};
        sourceDataFolders = {};
        outputFolder = [];
    end
    
    methods
        function obj = MSRPreprocessorBuilder(selectedClasses, sourceDataFolders, outputFolder)
            obj.selectedClasses = selectedClasses;
            obj.sourceDataFolders = sourceDataFolders;
            obj.outputFolder = outputFolder;
            
            obj.mandatoryChannelsName = obj.selectedRawDataChannels;
            obj.channelsToApplyNormalizationFunction = obj.selectedRawDataChannels;

            %default
            obj.dataAndLabelMerger = DefaultRawDataAndLabelMerger(obj.samplingFrequency, obj.mandatoryChannelsName, obj.selectedClasses, obj.assumedEventDuration);
            %default
            obj.sensorChannelDataTransformers{1} = ChannelDataTransformer(obj.channelsToApplyNormalizationFunction, obj.selectedRawDataChannels, obj.dataPreprocessingFunction);
        end
    end
    
    methods
        
        % Build a preprocessor
        function [preprocessor] = build(obj)
            props = [];
            props.dataSource = obj.dataSource;
            props.selectedClasses = obj.selectedClasses;
            props.sourceDataFolders = obj.sourceDataFolders;
            props.outputFolder = obj.outputFolder;
            props.sensorsRawDataFilePatterns = obj.sensorsRawDataFilePatterns;
            props.sensorDataReader = MSRMatlabReader(obj.selectedRawDataChannels);
            props.dataAndLabelMerger = obj.dataAndLabelMerger;
            props.sensorChannelDataTransformers = obj.sensorChannelDataTransformers;
            props.print = obj.print;
            preprocessor = DataSetsPreprocessor(props);
        end
        
    end
end

