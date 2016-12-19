function [ dataSet, eventClasses ] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataSplit, varargin )
%splitDataSets Creates a data set instance
%(DataClasses.DataStore()), splits the data into training and validation
%data and finally filters handrafted features and channels if defined.

    if ( sum( [ dataSplit(1) dataSplit(2) dataSplit(3)] ) ~= 1.0 )
        error('Data split ratio (training,validation,... must sum up to 1.0');
    end

    load( [ CONF.ALL_PATIENTS_PREPROCESSED_DATA_PATH dataSourceSubFolder '\' fileNamePrefix strjoin(varargin, '_') '.mat' ] );

    if(isfield(allPatients{1}, 'eventClasses'))
        eventClasses = allPatients{1}.eventClasses;
    else
        eventClasses = allPatients{1}.filteredEvents.classes;
    end
        
    if(splitByPatients)
        dataStratificator = PatientDataStratificator(allPatients, dataSplit);
    else %split over all events
        allData = [];
        allLabels = [];
        for i = 1 : length( allPatients )
            p = allPatients{ i };
            if(isfield(p, 'combinedData'))
                allData = [ allData; p.combinedData ];
                allLabels = [ allLabels; p.combinedLabels ];
            end;
        end    
        
        dataStratificator = AllDataStratificator(allLabels, allData, dataSplit, false, false);       
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

end

