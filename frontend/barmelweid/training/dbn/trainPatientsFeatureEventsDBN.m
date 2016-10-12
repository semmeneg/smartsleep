function [ dbn ] = trainPatientsFeatureEventsDBN( allPatientsDataPath, ...
    allPatientsDataFilePrefix, wekaPath )
%TRAINPATIENTDBN load mat file with data, features and labels of each patient
%   Set parameters like stratisfaction (training, validation and test
%   data), DBN layer count and units, ...

    load( [ allPatientsDataPath allPatientsDataFilePrefix '.mat' ] );

    dbnPath = [ allPatientsDataPath 'DBN\' ];
    fileNamePathPrefix = [ dbnPath allPatientsDataFilePrefix ];

    mkdir( dbnPath );
    
    allData = [];
    allLabels = [];
    eventClasses = allPatients{ 1 }.filteredEvents.classes;

    for i = 1 : length( allPatients )
        p = allPatients{ i };

        allData = [ allData; p.combinedData ];
        allLabels = [ allLabels; p.combinedLabels ];
    end

    % forgot to remove nans in MSR, need to do it here for safety, because
    % a nan would lead to NaN in all results => no use at all
    nanIdx = isnan( allData );
    allData( nanIdx ) = 0;
    
    params.dataStratification =  [ 0.6 0.2 0.2 ];
    params.uniformClassDistribution = false;
    params.extractFeatures = true;
    params.hiddenUnitsCount = 4 * size( allData, 2 );   % NOTE: more hidden-units increase performance dramatically, 4 is best, beyond that only increase in training-time but not classification performance
    params.hiddenLayers = 2;    % NOTE: 2 is optimum, more hidden layers decrease classification 
    params.lastLayerHiddenUnits = params.hiddenUnitsCount;  % equals
    params.maxEpochs = 150;     % NOTE: 150 Epochs seem to be enough, more would only increase training time but not classification
    params.normalize = false;   % NOTE: MUST NOT do normalizing, would lead to catastrophic classification using feature-vectors due to min-max
    params.sparse = false;      % NOTE: non-sparse seems to deliver better classification than with sparsity 

    [ dbn ] = genericDBNTrain( allData, allLabels, params );

    classifiedLabels = dbn.net.getOutput( allData );
    [ cm ] = calcCM( eventClasses, classifiedLabels, allLabels );
    
    totalSamples = length( allLabels );
    totalCorrect = trace( cm );
    totalWrong = totalSamples - totalCorrect;
    
    fid = fopen( [ fileNamePathPrefix '_DBN.txt' ], 'w' );

    fprintf( fid, '%s %12d\n', 'Total Number of Instances ', totalSamples );
    fprintf( fid, '%s %7d  %4.2f%%\n', 'Correctly Classified Instances', totalCorrect, 100 * ( totalCorrect / totalSamples ) );
    fprintf( fid, '%s %6d  %4.2f%%\n', 'Incorrectly Classified Instances', totalWrong, 100 * ( totalWrong / totalSamples ) );
    
    fprintf( fid, '\n\n' );
    printCMStandard( fid, eventClasses, cm, false );
    fprintf( fid, '\n\n' );
    printCMStandard( fid, eventClasses, transformCMToRelative( cm ), true );
    fclose( fid );
    
    save( [ fileNamePathPrefix '_DBN.mat' ], 'dbn' );
    
    arffFileName = [ fileNamePathPrefix '_DBNFEATURES.arff' ];
    channelNames = cell( params.lastLayerHiddenUnits, 1 );
    
    for i = 1 : params.lastLayerHiddenUnits
        channelNames{ i } = sprintf( 'FEATURE_%d', i );
    end
    
    exportGenericToWeka( dbn.features, allLabels, eventClasses, ...
        'Barmelweid DBN-Features', arffFileName, channelNames );
    
    trainWEKAModel( wekaPath, arffFileName, ...
        [ fileNamePathPrefix '_DBNFEATURES.model' ], ...
        [ fileNamePathPrefix '_DBNFEATURES_WEKARESULT.txt' ] );
end
