% RBMFeaturesTrainerTest
%
% Tests training features with Restricted Bolzman Machine.
%
classdef RBMFeaturesTrainerTest < matlab.unittest.TestCase
    
    properties (TestParameter)
       rawData = {struct('data', [1:12;13:24]', ...
                         'labels', {{'N1', 'N2', 'N2', 'N3', 'N2', 'N2', 'N3', 'N1', 'N1', 'W', 'W', 'R'}'})};
                      
       layersConfig ={[struct('hiddenUnitsCount', 8, 'maxEpochs', 10);struct('hiddenUnitsCount', 4, 'maxEpochs', 5)]};
    end
    
    methods (Test)
        
        %% Tests merge of raw data to labeled events
        function testBMFeaturesTrainer(testCase, layersConfig, rawData)
            
            rbmTrainer = RBMFeaturesTrainer(layersConfig, rawData);
            trainedData = rbmTrainer.run();
            testCase.assertNotEmpty(trainedData.features);
            testCase.assertEqual(size(trainedData.features, 1), 12); % expect still 16 rows
            testCase.assertEqual(size(trainedData.features, 2), layersConfig(end).hiddenUnitsCount); % expect last layers hidden units count
        end
    end
end

