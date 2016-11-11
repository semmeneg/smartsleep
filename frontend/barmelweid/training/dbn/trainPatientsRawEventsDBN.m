function [ dbn ] = trainPatientsRawEventsDBN( dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, varargin )
%trainPatientsRawEventsDBN load raw data mat file with data, features and labels of each patient
%   Set parameters like stratisfaction (training, validation and test
%   data), DBN layer count and units, 

    disp( [' Raw data DBN-Training on events of ' strjoin(varargin, ' & ') ' ...'] );

    trainedDataResultPath = [CONF.ALL_PATIENTS_TRAINED_DNB_DATA_PATH dataResultSubFolder '\'];
    classifiedDataResultPath = [CONF.ALL_PATIENTS_CLASSIFIED_WEKA_DATA_PATH dataResultSubFolder '\'];

    allPatientsDataFilePrefix = ['allpatients_RAWEVENTS_' strjoin(varargin, '_') ];
    
    if ( sum( [ dataStratificationRatios(1) dataStratificationRatios(2) dataStratificationRatios(3)] ) ~= 1.0 )
        allData = [dataSet.trainData; dataSet.validationData; dataSet.testData ];
        allLabels = [dataSet.trainLabels; dataSet.validationLabels; dataSet.testLabels ];
    else
        allData = dataSet.trainData;
        allLabels = dataSet.trainLabels;
    end
    
 params.extractFeatures = true;
%     params.hiddenUnitsCount = 4 * size( allData, 2 );   % NOTE: more hidden-units increase performance dramatically, 4 is best, beyond that only increase in training-time but not classification performance
%     params.hiddenLayers = 2;    % NOTE: 2 is optimum, more hidden layers decrease classification 
%     params.lastLayerHiddenUnits = params.hiddenUnitsCount;  % equals
%     params.maxEpochs = 150;     % NOTE: 150 Epochs seem to be enough, more would only increase training time but not classification
    params.normalize = false;   % NOTE: MUST NOT do normalizing, would lead to catastrophic classification using feature-vectors due to min-max
    params.sparse = false;      % NOTE: non-sparse seems to deliver better classification than with sparsity 

    layers = [];
    %RBM 1
    layerParams1.hiddenUnitsCount = 4 * size( allData, 2 );   % NOTE: more hidden-units increase performance dramatically, 4 is best, beyond that only increase in training-time but not classification performance
    layerParams1.maxEpochs = 150;     % NOTE: 150 Epochs seem to be enough, more would only increase training time but not classification
    layers = [layers layerParams1];
    %RBM 2
    layerParams2.hiddenUnitsCount = 4 * size( allData, 2 ); 
    layerParams2.maxEpochs = 150; 
    layers = [layers layerParams2];
    
    params.lastLayerHiddenUnits = layerParams2.hiddenUnitsCount;
    
    [ dbn ] = genericDBNTrain( dataSet, params, layers );
    
    dbn.features = dbn.net.getFeature( allData );

    classifiedLabels = dbn.net.getOutput( allData );
    
    
    [ cm ] = calcCM( eventClasses, classifiedLabels, allLabels);
    
    mkdir( trainedDataResultPath );
    trainedDataResultPathAndFilenamePrefix = [ trainedDataResultPath allPatientsDataFilePrefix ];    
    
    fid = fopen( [ trainedDataResultPathAndFilenamePrefix '_DBN.txt' ], 'w' );
    printCM( fid, eventClasses, cm );
    fclose( fid );
    
    save( [ trainedDataResultPathAndFilenamePrefix '_DBN.mat' ], 'dbn' );
    
    channelNames = cell( size(dbn.features,2), 1 );
    
    for i = 1 : size(dbn.features,2)
        channelNames{ i } = sprintf( 'FEATURE_%d', i );
    end
    
    if(applyWekaClassifier)
        
        arffFileName = [ trainedDataResultPathAndFilenamePrefix '_DBN.arff' ];
    
        exportGenericToWeka( dbn.features, allLabels, eventClasses, ...
            'Barmelweid DBN on raw data', arffFileName, channelNames );
        
        mkdir(classifiedDataResultPath);

        classifiedDataResultPathAndFilenamePrefix = [ classifiedDataResultPath allPatientsDataFilePrefix ];    
        trainWEKAModel( CONF.WEKA_PATH, arffFileName, ...
            [ trainedDataResultPathAndFilenamePrefix '_DBN.model' ], ...
            [ classifiedDataResultPathAndFilenamePrefix '_DBN_WEKARESULT.txt' ] );
        
        %appent Weka results to csv file
        wekaResultFileName = [allPatientsDataFilePrefix '_DBN_WEKARESULT.txt' ];
        appendWekaResult2Csv(classifiedDataResultPath, wekaResultFileName, 'cm_raw.csv', varargin{:}); 
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
