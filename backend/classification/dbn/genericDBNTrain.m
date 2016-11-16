function [ dbn ] = genericDBNTrain( dataSet, params, layers, backpropagation)
%GENERICDBNTRAIN Trains DBN with Random Bolzman Machine
% Uses DBN class from DeeBNet toolbox. 

    dbn = [];
    dbn.params = params;
    
%     dbnData = setupDBNData( windowLabels, windowData, params.dataStratification, ...
%         false, params.uniformClassDistribution );
    
    dbn.dataSet = dataSet;
    
    if ( params.normalize )
        dbn.dataSet.normalize( 'minmax' );
    else
        dbn.dataSet.valueType = ValueType.gaussian;
    end
    
    dbn.dataSet.shuffle();
    
%     % INFLUENCE: increasing number of hidden layers seems to REDUCE the
%     % classification performance
%     hiddenLayers = params.hiddenLayers;
%     % PAPER: Paper takes 4 times the input size
%     hiddenUnitsCount = params.hiddenUnitsCount; %size( dbn.dataSet.trainData, 2 );
%     % INFLUENCE: increasing max epochs help a bit but 100 is enough
%     maxEpochs = params.maxEpochs;
    % INFLUENCE: sparsity ?
    sparsity = params.sparse;
    
    dbn.net = DBN( 'classifier' );

    for layer = layers
        rbmParams = RbmParameters( layer.hiddenUnitsCount, ValueType.binary );
        rbmParams.samplingMethodType = SamplingClasses.SamplingMethodType.CD;
        rbmParams.performanceMethod = 'reconstruction';
        rbmParams.maxEpoch = layer.maxEpochs;
        rbmParams.sparsity = sparsity;
        dbn.net.addRBM( rbmParams );
    end

%     rbmParams = RbmParameters( params.lastLayerHiddenUnits, ValueType.binary );
%     rbmParams.samplingMethodType = SamplingClasses.SamplingMethodType.CD;
%     rbmParams.performanceMethod = 'classification';
%     rbmParams.rbmType = RbmType.discriminative;
%     rbmParams.maxEpoch = maxEpochs;  
%     rbmParams.sparsity = sparsity;
%     dbn.net.addRBM( rbmParams );

    %train
    tStart = tic;
    fprintf('Start DBN training: %s.\n', datetime);
    dbn.net.train( dbn.dataSet );
    fprintf('DBN train time used: %f seconds.\n', toc(tStart));
    
    %backpropagation
    if (backpropagation)
        tStart = tic;
        fprintf('Start backpropagation training: %s.\n', datetime);
        dbn.net.backpropagation( dbn.dataSet );
        fprintf('DBN backpropagation time used: %f seconds.\n', toc(tStart));
    end
    
end
