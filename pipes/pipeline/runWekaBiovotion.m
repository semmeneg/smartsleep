% Extract Biovotion sensordata, create handcrafted features (apply
% aggregation function and train Weka random forest classifier. Validate
% with 10foldCross.

subFolder = '2016-11-24_Biovotion_Rawdata_DBN_L1div2_L2div4_Weka_10fold';

selectedRawDataChannels = { 'Value05','Value06','Value07','Value08','Value09','Value10','Value11' };
samplingFrequency = 50.2 %has currently no influence for calculation of handcrafted features. 

mandatoryChannelsName = {};
selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};

aggregationFunctions = { @energyFeature, @meanFeature, @rootMeanSquareFeature, ...
                @skewnessFeature, @stdFeature, @sumFeature, @vecNormFeature };

allPatientsPath = [CONF.PATIENTS_DATA_PATH 'October2November2016Patients\' ];

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
    biovotionReader = BiovotionCsvReader(csvFile, selectedRawDataChannels);
    biovotionRawData = biovotionCsvReader.run();
    biovotionRawData.channelNames = selectedRawDataChannels;
    
    %3 merge label and events
    merger = DefaultAggregatedDataAndLabelMerger(samplingFrequency, labeledEvents, biovotionRawData, mandatoryChannelsName, selectedClasses,aggregationFunctions);
    [ data, time, labels, channelNames ]  = merger.run();
    
    %4 write ARFF file
    writer = WekaArffFileWriter(features, labels, classes, arffFileName);
            writer.run();
    %5 run Weka classifier
        
end

