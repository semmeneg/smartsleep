% Steps: Biovotion raw + labels -> Weka RandomForest 10foldCross
tic
clear();

LOG = Logger.getLogger('Biovotion Raw Weka');

preprocess = true;

raw_data_folder = '2016-12-01_Biovotion';
subFolderOutput = '2016-12-01_Raw_Weka__Biovotion';


selectedRawDataChannels = { 'Value05','Value06','Value07','Value08','Value09','Value10','Value11' };
samplingFrequency = 51; % Hz
assumedEventDuration = 30; % seconds

mandatoryChannelsName = {};
selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};

allPatientsPath = [CONF.BASE_DATA_PATH 'October2November2016Patients\' ];

files = dir( [ allPatientsPath 'P*' ] );
dirFlags = [ files.isdir ];
allPatientFolders = files( dirFlags );

patientCount = length( allPatientFolders );

allData = [];
allLabels = [];
allPatients = [];

% Preprocessing
if(preprocess)
    for i = 1 : patientCount
        patienFolderName = allPatientFolders( i ).name;
        
        fprintf('Process patient: %s\n', patienFolderName);
        
        % 1. parse labeled events
        labeledEventsFile = [allPatientsPath patienFolderName '\1_raw\*.txt' ];
        sleepPhaseParser = SleepPhaseEventParser(labeledEventsFile);
        labeledEvents = sleepPhaseParser.run();
        
        % 2. parse raw data
        LOG.logStart('Parse raw data');
        csvFile = [allPatientsPath patienFolderName '\1_raw\Biovotion\*.txt' ];
        rawDataReader = BiovotionCsvReader(csvFile, selectedRawDataChannels, 11);
        rawData = rawDataReader.run();
        if(isempty(rawData))
            disp('No data found for person.');
            continue;
        end
        rawData.channelNames = selectedRawDataChannels;
        LOG.logEnd('Parse raw data');
        
        % 3. linear interpolate/decimate values to fit target sampling frequency
        LOG.logStart('Interpolation');
        interpolator = SamplingRateInterpolationAndDecimation(samplingFrequency, rawData);
        interpolatedRawData = interpolator.run();
        LOG.logEnd('Interpolation');
        
        %4. merge label and events
        LOG.logStart('Merge labels and events');
        merger = DefaultRawDataAndLabelMerger(samplingFrequency, labeledEvents, interpolatedRawData, mandatoryChannelsName, selectedClasses, assumedEventDuration);
        [ data, time, labels, channelNames ] = merger.run();
        LOG.logEnd('Merge labels and events');
        
        %5. combine features and labels of all patients
        allData = [allData ; data];
        allLabels = [allLabels ; labels];
        
    end
    
    allData(isnan(allData)) = 0;
    
    preprocessedFolder = [ allPatientsPath 'all\' CONF.PREPROCESSED_DATA_SUBFOLDER '\' raw_data_folder];
    [s, mess, messid] = mkdir(preprocessedFolder);
    
    % save labeled raw data (dbn input)
    save([preprocessedFolder '\labeled_raw_data__Biovotion.mat' ], 'allData', 'allLabels');
else
    load([allPatientsPath 'all\' CONF.PREPROCESSED_DATA_SUBFOLDER '\' raw_data_folder '\labeled_raw_data__Biovotion.mat' ]);
    
end

wekaFolder = [ allPatientsPath 'all\' CONF.WEKA_DATA_SUBFOLDER '\'  subFolderOutput];
[s, mess, messid] = mkdir(wekaFolder);

%7. write ARFF file
arffFileName = [ wekaFolder '\raw_features__Biovotion.arff'];
writer = WekaArffFileWriter(allData, allLabels, selectedClasses, arffFileName);
writer.run();

%8. run Weka classifier

trainedModelFileName = 'weka_out__Biovotion.model';
textResultFileName = 'weka_out_confusion_matrix__Biovotion.txt';
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], wekaFolder, trainedModelFileName, textResultFileName, csvResultFileName, 'Biovotion Raw Weka');
classifier.run();

toc


