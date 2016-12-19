% ZephyrCsvReaderTest
%
% Tests zephyr raw data reader on CSV file.
%
classdef ZephyrCsvReaderTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        csvFile = {[CONF.PATIENTS_DATA_PATH 'UnitTest\parser\Zephyr\*Summary.csv' ]};
        selectedChannels = {{ 'HR', 'BR', 'PeakAccel', ...
        'BRAmplitude', 'ECGAmplitude', ...
        'VerticalMin', 'VerticalPeak', ...
        'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' }};
    end
    
    
    methods (Test)
        %% Tests reading from csv file.
        function testZephyrCsvReader(testCase, csvFile, selectedChannels) 
            warning ( 'off', 'all' );
            zephyrCsvReader = ZephyrCsvReader(csvFile, selectedChannels);
            zephyr = zephyrCsvReader.run();
            testCase.assertNotEmpty(zephyr);
        end
    end
end

