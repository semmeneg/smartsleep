% Runs a Restricted Bolzman Machine implementation to derrive higher order
% features from a set of input features.
%
classdef RBMFeaturesTrainer
    
    properties(Constant)
        sparsity = false;
    end
    
    properties
        rawData = [];
        dbn;
        backpropagation = false;
    end
    
    methods
        % Constructor
        %
        % param layersConfig is expected to be an array of hiddenLayer configurations (structs with 'hiddenUnitsCount', 'maxEpochs')
        % param rawData is a struct with 'labels', 'data', 'channelNames' (optional)
        % param backpropagation (boolean), enable backpropagation in case of validatoin data provided.
        function obj = RBMFeaturesTrainer(layersConfig, rawData, backpropagation)

            % Init DBN
            obj.dbn = DBN( 'classifier' );
            for layerIdx = 1 : length(layersConfig)
                rbmParams = RbmParameters( layersConfig(layerIdx).hiddenUnitsCount, ValueType.binary );
                rbmParams.samplingMethodType = SamplingClasses.SamplingMethodType.CD;
                rbmParams.performanceMethod = 'reconstruction';
                rbmParams.maxEpoch = layersConfig(layerIdx).maxEpochs;
                rbmParams.sparsity = obj.sparsity;
                obj.dbn.addRBM( rbmParams );
            end
            
            obj.rawData = rawData;
            
            if(nargin > 2)
                obj.backpropagation = backpropagation;
            end
        end
        
        % Returns a features struct with data and labels
        function [ resultSet ] = run(obj)
            
            Log.getLogger().infoStart(class(obj), 'run');
            
            resultSet = [];
            resultSet.labels = obj.rawData.labels;
            resultSet.features = [];
            
            dataSet = DataClasses.DataStore();
            dataSet.valueType = ValueType.gaussian;
            dataSet.trainData = obj.rawData.data;
            dataSet.trainLabels = obj.rawData.labels;
            if(isfield(obj.rawData, 'validationData') &&  ~isempty(obj.rawData.validationData))
                dataSet.validationData = obj.rawData.validationData;
                dataSet.validationLabels = obj.rawData.validationLabels;
            end
            
            dataSet.shuffle();
                        
            %train
            tStart = tic;
            fprintf('Start DBN training: %s.\n', datetime);
            obj.dbn.train( dataSet );
            fprintf('DBN train time used: %f seconds.\n', toc(tStart));
            
            %backpropagation
            if(obj.backpropagation)
                tStart = tic;
                fprintf('Start DBN backpropagation: %s.\n', datetime);
                obj.dbn.backpropagation( dataSet );
                fprintf('DBN backpropagation time used: %f seconds.\n', toc(tStart));
            end
            
            resultSet.features = obj.dbn.getFeature( obj.rawData.data );
            
            Log.getLogger().infoEnd(class(obj), 'run');
            
        end
        
        function dbn = getDBN(obj)
            dbn = obj.dbn;
        end
    end
    
end

