function appendWekaResult2Csv(resultsFolder, wekaResultFileName, csvFileName, varargin)
%appendWekaResult2Csv Parses Weka result files in given folder and appends
%   results in given csv file. 

    csvFile = [resultsFolder csvFileName];
    csvFileId = fopen(csvFile, 'a');
    fileName = [resultsFolder wekaResultFileName];
    result = parseWEKAResult(fileName);
    fprintf(csvFileId, strjoin(varargin, ' & '));
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

