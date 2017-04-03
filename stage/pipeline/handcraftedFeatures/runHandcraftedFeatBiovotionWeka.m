% Create handcrafted features by applying a set of aggregation functions to
% the set of data for each event window and channel.
% Apply Weka Random Forest classifer on merged data input.

tic
clear();

LOG = Log.getLogger();

% Common properties
sourceFolderPatterns = {[CONF.BASE_DATA_PATH '2016_10-11_Patients\P*' ], [CONF.BASE_DATA_PATH '2016_12_Patients\P*'], [CONF.BASE_DATA_PATH '2017_01_Patients\P*' ]};

sourceDataFolders = getFolderList(sourceFolderPatterns);

outputFolder = [CONF.BASE_OUTPUT_PATH '2017-04-03_HandcraftedFeatures_Biovotion_patients01-27\'];
[s, mess, messid] = mkdir(outputFolder);

selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};
dataSources = {'Biovotion'};

SETUP_LOG = SetupLog([outputFolder 'setup.log']);
SETUP_LOG.log(strjoin(dataSources, ' & '));
SETUP_LOG.log('Pipeline: Rawdata > Handcrafted features > Weka(RandomForest,10foldCross)');
SETUP_LOG.log(['Datafolders: ' join({sourceDataFolders.name}, ', ')]);

% ---- Preprocess Biovotion --------
dataAndLabelMerger
builder = BiovotionPreprocessorBuilder(selectedClasses, sourceDataFolders, outputFolder, dataAndLabelMerger);
builder.sensorChannelDataTransformer = [];
builder.dataAndLabelMerger = DefaultAggregatedDataAndLabelMerger(builder.samplingFrequency, builder.mandatoryChannelsName, builder.selectedClasses, builder.assumedEventDuration);

SETUP_LOG.log(['Channels: ' builder.selectedRawDataChannels]);
dataSets = builder.build().run();

% merge datasets
data = [];
labels = [];
for dataSet = dataSets
    data = [data ; dataSet{end}.data];
    labels = [labels ; dataSet{end}.labels];
end

dataSource = strjoin(dataSources, '_');

% write ARFF files
arffFileName = [ outputFolder 'dbn_created_features__' dataSource '.arff'];
writer = WekaArffFileWriter(data, labels, selectedClasses, arffFileName);
writer.run();

% run Weka classifier
trainedModelFileName = ['weka_out__' dataSource '.model'];
textResultFileName = ['weka_out_confusion_matrix__' dataSource '.txt'];
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], outputFolder, trainedModelFileName, textResultFileName, csvResultFileName, dataSource);
classifier.run();

toc
