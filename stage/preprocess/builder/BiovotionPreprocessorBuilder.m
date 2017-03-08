% Encapsulates the default properties for the preprocessing of Biovotion device data.
% Provides an instance of the DataSetsPreprocessor class.
%
classdef BiovotionPreprocessorBuilder
    
    properties(Access=public)
        selectedRawDataChannels = { 'Value06','Value07','Value08','Value09','Value10','Value11' };
        mandatoryChannelsName = {};
        samplingFrequency = 51.2; % Biovotion frequency: ~51.2 Hz
        assumedEventDuration = 30; % seconds
        dataSource = 'Biovotion';
        sensorsRawDataFilePatterns = {'*.txt'};
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
        function obj = BiovotionPreprocessorBuilder(selectedClasses, sourceDataFolders, outputFolder)
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
            props.sensorDataReader = BiovotionCsvReader(obj.selectedRawDataChannels, 11);
            props.sensorChannelDataTransformer = ChannelDataTransformer(obj.channelsToApplyNormalizationFunction, obj.selectedRawDataChannels, obj.dataPreprocessingFunction);
            props.dataAndLabelMerger = BiovotionRawDataAndLabelMerger(obj.samplingFrequency, obj.mandatoryChannelsName, obj.selectedClasses, obj.assumedEventDuration);
            props.print = obj.print;
            preprocessor = DataSetsPreprocessor(props);
        end
        
    end
end

