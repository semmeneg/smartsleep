classdef PatientDataStratificator
    %PatientDataStratificator groups the patients into sets
    % for training, validation and testing and combines the assigned data
    % sets.
    
    properties
        trainData = [];
        trainLabels = [];
        validationData = [];
        validationLabels = [];
        testData = [];
        testLabels = [];
    end
    
    methods
        function obj = PatientDataStratificator(allPatientData, dataSplit)
            
            train = dataSplit(1);
            validate = dataSplit(2);
            test = dataSplit(3);
            
            if ( sum( [ train validate test] ) ~= 1.0 )
                error( fprintf('Attention! Data split ratios do not sum up to 1.0 resp. 100 % Training = %.0f%% Validation = %.0f%% Testing = %.0f%%', train*100, validate*100, test*100) );
            end
            
            patientsCount = length( allPatientData );
            
            trainSamplesCount = floor( patientsCount * train );
            validationSamplesCount = floor( patientsCount * validate );
            testSamplesCount = floor( patientsCount * test );
            
            % add the additional one to the trainings data
            if( sum( [trainSamplesCount validationSamplesCount testSamplesCount] ) <  patientsCount)
                trainSamplesCount = trainSamplesCount + 1 ;
            end
            
            %trainings data
            [obj.trainData, obj.trainLabels] = split(allPatientData, 1, trainSamplesCount);
            %validation data
            [obj.validationData, obj.validationLabels] = split(allPatientData, trainSamplesCount + 1, trainSamplesCount+validationSamplesCount);
            %test data
            [obj.testData, obj.testLabels] = split(allPatientData, trainSamplesCount+validationSamplesCount + 1, trainSamplesCount+validationSamplesCount+testSamplesCount);
            
            fprintf('data instances split based on patients split:\n\t training(%0.2f): %d\n\tvalidation(%0.2f): %d\n\ttest(%0.2f): %d\n', train, length(obj.trainLabels), validate, length(obj.validationLabels), test, length(obj.testLabels));  
            
            function [data, labels] = split(allPatientData, startIdx, endIdx)
                data = [];
                labels = [];
                if (endIdx > startIdx && endIdx <= length(allPatientData))
                    for personData = [allPatientData{startIdx:endIdx}]
                        data = [ data; personData.combinedData ];
                        labels = [ labels; personData.combinedLabels ];
                    end
                end
            end
        end
    end
end

