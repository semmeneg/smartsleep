% This pipline parses Biovotion raw data and labeled events and merges
% them. At the end a Weka classification is trained and verified.
tic
clear();

subFolder = '2016-12-01_HandcraftedFeat_Biovotion_Weka';

selectedRawDataChannels = { 'Value05','Value06','Value07','Value08','Value09','Value10','Value11' };
samplingFrequency = 51; %has currently no influence for calculation of handcrafted features. 

mandatoryChannelsName = {};
selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};

aggregationFunctions = { @energyFeature, @meanFeature, @rootMeanSquareFeature, ...
    @skewnessFeature, @stdFeature, @sumFeature, @vecNormFeature };

allPatientsPath = [CONF.PATIENTS_DATA_PATH 'October2November2016Patients\' ];
% allPatientsPath = [CONF.PATIENTS_DATA_PATH 'Temp\' ];

files = dir( [ allPatientsPath 'P*' ] );
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
    labeledEventsFile = [allPatientsPath patienFolderName '\1_raw\*.txt' ];
    sleepPhaseParser = SleepPhaseEventParser(labeledEventsFile);
    labeledEvents = sleepPhaseParser.run();
    
    % 2. parse raw data
    csvFile = [allPatientsPath patienFolderName '\1_raw\Biovotion\*.txt' ];
    rawDataReader = BiovotionCsvReader(csvFile, selectedRawDataChannels, 11);
    rawData = rawDataReader.run();
    if(isempty(rawData))
        disp('No data found for person.');
        continue;
    end
    rawData.channelNames = selectedRawDataChannels;
    
    %3 merge label and events
    merger = DefaultAggregatedDataAndLabelMerger(samplingFrequency, labeledEvents, rawData, mandatoryChannelsName, selectedClasses, aggregationFunctions);
    [ data, time, labels, channelNames ] = merger.run();
    
    %4 combine features and labels of all patients
    allData = [allData ; data];
    allLabels = [allLabels ; labels];
    
end

allData(isnan(allData)) = 0;

%5 write ARFF file
combinedPatientsPath = [allPatientsPath 'all\' ]
[s, mess, messid] = mkdir([ combinedPatientsPath CONF.PREPROCESSED_DATA_SUBFOLDER '\' subFolder]);
arffFileName = [ combinedPatientsPath CONF.PREPROCESSED_DATA_SUBFOLDER '\'  subFolder '\raw_features__Biovotion.arff'];
writer = WekaArffFileWriter(allData, allLabels, selectedClasses, arffFileName);
writer.run();

%6 run Weka classifier
resultFolderPath = [ combinedPatientsPath CONF.WEKA_DATA_SUBFOLDER '\'  subFolder];
trainedModelFileName = 'weka_out__Biovotion.model';
textResultFileName = 'weka_out_confusion_matrix__Biovotion.txt';
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], resultFolderPath, trainedModelFileName, textResultFileName, csvResultFileName, 'test pipeline');
classifier.run();

toc

