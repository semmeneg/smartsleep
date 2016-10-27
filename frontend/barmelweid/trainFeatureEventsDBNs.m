
tic

CONF.setup();

 disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
 
%  dataStratificationRatios = [0.9 0.1 0.0];
 dataStratificationRatios = [1.0 0.4 0.0];
 splitByPatients = true; %If true, data stratification is applied the group of patients, otherwise to the combined data set of all patients is stratisfied.
%  feautreFilter = [FEATURES.ENERGY FEATURES.MAX FEATURES.RMS FEATURES.SKEWNESS FEATURES.STD FEATURES.VECTOR_NORM ];
feautreFilter = [];
 
%  dataStratificationRatios = [0.6 0.2 0.2];
%  splitByPatients = false;
%  feautreFilter = [];
  
 folderSuffix = '_100_40_split_1_HiddenLayer_All_Features';
%  folderSuffix = '_AllCombined_DNBRatio60-20-20';
 outputPath = [ CONF.getOutputPathWithTimestamp() folderSuffix '\']; 
 applyWekaClassifier = true;
 
 % Clean csv result file since we will just append intermediate results to the file later
 csvFile = [outputPath 'cm.csv'];
 if (exist(csvFile, 'file') == 2)
    delete(csvFile);
 end

 % EEG
 [dataSet, eventClasses] = createFilteredFeaturesDataSet(splitByPatients, dataStratificationRatios, feautreFilter , DATA_SOURCE.EEG);
 trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG);
 
 % EEG & MSR
 [dataSet, eventClasses] = createFilteredFeaturesDataSet(splitByPatients, dataStratificationRatios, feautreFilter , DATA_SOURCE.EEG, DATA_SOURCE.MSR);
 trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.MSR);
 
 % EEG & MSR & ZEPHYR
 [dataSet, eventClasses] = createFilteredFeaturesDataSet(splitByPatients, dataStratificationRatios, feautreFilter , DATA_SOURCE.EEG, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
 trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
 
 % EEG & ZEPHYR
 [dataSet, eventClasses] = createFilteredFeaturesDataSet(splitByPatients, dataStratificationRatios, feautreFilter , DATA_SOURCE.EEG, DATA_SOURCE.ZEPHYR);
 trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.EEG, DATA_SOURCE.ZEPHYR);
 
 % MSR
 [dataSet, eventClasses] = createFilteredFeaturesDataSet(splitByPatients, dataStratificationRatios, feautreFilter , DATA_SOURCE.MSR);
 trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.MSR);

 % MSR & ZEPHYR
 [dataSet, eventClasses] = createFilteredFeaturesDataSet(splitByPatients, dataStratificationRatios, feautreFilter , DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);
 trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR);

 % ZEPHYR
 [dataSet, eventClasses] = createFilteredFeaturesDataSet(splitByPatients, dataStratificationRatios, feautreFilter , DATA_SOURCE.ZEPHYR);
 trainPatientsFeatureEventsDBN(outputPath, dataSet, eventClasses, dataStratificationRatios, applyWekaClassifier, DATA_SOURCE.ZEPHYR);
 

 disp( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' );
toc
