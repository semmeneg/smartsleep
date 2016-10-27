classdef PatientDataStratificator
    %PatientDataStratificator groups the patients into sets
    % for training, validation and testing and combines the assigned data
    % sets.
    
    properties
        classes = [];
        trainData = [];
        trainLabels = [];
        validationData = [];
        validationLabels = [];
        testData = [];
        testLabels = [];
    end
    
    methods
        function obj = PatientDataStratificator(allPatientData, dataStratificationRatios)
            
            train = dataStratificationRatios(1);
            validate = dataStratificationRatios(2);
            test = dataStratificationRatios(3);
            
            if ( (train > 1.0) || (validate > 1.0) || (test > 1.0) )
                error( 'Stratification ratios for training, validation or test cannot not be > 1.0 (100%)' );
            end
            
            if ( sum( [ train validate test] ) ~= 1.0 )
                disp( fprintf('Attention! Data split will overlab (sum > 100%): Training = %.0f%% Validation = %.0f%% Testing = %.0f%%', train*100, validate*100, test*100) );
            end
            
            obj.classes = allPatientData{ 1 }.filteredEvents.classes;
                
            patientsCount = length( allPatientData );
            
            trainSamplesCount = floor( patientsCount * train );
            validationSamplesCount = floor( patientsCount * validate );
            testSamplesCount = floor( patientsCount * test );
            
            % add the additional one to the trainings data
            if( sum( [trainSamplesCount validationSamplesCount testSamplesCount] ) <  patientsCount)
                trainSamplesCount = trainSamplesCount + 1 ;
            end

            %trainings data
            for p = [allPatientData{1:trainSamplesCount}]
                obj.trainData = [ obj.trainData; p.combinedData ];
                obj.trainLabels = [ obj.trainLabels; p.combinedLabels ];
            end 
            
            %validation data
            if( (trainSamplesCount + validationSamplesCount) > patientsCount) % with overlap 
                validationStartIndex = patientsCount - validationSamplesCount + 1;
                validationEndIndex = patientsCount;
            else % without overlap
                validationStartIndex = trainSamplesCount + 1;
                validationEndIndex = trainSamplesCount+validationSamplesCount;
            end
            for p = [allPatientData{validationStartIndex:validationEndIndex}]
                obj.validationData = [ obj.validationData; p.combinedData ];
                obj.validationLabels = [ obj.validationLabels; p.combinedLabels ];
            end 
            
            %test data
            if( (trainSamplesCount + validationSamplesCount + testSamplesCount) > patientsCount) % with overlap 
                testStartIndex = patientsCount - testSamplesCount + 1;
                testEndIndex = patientsCount;
            else % without overlap
                testStartIndex = validationStartIndex + 1;
                testEndIndex = validationEndIndex+testSamplesCount;
            end
            for p = [allPatientData{testStartIndex:testEndIndex}]
                obj.testData = [ obj.testData; p.combinedData ];
                obj.testLabels = [ obj.testLabels; p.combinedLabels ];            
            end 
        end
    end
 end

