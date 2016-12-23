% Splits groups of datasets according defined ratios into trainings - , 
% validation - and optionally testing - data and label sets.
classdef DataGroupsStratificator
    
    properties
        trainData = [];
        trainLabels = [];
        validationData = [];
        validationLabels = [];
        testData = [];
        testLabels = [];
    end
    
    methods
        function obj = DataGroupsStratificator(dataSetsGroups, dataSplit)
            
            train = dataSplit(1);
            validate = dataSplit(2);
            test = dataSplit(3);
            
            if ( sum( [ train validate test] ) ~= 1.0 )
                error( fprintf('Attention! Data split ratios do not sum up to 1.0 resp. 100 % Training = %.0f%% Validation = %.0f%% Testing = %.0f%%', train*100, validate*100, test*100) );
            end
            
            dataSetsGroupsCount = length( dataSetsGroups );
            
            trainSamplesCount = floor( dataSetsGroupsCount * train );
            validationSamplesCount = floor( dataSetsGroupsCount * validate );
            testSamplesCount = floor( dataSetsGroupsCount * test );
            
            % add the additional one to the trainings data
            if( sum( [trainSamplesCount validationSamplesCount testSamplesCount] ) <  dataSetsGroupsCount)
                trainSamplesCount = trainSamplesCount + 1 ;
            end
            
            %trainings data
            [obj.trainData, obj.trainLabels] = split(dataSetsGroups, 1, trainSamplesCount);
            %validation data
            [obj.validationData, obj.validationLabels] = split(dataSetsGroups, trainSamplesCount + 1, trainSamplesCount+validationSamplesCount);
            %test data
            [obj.testData, obj.testLabels] = split(dataSetsGroups, trainSamplesCount+validationSamplesCount + 1, trainSamplesCount+validationSamplesCount+testSamplesCount);
            
            fprintf('data instances split based on groups split:\n\t training(%0.2f): %d\n\tvalidation(%0.2f): %d\n\ttest(%0.2f): %d\n', train, length(obj.trainLabels), validate, length(obj.validationLabels), test, length(obj.testLabels));  
            
            function [data, labels] = split(dataSetsGroups, startIdx, endIdx)
                data = [];
                labels = [];
                if (endIdx >= startIdx && endIdx <= length(dataSetsGroups))
                    for dataGroup = [dataSetsGroups{startIdx:endIdx}]
                        data = [ data; dataGroup.data ];
                        labels = [ labels; dataGroup.labels ];
                    end
                end
            end
        end
    end
end

