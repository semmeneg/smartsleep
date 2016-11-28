% BiovotionCsvReaderTest
%
% Tests biovotion raw data reader on CSV file.
%
classdef BiovotionCsvReaderTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        csvFile = {[CONF.PATIENTS_DATA_PATH 'UnitTest\parser\biovotion\*.txt' ]};
        selectedChannels = {{ 'Value05','Value06','Value07','Value08','Value09','Value10','Value11' }};
    end
    
    
    methods (Test)
        %% Tests reading from csv file.
        function testBiovotionCsvReader(testCase, csvFile, selectedChannels) 
            warning ( 'off', 'all' );
            biovotionCsvReader = BiovotionCsvReader(csvFile, selectedChannels);
            biovotion = biovotionCsvReader.run();
            testCase.assertNotEmpty(biovotion);
            testCase.assertNotEmpty(biovotion.time);
            testCase.assertGreaterThan(length(biovotion.time), 1);
            testCase.assertNotEmpty(biovotion.data);
            testCase.assertGreaterThan(size(biovotion.data, 1), 1);
            testCase.assertEqual(length(biovotion.data),size(biovotion.time, 1));
        end
    end
end

