
tic

clear();

CONF.setup();

 disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
 
dataSourceSubFolder = '2016-11-11_Features';
dataResultSubFolder = '2016-11-11_Features';
 
 dataStratificationRatios = [1.0 0.4 0.0];
 splitByPatients = true; %If true, data stratification is applied the group of patients, otherwise to the combined data set of all patients is stratisfied.
%  feautreFilter = [FEATURES.ENERGY FEATURES.MAX FEATURES.RMS FEATURES.SKEWNESS FEATURES.STD FEATURES.VECTOR_NORM ];
feautreFilter = [];
 
fileNamePrefix = 'allpatients_EVENTS_';

applyWekaClassifier = true;
 
 % Clean csv result file since we will just append intermediate results to the file later
 csvFile = [CONF.ALL_PATIENTS_CLASSIFIED_WEKA_DATA_PATH dataResultSubFolder '\cm.csv'];
 if (exist(csvFile, 'file') == 2)
    delete(csvFile);
 end

 % EEG
 [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.EEG);
 trainPatientsFeatureEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG);
 
 % EEG & MSR
 [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.EEG, DATA_SOURCE.MSR);
 trainPatientsFeatureEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.MSR);
 
 % EEG & MSR & ZEPHYR
 [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.EEG, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
 trainPatientsFeatureEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
 
 % EEG & ZEPHYR
 [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.EEG, DATA_SOURCE.ZEPHYR);
 trainPatientsFeatureEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.ZEPHYR);
 
 MSR
 [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.MSR);
 trainPatientsFeatureEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.MSR);

 % MSR & ZEPHYR
 [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
 trainPatientsFeatureEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);

 % ZEPHYR
 [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios,  DATA_SOURCE.ZEPHYR);
 trainPatientsFeatureEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.ZEPHYR);
 

 disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
toc
