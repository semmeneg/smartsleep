% Call only Weka training with paths to already existing data stored in a
% ARFF file.

clear();

CONF.setupJava();

dataResultSubFolder = '2016-11-16_RAW_MSR';

sources = {DATA_SOURCE.MSR};

allPatientsDataFilePrefix = ['allpatients_RAWEVENTS_' strjoin(sources, '_') ];

%Input
trainedDataResultPath = [CONF.ALL_PATIENTS_TRAINED_DNB_DATA_PATH dataResultSubFolder '\'];
arffFileName = [ trainedDataResultPath allPatientsDataFilePrefix '_DBN.arff' ];

%Output
classifiedDataResultPath = [CONF.ALL_PATIENTS_CLASSIFIED_WEKA_DATA_PATH dataResultSubFolder '\'];
trainedModelFileName = [ allPatientsDataFilePrefix '_DBN.model' ];
textResultFileName = [ allPatientsDataFilePrefix '_DBN_WEKARESULT.txt' ];
description = ['Weka classification for sources ' strjoin(sources, ' & ')];

wekaClassifier = WekaClassifier(arffFileName, classifiedDataResultPath, trainedModelFileName, textResultFileName, 'cm.csv', description);
wekaClassifier.run();



