% Runs a Restricted Bolzman Machine implementation to derrive higher order
% features from a set of input features.
%
classdef RBMFeaturesTrainer
    
    properties(Constant)
        sparsity = false;
    end
    
    properties
        layersConfig = []
        rawData = [];
    end
    
    methods
        % Constructor
        %
        % param layersConfig is expected to be an array of hiddenLayer configurations (structs with 'hiddenUnitsCount', 'maxEpochs')
        % param rawData is a struct with 'time', 'data', 'channelNames' (optional)
        function obj = RBMFeaturesTrainer(layersConfig, rawData)
            obj.layersConfig = layersConfig;
            obj.rawData = rawData;
        end
        
        % Returns a struct of features with
        function [ features ] = run(obj)
            
            dataSet = DataClasses.DataStore();
            dataSet.valueType = ValueType.gaussian;
            dataSet.trainData = obj.rawData.data;
            dataSet.trainLabels = obj.rawData.labels;
            
            dbn = DBN( 'classifier' );
            
            for layerIdx = 1 : length(obj.layersConfig)
                rbmParams = RbmParameters( obj.layersConfig(layerIdx).hiddenUnitsCount, ValueType.binary );
                rbmParams.samplingMethodType = SamplingClasses.SamplingMethodType.CD;
                rbmParams.performanceMethod = 'reconstruction';
                rbmParams.maxEpoch = obj.layersConfig(layerIdx).maxEpochs;
                rbmParams.sparsity = obj.sparsity;
                dbn.addRBM( rbmParams );
            end
            
            %train
            tStart = tic;
            fprintf('Start DBN training: %s.\n', datetime);
            dbn.train( dataSet );
            fprintf('DBN train time used: %f seconds.\n', toc(tStart));
            
            features = dbn.getFeature( obj.rawData.data );
            
        end
    end
    
end

