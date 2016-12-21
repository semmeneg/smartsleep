% TimedDataIntersection
%
% Tests merge for datasets based on matching times.
%
classdef TimedDataIntersectionTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        dataSets = {{struct('time', (1:6)', 'labels', {{'N1'; 'N1'; 'N2'; 'W'; 'R'; 'N2'}}, 'data', rand(6, 3)); ...
                     struct('time', (3:7)', 'labels', {{'N2'; 'W'; 'R'; 'N2'; 'N1'}}, 'data', rand(5, 3))}};
    end
    
    methods (Test)
        
        %% Tests merge of raw data to labeled events
        function testTimedDataIntersection(testCase, dataSets)
            
            merger = TimedDataIntersection(dataSets);
            [ time, labels, data ] = merger.run();
            testCase.assertNotEmpty(time);
            testCase.assertEqual(size(time,1), 4);
            testCase.assertEqual(time(1), 3);
            
            testCase.assertNotEmpty(labels);
            testCase.assertEqual(size(labels,1), 4);
            testCase.assertEqual(labels(1), {'N2'});
            
            testCase.assertNotEmpty(data);
            testCase.assertEqual(size(data,1), 4);
            dataSet2 = dataSets{2};
            testCase.assertEqual(sum(data(:,4)), sum(dataSet2.data(1:4,1)), 'AbsTol', 0.01);
            
        end
    end
end

