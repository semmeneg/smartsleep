% NamedDataSetsIntersectionTest
%
% Tests merge for datasets grops where datasets with same name are merged according the matching time.
%
classdef NamedDataSetsIntersectionTest < matlab.unittest.TestCase
    
    properties(Constant)
        dataSet1 = struct('name', 'Data Set 1', 'time', (1:6)', 'labels', {{'N1'; 'N1'; 'N2'; 'W'; 'R'; 'N2'}}, 'data', rand(6, 3));
        dataSet2 = struct('name', 'Data Set 2', 'time', (10:15)', 'labels', {{'N2'; 'W'; 'R'; 'N2'; 'N1'}}, 'data', rand(5, 3));
        dataSet3 = struct('name', 'Data Set 1', 'time', (3:7)', 'labels', {{'N2'; 'W'; 'R'; 'N2'; 'N1'}}, 'data', rand(5, 3));
        dataSet4 = struct('name', 'Data Set 4', 'time', (1:6)', 'labels', {{'N1'; 'N1'; 'N2'; 'W'; 'R'; 'N2'}}, 'data', rand(6, 3));
        
        dataSetsGroup1 = {NamedDataSetsIntersectionTest.dataSet1, NamedDataSetsIntersectionTest.dataSet2};
        dataSetsGroup2 = {NamedDataSetsIntersectionTest.dataSet3, NamedDataSetsIntersectionTest.dataSet4};
    end
    properties (TestParameter)
        dataSetsGroups = {{NamedDataSetsIntersectionTest.dataSetsGroup1, NamedDataSetsIntersectionTest.dataSetsGroup2}};
        expectedMergedDataSet = {struct('name', 'Data Set 1', 'time', (3:6)', 'labels', {{'N2'; 'W'; 'R'; 'N2'}}, 'data', [NamedDataSetsIntersectionTest.dataSet1.data(3:6,:) NamedDataSetsIntersectionTest.dataSet3.data(1:4,:)])};
            
    end
    
    methods (Test)
        
        %% Tests merge of raw data to labeled events
        function testTimedDataIntersection(testCase, dataSetsGroups, expectedMergedDataSet)
            
            merger = NamedDataSetsIntersection();
            [ mergedDataSets ] = merger.run(dataSetsGroups);
            testCase.assertNotEmpty(mergedDataSets);
            
            testCase.assertEqual(mergedDataSets{1}, expectedMergedDataSet);
             
%             testCase.assertEqual(length(mergedDataSets), 1);
%              testCase.assertEqual(mergedDataSets{1}.name, obj.dataSet1.name);
%              
%              time = mergedDataSets{1}.time;
%              testCase.assertEqual(time(1), 3);
%              
%              testCase.assertEqual(mergedDataSets{1}.time(1), 3);
%             
%             testCase.assertNotEmpty(labels);
%             testCase.assertEqual(size(labels,1), 4);
%             testCase.assertEqual(labels(1), {'N2'});
%             
%             testCase.assertNotEmpty(data);
%             testCase.assertEqual(size(data,1), 4);
%             dataSet2 = dataSets{2};
%             testCase.assertEqual(sum(data(:,4)), sum(dataSet2.data(1:4,1)), 'AbsTol', 0.01);
            
        end
    end
end

