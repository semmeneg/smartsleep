% ChannelDataTransformerTest
%
% Tests function applied to specific channels of a data matrix.
%
classdef ChannelDataTransformerTest < matlab.unittest.TestCase
    
    properties(MethodSetupParameter)
        
    end    
    
    properties (TestParameter)
        channels = {{'Channel1', 'Channel3'}};
        allChannels = {{'Channel1', 'Channel2', 'Channel3'}};
    end
    
    methods (Test)
        
        function testChannelDataTransformation(testCase, channels, allChannels)
            
            dataset1channel1 = [-10:0 ; 0:10].';
            dataset1channel2 = [-20:2:0 ; 0:2:20].';
            dataset1channel3 = [-30:3:0 ; 0:3:30].';
            dataset2channel1 = [-40:4:0 ; 0:4:40].';
            dataset2channel2 = [-50:5:0 ; 0:5:50].';
            dataset2channel3 = [-60:6:0 ; 0:6:60].';
            dataSet1 =[];
            dataSet1.data = [dataset1channel1 dataset1channel2 dataset1channel3];
            datasets = {dataSet1};
            dataSet2 =[];
            dataSet2.data = [dataset2channel1 dataset2channel2 dataset2channel3];
            datasets{end+1} = dataSet2;
            
            f = @(values, minValue, maxValue)normalizeToRangeWithMinMax(values,-5,5, minValue, maxValue);
            
            transformator = ChannelDataTransformer(channels, allChannels, f);
            datasets = transformator.run(datasets);
            testCase.assertEqual(datasets{1}.data(1,1), -1.25);
            testCase.assertEqual(datasets{2}.data(1,1), -5);
            
            %channel 2 not transformed
            testCase.assertEqual(datasets{1}.data(1,3), -20);
            testCase.assertEqual(datasets{2}.data(11,4), 50);            
        end
    end
end

