function [ dbn ] = trainPatientsRawEventsDBN( allPatientsDataPath, ...
    allPatientsDataFilePrefix )
%TRAINPATIENTDBN Summary of this function goes here
%   Detailed explanation goes here

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

    windowSampleSize = size( allData, 2 ); 
    
%     fftData = fft( allData );
%     Px = fftData .* conj( fftData ) / ( windowSampleSize * windowSampleSize ); 
%     allData = Px( :, 1 : floor( windowSampleSize / 2.0 ) );


    params.dataStratification =  [ 0.6 0.2 0.2 ];
    params.uniformClassDistribution = false;
    params.extractFeatures = true;

    params.hiddenUnitsCount = 4 * windowSampleSize;   % NOTE: more hidden-units increase performance dramatically, 4 is best, beyond that only increase in training-time but not classification performance
    params.hiddenLayers = 2;    % NOTE: 2 is optimum, more hidden layers decrease classification 
    params.lastLayerHiddenUnits = params.hiddenUnitsCount;  % equals
    params.maxEpochs = 150;     % NOTE: 150 Epochs seem to be enough, more would only increase training time but not classification
    params.normalize = false;   % NOTE: MUST NOT do normalizing, would lead to catastrophic classification using feature-vectors due to min-max
    params.sparse = false;      % NOTE: non-sparse seems to deliver better classification than with sparsity 

    [ dbn ] = genericDBNTrain( allData, allLabels, params );

    classifiedLabels = dbn.net.getOutput( allData );
    [ cm ] = calcCM( eventClasses, classifiedLabels, allLabels );
    
    
    fid = fopen( [ fileNamePathPrefix '_DBN.txt' ], 'w' );
    printCM( fid, eventClasses, cm );
    fclose( fid );
    
    save( [ fileNamePathPrefix '_DBN.mat' ], 'dbn' );
end
