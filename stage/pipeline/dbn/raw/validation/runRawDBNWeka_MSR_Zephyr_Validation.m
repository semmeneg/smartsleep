% Apply trained DBN model and Weka classifier model to a dataset

tic
clear();

LOG = Log.getLogger();

% Common properties
sourceFolderPatterns = {[CONF.BASE_DATA_PATH '2016_01-05_Persons\Patient27*']};

sourceDataFolders = getFolderList(sourceFolderPatterns);

modelsFolder = [CONF.BASE_OUTPUT_PATH '2017-03-11_Raw_DBN_Weka_with_MSR_Zephyr_normalized_persons_04-16\'];
outputFolder = [modelsFolder 'validation\Patient27\'];
[s, mess, messid] = mkdir(outputFolder);

selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};
dataSources = {'MSR', 'Zephyr'};

%_____________________________________________________________________________________________________________________________________
% Preprocess MSR
% ------------------------------------------------------------------------------------------------------------------------------------
preprocessor = MSRPreprocessorBuilder(selectedClasses, sourceDataFolders, outputFolder).build();
dataSets = preprocessor.run();

sensors = [];
sensors{end+1} = dataSets;

%_____________________________________________________________________________________________________________________________________
% Preprocess Zephyr
% ------------------------------------------------------------------------------------------------------------------------------------
preprocessor = ZephyrPreprocessorBuilder(selectedClasses, sourceDataFolders, outputFolder).build();
dataSets = preprocessor.run();

sensors{end+1} = dataSets;
% ------------------------------------------------------------------------------------------------------------------------------------

sensorDataMerger = NamedDataSetsIntersection();
[ mergedDataSets ] = sensorDataMerger.run(sensors);


dataSource = strjoin(dataSources, '_');

% Load DBN trained model
dbnLearnedModelFolder = [ modelsFolder 'dbn\'];
dbnLearnedModelFile = [dbnLearnedModelFolder 'dbn_trainedModel_' dataSource '.mat'];
load(dbnLearnedModelFile, 'dbn');

higherOrderFeaturesDBN = [];
higherOrderFeaturesDBN.features = dbn.getFeature( mergedDataSets{1}.data );
higherOrderFeaturesDBN.labels = mergedDataSets{1}.labels;

% write ARFF files
arffFileName = [ outputFolder 'dbn_created_features__' dataSource '.arff'];
writer = WekaArffFileWriter(higherOrderFeaturesDBN.features, higherOrderFeaturesDBN.labels, selectedClasses, arffFileName);
writer.run();

% run Weka classifier
trainedModelFileName = ['weka_out__' dataSource '.model'];
textResultFileName = ['weka_out_confusion_matrix__' dataSource '.txt'];
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], outputFolder, trainedModelFileName, textResultFileName, csvResultFileName, dataSource);
classifier.run();

toc
