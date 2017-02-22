% ZephyrDataAndLabelMergerTest
%
% Tests merger for zephyr rawdata and labeled events merger.
%
classdef ZephyrDataAndLabelMergerTest < matlab.unittest.TestCase
    
    properties
        selectedChannels = { 'HR', 'BR', 'PeakAccel', ...
            'BRAmplitude', 'ECGAmplitude', ...
            'VerticalMin', 'VerticalPeak', ...
            'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };
            
        rawData = [];
    end
    
    properties(MethodSetupParameter)
        rawDataFile = {[CONF.BASE_DATA_PATH 'UnitTest\transformation\Zephyr_Rawdata.csv' ]};
    end    
    
    properties (TestParameter)
        labeledEvents = {struct( 'time', [1455144247.00000,1455144247.00000,1455144277.00000,1455144307.00000,1455144337.00000,1455144339.00000,1455144366.99999,1455144397.00000,1455144427.00000,1455144457.00000,1455144487.00000,1455144517.00000,1455144547.00001,1455144577.00001], ...
                        'durations', [30,2,30,30,30,7,30,30,30,30,30,30,30,30], ...
                        'names', {{'W','Lichtaus', 'N1', 'N2', 'N2', 'Arousal','N2', 'N3', 'N2', 'R', 'N3', 'N2', 'N1', 'N1'}})};
        
        mandatoryChannelsName = {{'HR', 'BR'}};
        selectedClasses = {{'R', 'W', 'N1', 'N2', 'N3'}};
        assumedEventDuration = {30};
        
        aggregationFunctions = {{ @energyFeature, @meanFeature, @rootMeanSquareFeature, ...
                @skewnessFeature, @stdFeature, @sumFeature, @vecNormFeature }};
        
    end
    
    methods(TestMethodSetup)
        function setup(testCase, rawDataFile)
            warning ( 'off', 'all' );
            zephyrCsvReader = ZephyrCsvReader(testCase.selectedChannels);
            testCase.rawData = zephyrCsvReader.run(rawDataFile);
            testCase.rawData.channelNames = testCase.selectedChannels;
        end
    end
    
    
    methods (Test)
        
        %% Tests merge of raw data to labeled events
        function testZephyrRawDataAndLabelMerger(testCase, labeledEvents, mandatoryChannelsName, selectedClasses, assumedEventDuration)
            
            merger = ZephyrRawDataAndLabelMerger(mandatoryChannelsName, selectedClasses, assumedEventDuration);
            [ data, time, labels, channelNames ] = merger.run(labeledEvents, testCase.rawData);
            testCase.assertNotEmpty(data);
            testCase.assertEqual(size(data,1), 12);
            testCase.assertEqual(size(time,1), 12);
            testCase.assertEqual(size(labels,1), 12);
            testCase.assertEqual(size(channelNames,2), 11);
            testCase.assertTrue(isequal(channelNames,testCase.selectedChannels));
        end
        
        %% Tests merge of calculated features to labeled events
        function testZephyrAggregatedDataAndLabelMerger(testCase, labeledEvents, mandatoryChannelsName, selectedClasses, aggregationFunctions, assumedEventDuration)
            
            merger = DefaultAggregatedDataAndLabelMerger(1, mandatoryChannelsName, selectedClasses, aggregationFunctions, assumedEventDuration);
            [ data, time, labels, channelNames ] = merger.run(labeledEvents, testCase.rawData);
            testCase.assertNotEmpty(data);
            testCase.assertEqual(size(data,1), 12);
            testCase.assertEqual(size(time,1), 12);
            testCase.assertEqual(size(labels,1), 12);
            testCase.assertEqual(size(channelNames,2), 11);
            testCase.assertTrue(isequal(channelNames,testCase.selectedChannels));
        end        
    end
end

