tic

CONF.setup();

 disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
 
%  dataStratificationRatios = [0.9 0.1 0.0];
 dataStratificationRatios = [0.001 0.001 0.998];
%  splitByPatients = true; %If true, data stratification is applied the group of patients, otherwise to the combined data set of all patients is stratisfied.
%  testDescription = 'Patients split ';
 
 testDescription = 'Combined data split';
 splitByPatients = false;
 
 applyWekaClassifier = true;
 outputPath = [CONF.getRawDataOutputPathWithTimestamp() '\'];


%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.MSR);
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.ZEPHYR);
 trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG);
%  
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.MSR);
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.ZEPHYR);
%  
%  trainPatientsRawEventsDBN(testDescription, outputPath, splitByPatients, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);

 disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
toc