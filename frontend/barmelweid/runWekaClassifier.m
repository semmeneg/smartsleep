% Loads features, labels and classes from given matlab source, prepares
% Weka input file and runs the Weka Random Forest classifier with
% 10foldCross validation.

inputSubFolder = '2016-11-24_Features';
inputArffFileName = 'allpatients_EVENTS_MSR_ZEPHYR.arff';

outputSubFolder = '2016-11-24_Handcrafted_Features_MSR_Zephyr';

arffFile = [CONF.ALL_PATIENTS_DATA_PATH CONF.PREPROCESSED_DATA_SUBFOLDER  '\' inputSubFolder '\' inputArffFileName];
resultFolderPath = [CONF.ALL_PATIENTS_DATA_PATH CONF.CLASSIFIED_DATA_SUBFOLDER '\Weka\' outputSubFolder ];
trainedModelFileName = 'allpatients_MSR_ZEPHYR_FEATURES_WEKARESULT.model';
textResultFileName = 'allpatients_MSR_ZEPHYR_FEATURES_WEKARESULT.txt';
csvResultFileName = 'cm.csv';

classifier = WekaClassifier(arffFile, [], resultFolderPath, trainedModelFileName, textResultFileName, csvResultFileName, 'MSR & Zephyr');
classifier.run();