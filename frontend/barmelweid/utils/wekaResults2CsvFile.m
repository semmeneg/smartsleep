% Extract Weka Results from a all files in directory and write a combined
% CSV file for further plots

FOLDER = [ALL_PATIENTS_CLASSIFIED_WEKA_DATA_PATH '2016-10-18_00-02-23_PatientsGrouped_DNBRatio90-10-00\'];

csvFile = [FOLDER 'cm.csv'];

if (exist(csvFile, 'file') == 2)
    delete(csvFile);
end
 
COMBINATIONS = {{DATA_SOURCE.EEG}, {DATA_SOURCE.EEG, DATA_SOURCE.MSR}, {DATA_SOURCE.EEG, DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR}, {DATA_SOURCE.EEG, DATA_SOURCE.ZEPHYR}, {DATA_SOURCE.MSR}, {DATA_SOURCE.MSR, DATA_SOURCE.ZEPHYR}, {DATA_SOURCE.ZEPHYR}};
        
for i = 1 : length(COMBINATIONS)
    csvFileId = fopen(csvFile, 'a');
    fileName = [FOLDER '\allpatients_EVENTS_' strjoin(COMBINATIONS{i}, '_') '_DBNFEATURES_WEKARESULT.txt'];
    result = parseWEKAResult(fileName);
    fprintf(csvFileId, strjoin(COMBINATIONS{i}, ' & '));
    fprintf(csvFileId, '\n');
    for row = 1:length(result.classes)
        fprintf(csvFileId,'%s;',result.classes{row});
    end
    fprintf(csvFileId, '\n');
    [nrows,ncols] = size(result.cmAbs);
    for row = 1:nrows
        fprintf(csvFileId,'%d;',result.cmAbs(row,:));
        fprintf(csvFileId, '\n');
    end
    fprintf(csvFileId, '%d', result.corrAbs);
    fprintf(csvFileId, ';');
    fprintf(csvFileId, '%d', result.incorrAbs);
    fprintf(csvFileId, '\n');    
    fclose(csvFileId);
end

 



