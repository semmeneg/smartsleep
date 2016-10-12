function [ dbn ] = genericDBNTrain( windowData, windowLabels, params )
%GENERICDBNTRAIN Trains DBN with Random Bolzman Machine
% Uses DBN class from DeeBNet toolbox. 

    dbn = [];
    dbn.params = params;
    
    dbnData = setupDBNData( windowLabels, windowData, params.dataStratification, ...
        false, params.uniformClassDistribution );
    
    dbn.dataSet = DataClasses.DataStore();
    dbn.dataSet.valueType = ValueType.probability;
    dbn.dataSet.trainData = dbnData.trainData;
    dbn.dataSet.trainLabels = dbnData.trainLabels;
    dbn.dataSet.validationData = dbnData.validationData;
    dbn.dataSet.validationLabels = dbnData.validationLabels;
    dbn.dataSet.testData = dbnData.testData;
    dbn.dataSet.testLabels = dbnData.testLabels;
    
    if ( params.normalize )
        dbn.dataSet.normalize( 'minmax' );
    else
        dbn.dataSet.valueType = ValueType.gaussian;
    end
    
    dbn.dataSet.shuffle();
    
    % INFLUENCE: increasing number of hidden layers seems to REDUCE the
    % classification performance
    hiddenLayers = params.hiddenLayers;
    % PAPER: Paper takes 4 times the input size
    hiddenUnitsCount = params.hiddenUnitsCount; %size( dbn.dataSet.trainData, 2 );
    % INFLUENCE: increasing max epochs help a bit but 100 is enough
    maxEpochs = params.maxEpochs;
    % INFLUENCE: sparsity ?
    sparsity = params.sparse;
    
    dbn.net = DBN( 'classifier' );

    for i = 1 : hiddenLayers
        rbmParams = RbmParameters( hiddenUnitsCount, ValueType.binary );
        rbmParams.samplingMethodType = SamplingClasses.SamplingMethodType.CD;
        rbmParams.performanceMethod = 'reconstruction';
        rbmParams.maxEpoch = maxEpochs;
        rbmParams.sparsity = sparsity;
        dbn.net.addRBM( rbmParams );
    end

    rbmParams = RbmParameters( params.lastLayerHiddenUnits, ValueType.binary );
    rbmParams.samplingMethodType = SamplingClasses.SamplingMethodType.CD;
    rbmParams.performanceMethod = 'classification';
    rbmParams.rbmType = RbmType.discriminative;
    rbmParams.maxEpoch = maxEpochs;  
    rbmParams.sparsity = sparsity;
    dbn.net.addRBM( rbmParams );

    dbn.net.train( dbn.dataSet );
    dbn.net.backpropagation( dbn.dataSet );
    
    if ( params.extractFeatures )
        dbn.features = dbn.net.getFeature( windowData );
    end
end
