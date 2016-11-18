% Call only Weka training with paths to already existing data stored in a
% ARFF file.

CONF.setupJava();

dataResultSubFolder = 'Enter subfolder here ...';
sources = {DATA_SOURCE.MSR DATA_SOURCE.ZEPHYR};

trainedDataResultPath = [CONF.ALL_PATIENTS_TRAINED_DNB_DATA_PATH dataResultSubFolder '\'];
classifiedDataResultPath = [CONF.ALL_PATIENTS_CLASSIFIED_WEKA_DATA_PATH dataResultSubFolder '\'];
allPatientsDataFilePrefix = ['allpatients_RAWEVENTS_' strjoin(sources, '_') ];

arffFileName = [ trainedDataResultPath '_DBN.arff' ];

trainedModelFileName = [ classifiedDataResultPathAndFilenamePrefix '_DBN.model' ];
textResultFileName = [ classifiedDataResultPathAndFilenamePrefix '_DBN_WEKARESULT.txt' ];
description = ['Weka classification for sources ' strjoin(varargin, ' & ')];

wekaClassifier = WekaClassifier(arffFileName, classifiedDataResultPath, trainedModelFileName, textResultFileName, 'cm.csv', description);
wekaClassifier.run();

