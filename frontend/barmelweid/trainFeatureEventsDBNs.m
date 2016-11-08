
tic

CONF.setup();

 disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
 
dataSourceSubFolder = '2016-11-08_Zephyr_Features';
dataResultSubFolder = '2016-11-08_Zephyr_Features_2_hidden_1_classification_layer'; 

% dataSourceSubFolder = '2016-06';
% dataResultSubFolder = '2016-06';
 
%  dataStratificationRatios = [0.9 0.1 0.0];
 dataStratificationRatios = [1.0 0.4 0.0];
 splitByPatients = false; %If true, data stratification is applied the group of patients, otherwise to the combined data set of all patients is stratisfied.
%  feautreFilter = [FEATURES.ENERGY FEATURES.MAX FEATURES.RMS FEATURES.SKEWNESS FEATURES.STD FEATURES.VECTOR_NORM ];
feautreFilter = [];
 
%  dataStratificationRatios = [0.6 0.2 0.2];
%  splitByPatients = false;
%  feautreFilter = [];

fileNamePrefix = 'allpatients_WINDOWS_';

applyWekaClassifier = true;
 
 % Clean csv result file since we will just append intermediate results to the file later
 csvFile = [CONF.ALL_PATIENTS_CLASSIFIED_WEKA_DATA_PATH dataResultSubFolder '\cm.csv'];
 if (exist(csvFile, 'file') == 2)
    delete(csvFile);
 end

%  % EEG
%  [dataSet, eventClasses] = createFilteredFeaturesDataSet(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.EEG);
%  trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG);
%  
%  % EEG & MSR
%  [dataSet, eventClasses] = createFilteredFeaturesDataSet(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.EEG, DATA_SOURCE.MSR);
%  trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.MSR);
%  
%  % EEG & MSR & ZEPHYR
%  [dataSet, eventClasses] = createFilteredFeaturesDataSet(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.EEG, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
%  trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
%  
%  % EEG & ZEPHYR
%  [dataSet, eventClasses] = createFilteredFeaturesDataSet(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.EEG, DATA_SOURCE.ZEPHYR);
%  trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.ZEPHYR);
%  
%  % MSR
%  [dataSet, eventClasses] = createFilteredFeaturesDataSet(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.MSR);
%  trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.MSR);
% 
%  % MSR & ZEPHYR
%  [dataSet, eventClasses] = createFilteredFeaturesDataSet(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
%  trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);

 % ZEPHYR
 [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.ZEPHYR);
 trainPatientsFeatureEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.ZEPHYR);
 

 disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
toc
