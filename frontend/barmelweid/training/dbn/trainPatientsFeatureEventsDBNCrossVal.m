function [ dbn ] = trainPatientsFeatureEventsDBNCrossVal( allPatientsDataPath, ...
    allPatientsDataFilePrefix, wekaPath, ratio )
%TRAINPATIENTDBN Summary of this function goes here
%   Detailed explanation goes here

    load( [ allPatientsDataPath allPatientsDataFilePrefix '.mat' ] );
    patientCount = length( allPatients );
    
    dbnPath = [ allPatientsDataPath 'DBN\' ];
        mkdir( dbnPath );

    splitPercent = ratio;
    splitIdx = floor( patientCount * splitPercent );
    
    patientsHalf1 = allPatients( 1 : splitIdx );
    patientsHalf2 = allPatients( splitIdx + 1 : end );

    xvalPath = [ dbnPath 'CrossValidation\' ];
    fileNamePathPrefix = [ xvalPath 'XValidation_DBN_' allPatientsDataFilePrefix ];
    mkdir( xvalPath );
    
    patient1Labels = [];
    patient1Data = [];
    eventClasses = allPatients{ 1 }.filteredEvents.classes;
    
    for i = 1 : length( patientsHalf1 )
        patient = patientsHalf1{ i };

        patient1Labels = [ patient1Labels; patient.combinedLabels ];
        patient1Data = [ patient1Data; patient.combinedData ];
    end

    % forgot to remove nans in MSR, need to do it here for safety, because
    % a nan would lead to NaN in all results => no use at all
    nanIdx = isnan( patient1Data );
    patient1Data( nanIdx ) = 0;
    
    params.dataStratification =  [ 0.6 0.2 0.2 ];
    params.uniformClassDistribution = false;
    params.extractFeatures = true;
    params.hiddenUnitsCount = 4 * size( patient1Data, 2 );   % NOTE: more hidden-units increase performance dramatically, 4 is best, beyond that only increase in training-time but not classification performance
    params.hiddenLayers = 3;    % NOTE: 2 is optimum, more hidden layers decrease classification 
    params.lastLayerHiddenUnits = params.hiddenUnitsCount;  % equals
    params.maxEpochs = 150;     % NOTE: 150 Epochs seem to be enough, more would only increase training time but not classification
    params.normalize = false;   % NOTE: MUST NOT do normalizing, would lead to catastrophic classification using feature-vectors due to min-max
    params.sparse = false;      % NOTE: non-sparse seems to deliver better classification than with sparsity 

    [ dbn ] = genericDBNTrain( patient1Data, patient1Labels, params );
    patient1Features = dbn.features;
    
    save( [ fileNamePathPrefix '.mat' ], 'dbn' );
     
    % EXPORT FEATURES TO WEKA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    patient1ArffFileName = [ fileNamePathPrefix '_FIRST_DBNFEATURES.arff' ];
    patient1ModelFileName = [ fileNamePathPrefix '_DBNFEATURES.model' ];
    channelNames = cell( params.lastLayerHiddenUnits, 1 );
    
    for i = 1 : params.lastLayerHiddenUnits
        channelNames{ i } = sprintf( 'FEATURE_%d', i );
    end
    
    exportGenericToWeka( patient1Features, patient1Labels, eventClasses, ...
        'Barmelweid DBN-Features', patient1ArffFileName, channelNames );
    
    trainWEKAModel( wekaPath, patient1ArffFileName, ...
        patient1ModelFileName, ...
        [ fileNamePathPrefix '_DBNFEATURES_WEKARESULT.txt' ] );
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % CLASSIFY 40% patients, generate their features and export TO WEKA %%
    patient2Labels = [];
    patient2Data = [];

    for i = 1 : length( patientsHalf2 )
        patient = patientsHalf2{ i };

        patient2Labels = [ patient2Labels; patient.combinedLabels ];
        patient2Data = [ patient2Data; patient.combinedData ];
    end
    
    patient2Features = dbn.net.getFeature( patient2Data );
    patient2ClassifiedLabels = dbn.net.getOutput( patient2Data );
    
    [ cm ] = calcCM( eventClasses, patient2ClassifiedLabels, patient2Labels );
    totalSamples = length( patient2Labels );
    totalCorrect = trace( cm );
    totalWrong = totalSamples - totalCorrect;
    
    fid = fopen( [ fileNamePathPrefix '_DBNCLASSIFICATION_CROSSCLASSIFICATIONRESULT.txt' ], 'w' );
    fprintf( fid, '%s %12d\n', 'Total Number of Instances ', totalSamples );
    fprintf( fid, '%s %7d  %4.2f%%\n', 'Correctly Classified Instances', totalCorrect, 100 * ( totalCorrect / totalSamples ) );
    fprintf( fid, '%s %6d  %4.2f%%\n', 'Incorrectly Classified Instances', totalWrong, 100 * ( totalWrong / totalSamples ) );
    fprintf( fid, '\n\n' );
    printCMStandard( fid, eventClasses, cm, false );
    fprintf( fid, '\n\n' );
    printCMStandard( fid, eventClasses, transformCMToRelative( cm ), true );
    fclose( fid );
    
    patient2ArffFileName = [ fileNamePathPrefix '_SECOND_DBNFEATURES.arff' ];
    
    exportGenericToWeka( patient2Features, patient2Labels, eventClasses, ...
        'Barmelweid DBN-Features', patient2ArffFileName, channelNames );
        
    [ output ] = classifyWithWEKAModel( wekaPath, ...
        patient1ModelFileName, patient2ArffFileName, false );
    
    crossValResultsFile = [ fileNamePathPrefix '_WEKACLASSIFICATION_CROSSCLASSIFICATIONRESULT.txt' ];
    
    writeTextToFile( output, crossValResultsFile );
end
