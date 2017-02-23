% Create higher order features with DBN and run
% Weka Random Forest classifer on merged data input.

tic
clear();

LOG = Log.getLogger();

% Common properties
%sourceFolderPatterns = {[CONF.BASE_DATA_PATH '2016_10-11_Patients\P*' ], [CONF.BASE_DATA_PATH '2016_12_Patients\P*'], [CONF.BASE_DATA_PATH '2017_01_Patients\P*' ]};
sourceFolderPatterns = {[CONF.BASE_DATA_PATH '2016_12_Patients\P12*'], ...
[CONF.BASE_DATA_PATH '2016_12_Patients\P13*'], ...
[CONF.BASE_DATA_PATH '2016_12_Patients\P16*'], ...
[CONF.BASE_DATA_PATH '2016_12_Patients\P17*'], ...
[CONF.BASE_DATA_PATH '2017_01_Patients\P18*'], ...
[CONF.BASE_DATA_PATH '2017_01_Patients\P19*'], ...
[CONF.BASE_DATA_PATH '2017_01_Patients\P20*'], ...
[CONF.BASE_DATA_PATH '2017_01_Patients\P21*'], ...
[CONF.BASE_DATA_PATH '2017_01_Patients\P25*']};

sourceDataFolders = getFolderList(sourceFolderPatterns);

outputFolder = [CONF.BASE_OUTPUT_PATH '2017-02-22_Raw_DBN_Weka_with_Biovotion_value6-7\'];
% outputFolder = [CONF.BASE_OUTPUT_PATH '2017-02-15_Test\'];
[s, mess, messid] = mkdir(outputFolder);

selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};
dataSources = {'Biovotion'};

SETUP_LOG = SetupLog([outputFolder 'setup.log']);
SETUP_LOG.log(strjoin(dataSources, ' & '));
SETUP_LOG.log('Pipeline: Rawdata > DBN > Weka(RandomForest,10foldCross)');
SETUP_LOG.log(['Datafolders: ' join({sourceDataFolders.name}, ', ')]);

% process Biovotion
% selectedRawDataChannels = { 'Value05','Value06','Value07','Value08','Value09','Value10','Value11' };
selectedRawDataChannels = { 'Value06','Value07','Value08' };
samplingFrequency = 51.2; % Biovotion frequency: ~51.2 Hz
assumedEventDuration = 30; % seconds

props = [];
props.dataSource = dataSources{1};
props.selectedClasses = selectedClasses;
props.sourceDataFolders = sourceDataFolders;
props.outputFolder = outputFolder;
props.sensorsRawDataFilePatterns = {'*.txt'};struct
props.sensorDataReader = BiovotionCsvReader(selectedRawDataChannels, 11);
props.sensorChannelDataTransformer = ChannelDataTransformer({'Value06','Value07','Value08'}, selectedRawDataChannels, @(values)values-min(values));
props.dataAndLabelMerger = BiovotionRawDataAndLabelMerger(samplingFrequency, selectedRawDataChannels, selectedClasses, assumedEventDuration);
props.print = true;

preprocessor = DataSetsPreprocessor(props);
dataSets = preprocessor.run();


sensors = [];
sensors{end+1} = dataSets;

sensorDataMerger = NamedDataSetsIntersection();
[ mergedDataSets ] = sensorDataMerger.run(sensors);

%Split data(sets) in trainings and validation data
dataSplit = [0.7, 0.3, 0.0];
splittedData = DataGroupsStratificator(mergedDataSets, dataSplit);

% Run DBN (RBM)
dbnInputData.data = splittedData.trainData;
dbnInputData.labels = splittedData.trainLabels;
dbnInputData.validationData = splittedData.validationData;
dbnInputData.validationLabels = splittedData.validationLabels;

inputComponents = floor(size( dbnInputData.data, 2 ));
SETUP_LOG.log([ 'DBN data split (training:validation:test): ' num2str(dataSplit) ]);
SETUP_LOG.log(sprintf('%s %d', 'Rawdata components:', inputComponents));
layersConfig =[struct('hiddenUnitsCount', floor(inputComponents /2), 'maxEpochs', 10); ...
               struct('hiddenUnitsCount', floor(inputComponents /3), 'maxEpochs', 10)];

rbmTrainer = RBMFeaturesTrainer(layersConfig, dbnInputData, false);
SETUP_LOG.logDBN(rbmTrainer.getDBN());
higherOrderFeaturesDBN = rbmTrainer.run();

dataSource = strjoin(dataSources, '_');

% Save DBN trained model
% dbnLearnedModelFolder = [ BASE_PATH '\processed\' CONF.DBN_DATA_SUBFOLDER '\'  processingOutputFolder];
% [s, mess, messid] = mkdir(dbnLearnedModelFolder);
% dbnLearnedModelFile = [dbnLearnedModelFolder '\dbn_trainedModel_' dataSource '.mat'];
% dbn = rbmTrainer.getDBN();
% save(dbnLearnedModelFile, 'dbn');

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