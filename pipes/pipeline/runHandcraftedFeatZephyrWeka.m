% This is a testpipeline to verify new object oriented code.

clear();

subFolder = '2016-11-24_PipelineTest_HandcraftedFeat_Zephyr_Weka_inclusivePatient26';

selectedRawDataChannels = { 'HR', 'BR', 'PeakAccel', ...
    'BRAmplitude', 'ECGAmplitude', ...
    'VerticalMin', 'VerticalPeak', ...
    'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };

mandatoryChannelsName = { 'HR', 'BR' };
selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};

aggregationFunctions = { @energyFeature, @meanFeature, @rootMeanSquareFeature, ...
    @skewnessFeature, @stdFeature, @sumFeature, @vecNormFeature };

files = dir( [ CONF.PATIENTS_DATA_PATH 'Patient*' ] );
dirFlags = [ files.isdir ];
allPatientFolders = files( dirFlags );

patientCount = length( allPatientFolders );

allData = [];
allLabels = [];
allPatients = [];

for i = 1 : patientCount
    patienFolderName = allPatientFolders( i ).name;
    
    fprintf('Process patient: %s\n', patienFolderName);
    
    % 1. parse labeled events
    labeledEventsFile = [CONF.PATIENTS_DATA_PATH patienFolderName '\1_raw\*.txt' ];
    sleepPhaseParser = SleepPhaseEventParser(labeledEventsFile);
    labeledEvents = sleepPhaseParser.run();
    
    % Can be removed when wrong placed file in Patient26 folder is moved 
    if(isempty(labeledEvents))
        disp('No labels found for person.');
        continue;
    end
    
    % 2. parse raw data
    csvFile = [CONF.PATIENTS_DATA_PATH patienFolderName '\1_raw\Zephyr\*_Summary.csv' ];
    zephyrReader = ZephyrCsvReader(csvFile, selectedRawDataChannels);
    zephyrRawData = zephyrReader.run();
    if(isempty(zephyrRawData))
        disp('No data found for person.');
        continue;
    end
    zephyrRawData.channelNames = selectedRawDataChannels;
    
    %3 merge label and events
    merger = ZephyrAggregatedDataAndLabelMerger(labeledEvents, zephyrRawData, mandatoryChannelsName, selectedClasses, aggregationFunctions);
    [ data, time, labels, channelNames ] = merger.run();
    
    %4 combine features and labels of all patients
    allData = [allData ; data];
    allLabels = [allLabels ; labels];
    
end

%5 write ARFF file
[s, mess, messid] = mkdir([ CONF.ALL_PATIENTS_PREPROCESSED_DATA_PATH subFolder]);
arffFileName = [ CONF.ALL_PATIENTS_PREPROCESSED_DATA_PATH subFolder '\allpatients_EVENTS_ZEPHYR.arff'];
writer = WekaArffFileWriter(allData, allLabels, selectedClasses, arffFileName);
writer.run();

%6 run Weka classifier
resultFolderPath = [ CONF.ALL_PATIENTS_CLASSIFIED_WEKA_DATA_PATH subFolder];
trainedModelFileName = 'allpatients_ZEPHYR_FEATURES_WEKARESULT.model';
textResultFileName = 'allpatients_ZEPHYR_FEATURES_WEKARESULT.txt';
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], resultFolderPath, trainedModelFileName, textResultFileName, csvResultFileName, 'test pipeline');
classifier.run();


