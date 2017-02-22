% UtilsTest
%
% Tests the utils functions.
%
classdef UtilTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        sourceFolderPatterns = {{[CONF.BASE_DATA_PATH 'UnitTest\utils\2016_10-11_Patients\P*' ], [CONF.BASE_DATA_PATH 'UnitTest\utils\2016_12_Patients\P*']}};
    end
    
    
    methods (Test)
        %% Tests reading from csv file.
        function testGetFolderList(testCase, sourceFolderPatterns) 
            warning ( 'off', 'all' );
            sourceFolders = getFolderList(sourceFolderPatterns);
            testCase.assertEqual(length(sourceFolders), 2);
        end
    end
end

