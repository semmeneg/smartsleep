function [ dbn ] = trainPatientsRawEventsDBN( dataResultSubFolder, dataSet, eventClasses, applyDBNClassifier, applyWekaClassifier, useSplitForWeka, varargin )
%trainPatientsRawEventsDBN load raw data mat file with data, features and labels of each patient
%   Set parameters like stratisfaction (training, validation and test
%   data), DBN layer count and units, 

    disp( [' Raw data DBN-Training on events of ' strjoin(varargin, ' & ') ' ...'] );

    trainedDataResultPath = [CONF.ALL_PATIENTS_TRAINED_DNB_DATA_PATH dataResultSubFolder '\'];
    classifiedDataResultPath = [CONF.ALL_PATIENTS_CLASSIFIED_WEKA_DATA_PATH dataResultSubFolder '\'];

    allPatientsDataFilePrefix = ['allpatients_RAWEVENTS_' strjoin(varargin, '_') ];
    
    allData = [dataSet.trainData; dataSet.validationData; dataSet.testData ];
    allLabels = [dataSet.trainLabels; dataSet.validationLabels; dataSet.testLabels ];
    
    params.extractFeatures = true;
    params.normalize = false;   % NOTE: MUST NOT do normalizing, would lead to catastrophic classification using feature-vectors due to min-max
    params.sparse = false;      % NOTE: non-sparse seems to deliver better classification than with sparsity 

    layers = [];
    %RBM 1
    layerParams1.hiddenUnitsCount = size( allData, 2 );
%     layerParams1.hiddenUnitsCount = floor(size( allData, 2 ) / 4);
    layerParams1.maxEpochs = 50;
    layers = [layers layerParams1];
    
    %RBM 2
    layerParams2.hiddenUnitsCount =  floor(size( allData, 2 ) / 2);
    layerParams2.maxEpochs = 50;
    layers = [layers layerParams2];
    
    %RBM 3
%     layerParams3.hiddenUnitsCount = 2 * size( allData, 2 );
%     layerParams3.maxEpochs = 100;
%     layers = [layers layerParams3];    
    
    params.lastLayerHiddenUnits = layerParams2.hiddenUnitsCount;
    
    [ dbn ] = genericDBNTrain( dataSet, params, layers, applyDBNClassifier );
    
    
    
    dbn.features = dbn.net.getFeature( allData );
    
    trainedDataResultPathAndFilenamePrefix = [ trainedDataResultPath allPatientsDataFilePrefix ];
    mkdir( trainedDataResultPath );

    % get labels classified by DBN if enabled
    if (applyDBNClassifier)
        classifiedLabels = dbn.net.getOutput( allData );
        [ mc ] = calcCM( eventClasses, classifiedLabels, allLabels);
        fid = fopen( [ trainedDataResultPathAndFilenamePrefix '_DBN.txt' ], 'w' );
        printCM( fid, eventClasses, cm );
        fclose( fid );
    end
    
    tStart = tic;
    fprintf('Start saving DBN trained model: %s.\n', datetime);
    save( [ trainedDataResultPathAndFilenamePrefix '_DBN.mat' ], 'dbn' );
    fprintf('Time used for saving DBN trained model: %f seconds.\n', toc(tStart));
    
    if(applyWekaClassifier)
        
        % Weka input: write features and labels to ARFF file
        if(useSplitForWeka)
            features = dbn.net.getFeature(dataSet.trainData);
            labels = dataSet.trainLabels;
            
            validationFeatures = dbn.net.getFeature(dataSet.validationData);
            validationLabels = dataSet.validationLabels;
            validationArffFileName = [ trainedDataResultPathAndFilenamePrefix '_validation_DBN.arff' ];
            wekaArffFileWriter = WekaArffFileWriter(validationFeatures, validationLabels, eventClasses, validationArffFileName);
            wekaArffFileWriter.run();
        else
            features = dbn.net.getFeature(allData);
            labels = allLabels;
            validationArffFileName = [];
        end
            
        arffFileName = [ trainedDataResultPathAndFilenamePrefix '_DBN.arff' ];
        wekaArffFileWriter = WekaArffFileWriter(features, labels, eventClasses, arffFileName);
        wekaArffFileWriter.run();
        
        trainedModelFileName = [ allPatientsDataFilePrefix '_DBN.model' ];
        textResultFileName = [ allPatientsDataFilePrefix '_DBN_WEKARESULT.txt' ];
        description = ['Weka classification for sources ' strjoin(varargin, ' & ')];
        
        wekaClassifier = WekaClassifier(arffFileName, validationArffFileName, classifiedDataResultPath, trainedModelFileName, textResultFileName, 'cm.csv', description);
        wekaClassifier.run();
%         
%         channelNames = cell( size(dbn.features,2), 1 );
%     
%         for i = 1 : size(dbn.features,2)
%             channelNames{ i } = sprintf( 'FEATURE_%d', i );
%         end
%         
%         arffFileName = [ trainedDataResultPathAndFilenamePrefix '_DBN.arff' ];
%     
%         tStart = tic;
%         fprintf('Start saving DBN output to ARFF file for Weka: %s.\n', datetime);
%         exportGenericToWeka( dbn.features, allLabels, eventClasses, ...
%             'Barmelweid DBN on raw data', arffFileName, channelNames );
%         fprintf('Time used saving DBN output to ARFF file: %f seconds.\n', toc(tStart));
%         
%         mkdir(classifiedDataResultPath);
% 
%         classifiedDataResultPathAndFilenamePrefix = [ classifiedDataResultPath allPatientsDataFilePrefix ];    
% 
%         tStart = tic;
%         fprintf('Start Weka classification training: %s.\n', datetime);
%         trainWEKAModel( CONF.WEKA_PATH, arffFileName, ...
%             [ trainedDataResultPathAndFilenamePrefix '_DBN.model' ], ...
%             [ classifiedDataResultPathAndFilenamePrefix '_DBN_WEKARESULT.txt' ] );
%         fprintf('Weka training time used: %f seconds.\n', toc(tStart));
%         
%         appent Weka results to csv file
%         wekaResultFileName = [allPatientsDataFilePrefix '_DBN_WEKARESULT.txt' ];
%         appendWekaResult2Csv(classifiedDataResultPath, wekaResultFileName, 'cm.csv', varargin{:}); 
    end
end

function [defaultRbmParameters] = createDefaultRbmParameters(allDataSize)

     defaultHiddenUnitsCount = 4 * allDataSize; % PAPER: Paper takes 4 times the input size, NOTE: more hidden-units increase performance dramatically, 4 is best, beyond that only increase in training-time but not classification performance
     defaultMaxEpochs = 150;     % NOTE: 150 Epochs seem to be enough, more would only increase training time but not classification
    
    defaultRbmParameters = RbmParameters( defaultHiddenUnitsCount, ValueType.binary );
    defaultRbmParameters.samplingMethodType = SamplingClasses.SamplingMethodType.CD;
    defaultRbmParameters.performanceMethod = 'reconstruction';
    defaultRbmParameters.maxEpoch = defaultMaxEpochs;
    defaultRbmParameters.sparsity = false; % NOTE: non-sparse seems to deliver better classification than with sparsity 
end
