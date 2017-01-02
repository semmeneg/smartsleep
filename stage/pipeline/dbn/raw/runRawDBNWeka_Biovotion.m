% Create higher order features with DBN and run
% Weka Random Forest classifer on merged data input.

tic
clear();

LOG = Log.getLogger();

% Common properties
dataInputFolder = '2016_12_Patients';
processingOutputFolder = '2016-01-02_Raw_DBN_Weka_with_Biovotion';
BASE_PATH = [CONF.BASE_DATA_PATH dataInputFolder '\'];
% BASE_PATH = [CONF.BASE_DATA_PATH 'Test\' dataInputFolder];

selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};
dataSources = {'Biovotion'};

% process Biovotion
selectedRawDataChannels = { 'Value05','Value06','Value07','Value08','Value09','Value10','Value11' };
samplingFrequency = 51.2; % Biovotion frequency: ~51.2 Hz
assumedEventDuration = 30; % seconds

props = [];
props.dataSource = dataSources{1};
props.rawDataSetsFolderPattern = [ BASE_PATH '\P*' ];
props.basePath = BASE_PATH;
props.sensorsRawDataFilePatterns = {'*.txt'};
props.sensorDataReader = BiovotionCsvReader(selectedRawDataChannels, 11); 
props.dataAndLabelMerger = BiovotionRawDataAndLabelMerger(samplingFrequency, selectedRawDataChannels, selectedClasses, assumedEventDuration);

preprocessor = DataSetsPreprocessor(props);
dataSets = preprocessor.run();


sensors = [];
sensors{end+1} = dataSets;

sensorDataMerger = NamedDataSetsIntersection();
[ mergedDataSets ] = sensorDataMerger.run(sensors);

%Split data(sets) in trainings and validation data
dataSplit = [0.6, 0.4, 0.0];
splittedData = DataGroupsStratificator(mergedDataSets, dataSplit);

resultFolder = [ BASE_PATH '\processed\' CONF.WEKA_DATA_SUBFOLDER '\'  processingOutputFolder];
[s, mess, messid] = mkdir(resultFolder);

% Run DBN (RBM)
dbnInputData.data = splittedData.trainData;
dbnInputData.labels = splittedData.trainLabels;
dbnInputData.validationData = splittedData.validationData;
dbnInputData.validationLabels = splittedData.validationLabels;

inputComponents = floor(size( dbnInputData.data, 2 ));
SETUP_LOG = SetupLog([resultFolder '\setup.log']);
SETUP_LOG.log(strjoin(dataSources, ' & '));
SETUP_LOG.log('Pipeline: Rawdata > DBN > Weka(RandomForest,10foldCross)');
SETUP_LOG.log([ 'DBN data split (training:validation:test): ' num2str(dataSplit) ]);
SETUP_LOG.log(sprintf('%s %d', 'Rawdata components:', inputComponents));
layersConfig =[struct('hiddenUnitsCount', floor(inputComponents /4), 'maxEpochs', 50); ...
               struct('hiddenUnitsCount', floor(inputComponents * 4), 'maxEpochs', 50)];

rbmTrainer = RBMFeaturesTrainer(layersConfig, dbnInputData);
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
arffFileName = [ resultFolder '\dbn_created_features__' dataSource '.arff'];
writer = WekaArffFileWriter(higherOrderFeaturesDBN.features, higherOrderFeaturesDBN.labels, selectedClasses, arffFileName);
writer.run();

% run Weka classifier
trainedModelFileName = ['weka_out__' dataSource '.model'];
textResultFileName = ['weka_out_confusion_matrix__' dataSource '.txt'];
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], resultFolder, trainedModelFileName, textResultFileName, csvResultFileName, dataSource);
classifier.run();

toc
