function [ dbn ] = trainPatientsFeatureEventsDBN( dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, varargin )
%trainPatientsFeatureEventsDBN load mat file with data, features and labels of each patient
%   Set parameters like stratisfaction (training, validation and test
%   data), DBN layer count and units, ...

    disp( ['DBN-Training on events of ' strjoin(varargin, ' & ') ' ...'] );
    
    trainedDataResultPath = [CONF.ALL_PATIENTS_TRAINED_DNB_DATA_PATH dataResultSubFolder '\'];
    classifiedDataResultPath = [CONF.ALL_PATIENTS_CLASSIFIED_WEKA_DATA_PATH dataResultSubFolder '\'];

    allPatientsDataFilePrefix = ['allpatients_WINDOWS_' strjoin(varargin, '_') ];
    
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
    
    totalSamples = length( allLabels );
    totalCorrect = trace( cm );
    totalWrong = totalSamples - totalCorrect;
    
    mkdir( trainedDataResultPath );
    trainedDataResultPathAndFilenamePrefix = [ trainedDataResultPath allPatientsDataFilePrefix ];    
    
    fid = fopen( [ trainedDataResultPathAndFilenamePrefix '_DBN.txt' ], 'w' );

    fprintf( fid, 'DNB ratios: traing=%4.2f validation=%4.2f test=%4.2f\n', dataStratificationRatios);        
    
    fprintf( fid, '%s %12d\n', 'Total Number of Instances ', totalSamples );
    fprintf( fid, '%s %7d  %4.2f%%\n', 'Correctly Classified Instances', totalCorrect, 100 * ( totalCorrect / totalSamples ) );
    fprintf( fid, '%s %6d  %4.2f%%\n', 'Incorrectly Classified Instances', totalWrong, 100 * ( totalWrong / totalSamples ) );
    
    fprintf( fid, '\n\n' );
    printCMStandard( fid, eventClasses, cm, false );
    fprintf( fid, '\n\n' );
    printCMStandard( fid, eventClasses, transformCMToRelative( cm ), true );
    fclose( fid );
    
    save( [ trainedDataResultPathAndFilenamePrefix '_DBN.mat' ], 'dbn' );
    
    channelNames = cell( params.lastLayerHiddenUnits, 1 );
    
    for i = 1 : params.lastLayerHiddenUnits
        channelNames{ i } = sprintf( 'FEATURE_%d', i );
    end
    
    if(applyWekaClassifier)
        
        arffFileName = [ trainedDataResultPathAndFilenamePrefix '_DBNFEATURES.arff' ];
    
        exportGenericToWeka( dbn.features, allLabels, eventClasses, ...
            'Barmelweid DBN-Features', arffFileName, channelNames );
        
        mkdir(classifiedDataResultPath);

        classifiedDataResultPathAndFilenamePrefix = [ classifiedDataResultPath allPatientsDataFilePrefix ];    
        trainWEKAModel( CONF.WEKA_PATH, arffFileName, ...
            [ trainedDataResultPathAndFilenamePrefix '_DBNFEATURES.model' ], ...
            [ classifiedDataResultPathAndFilenamePrefix '_DBNFEATURES_WEKARESULT.txt' ] );
        
        %appent Weka results to csv file
        wekaResultFileName = [allPatientsDataFilePrefix '_DBNFEATURES_WEKARESULT.txt' ];
        appendWekaResult2Csv(classifiedDataResultPath, wekaResultFileName, 'cm.csv', varargin{:}); 
    end
    
    disp( ['Finished DBN-Training on events ' strjoin(varargin, ' & ') '.'] );    
end
