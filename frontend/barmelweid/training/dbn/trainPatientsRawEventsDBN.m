function [ dbn ] = trainPatientsRawEventsDBN( dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, varargin )
%trainPatientsRawEventsDBN load raw data mat file with data, features and labels of each patient
%   Set parameters like stratisfaction (training, validation and test
%   data), DBN layer count and units, 

    disp( [' Raw data DBN-Training on events of ' strjoin(varargin, ' & ') ' ...'] );

    trainedDataResultPath = [CONF.ALL_PATIENTS_TRAINED_DNB_DATA_PATH dataResultSubFolder '\'];
    classifiedDataResultPath = [CONF.ALL_PATIENTS_CLASSIFIED_WEKA_DATA_PATH dataResultSubFolder '\'];

    allPatientsDataFilePrefix = ['allpatients_RAWEVENTS_' strjoin(varargin, '_') ];
    
    allData = [dataSet.trainData; dataSet.validationData; dataSet.testData ];
    
    params.extractFeatures = true;
    params.hiddenUnitsCount = 4 * size(allData, 2);   % NOTE: more hidden-units increase performance dramatically, 4 is best, beyond that only increase in training-time but not classification performance
    params.hiddenLayers = 2;    % NOTE: 2 is optimum, more hidden layers decrease classification 
    params.lastLayerHiddenUnits = params.hiddenUnitsCount;  % equals
    params.maxEpochs = 150;     % NOTE: 150 Epochs seem to be enough, more would only increase training time but not classification
    params.normalize = false;   % NOTE: MUST NOT do normalizing, would lead to catastrophic classification using feature-vectors due to min-max
    params.sparse = false;      % NOTE: non-sparse seems to deliver better classification than with sparsity 

    [ dbn ] = genericDBNTrain( dataSet, params );

    classifiedLabels = dbn.net.getOutput( allData );
    allLabels = [dataSet.trainLabels; dataSet.validationLabels; dataSet.testLabels ];
    
    [ cm ] = calcCM( eventClasses, classifiedLabels, allLabels);
    
    mkdir( trainedDataResultPath );
    trainedDataResultPathAndFilenamePrefix = [ trainedDataResultPath allPatientsDataFilePrefix ];    
    
    fid = fopen( [ trainedDataResultPathAndFilenamePrefix '_DBN.txt' ], 'w' );
    printCM( fid, eventClasses, cm );
    fclose( fid );
    
    save( [ trainedDataResultPathAndFilenamePrefix '_DBN.mat' ], 'dbn' );
    
    channelNames = cell( params.lastLayerHiddenUnits, 1 );
    
    for i = 1 : params.lastLayerHiddenUnits
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
