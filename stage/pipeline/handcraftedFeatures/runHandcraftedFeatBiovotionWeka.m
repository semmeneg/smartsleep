% Create handcrafted features by applying a set of aggregation functions to
% the set of data for each event window and channel.
% Apply Weka Random Forest classifer on merged data input.

tic
clear();

LOG = Log.getLogger();

% Common properties
sourceFolderPatterns = {[CONF.BASE_DATA_PATH '2016_10-11_Patients\P*' ], [CONF.BASE_DATA_PATH '2016_12_Patients\P*'], [CONF.BASE_DATA_PATH '2017_01_Patients\P*' ]};
%sourceFolderPatterns = {[CONF.BASE_DATA_PATH '2016_10-11_Patients\PatientB01*' ]};

sourceDataFolders = getFolderList(sourceFolderPatterns);

outputFolder = [CONF.BASE_OUTPUT_PATH '2017-04-04_HandcraftedFeatures_Biovotion_patients01-27_with_normalization\'];
%outputFolder = [CONF.BASE_OUTPUT_PATH 'test\'];

[s, mess, messid] = mkdir(outputFolder);

selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};
dataSources = {'Biovotion'};

SETUP_LOG = SetupLog([outputFolder 'setup.log']);
SETUP_LOG.log(strjoin(dataSources, ' & '));
SETUP_LOG.log('Pipeline: Rawdata > Handcrafted features > Weka(RandomForest,10foldCross)');
SETUP_LOG.log(['Datafolders: ' join({sourceDataFolders.name}, ', ')]);

% ---- Preprocess Biovotion --------
builder = BiovotionPreprocessorBuilder(selectedClasses, sourceDataFolders, outputFolder);
aggregationFunctions = { @energyFeature, @meanFeature, @rootMeanSquareFeature, ...
    @skewnessFeature, @stdFeature, @sumFeature, @vecNormFeature };
%builder.sensorChannelDataTransformers = {};
builder.sensorChannelDataTransformers{end} = ChannelDataAggregationFunctionTransformer(builder.selectedRawDataChannels, builder.selectedRawDataChannels, aggregationFunctions);

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
