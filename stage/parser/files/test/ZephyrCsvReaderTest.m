% ZephyrCsvReaderTest
%
% Tests zephyr raw data reader on CSV file.
%
classdef ZephyrCsvReaderTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        csvFile = {[CONF.BASE_DATA_PATH 'UnitTest\parser\Zephyr\*Summary.csv' ]};
        selectedChannels = {{ 'HR', 'BR', 'PeakAccel', ...
        'BRAmplitude', 'ECGAmplitude', ...
        'VerticalMin', 'VerticalPeak', ...
        'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' }};
    end
    
    
    methods (Test)
        %% Tests reading from csv file.
        function testZephyrCsvReader(testCase, csvFile, selectedChannels) 
            warning ( 'off', 'all' );
            zephyrCsvReader = ZephyrCsvReader(selectedChannels);
            zephyr = zephyrCsvReader.run(csvFile);
            testCase.assertNotEmpty(zephyr);
            testCase.assertTrue(sum(isnan(zephyr.time)) == 0);
            testCase.assertTrue(sum(sum(isnan(zephyr.data))) == 0);
        end
    end
end

