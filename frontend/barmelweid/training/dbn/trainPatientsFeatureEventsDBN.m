function [ dbn ] = trainPatientsFeatureEventsDBN( resultPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, varargin )
%trainPatientsFeatureEventsDBN load mat file with data, features and labels of each patient
%   Set parameters like stratisfaction (training, validation and test
%   data), DBN layer count and units, ...

    disp( ['DBN-Training on events of ' strjoin(varargin, ' & ') ' ...'] );

    allPatientsDataFilePrefix = ['allpatients_EVENTS_' strjoin(varargin, '_') ];
    
    allData = [dataSet.trainData; dataSet.validationData; dataSet.testData ];
    
    params.extractFeatures = true;
    params.hiddenUnitsCount = 4 * size( allData, 2 );   % NOTE: more hidden-units increase performance dramatically, 4 is best, beyond that only increase in training-time but not classification performance
    params.hiddenLayers = 2;    % NOTE: 2 is optimum, more hidden layers decrease classification 
    params.lastLayerHiddenUnits = params.hiddenUnitsCount;  % equals
    params.maxEpochs = 150;     % NOTE: 150 Epochs seem to be enough, more would only increase training time but not classification
    params.normalize = false;   % NOTE: MUST NOT do normalizing, would lead to catastrophic classification using feature-vectors due to min-max
    params.sparse = false;      % NOTE: non-sparse seems to deliver better classification than with sparsity 

    [ dbn ] = genericDBNTrain( dataSet, params );

    classifiedLabels = dbn.net.getOutput( allData );
    allLabels = [dataSet.trainLabels; dataSet.validationLabels; dataSet.testLabels ];
    
    [ cm ] = calcCM( eventClasses, classifiedLabels, allLabels);
    
    totalSamples = length( allLabels );
    totalCorrect = trace( cm );
    totalWrong = totalSamples - totalCorrect;
    
    mkdir( resultPath );
    resultPathAndFilenamePrefix = [ resultPath allPatientsDataFilePrefix ];    
    
    fid = fopen( [ resultPathAndFilenamePrefix '_DBN.txt' ], 'w' );

    fprintf( fid, 'DNB ratios: traing=%4.2f validation=%4.2f test=%4.2f\n', dataStratificationRatios);    
    
    fprintf( fid, '%s %12d\n', 'Total Number of Instances ', totalSamples );
    fprintf( fid, '%s %7d  %4.2f%%\n', 'Correctly Classified Instances', totalCorrect, 100 * ( totalCorrect / totalSamples ) );
    fprintf( fid, '%s %6d  %4.2f%%\n', 'Incorrectly Classified Instances', totalWrong, 100 * ( totalWrong / totalSamples ) );
    
    fprintf( fid, '\n\n' );
    printCMStandard( fid, eventClasses, cm, false );
    fprintf( fid, '\n\n' );
    printCMStandard( fid, eventClasses, transformCMToRelative( cm ), true );
    fclose( fid );
    
    save( [ resultPathAndFilenamePrefix '_DBN.mat' ], 'dbn' );
    
    channelNames = cell( params.lastLayerHiddenUnits, 1 );
    
    for i = 1 : params.lastLayerHiddenUnits
        channelNames{ i } = sprintf( 'FEATURE_%d', i );
    end
    
    if(applyWekaClassifier)
        
        arffFileName = [ resultPathAndFilenamePrefix '_DBNFEATURES.arff' ];
    
        exportGenericToWeka( dbn.features, allLabels, eventClasses, ...
            'Barmelweid DBN-Features', arffFileName, channelNames );

        trainWEKAModel( CONF.WEKA_PATH, arffFileName, ...
            [ resultPathAndFilenamePrefix '_DBNFEATURES.model' ], ...
            [ resultPathAndFilenamePrefix '_DBNFEATURES_WEKARESULT.txt' ] );
        
        %appent Weka results to csv file
        appendWekaResult2Csv(resultPath, 'cm.csv', varargin{:}); 
    end
    
    disp( ['Finished DBN-Training on events ' strjoin(varargin, ' & ') '.'] );    
end
