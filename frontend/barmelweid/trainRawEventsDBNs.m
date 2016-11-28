tic

clear();

CONF.setupJava();

disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
 
 dataSourceSubFolder = '2016-11-14_RAW_MSR';
 dataResultSubFolder = '2016-11-24_RAW_MSR_L1x1_L2x0.5_50epochs';

 applyDBNClassifier = false;
 
 % data split (training/validation) can be applied to DBN or Weka classifier.
 dataSplit = [1.0 0.0 0.0];
 % dataSplit = [1.0 0.0 0.0]; 
 splitByPatients = true; %If true, data stratification is applied the group of patients, otherwise to the combined data set of all patients is stratisfied.
 
 applyWekaClassifier = true;
 useSplitForWeka = false; % enables split of training/validation data. Otherwise default is used (10foldCrossValidation).
 outputPath = [CONF.getRawDataOutputPathWithTimestamp() '\'];
    
 fileNamePrefix = 'allpatients_RAWEVENTS_';

 % Zephyr
% [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataSplit, DATA_SOURCE.ZEPHYR);
% trainPatientsRawEventsDBN(dataResultSubFolder, dataSet, eventClasses, applyDBNClassifier, applyWekaClassifier, useSplitForWeka, DATA_SOURCE.ZEPHYR);

% MSR
[dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataSplit, DATA_SOURCE.MSR);
trainPatientsRawEventsDBN(dataResultSubFolder, dataSet, eventClasses, applyDBNClassifier, applyWekaClassifier, useSplitForWeka, DATA_SOURCE.MSR);

% [dataSet, eventClasses] = splitDataSets(dataSourceSubFolder, fileNamePrefix, splitByPatients, dataSplit, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
% trainPatientsRawEventsDBN(dataResultSubFolder, dataSet, eventClasses, applyDBNClassifier, applyWekaClassifier, useSplitForWeka, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);

 
% trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataSplit, applyDBNClassifier, applyWekaClassifier, useSplitForWeka, DATA_SOURCE.EEG);
%  
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataSplit, applyDBNClassifier, applyWekaClassifier, useSplitForWeka, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataSplit, applyDBNClassifier, applyWekaClassifier, useSplitForWeka, DATA_SOURCE.EEG, DATA_SOURCE.MSR);
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataSplit, applyDBNClassifier, applyWekaClassifier, useSplitForWeka, DATA_SOURCE.EEG, DATA_SOURCE.ZEPHYR);
%  
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataSplit, applyDBNClassifier, applyWekaClassifier, useSplitForWeka, DATA_SOURCE.EEG, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);

 disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
toc