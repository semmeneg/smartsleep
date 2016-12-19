% SamplingRateInterpolationAndDecimationTest
%
% Tests interpolation and decimation to target sampling frequency.
%
classdef SamplingRateInterpolationAndDecimationTest < matlab.unittest.TestCase
    
    properties (TestParameter)
       rawData = {struct('time', [1 1 1 1 2 2 3 3 3 3 4 4 4 4 4 4 4 4]' , ...
                         'data', [1:18;20:37]')};
                      
        targetSamplingFrequency = {4};
    end
    
    methods (Test)
        
        %% Tests merge of raw data to labeled events
        function testSamplingRateInterpolationAndDecimation(testCase, rawData, targetSamplingFrequency)
            
            interp = SamplingRateInterpolationAndDecimation(targetSamplingFrequency, rawData);
            transformedData = interp.run();
            testCase.assertNotEmpty(transformedData);
            testCase.assertEqual(size(transformedData.data, 1), 16);
        end
    end
end

