function [ dbn ] = trainPatientsRawEventsDBN( testDescription, resultPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, varargin )
%trainPatientsRawEventsDBN load raw data mat file with data, features and labels of each patient
%   Set parameters like stratisfaction (training, validation and test
%   data), DBN layer count and units, 

    disp( ['DBN-Training on events of ' strjoin(varargin, ' & ') ' ...'] );

    allPatientsDataFilePrefix = ['allpatients_RAWEVENTS_' strjoin(varargin, '_') ];
    load( [ CONF.ALL_PATIENTS_DATA_PATH allPatientsDataFilePrefix '.mat' ] );

    mkdir( resultPath );
    resultPathAndFilenamePrefix = [ resultPath allPatientsDataFilePrefix ];
    
    if(splitByPatients)
        dataStratificator = PatientDataStratificator(allPatients, dataStratificationRatios);
    else %split over all events
        allData = [];
        allLabels = [];
        for i = 1 : length( allPatients )
            p = allPatients{ i };

            allData = [ allData; p.combinedData ];
            allLabels = [ allLabels; p.combinedLabels ];
        end    
        eventClasses = allPatients{ 1 }.filteredEvents.classes;
        dataStratificator = AllDataStratificator(eventClasses, allLabels, allData, dataStratificationRatios, false, false);       
    end
       
    dataSet = DataClasses.DataStore();
    dataSet.valueType = ValueType.probability;
    dataSet.trainData = dataStratificator.trainData;
    dataSet.trainLabels = dataStratificator.trainLabels;
    dataSet.validationData = dataStratificator.validationData;
    dataSet.validationLabels = dataStratificator.validationLabels;
    dataSet.testData = dataStratificator.testData;
    dataSet.testLabels = dataStratificator.testLabels;    

    % forgot to remove nans in MSR, need to do it here for safety, because
    % a nan would lead to NaN in all results => no use at all
    dataSet.trainData( isnan( dataSet.trainData ) ) = 0;
    dataSet.validationData( isnan( dataSet.validationData ) ) = 0;
    dataSet.testData( isnan( dataSet.testData ) ) = 0;
    
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
    
    [ cm ] = calcCM( dataStratificator.classes, classifiedLabels, allLabels);
    
    
    fid = fopen( [ resultPathAndFilenamePrefix '_DBN.txt' ], 'w' );
    printCM( fid, dataStratificator.classes, cm );
    fclose( fid );
    
    save( [ resultPathAndFilenamePrefix '_DBN.mat' ], 'dbn' );
end
