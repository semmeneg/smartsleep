% Create higher order features with DBN and run
% Weka Random Forest classifer on merged data input.

tic
clear();

LOG = Log.getLogger();

% Common properties
dataInputFolder = '2016_01-05_Persons';
processingOutputFolder = '2016-12-23_Raw_DBN_Weka_with_Zephyr';
BASE_PATH = [CONF.BASE_DATA_PATH dataInputFolder '\'];
% BASE_PATH = [CONF.BASE_DATA_PATH 'Test\' dataInputFolder];

selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};
dataSources = {'Zephyr'};

sensors = [];

% Process Zephyr data
props = [];
props.rawDataSetsFolderPattern = [ BASE_PATH '\Patient*' ];
props.basePath = BASE_PATH;
props.selectedRawDataChannels = { 'HR', 'BR', 'PeakAccel', ...
    'BRAmplitude', 'ECGAmplitude', ...
    'VerticalMin', 'VerticalPeak', ...
    'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };
props.mandatoryChannelsName = { 'HR', 'BR' };
props.samplingFrequency = 1; % Hz
props.assumedEventDuration = 30; % seconds
props.selectedClasses = selectedClasses;

preprocessor = ZephyrPreprocessor(props);
zephyrDataSets = preprocessor.run();

sensors{end+1} = zephyrDataSets;

sensorDataMerger = NamedDataSetsIntersection();
[ mergedDataSets ] = sensorDataMerger.run(sensors);

%Split data(sets) in trainings and validation data
splittedData = DataGroupsStratificator(mergedDataSets, [1.0, 0.0, 0.0]);

resultFolder = [ BASE_PATH '\processed\' CONF.WEKA_DATA_SUBFOLDER '\'  processingOutputFolder];
[s, mess, messid] = mkdir(resultFolder);

% Run DBN (RBM)
dbnInputData.data = splittedData.trainData;
dbnInputData.labels = splittedData.trainLabels;

inputComponents = floor(size( dbnInputData.data, 2 ));
SETUP_LOG = SetupLog([resultFolder '\setup.log']);
SETUP_LOG.log(strjoin(dataSources, ' & '));
SETUP_LOG.log('Pipeline: Rawdata > DBN > Weka(RandomForest,10foldCross)');
SETUP_LOG.log(sprintf('%s %d', 'Rawdata components:', inputComponents));
layersConfig =[struct('hiddenUnitsCount', floor(inputComponents * 4), 'maxEpochs', 150); ...
               struct('hiddenUnitsCount', floor(inputComponents * 4), 'maxEpochs', 150)];

rbmTrainer = RBMFeaturesTrainer(layersConfig, dbnInputData);
SETUP_LOG.logDBN(rbmTrainer.getDBN());
higherOrderFeaturesDBN = rbmTrainer.run();

% Save DBN trained model
dataSource = strjoin(dataSources, '_');
dbnLearnedModelFolder = [ BASE_PATH '\processed\' CONF.DBN_DATA_SUBFOLDER '\'  processingOutputFolder];
[s, mess, messid] = mkdir(dbnLearnedModelFolder);
dbnLearnedModelFile = [dbnLearnedModelFolder '\dbn_trainedModel_' dataSource '.mat'];
dbn = rbmTrainer.getDBN();
save(dbnLearnedModelFile, 'dbn');

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
