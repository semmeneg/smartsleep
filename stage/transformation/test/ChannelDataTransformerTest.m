% ChannelDataTransformerTest
%
% Tests function applied to specific channels of a data matrix.
%
classdef ChannelDataTransformerTest < matlab.unittest.TestCase
    
    properties(MethodSetupParameter)
        
    end    
    
    properties (TestParameter)
        channels = {{'Channel1', 'Channel3'}};
        allChannels = {{'Channel1', 'Channel2', 'Channel3', 'Channel4'}};
        data = {transpose([1:10; 2:11; 3:12; 4:13])};        
    end
    
    methods (Test)
        
        %% Tests merge of raw data to labeled events
        function testChannelDataTransformation(testCase, channels, allChannels, data)
            
            f = @(values)values-min(values);
            transformator = ChannelDataTransformer(channels, allChannels, f);
            transformedData = transformator.run(data);
            testCase.assertEqual(transformedData(1,1), 0);
            testCase.assertEqual(transformedData(1,2), 2);
            testCase.assertEqual(transformedData(1,3), 0);
            testCase.assertEqual(transformedData(1,4), 4);
        end
    end
end

