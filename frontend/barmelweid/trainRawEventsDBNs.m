tic

clear();

CONF.setupJava();

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
 
 dataSourceSubFolder = '2016-11-16_RAW_MSR_Zephyr';
 dataResultSubFolder = '2016-11-16_RAW_MSR_Zephyr_2';

 applyDBNClassifier = false;
 % dataStratificationRatios = [0.6 0.4 0.0];
 dataStratificationRatios = [1.0 0.0 0.0]; % if we do not apply DBN classifier, no validation data is used.
 splitByPatients = true; %If true, data stratification is applied the group of patients, otherwise to the combined data set of all patients is stratisfied.
 
 applyWekaClassifier = true;
 outputPath = [CONF.getRawDataOutputPathWithTimestamp() '\'];
    
 fileNamePrefix = 'allpatients_RAWEVENTS_';

 % Zephyr
% [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios, DATA_SOURCE.ZEPHYR);
% trainPatientsRawEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyDBNClassifier, applyWekaClassifier, DATA_SOURCE.ZEPHYR);

% MSR
% [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios, DATA_SOURCE.MSR);
% trainPatientsRawEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyDBNClassifier, applyWekaClassifier, DATA_SOURCE.MSR);

[dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
trainPatientsRawEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyDBNClassifier, applyWekaClassifier, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);

 
% trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyDBNClassifier, applyWekaClassifier, DATA_SOURCE.EEG);
%  
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyDBNClassifier, applyWekaClassifier, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyDBNClassifier, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.MSR);
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyDBNClassifier, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.ZEPHYR);
%  
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyDBNClassifier, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);

 disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
toc