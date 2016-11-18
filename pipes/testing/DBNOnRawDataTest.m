% DBNOnRawDataTest
%
% Unittest for raw data DBN training 
%
classdef DBNOnRawDataTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        dataSourceSubFolder = {'UnitTesting'};
        dataResultSubFolder = {'UnitTesting'};
        fileNamePrefix = {'allpatients_RAWEVENTS_'};
    end
    
    
    methods (Test)
        %% Tests data split and DBN raw data training.
        function testZephyr(testCase, dataSourceSubFolder, dataResultSubFolder, fileNamePrefix)
            CONF.setupJava();
            dataStratificationRatios = [1.0 0.0 0.0]; 
            splitByPatients = true;
            
            [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios, DATA_SOURCE.ZEPHYR);
            
            % assert 
            allDataEventsCount = 4 * 200; % 4 patients with 200 entries in testdataset
            testCase.assertEqual(size(dataSet.trainData,1),allDataEventsCount);
            testCase.assertEqual(length(eventClasses),5);
            
            applyDBNClassifier = false;
            applyWekaClassifier = true;
            
            dbn = trainPatientsRawEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyDBNClassifier, applyWekaClassifier, DATA_SOURCE.ZEPHYR);
            testCase.assertGreaterThan(length(dbn.features), 0);
            
        end        
    end

end

