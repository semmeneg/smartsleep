% DiffSamplingRateInterpolationTest
%
% Tests interpolation and decimation to target sampling frequency.
%
classdef DiffSamplingRateInterpolationTest < matlab.unittest.TestCase
    
    properties (TestParameter)
       rawData = {struct('time', [1 1 1 1 2 3 3 3 4 4 4 4 4 4 4 4 5 5]' , ...
                         'data', [1:18;19:36]')};

        expectedResult = {struct('time', [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4]' , ...
                         'data', [1,19;2,20;3,21;4,22;
                                  5,23;5.25,23.25;5.5,23.5;5.75,23.75;
                                  6,24;7,25;8,26;8.5,26.5;
                                  9,27;10,28;11,29;12,30])};                     
                     
        targetSamplingFrequency = {4};
    end
    
    methods (Test)
        
        %% Tests interpolation and decimation
        function testDiffSamplingRateInterpolation(testCase, rawData, targetSamplingFrequency, expectedResult)
            
            interp = DiffSamplingRateInterpolation(targetSamplingFrequency, rawData);
            transformedData = interp.run();
            expectedResult.channelNames = [];
            testCase.assertEqual(transformedData, expectedResult, 'AbsTol', 0.01);
        end
    end
end

