tic

clear();

CONF.setup();

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
 
 dataSourceSubFolder = '2016-11-14_RAW_MSR';
 dataResultSubFolder = '2016-11-14_RAW_MSR';
 
 dataStratificationRatios = [0.9 0.1 0.0];
%   dataStratificationRatios = [0.0001 0.0001 0.0];

%  splitByPatients = true; %If true, data stratification is applied the group of patients, otherwise to the combined data set of all patients is stratisfied.
%  testDescription = 'Patients split ';
 
 testDescription = 'Combined data split';
 splitByPatients = false;
 
 applyWekaClassifier = true;
 outputPath = [CONF.getRawDataOutputPathWithTimestamp() '\'];
    
 fileNamePrefix = 'allpatients_RAWEVENTS_';

% [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios, DATA_SOURCE.ZEPHYR);
% trainPatientsRawEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.ZEPHYR);

[dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataStratificationRatios, DATA_SOURCE.MSR);
trainPatientsRawEventsDBN(dataResultSubFolder, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.MSR);

 
% trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG);
%  
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.MSR);
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.ZEPHYR);
%  
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);

 disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
toc