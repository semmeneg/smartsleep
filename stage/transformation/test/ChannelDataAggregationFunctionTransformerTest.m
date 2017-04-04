% ChannelDataAggregationFunctionTransformerTest
%
% Tests function applied to specific channels of a data matrix.
%
classdef ChannelDataAggregationFunctionTransformerTest < matlab.unittest.TestCase
    
    properties(MethodSetupParameter)
        
    end    
    
    properties (TestParameter)
        channels = {{'Channel1', 'Channel3'}};
        allChannels = {{'Channel1', 'Channel2', 'Channel3'}};
    end
    
    methods (Test)
        
        function testChannelDataTransformation(testCase, channels, allChannels)
            
            dataSet1 = [];
            dataSet1.data = [1  2  3  4  5  6  7  8  9; ...
                             10 11 12 13 14 15 16 17 18; ...
                             19 20 21 22 23 24 25 26 27] ;
                         
            datasets = {dataSet1};
            
            aggregationFunctions = { @meanFeature, @sumFeature };
            
            transformator = ChannelDataAggregationFunctionTransformer(channels, allChannels, aggregationFunctions);
            datasets = transformator.run(datasets);
            testCase.assertEqual(size(datasets{1}.data), [3,4]);
            testCase.assertEqual(datasets{1}.data(1,1), 2.0); %mean of 1,2,3
            testCase.assertEqual(datasets{1}.data(1,2), 6.0); %sum of 1,2,3
            testCase.assertEqual(datasets{1}.data(3,4), 78.0); %sum of 25, 26, 27
        end
    end
end

