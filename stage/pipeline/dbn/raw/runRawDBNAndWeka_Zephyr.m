% This pipline parses Zephyr raw data and labeled events and merges
% them. The .
tic
clear();

LOG = Logger.getLogger('Zephyr DBN');

preprocess = true;
subFolderOutput = '2016-11-30_Zephyir_DBN_Features_L1x4_L2x4_L3x2_Weka_Classified';
subFolderInput = subFolderOutput;

allPatientsPath = [CONF.BASE_DATA_PATH '' ];
% allPatientsPath = [CONF.BASE_DATA_PATH 'Temp\' ];

selectedClasses = {'R', 'W', 'N1', 'N2', 'N3'};

% Preprocessing
if(preprocess)
    
    selectedRawDataChannels = { 'HR', 'BR', 'PeakAccel', ...
    'BRAmplitude', 'ECGAmplitude', ...
    'VerticalMin', 'VerticalPeak', ...
    'LateralMin', 'LateralPeak', 'SagittalMin', 'SagittalPeak' };

    samplingFrequency = 1; % Hz
    assumedEventDuration = 30; % seconds
    mandatoryChannelsName = { 'HR', 'BR' };
    
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
        LOG.logStart('Parse raw data');
        csvFile = [allPatientsPath patienFolderName '\1_raw\Zephyr\*_Summary.csv' ];
        rawDataReader = ZephyrCsvReader(csvFile, selectedRawDataChannels);
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
    
    preprocessedFolder = [ allPatientsPath 'all\' CONF.PREPROCESSED_DATA_SUBFOLDER '\' subFolderOutput];
    [s, mess, messid] = mkdir(preprocessedFolder);
    
    % save labeled raw data (dbn input)
    save([preprocessedFolder '\labeled_raw_data__Zephyr.mat' ], 'allData', 'allLabels');
else
    load([allPatientsPath 'all\' CONF.PREPROCESSED_DATA_SUBFOLDER '\' subFolderInput '\labeled_raw_data__Zephyr.mat' ]);
    
end

%6. Run DBN (RBM)
dbnInputData.data = allData;
dbnInputData.labels = allLabels;

inputComponents = floor(size( allData, 2 ));
layersConfig =[struct('hiddenUnitsCount', floor(inputComponents *4), 'maxEpochs', 100);struct('hiddenUnitsCount', floor(inputComponents *4), 'maxEpochs', 100);struct('hiddenUnitsCount', floor(inputComponents *2), 'maxEpochs', 100)];

rbmTrainer = RBMFeaturesTrainer(layersConfig, dbnInputData);
higherOrderFeaturesDBN = rbmTrainer.run();

wekaFolder = [ allPatientsPath 'all\' CONF.WEKA_DATA_SUBFOLDER '\'  subFolderOutput];
[s, mess, messid] = mkdir(wekaFolder);

%7. write ARFF file
arffFileName = [ wekaFolder '\dbn_created_features__Zephyr.arff'];
writer = WekaArffFileWriter(higherOrderFeaturesDBN.features, higherOrderFeaturesDBN.labels, selectedClasses, arffFileName);
writer.run();

%8. run Weka classifier

trainedModelFileName = 'weka_out__Zephyr.model';
textResultFileName = 'weka_out_confusion_matrix__Zephyr.txt';
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], wekaFolder, trainedModelFileName, textResultFileName, csvResultFileName, 'Zephyr Raw DBN');
classifier.run();

toc

