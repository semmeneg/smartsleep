classdef AllDataStratificator
    %AllDataStratificator splits the whole given data set into
    % training, validation and testing according the defined stratification ratios.
    
    properties
        trainData = [];
        trainLabels = [];
        validationData = [];
        validationLabels = [];
        testData = [];
        testLabels = [];
    end
    
    methods
        function obj = AllDataStratificator(labels, rawData, dataStratificationRatios, filterHoles, uniformClassDistribution )
            
            train = dataStratificationRatios( 1 );
            validate = dataStratificationRatios( 2 );
            test = dataStratificationRatios( 3 );
            
            if ( sum( [ train validate test] ) ~= 1.0 )
                error( fprintf(' Sum of stratification ratios for training, validation and test cannot not be > 1.0 (100%): Training = %.0f%% Validation = %.0f%% Testing = %.0f%%', train*100, validate*100, test*100) );
            end
            
            % NOTE: split the data-set into two parts: training- and
            % validation-data using stratification.
            uniqueLabels = unique( labels );
            
            if ( uniformClassDistribution )
                % NOTE: to compensate the overrepresentation of a given class we select
                % samples so that each label is represented equally. Count each
                % the total occurences of all classes and take the minimum as the value
                % the others are reduced to => will lead to an uniform distribution of
                % classes - will only work if minimum is not too low
                
                [ labelCount, labelBins ] = hist( labels, uniqueLabels );
                minLabelCount = min( labelCount );
                
                uniformLabels = [];
                uniformData = [];
                
                for i = 1 : length( labelBins )
                    l = labelBins( i );
                    
                    % select samples equally spaced over the whole intervall (include
                    % all patients)
                    labelIdxAll = find( labels == l );
                    v = floor( linspace( 1, length( labelIdxAll ), minLabelCount ) );
                    labelIdx = labelIdxAll( v ) ;
                    
                    uniformLabels( end + ( 1 : minLabelCount ), 1 ) = l;
                    uniformData( end + ( 1 : minLabelCount ), : ) = rawData( labelIdx, : );
                end
                
                labels = uniformLabels;
                rawData = uniformData;
            end
            
            for i = 1 : length( uniqueLabels )
                label = uniqueLabels( i );
                labelIdx = find( labels == label );
                
                if ( filterHoles )
                    % NOTE: filter out the beginning of the labels and holes in the
                    % labels. Reason: when an activity changes it is not an aprupt
                    % change but can be a smooth change over a few seconds, as long as
                    % a window => filter out activity-transitions
                    labelIdx = labelIdx( find( diff( diff( labelIdx ) ) == 0 ) + 1 );
                end
                
                labelIdxCount = length( labelIdx );
                
                trainSamplesCount = floor( labelIdxCount * train );
                validationSamplesCount = floor( labelIdxCount * validate );
                testSamplesCount = floor( labelIdxCount * test );
                
                delta = labelIdxCount - ( trainSamplesCount + validationSamplesCount + testSamplesCount );
                trainSamplesCount = trainSamplesCount + delta;
                
                trainIdx = labelIdx( 1 : trainSamplesCount );
                validationIdx = labelIdx( trainSamplesCount + 1 : trainSamplesCount + validationSamplesCount );
                testIdx = labelIdx( trainSamplesCount + validationSamplesCount + 1 : end );
                
                obj.trainData( end + ( 1 : trainSamplesCount ), : ) = rawData( trainIdx, : );
                obj.trainLabels( end + ( 1 : trainSamplesCount ), 1 ) = label;
                
                obj.validationData( end + ( 1 : validationSamplesCount ), : ) = rawData( validationIdx, : );
                obj.validationLabels( end + ( 1 : validationSamplesCount ), 1 ) = label;
                
                obj.testData( end + ( 1 : testSamplesCount ), : ) = rawData( testIdx, : );
                obj.testLabels( end + ( 1 : testSamplesCount ), 1 ) = label;
                
            end
        end
    end
end
    
