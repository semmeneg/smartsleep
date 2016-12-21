% DiffSamplingRateInterpolationTest
%
% Tests interpolation and decimation to target sampling frequency.
%
classdef DiffSamplingRateInterpolationTest < matlab.unittest.TestCase
    
    properties (TestParameter)
       rawData = {struct('time', [1 1 1 1 2 3 3 3 4 4 4 4 4 4 4 4]' , ...
                         'data', [1:16;17:32]')};

        expectedResult = {struct('time', [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4]' , ...
                         'data', [1,17;2,18;3,19;4,20;
                                  5,21;5.25,21.25;5.5,21.5;5.75,21.75;
                                  6,22;7,23;8,24;8.5,24.5;
                                  9,25;10,26;11,27;12,28])};                     
                     
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

