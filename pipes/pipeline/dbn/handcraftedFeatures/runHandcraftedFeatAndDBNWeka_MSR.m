% Create handcrafted features (applying aggregations functions). Run
% DBN/RBM with handcrafted features and use outcome with Weka Random Forest
% classifer.

clear();

subFolder = '2016-11-29_HandcraftedFeat_DBN_Weka_with_MSR';

sensorsRawDataFilePatterns = {'*HAND.mat', '*FUSS.mat'};

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
    
    % process all sensors
    person = struct('time', [], 'labels', [], 'data', []};
    
    for rawDataFilePattern = sensorsRawDataFilePatterns
        % 2. parse raw data
        rawDataFile = [CONF.PATIENTS_DATA_PATH patienFolderName '\1_raw\MSR\*_Summary.csv' ];
        reader = MSRMatlabReader(rawDataFile, selectedRawDataChannels);
        rawData = reader.run();
        if(isempty(rawData))
            disp('No data found for person.');
            continue;
        end
        rawData.channelNames = selectedRawDataChannels;
        
        %3 merge label and events
        merger = MSRAggregatedDataAndLabelMerger(labeledEvents, rawData, mandatoryChannelsName, selectedClasses, aggregationFunctions);
        [ sensorData, sensorTime, sensorLabels, channelNames ] = merger.run();
        
        person.time = [person.time ; sensorTime];
        person.labels = [person.labels ; sensorLabels];
        person.data = [person.data ; sensorData];
    end
    
    %4 Merge sensors data
    sensorDataMerger = TimedDataIntersection(person);
    [personTime, personData, personLabels] = sensorDataMerger.run();
    
    %5 combine features and labels of all patients
    allData = [allData ; personData];
    allLabels = [allLabels ; personLabels];
    
end

%6 write ARFF file
[s, mess, messid] = mkdir([ CONF.ALL_PATIENTS_PREPROCESSED_DATA_PATH subFolder]);
arffFileName = [ CONF.ALL_PATIENTS_PREPROCESSED_DATA_PATH subFolder '\allpatients_EVENTS_ZEPHYR.arff'];
writer = WekaArffFileWriter(allData, allLabels, selectedClasses, arffFileName);
writer.run();

%7 run Weka classifier
resultFolderPath = [ CONF.ALL_PATIENTS_CLASSIFIED_WEKA_DATA_PATH subFolder];
trainedModelFileName = 'allpatients_ZEPHYR_FEATURES_WEKARESULT.model';
textResultFileName = 'allpatients_ZEPHYR_FEATURES_WEKARESULT.txt';
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], resultFolderPath, trainedModelFileName, textResultFileName, csvResultFileName, 'test pipeline');
classifier.run();


