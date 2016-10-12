function [ dataSet ] = trainDBN( dataSet, dataSetParams )
%TRAINDBN Summary of this function goes here
%   Detailed explanation goes here

    if ( isfield( dataSetParams, 'dbn' ) )
        % when params explicitly disable training of DBN, then don't
        if ( ~ dataSetParams.dbn.train )
            return;
        end
        
        if ( ~ isfield( dataSetParams.dbn, 'featuresCount' ) )
            dataSetParams.dbn.featuresCount = 50;
        end
    else
        dataSetParams.dbn.featuresCount = 50;
    end
    
    % if no activities (=no labels) are specified, we don't have labels,
    % thus no training of feature-extraction and classification DBN
    if ( ~ isfield( dataSet.dbn, 'labels' ) )
        return;
    end
    
    % NOTE: DeeBNet needs data and labels in column-major form: 
    % NUMBER_OF_SAMPLES x DIMENSIONALITY_OF_EACH_SAMPLE
    
    DATA_STRATIFICATION = [ 0.6 0.2 0.2 ];
    FILTER_HOLES = true;
    UNIFORM_CLASS_DISTRIBUTION = false;
    
    dbnData = setupDBNData( dataSet.dbn.labels, dataSet.dbn.data, ...
        DATA_STRATIFICATION, FILTER_HOLES, UNIFORM_CLASS_DISTRIBUTION );
    
    data = DataClasses.DataStore();
    data.valueType = ValueType.probability;
    data.trainData = dbnData.trainData;
    data.trainLabels = dbnData.trainLabels;
    data.validationData = dbnData.validationData;
    data.validationLabels = dbnData.validationLabels;
    data.testData = dbnData.testData;
    data.testLabels = dbnData.testLabels;
    data.valueType = ValueType.probability;
    
    % shuffle data for training
    data.shuffle();

    hiddenLayers = 2;
    
    %hiddenUnitsCount = 10; 
    %hiddenUnitsCount = 500;
    hiddenUnitsCount = 2 * size( dataSet.dbn.data, 2 );
     
    %maxEpochs = 1;
    %maxEpochs = 10;
    maxEpochs = 150;
    
    sparsity = true;
    
    % Construct and train classification DBN (need to use a different DBN
    % because it has different layer types and different number of hidden
    % units )
    dataSet.dbn.classificator = DBN('classifier');
 
    for i = 1 : hiddenLayers
        rbmParams = RbmParameters( hiddenUnitsCount ,ValueType.binary);
        rbmParams.samplingMethodType = SamplingClasses.SamplingMethodType.CD;
        rbmParams.performanceMethod = 'reconstruction';
        rbmParams.maxEpoch = maxEpochs;
        rbmParams.sparsity = sparsity;
        dataSet.dbn.classificator.addRBM( rbmParams );
    end
    
    % NOTE: reducing the number of units from 2000 to 500 to 50 didn't show
    % significant increase of classification errors. Reducing it to 10
    % led to fluctiations in classification errors when repeatedly trained
    rbmParams = RbmParameters( dataSetParams.dbn.featuresCount, ValueType.binary );
    rbmParams.samplingMethodType = SamplingClasses.SamplingMethodType.CD;
    rbmParams.performanceMethod = 'classification';
    rbmParams.rbmType = RbmType.discriminative;
    rbmParams.maxEpoch = maxEpochs;
    rbmParams.sparsity = sparsity;
    dataSet.dbn.classificator.addRBM(rbmParams);

    % NOTE: using maxEpoch = 50 on all layers leads to varying results:
    % training using the same set can lead to different classification
    % results on the same training-set ( for better or
    % worse). E.g. one training-run showed a classification of only 80% and then the
    % next run showed 92%. When increasing maxEpoch this seems to much more
    % stable results which differ only in fractions. The reason for this is
    % obviously in the stochastic nature of the DBN/RBM when performing 
    % Gibbs sampling
    
    dataSet.dbn.classificator.train(data);
    dataSet.dbn.classificator.backpropagation(data);
    
    % extract features from the original (unshuffled) data
    dataSet.dbn.features = dataSet.dbn.classificator.getFeature( dataSet.dbn.data );
end
