% This is a testpipeline to verify new object oriented code.

tic
clear();

LOG = Log.getLogger();

% Common properties
p.dataInputFolder = '2016_01-05_Persons';
p.processingOutputFolder = '2016-11-24_PipelineTest_HandcraftedFeat_Zephyr_Weka_inclusivePatient26';
% p.BASE_PATH = [CONF.BASE_DATA_PATH p.dataInputFolder '\'];
p.BASE_PATH = [CONF.BASE_DATA_PATH 'Test\' p.dataInputFolder '\'];

p.selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};
p.dataSources = {'Zephyr'};

files = dir( [ p.BASE_PATH 'Patient*' ] );
p.allPatientFolders = files( [ files.isdir ] );
p.patientCount = length( p.allPatientFolders );

% Process Zephyr data
aggregationFunctions = { @energyFeature, @meanFeature, @rootMeanSquareFeature, ...
    @skewnessFeature, @stdFeature, @sumFeature, @vecNormFeature };

selectedRawDataChannels = { 'HR', 'BR', 'PeakAccel', ...
    'BRAmplitude', 'ECGAmplitude', ...
    'VerticalMin', 'VerticalPeak', ...
    'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };

samplingFrequency = 1; % Hz
assumedEventDuration = 30; % seconds
mandatoryChannelsName = { 'HR', 'BR' };

allTime = [];
allData = [];
allLabels = [];
allPatients = [];

for i = 1 : p.patientCount
    patienFolderName = p.allPatientFolders( i ).name;
    
    LOG.trace('Zephyr', fprintf('Process patient: %s\n', patienFolderName));
    % parse labeled events
    labeledEventsFile = [p.BASE_PATH patienFolderName '\1_raw\*.txt' ];
    sleepPhaseParser = SleepPhaseEventParser(labeledEventsFile);
    labeledEvents = sleepPhaseParser.run();
    
    % parse raw data
    csvFile = [p.BASE_PATH patienFolderName '\1_raw\' p.dataSources{1} '\*_Summary.csv' ];
    rawDataReader = ZephyrCsvReader(csvFile, selectedRawDataChannels);
    rawData = rawDataReader.run();
    if(isempty(rawData))
        disp('No data found for person.');
        continue;
    end
    rawData.channelNames = selectedRawDataChannels;
    data = rawData.data;
    data(isnan(data)) = 0;
    
    % merge label and events
    LOG.trace('Zephyr', 'merge patient labels and data');
    merger = ZephyrAggregatedDataAndLabelMerger(labeledEvents, rawData, mandatoryChannelsName, p.selectedClasses, aggregationFunctions);
    [ data, time, labels, channelNames ] = merger.run();
    
    % combine features and labels of all patients
    allTime = [allTime ; data];
    allData = [allData ; data];
    allLabels = [allLabels ; labels];
    
end

allData(isnan(allData)) = 0;

wekaFolder = [ p.BASE_PATH '\processed\' CONF.WEKA_DATA_SUBFOLDER '\'  p.processingOutputFolder];
[s, mess, messid] = mkdir(wekaFolder);

% write ARFF file
dataSource = strjoin(p.dataSources, '_');
arffFileName = [ wekaFolder '\handcrafted_features__' dataSource '.arff'];
writer = WekaArffFileWriter(allData, allLabels, p.selectedClasses, arffFileName);
writer.run();

% run Weka classifier
trainedModelFileName = ['weka_out__' dataSource '.model'];
textResultFileName = ['weka_out_confusion_matrix__' dataSource '.txt'];
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], wekaFolder, trainedModelFileName, textResultFileName, csvResultFileName, dataSource);
classifier.run();


