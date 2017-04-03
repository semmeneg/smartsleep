% Create higher order features with DBN and run
% Weka Random Forest classifer on merged data input.
tic
clear();

LOG = Log.getLogger();

% Common properties
sourceFolderPatterns = {[CONF.BASE_DATA_PATH '2016_01-05_Persons\Patient*']};
%sourceFolderPatterns = {[CONF.BASE_DATA_PATH '2016_01-05_Persons\Patient01*']};

sourceDataFolders = getFolderList(sourceFolderPatterns);

outputFolder = [CONF.BASE_OUTPUT_PATH '2017-03-17_Raw_DBN__Zephyr__normalized_overall_persons_1-27\'];
[s, mess, messid] = mkdir(outputFolder);

selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};
dataSources = {'Zephyr'};

SETUP_LOG = SetupLog([outputFolder 'setup.log']);
SETUP_LOG.log(strjoin(dataSources, ' & '));
SETUP_LOG.log('Pipeline: Rawdata > DBN > Weka(RandomForest,10foldCross)');
SETUP_LOG.log(['Datafolders: ' join({sourceDataFolders.name}, ', ')]);

% ---- Preprocess Zephyr -----------
preprocessor = ZephyrPreprocessorBuilder(selectedClasses, sourceDataFolders, outputFolder).build();
dataSets = preprocessor.run();

sensors = [];
sensors{end+1} = dataSets;

sensorDataMerger = NamedDataSetsIntersection();
[ mergedDataSets ] = sensorDataMerger.run(sensors);

%Split data(sets) in trainings and validation data
dataSplit = [0.7, 0.3, 0.0];
splittedData = DataGroupsStratificator(mergedDataSets, dataSplit);

SETUP_LOG.log(sprintf('Trainings data lowest value: %d',  min(min(splittedData.trainData))));
SETUP_LOG.log(sprintf('Trainings data highest value: %d',  max(max(splittedData.trainData))));

% Run DBN (RBM)
dbnInputData.data = splittedData.trainData;
dbnInputData.labels = splittedData.trainLabels;
dbnInputData.validationData = splittedData.validationData;
dbnInputData.validationLabels = splittedData.validationLabels;

inputComponents = floor(size( dbnInputData.data, 2 ));
SETUP_LOG.log([ 'DBN data split (training:validation:test): ' num2str(dataSplit) ]);
SETUP_LOG.log(sprintf('%s %d', 'Rawdata components:', inputComponents));
layersConfig =[struct('hiddenUnitsCount', floor(inputComponents *4), 'maxEpochs', 150); ...
    struct('hiddenUnitsCount', floor(inputComponents *4), 'maxEpochs', 150)];

rbmTrainer = RBMFeaturesTrainer(layersConfig, dbnInputData, true);
SETUP_LOG.logDBN(rbmTrainer.getDBN());
higherOrderFeaturesDBN = rbmTrainer.run();

dataSource = strjoin(dataSources, '_');

% Save DBN trained model
dbnLearnedModelFolder = [ outputFolder '\dbn\'];
[s, mess, messid] = mkdir(dbnLearnedModelFolder);
dbnLearnedModelFile = [dbnLearnedModelFolder '\dbn_trainedModel_' dataSource '.mat'];
dbn = rbmTrainer.getDBN();
save(dbnLearnedModelFile, 'dbn');

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
