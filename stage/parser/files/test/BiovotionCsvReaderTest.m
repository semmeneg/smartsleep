% UtilTests
%
% Tests biovotion raw data reader on CSV file.
%
classdef BiovotionCsvReaderTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        csvFile = {[CONF.BASE_DATA_PATH 'UnitTest\parser\biovotion\*.txt' ]};
        selectedChannels = {{ 'Value05','Value06','Value07','Value08','Value09','Value10','Value11' }};
    end
    
    
    methods (Test)
        %% Tests reading from csv file.
        function testBiovotionCsvReader(testCase, csvFile, selectedChannels) 
            warning ( 'off', 'all' );
            biovotionCsvReader = BiovotionCsvReader(selectedChannels, 11);
            biovotion = biovotionCsvReader.run(csvFile);
            testCase.assertNotEmpty(biovotion);
            testCase.assertNotEmpty(biovotion.time);
            testCase.assertGreaterThan(length(biovotion.time), 1);
            testCase.assertNotEmpty(biovotion.data);
            testCase.assertEqual(size(biovotion.data, 1), 1016);
            testCase.assertEqual(length(biovotion.data),size(biovotion.time, 1));
            
            biovotionCsvReader = BiovotionCsvReader(selectedChannels, 12);
            biovotion = biovotionCsvReader.run(csvFile);
            testCase.assertEqual(size(biovotion.data, 1), 59);
        end
    end
end

