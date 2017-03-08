% UtilsTest
%
% Tests the utils functions.
%
classdef UtilTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        sourceFolderPatterns = {{[CONF.BASE_DATA_PATH 'UnitTest\utils\2016_10-11_Patients\P*' ], [CONF.BASE_DATA_PATH 'UnitTest\utils\2016_12_Patients\P*']}};
    end
    
    
    methods (Test)
%         %% Tests reading from csv file.
%         function testGetFolderList(testCase, sourceFolderPatterns) 
%             warning ( 'off', 'all' );
%             sourceFolders = getFolderList(sourceFolderPatterns);
%             testCase.assertEqual(length(sourceFolders), 2);
%         end
        
        %% Tests normalization of vector to given range
        function testNormalizeToRange(testCase) 
            
            testdata = [-2 -1 0 1 2]';
            
            dataSets = {};
            dataSets{1}.data = [testdata testdata*2];
            dataSets{2}.data = [testdata*4 testdata*8];
            
            a=-4;
            b=4;
            allValues = [];
            for dataSetIdx = 1 : length(dataSets)
                allValues = [allValues; dataSets{dataSetIdx}.data];
            end
            
            % test channel 1
            valuesNormalized = normalizeToRange(dataSets{1}.data(:,1), allValues(:,1), a, b);
            expectedOut = -1:0.5:1;
            testCase.assertEqual(valuesNormalized, expectedOut');
            
            valuesNormalized = normalizeToRange(dataSets{2}.data(:,1), allValues(:,1), a, b);
            expectedOut = expectedOut*4;
            testCase.assertEqual(valuesNormalized, expectedOut');
            
            % test channel 2
            valuesNormalized = normalizeToRange(dataSets{1}.data(:,2), allValues(:,2), a, b);
            expectedOut = -1:0.5:1;
            testCase.assertEqual(valuesNormalized, expectedOut');
            
            valuesNormalized = normalizeToRange(dataSets{2}.data(:,2), allValues(:,2), a, b);
            expectedOut = expectedOut*4;
            testCase.assertEqual(valuesNormalized, expectedOut');            

        end
    end
end

