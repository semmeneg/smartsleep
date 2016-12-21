% Create higher order features with DBN of MSR and Zephyr and run
% Weka Random Forest classifer on merged data input.

tic
clear();

LOG = Log.getLogger();

% Common properties
p.dataInputFolder = '2016_01-05_Persons';
p.processingOutputFolder = '2016-12-21_Raw_DBN_Weka_with_MSR_Zephyr';
% p.BASE_PATH = [CONF.BASE_DATA_PATH p.dataInputFolder '\'];
p.BASE_PATH = [CONF.BASE_DATA_PATH 'Test\' p.dataInputFolder '\'];

p.selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};
p.dataSources = {'MSR', 'Zephyr'};

files = dir( [ p.BASE_PATH 'Patient*' ] );
p.allPatientFolders = files( [ files.isdir ] );
p.patientCount = length( p.allPatientFolders );

% process MSR
sensorsRawDataFilePatterns = {'*HAND.mat', '*FUSS.mat'};
samplingFrequency = ceil(19.7); % MSR 145B frequency: ~19.7 Hz (512/26) rounded up for interpolation
assumedEventDuration = 30; % seconds

selectedRawDataChannels = { 'ACC x', 'ACC y', 'ACC z' };
mandatoryChannelsName = selectedRawDataChannels;
allTime = [];
allLabels = [];
allData = [];

LOG.trace('MSR', '_____________ Start processing MSR data ____________');
for i = 1 : p.patientCount
    patienFolderName = p.allPatientFolders( i ).name;
    
    LOG.trace('MSR', sprintf('Process patient: %s\n', ['----' patienFolderName '----']));
    
    % parse labeled events
    sleepPhaseParser = SleepPhaseEventParser([p.BASE_PATH patienFolderName '\1_raw\*.txt' ]);
    labeledEvents = sleepPhaseParser.run();
    
    % process all sensors
    sensors = [];
    
    for sensorsRawDataFilePatternsIdx = 1 : length(sensorsRawDataFilePatterns)
        % parse raw data
        rawDataFile = [ p.BASE_PATH patienFolderName '\1_raw\' p.dataSources{1} '\' sensorsRawDataFilePatterns{sensorsRawDataFilePatternsIdx} ];
        reader = MSRMatlabReader(rawDataFile, selectedRawDataChannels);
        rawData = reader.run();
        if(isempty(rawData))
            LOG.trace('MSR', 'No data found for sensor.');
            continue;
        end
        rawData.channelNames = selectedRawDataChannels;
        
        % linear interpolate/decimate values to fit target sampling frequency
        LOG.trace('MSR', 'interpolate patient');
        interpolator = DiffSamplingRateInterpolation(samplingFrequency, rawData);
        interpolatedRawData = interpolator.run();
        
        % merge label and events
        LOG.trace('MSR', 'merge patient labels and data');
        merger = DefaultRawDataAndLabelMerger(samplingFrequency, labeledEvents, interpolatedRawData, mandatoryChannelsName, p.selectedClasses, assumedEventDuration);
        [ sensorData, sensorTime, sensorLabels, channelNames ] = merger.run();
        
        sensors{end+1} = struct('time', sensorTime, 'labels', sensorLabels, 'data', sensorData);
    end
    
    if(isempty(sensors))
        disp('No data found for person.');
        continue;
    end
    
    % Merge sensors data
    sensorDataMerger = TimedDataIntersection(sensors);
    [personTime, personLabels, personData ] = sensorDataMerger.run();
    
    % combine features and labels of all patients
    allTime = [allTime; personTime];
    allLabels = [allLabels ; personLabels];
    allData = [allData ; personData];
end

sensors = [];
sensors{1} = struct('time', allTime, 'labels', allLabels, 'data', allData);

% Process Zephyr data
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

LOG.trace('Zephyr', '_____________ Start processing MSR data ____________');
for i = 1 : p.patientCount
    patienFolderName = p.allPatientFolders( i ).name;
    
    LOG.trace('Zephyr', sprintf('Process patient: %s\n', ['----' patienFolderName '----']));
    
    % parse labeled events
    labeledEventsFile = [p.BASE_PATH patienFolderName '\1_raw\*.txt' ];
    sleepPhaseParser = SleepPhaseEventParser(labeledEventsFile);
    labeledEvents = sleepPhaseParser.run();
    
    % parse raw data
    csvFile = [p.BASE_PATH patienFolderName '\1_raw\' p.dataSources{2} '\*_Summary.csv' ];
    rawDataReader = ZephyrCsvReader(csvFile, selectedRawDataChannels);
    rawData = rawDataReader.run();
    if(isempty(rawData))
        LOG.trace('MSR', 'No data found for person.');
        continue;
    end
    rawData.channelNames = selectedRawDataChannels;
    
    % linear interpolate/decimate values to fit target sampling frequency
    LOG.trace('Zephyr', 'interpolate patient');
    interpolator = DiffSamplingRateInterpolation(samplingFrequency, rawData);
    interpolatedRawData = interpolator.run();
    
    % merge label and events
    LOG.trace('Zephyr', 'merge patient labels and data');
    merger = DefaultRawDataAndLabelMerger(samplingFrequency, labeledEvents, interpolatedRawData, mandatoryChannelsName, p.selectedClasses, assumedEventDuration);
    [ data, time, labels, channelNames ] = merger.run();
    
    % combine features and labels of all patients
    allTime = [allTime ; time];
    allData = [allData ; data];
    allLabels = [allLabels ; labels];
    
end

allData(isnan(allData)) = 0;

sensors{2} = struct('time', allTime, 'labels', allLabels, 'data', allData);

% Merge device data
sensorDataMerger = TimedDataIntersection(sensors);
[allTime, allLabels, allData ] = sensorDataMerger.run();

resultFolder = [ p.BASE_PATH '\processed\' CONF.WEKA_DATA_SUBFOLDER '\'  p.processingOutputFolder];
[s, mess, messid] = mkdir(resultFolder);

% Run DBN (RBM)
dbnInputData.data = allData;
dbnInputData.labels = allLabels;

inputComponents = floor(size( allData, 2 ));
SETUP_LOG = SetupLog([resultFolder '\setup.log']);
SETUP_LOG.log('MSR & Zephyr');
SETUP_LOG.log('Pipeline: Rawdata > DBN > Weka(RandomForest,10foldCross)');
SETUP_LOG.log(sprintf('%s %d', 'Rawdata components:', inputComponents));
layersConfig =[struct('hiddenUnitsCount', floor(inputComponents /4), 'maxEpochs', 100); ...
               struct('hiddenUnitsCount', floor(inputComponents * 4), 'maxEpochs', 100)];

rbmTrainer = RBMFeaturesTrainer(layersConfig, dbnInputData);
SETUP_LOG.logDBN(rbmTrainer.getDBN());
higherOrderFeaturesDBN = rbmTrainer.run();

% Save DBN trained model
dataSource = strjoin(p.dataSources, '_');
dbnLearnedModelFolder = [ p.BASE_PATH '\processed\' CONF.DBN_DATA_SUBFOLDER '\'  p.processingOutputFolder];
[s, mess, messid] = mkdir(dbnLearnedModelFolder);
dbnLearnedModelFile = [dbnLearnedModelFolder '\dbn_trainedModel_' dataSource '.mat'];
dbn = rbmTrainer.getDBN();
save(dbnLearnedModelFile, 'dbn');

% write ARFF files
arffFileName = [ resultFolder '\dbn_created_features__' dataSource '.arff'];
writer = WekaArffFileWriter(higherOrderFeaturesDBN.features, higherOrderFeaturesDBN.labels, p.selectedClasses, arffFileName);
writer.run();

% run Weka classifier
trainedModelFileName = ['weka_out__' dataSource '.model'];
textResultFileName = ['weka_out_confusion_matrix__' dataSource '.txt'];
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], resultFolder, trainedModelFileName, textResultFileName, csvResultFileName, dataSource);
classifier.run();

toc
