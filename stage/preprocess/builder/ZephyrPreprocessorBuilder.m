% Encapsulates the default properties for the preprocessing of Zephyr device data.
% Provides an instance of the DataSetsPreprocessor class.
%
classdef ZephyrPreprocessorBuilder
    
    properties(Access=public)
        selectedRawDataChannels = { 'HR', 'BR', 'PeakAccel', ...
            'BRAmplitude', 'ECGAmplitude', ...
            'VerticalMin', 'VerticalPeak', ...
            'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };
        mandatoryChannelsName = { 'HR', 'BR' };
        samplingFrequency = 1; % 1 Hz
        assumedEventDuration = 30; % seconds
        dataSource = 'Zephyr';
        sensorsRawDataFilePatterns = {'*_Summary.csv'};
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
        function obj = ZephyrPreprocessorBuilder(selectedClasses, sourceDataFolders, outputFolder)
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
            props.sensorDataReader = ZephyrCsvReader(obj.selectedRawDataChannels);
            props.dataAndLabelMerger = obj.dataAndLabelMerger;
            props.sensorChannelDataTransformers = obj.sensorChannelDataTransformers;
            props.print = obj.print;
            preprocessor = DataSetsPreprocessor(props);
        end
        
    end
end

