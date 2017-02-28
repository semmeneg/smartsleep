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
        
        %% Tests normalization of vector to given range
        function testNormalizeToRange(testCase) 
            
            values = -10:10;
            a=-5;
            b=5;
            valuesNormalized = normalizeToRange(values, a, b);
            expectedOut = -5:0.5:5;
            testCase.assertEqual(valuesNormalized, expectedOut);
        end
    end
end

