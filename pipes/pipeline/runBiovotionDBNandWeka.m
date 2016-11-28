% This pipline parses Biovotion raw data and labeled events and merges
% them. The .
tic
clear();

LOG = Logger.getLogger('Biovotion DBN');

subFolder = '2016-11-28_Biovotion_DBN_Features_Weka_Classified';

selectedRawDataChannels = { 'Value05','Value06','Value07','Value08','Value09','Value10','Value11' };

samplingFrequency = 51; % Hz
assumedEventDuration = 30; % seconds

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
    LOG.logStart('Parse raw data');
    csvFile = [allPatientsPath patienFolderName '\1_raw\Biovotion\*.txt' ];
    rawDataReader = BiovotionCsvReader(csvFile, selectedRawDataChannels);
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

%6. write ARFF file
combinedPatientsPath = [allPatientsPath 'all\' ]
[s, mess, messid] = mkdir([ combinedPatientsPath CONF.PREPROCESSED_DATA_SUBFOLDER '\' subFolder]);
arffFileName = [ combinedPatientsPath CONF.PREPROCESSED_DATA_SUBFOLDER '\'  subFolder '\allpatients_EVENTS_Biovotion.arff'];
writer = WekaArffFileWriter(allData, allLabels, selectedClasses, arffFileName);
writer.run();

%7. run Weka classifier
resultFolderPath = [ combinedPatientsPath CONF.CLASSIFIED_DATA_SUBFOLDER '\'  subFolder];
trainedModelFileName = 'allpatients_Biovotion_FEATURES_WEKARESULT.model';
textResultFileName = 'allpatients_Biovotion_FEATURES_WEKARESULT.txt';
csvResultFileName = 'cm.csv';
classifier = WekaClassifier(arffFileName, [], resultFolderPath, trainedModelFileName, textResultFileName, csvResultFileName, 'test pipeline');
classifier.run();

toc

