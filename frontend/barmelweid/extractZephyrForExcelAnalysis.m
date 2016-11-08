% Extract data for Excel Analysis

dataSetFolderName = '2016-11-03_ohne_entropy_und_maxFreq';
dataSetFolderPath = [ CONF.ALL_PATIENTS_DATA_PATH '2_preprocessed\' dataSetFolderName '\' ];
dataSetPath = [ dataSetFolderPath 'allpatients_WINDOWS_ZEPHYR.mat' ];
load( dataSetPath );
outputFileName = [ dataSetFolderPath '2016-11-03_zephyrDataAnalysis.xlsx' ];

% write calculated features without 0 filter
row = 5;
for i = 1 : length(allPatients)
    patient = allPatients{i};
    if (~isempty(patient.zephyr) && ~isempty(patient.zephyr.data))
        xlswrite(outputFileName, {patient.folder},'Ohne Filter', ['A' num2str(row)]);
        xlswrite(outputFileName, patient.zephyr.data,'Ohne Filter', ['B' num2str(row)] );
        row = row + size(patient.zephyr.data, 1);
    end
end

% write calculated features with simple 0 filter (all values 0)
row = 5;
for i = 1 : length(allPatients)
    patient = allPatients{i};
    if (~isempty(patient.zephyr) && ~isempty(patient.zephyr.data))
        xlswrite(outputFileName, {patient.folder},'Einfacher Filter', ['A' num2str(row)]);
        xlswrite(outputFileName, patient.combinedData,'Einfacher Filter', ['B' num2str(row)] );
        row = row + size(patient.combinedData, 1);
    end
end