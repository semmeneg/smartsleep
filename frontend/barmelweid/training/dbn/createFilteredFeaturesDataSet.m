function [ dataSet, eventClasses ] = createFilteredFeaturesDataSet(splitByPatients, dataStratificationRatios, includeFeatureVectors, varargin )
%createFilteredFeaturesDataSet Creates a data set instance
%(DataClasses.DataStore()), splits the data into training and validation
%data and finally filters handrafted features and channels if defined.

    load( [ CONF.ALL_PATIENTS_DATA_PATH 'allpatients_EVENTS_' strjoin(varargin, '_') '.mat' ] );

    eventClasses = allPatients{ 1 }.filteredEvents.classes;
    
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
        
        dataStratificator = AllDataStratificator(eventClasses, allLabels, allData, dataStratificationRatios, false, false);       
    end
       
    dataSet = DataClasses.DataStore();
    dataSet.valueType = ValueType.probability;
    if(isempty(includeFeatureVectors))
        dataSet.trainData = dataStratificator.trainData;
        dataSet.trainLabels = dataStratificator.trainLabels;
        dataSet.validationData = dataStratificator.validationData;
        dataSet.validationLabels = dataStratificator.validationLabels;
        dataSet.testData = dataStratificator.testData;
        dataSet.testLabels = dataStratificator.testLabels;    
    else
        componentCount = length(allPatients{ 1 }.combinedChannels);
        includeFeatureVectors = 1:FEATURES.getFeaturesCount():componentCount;
        dataSet.trainData = dataStratificator.trainData(:,includeFeatureVectors);
        dataSet.trainLabels = dataStratificator.trainLabels;
        dataSet.validationData = dataStratificator.validationData(:,includeFeatureVectors);
        dataSet.validationLabels = dataStratificator.validationLabels;
        dataSet.testData = dataStratificator.testData(:,includeFeatureVectors);
        dataSet.testLabels = dataStratificator.testLabels; 
    end

    % forgot to remove nans in MSR, need to do it here for safety, because
    % a nan would lead to NaN in all results => no use at all
    dataSet.trainData( isnan( dataSet.trainData ) ) = 0;
    dataSet.validationData( isnan( dataSet.validationData ) ) = 0;
    dataSet.testData( isnan( dataSet.testData ) ) = 0;

end

