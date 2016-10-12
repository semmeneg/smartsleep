function [ dbn ] = accelerometerDBNTrain( windowData, windowLabels, params )
%GENERICDBNTRAIN Summary of this function goes here
%   Detailed explanation goes here

    dbn = [];
    
    dbn.dataSet = setupDBNData( windowLabels, windowData, params.dataStratification, ...
        false, params.uniformClassDistribution );
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
    sparsity = false;

    dbn.net = DBN( 'classifier' );

    for i = 1 : hiddenLayers
        rbmParams = RbmParameters( hiddenUnitsCount ,ValueType.binary);
        rbmParams.samplingMethodType = SamplingClasses.SamplingMethodType.CD;
        rbmParams.performanceMethod = 'reconstruction';
        rbmParams.maxEpoch = maxEpochs;
        rbmParams.sparsity = sparsity;
        dbn.net.addRBM( rbmParams );
    end

    rbmParams = RbmParameters( hiddenUnitsCount, ValueType.binary );
    rbmParams.samplingMethodType = SamplingClasses.SamplingMethodType.CD;
    rbmParams.performanceMethod = 'classification';
    rbmParams.rbmType = RbmType.discriminative;
    rbmParams.maxEpoch = maxEpochs;  
    rbmParams.sparsity = sparsity;
    dbn.net.addRBM(rbmParams);

    dbn.net.train( dbn.dataSet );
    dbn.net.backpropagation( dbn.dataSet );
end
