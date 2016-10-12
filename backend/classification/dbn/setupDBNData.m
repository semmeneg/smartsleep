function [ dbnData ] = setupDBNData( labels, rawData, dataStratification, ...
    filterHoles, uniformClassDistribution )
%STRATIFYDATA Split data (training, validation, test)
%   Splits data according defined stratifaction ratios and consider a
%   uniform class distribution.
%   filter out the beginning of the labels and holes in the labels.
   
    if ( sum( dataStratification ) ~= 1.0 )
        error( 'Data-stratification must sum to 1.0' );
    end

    dbnData = [];
    dbnData.trainData = [];
    dbnData.trainLabels = [];
    dbnData.validationData = [];
    dbnData.validationLabels = [];
    dbnData.testData = [];
    dbnData.testLabels = [];
    
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

    trainingDataRatio = dataStratification( 1 );
    validationDataRatio = dataStratification( 2 );
    testDataRatio = dataStratification( 3 );
    
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
        
        trainSamplesCount = floor( labelIdxCount * trainingDataRatio );
        validationSamplesCount = floor( labelIdxCount * validationDataRatio );
        testSamplesCount = floor( labelIdxCount * testDataRatio );

        delta = labelIdxCount - ( trainSamplesCount + validationSamplesCount + testSamplesCount );
        trainSamplesCount = trainSamplesCount + delta;
        
        trainIdx = labelIdx( 1 : trainSamplesCount );
        validationIdx = labelIdx( trainSamplesCount + 1 : trainSamplesCount + validationSamplesCount );
        testIdx = labelIdx( trainSamplesCount + validationSamplesCount + 1 : end );
        
        dbnData.trainData( end + ( 1 : trainSamplesCount ), : ) = ...
            rawData( trainIdx, : );
        dbnData.trainLabels( end + ( 1 : trainSamplesCount ), 1 ) = label;
        
        dbnData.validationData( end + ( 1 : validationSamplesCount ), : ) = ...
            rawData( validationIdx, : );
        dbnData.validationLabels( end + ( 1 : validationSamplesCount ), 1 ) = label;
        
        dbnData.testData( end + ( 1 : testSamplesCount ), : ) = ...
            rawData( testIdx, : );
        dbnData.testLabels( end + ( 1 : testSamplesCount ), 1 ) = label;
    end
end
