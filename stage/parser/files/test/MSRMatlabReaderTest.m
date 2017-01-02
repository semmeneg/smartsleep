% MSRMatlabReaderTest
%
% Tests MSR raw data reader on matlab file.
%
classdef MSRMatlabReaderTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        file = {[CONF.BASE_DATA_PATH 'UnitTest\parser\MSR\test.mat' ]};
        selectedChannels = {{ 'ACC x', 'ACC y', 'ACC z' }};
    end
    
    methods (Test)
        %% Tests reading from csv file.
        function testMSRMatlabReader(testCase, file, selectedChannels) 
            warning ( 'off', 'all' );
            reader = MSRMatlabReader(selectedChannels);
            dataSet = reader.run(file);
            testCase.assertNotEmpty(dataSet);
            testCase.assertNotEmpty(dataSet.time);
            testCase.assertGreaterThan(length(dataSet.time), 1);
            testCase.assertNotEmpty(dataSet.data);
            testCase.assertEqual(size(dataSet.data, 1), 99);
            testCase.assertEqual(length(dataSet.data),size(dataSet.time, 1));
            
        end
    end
end

