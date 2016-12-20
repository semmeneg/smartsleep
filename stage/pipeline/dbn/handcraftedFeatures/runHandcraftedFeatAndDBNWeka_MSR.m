% Create handcrafted features (applying aggregations functions) and run 
% Weka Random Forest classifer.

clear();

subFolder = '2016-12-14_HandcraftedFeat_Weka_with_MSR';

BASE_PATH = [CONF.BASE_DATA_PATH '' ];
% BASE_PATH = [CONF.BASE_DATA_PATH 'Temp\' ];

dataSource = 'MSR';

sensorsRawDataFilePatterns = {'*HAND.mat', '*FUSS.mat'};
samplingFrequency = 19.7; % MSR 145B frequency: ~19.7 Hz (512/26) -> 591 samples

selectedRawDataChannels = { 'ACC x', 'ACC y', 'ACC z' };
mandatoryChannelsName = selectedRawDataChannels;

selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};

aggregationFunctions = { @energyFeature, @meanFeature, @rootMeanSquareFeature, ...
    @skewnessFeature, @stdFeature, @sumFeature, @vecNormFeature };

files = dir( [ BASE_PATH 'Patient*' ] );
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
    sleepPhaseParser = SleepPhaseEventParser([BASE_PATH patienFolderName '\1_raw\*.txt' ]);
    labeledEvents = sleepPhaseParser.run();
    
    % process all sensors
    sensors = [];
    
    for sensorsRawDataFilePatternsIdx = 1 : length(sensorsRawDataFilePatterns)
        % 2. parse raw data
        rawDataFile = [ BASE_PATH patienFolderName '\1_raw\' dataSource '\' sensorsRawDataFilePatterns{sensorsRawDataFilePatternsIdx} ];
        reader = MSRMatlabReader(rawDataFile, selectedRawDataChannels);
        rawData = reader.run();
        if(isempty(rawData))
            disp('No data found for sensor.');
            continue;
        end
        
        %3 merge label and events
        merger = DefaultAggregatedDataAndLabelMerger(samplingFrequency, labeledEvents, rawData, mandatoryChannelsName, selectedClasses, aggregationFunctions);
        [ sensorData, sensorTime, sensorLabels, channelNames ] = merger.run();
        
        sensors{end+1} = struct('time', sensorTime, 'labels', sensorLabels, 'data', sensorData);
    end
    
    if(isempty(sensors))
        disp('No data found for person.');
        continue;
    end
    
    %4 Merge sensors data
    sensorDataMerger = TimedDataIntersection(sensors);
    [personTime, personLabels, personData ] = sensorDataMerger.run();
    
    %5 combine features and labels of all patients
    allLabels = [allLabels ; personLabels];
    allData = [allData ; personData];
end


wekaFolder = [ BASE_PATH 'all\' CONF.WEKA_DATA_SUBFOLDER '\'  subFolder];
[s, mess, messid] = mkdir(wekaFolder);

%7 write ARFF file
arffFileName = [ wekaFolder '\handcrafted_features__' dataSource '.arff'];
writer = WekaArffFileWriter(allData, allLabels, selectedClasses, arffFileName);
writer.run();

%8 run Weka classifier
trainedModelFileName = ['weka_out__' dataSource '.model'];
textResultFileName = ['weka_out_confusion_matrix__' dataSource '.txt'];
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], wekaFolder, trainedModelFileName, textResultFileName, csvResultFileName, dataSource);
classifier.run();


