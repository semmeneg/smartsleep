% WekaClassifierTest
%
% Unittest for testing the Weka classification wrapper.
%
classdef WekaClassifierTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        
        features = {[0.4018    0.3377    0.5752    0.5470    0.4868    0.3507; ...
                    0.0760    0.9001    0.0598    0.2963    0.4359    0.9390; ...
                    0.2399    0.3692    0.2348    0.7447    0.4468    0.8759; ...
                    0.1233    0.1112    0.3532    0.1890    0.3063    0.5502; ...
                    0.1839    0.7803    0.8212    0.6868    0.5085    0.6225; ...
                    0.2400    0.3897    0.0154    0.1835    0.5108    0.5870; ...
                    0.4173    0.2417    0.0430    0.3685    0.8176    0.2077; ...
                    0.0497    0.4039    0.1690    0.6256    0.7948    0.3012; ...
                    0.9027    0.0965    0.6491    0.7802    0.6443    0.4709; ...
                    0.9448    0.1320    0.7317    0.0811    0.3786    0.2305; ...
                    0.4909    0.9421    0.6477    0.9294    0.8116    0.8443; ...
                    0.4893    0.9561    0.4509    0.7757    0.5328    0.1948]};
        
        labels = {[2;3;3;4;3;4;5;4;4;2;2;1]};
        classes = {{'R','W','N1','N2','N3'}};
        arffInputFile = {[CONF.PATIENTS_DATA_PATH 'UnitTest\classifier\test.arff' ]};
        resultFolderPath = {[CONF.PATIENTS_DATA_PATH 'UnitTest\classifier\weka_result\' ]};
        trainedModelFileName = {'trainedWekaModel.model'};
        textResultFileName = {'wekaResults.txt'};
        csvResultFileName = {'wekaResults.csv'};
    end
    
    
    methods (Test)
        %% Tests data split and DBN raw data training.
        function testWekaClassification(testCase, features, labels, classes, arffInputFile, resultFolderPath, trainedModelFileName, textResultFileName, csvResultFileName)
            testCase.cleanup(resultFolderPath);
            
            classifier = WekaClassifier(features, labels, classes, arffInputFile, resultFolderPath, trainedModelFileName, textResultFileName, csvResultFileName, 'unittest');
            classifier.run();
            
            resultFile = [resultFolderPath textResultFileName];
            testCase.assertGreaterThan(exist(resultFile, 'file'), 0);
            wekaResultReader = WekaResultReader([resultFolderPath textResultFileName]);
            wekaResult = wekaResultReader.run();
            testCase.assertTrue(isfield(wekaResult, 'totalInstances'));
            testCase.assertEqual(wekaResult.totalInstances, size(features, 1));
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

