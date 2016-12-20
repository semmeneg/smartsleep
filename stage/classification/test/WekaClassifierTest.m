% WekaClassifierTest
%
% Unittest for testing the Weka classification wrapper.
%
classdef WekaClassifierTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        
        arffFile = {[CONF.BASE_DATA_PATH 'UnitTest\classification\test.arff' ]};
        resultFolderPath = {[CONF.BASE_DATA_PATH 'UnitTest\classification\weka_result\' ]};
        trainedModelFileName = {'trainedWekaModel.model'};
        textResultFileName = {'wekaResults.txt'};
        csvResultFileName = {'wekaResults.csv'};
    end
    
    
    methods (Test)
        %% Tests data split and DBN raw data training.
        function testWekaClassification(testCase, arffFile, resultFolderPath, trainedModelFileName, textResultFileName, csvResultFileName)
            testCase.cleanup(resultFolderPath);
            
            classifier = WekaClassifier(arffFile, [], resultFolderPath, trainedModelFileName, textResultFileName, csvResultFileName, 'unittest');
            classifier.run();
            
            resultFile = [resultFolderPath textResultFileName];
            testCase.assertGreaterThan(exist(resultFile, 'file'), 0);
            wekaResultReader = WekaResultReader([resultFolderPath textResultFileName]);
            wekaResult = wekaResultReader.run();
            testCase.assertTrue(isfield(wekaResult, 'totalInstances'));
            testCase.assertEqual(wekaResult.totalInstances, 12);
            testCase.cleanup(resultFolderPath);
        end
    end
    
    methods
        %% delete generated files
        function cleanup(~, file)
            [s, mess, messid] = rmdir(file,'s');
        end
    end
    
end

