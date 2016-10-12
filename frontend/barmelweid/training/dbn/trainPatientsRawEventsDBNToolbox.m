function [ dbn ] = trainPatientsRawEventsDBNToolbox( allPatientsDataPath, ...
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

    dataStratification = [ 0.6 0.2 0.2 ];
    dbnData = setupDBNData( allLabels, allData, dataStratification, false, false );
    
    % train a reconstruciton DBN with layer sizes 1000-500-250-30 (same as in Hinton
    % and Salakhutdinov 2006 Science paper)
    % set RBM params (could make into a cell array for each RBM if we wanted
    % different params)
    rbmParams.strID = 'clsf'; % used in model filename
    rbmParams.outDir = ['out' filesep];	% where the file will be written
    rbmParams.numEpochs = 150; % number of complete passes through data, usually want more than this
    rbmParams.verbosity = 1; % means that model is written to file but epoch error written to console

    % set DBN params
    dbnParams.strID = 'clsf';
    dbnParams.outDir = ['out' filesep];	
    dbnParams.numEpochs = 150;
    dbnParams.verbosity = 1;

    hiddenUnitsCount = 4 * windowSampleSize;  
    
    dbn = TrainDeepNN( [ hiddenUnitsCount hiddenUnitsCount ] ,'RBM', rbmParams, dbnParams, ...
        dbnData.trainData, dbnData.validationData, dbnData.trainLabels, dbnData.validationLabels );
    
    % make label predictions, subtract 1 b/c labels start at 1 but index starts at 1
    [~,predLabels] = max(dbn.PropLayerActivs( dbnData.testData ),[],2); 
    predLabels = predLabels - 1;

    [ cm ] = calcCM( eventClasses, predLabels, dbnData.testLabels );
    
    fid = fopen( [ fileNamePathPrefix '_DBN.txt' ], 'w' );
    printCM( fid, eventClasses, cm );
    fclose( fid );
    
    save( [ fileNamePathPrefix '_DBN.mat' ], 'dbn' );
end
