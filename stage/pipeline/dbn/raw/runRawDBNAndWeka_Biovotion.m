% This pipline parses Biovotion raw data and labeled events and merges
% them. The .
tic
clear();

LOG = Log.getLogger();

preprocess = true;

subFolderOutput = '2016-12-01_Biovotion_DBN_Features_L1x4_L2x4_L2x2_Weka_Classified';
subFolderInput = subFolderOutput;

allPatientsPath = [CONF.PATIENTS_DATA_PATH 'October2November2016Patients\' ];
% allPatientsPath = [CONF.PATIENTS_DATA_PATH 'Temp\' ];

selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};

% Preprocessing
if(preprocess)
    
    selectedRawDataChannels = { 'Value05','Value06','Value07','Value08','Value09','Value10','Value11' };
    samplingFrequency = 51; % Hz
    assumedEventDuration = 30; % seconds
    mandatoryChannelsName = {};
    
    aggregationFunctions = { @energyFeature, @meanFeature, @rootMeanSquareFeature, ...
        @skewnessFeature, @stdFeature, @sumFeature, @vecNormFeature };
    
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
        LOG.trace('Biovotion', 'Parse raw data');
        csvFile = [allPatientsPath patienFolderName '\1_raw\Biovotion\*.txt' ];
        rawDataReader = BiovotionCsvReader(csvFile, selectedRawDataChannels, 11);
        rawData = rawDataReader.run();
        if(isempty(rawData))
            disp('No data found for person.');
            continue;
        end
        rawData.channelNames = selectedRawDataChannels;
        
        % 3. linear interpolate/decimate values to fit target sampling frequency
        LOG.trace('Biovotion', 'Interpolation');
        interpolator = SamplingRateInterpolationAndDecimation(samplingFrequency, rawData);
        interpolatedRawData = interpolator.run();
        
        %4. merge label and events
        LOG.trace('Biovotion', 'Merge labels and events');
        merger = DefaultRawDataAndLabelMerger(samplingFrequency, labeledEvents, interpolatedRawData, mandatoryChannelsName, selectedClasses, assumedEventDuration);
        [ data, time, labels, channelNames ] = merger.run();
        
        %5. combine features and labels of all patients
        allData = [allData ; data];
        allLabels = [allLabels ; labels];
        
    end
    
    allData(isnan(allData)) = 0;
    
    preprocessedFolder = [ allPatientsPath 'all\' CONF.PREPROCESSED_DATA_SUBFOLDER '\' subFolderOutput];
    [s, mess, messid] = mkdir(preprocessedFolder);
    
    % save labeled raw data (dbn input)
    save([preprocessedFolder '\labeled_raw_data__Biovotion.mat' ], 'allData', 'allLabels');
else
    load([allPatientsPath 'all\' CONF.PREPROCESSED_DATA_SUBFOLDER '\' subFolderInput '\labeled_raw_data__Biovotion.mat' ]);
    
end

%6. Run DBN (RBM)
dbnInputData.data = allData;
dbnInputData.labels = allLabels;

inputComponents = floor(size( allData, 2 ));
layersConfig =[struct('hiddenUnitsCount', floor(inputComponents *4), 'maxEpochs', 100); ...
               struct('hiddenUnitsCount', floor(inputComponents * 4), 'maxEpochs', 100); ...
               struct('hiddenUnitsCount', floor(inputComponents * 2), 'maxEpochs', 100)];

rbmTrainer = RBMFeaturesTrainer(layersConfig, dbnInputData);
higherOrderFeaturesDBN = rbmTrainer.run();

wekaFolder = [ allPatientsPath 'all\' CONF.WEKA_DATA_SUBFOLDER '\'  subFolderOutput];
[s, mess, messid] = mkdir(wekaFolder);

%7. write ARFF file
arffFileName = [ wekaFolder '\dbn_created_features__Biovotion.arff'];
writer = WekaArffFileWriter(higherOrderFeaturesDBN.features, higherOrderFeaturesDBN.labels, selectedClasses, arffFileName);
writer.run();

%8. run Weka classifier

trainedModelFileName = 'weka_out__Biovotion.model';
textResultFileName = 'weka_out_confusion_matrix__Biovotion.txt';
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], wekaFolder, trainedModelFileName, textResultFileName, csvResultFileName, 'Biovotion Raw DBN');
classifier.run();

toc

