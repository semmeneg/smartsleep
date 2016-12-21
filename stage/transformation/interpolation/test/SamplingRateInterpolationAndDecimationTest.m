% SamplingRateInterpolationAndDecimationTest
%
% Tests interpolation and decimation to target sampling frequency.
%
classdef SamplingRateInterpolationAndDecimationTest < matlab.unittest.TestCase
    
    properties (TestParameter)
       rawData = {struct('time', [1 1 1 1 2 3 3 3 4 4 4 4 4 4 4 4]' , ...
                         'data', [1:16;17:32]')};
        
        expectedResult = {struct('time', [1 1 1 1 3 3 3 3 4 4 4 4]' , ...
                         'data', [1,17;2,18;3,19;4,20;6,22;6.67,22.67;7.33,23.33;8,24;9,25;11.33,27.33;13.67,29.67;16,32])};
                     
        targetSamplingFrequency = {4};
    end
    
    methods (Test)
        
        %% Tests merge of raw data to labeled events
        function testSamplingRateInterpolationAndDecimation(testCase, rawData, targetSamplingFrequency, expectedResult)
            
            interp = SamplingRateInterpolationAndDecimation(targetSamplingFrequency, rawData);
            transformedData = interp.run();
            expectedResult.channelNames = [];
            testCase.assertEqual(transformedData, expectedResult, 'AbsTol', 0.01);
        end
    end
end

