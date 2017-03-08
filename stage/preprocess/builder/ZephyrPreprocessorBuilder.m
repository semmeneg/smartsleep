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
        dataPreprocessingFunction = @(values, allValues)normalizeToRangeWithMinMax(values, allValues, -5,5);
        channelsToApplyNormalizationFunction = {};
        print = false;
    end
    
    properties(Access=private)
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
            props.sensorChannelDataTransformer = ChannelDataTransformer(obj.channelsToApplyNormalizationFunction, obj.selectedRawDataChannels, obj.dataPreprocessingFunction);
            props.dataAndLabelMerger = DefaultRawDataAndLabelMerger(obj.samplingFrequency, obj.mandatoryChannelsName, obj.selectedClasses, obj.assumedEventDuration);
            props.print = obj.print;
            preprocessor = DataSetsPreprocessor(props);
        end
        
    end
end
