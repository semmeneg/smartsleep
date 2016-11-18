% WekaClassification encapsulates Weka classification
%
classdef WekaClassifier
    properties
        features = [];
        labels = [];
        classes = [];
        arffInputFile = [];
        resultFolderPath = [];
        trainedModelFileName = [];
        textResultFileName = [];
        csvResultFileName = [];
        description = [];
    end
    
    methods
        %% Construct and initialize classifier.
        function obj = WekaClassifier(arffInputFile, resultFolderPath, trainedModelFileName, textResultFileName, csvResultFileName, description)
            obj.arffInputFile = arffInputFile;
            obj.resultFolderPath = resultFolderPath;
            obj.trainedModelFileName = trainedModelFileName;
            obj.textResultFileName = textResultFileName;
            obj.csvResultFileName = csvResultFileName;
            obj.description = description;
            
        end
        
        %% Run the pipe
        function run(obj)
            
            % create directory for result files
            [status,message,messageid] = mkdir(obj.resultFolderPath);
            
            % Weka output: trained modelfile
            modelFile = [obj.resultFolderPath obj.trainedModelFileName];
            
            textResultsFile = [obj.resultFolderPath obj.textResultFileName];
            
            tStart = tic;
            fprintf('Start Weka classification training: %s.\n', datetime);
            oldFolder = cd( CONF.WEKA_PATH );
            cmd = [ 'java -Xmx6144m -cp weka.jar weka.classifiers.trees.RandomForest' ...
                ' -t "' obj.arffInputFile '"'...
                ' -d "' modelFile  '"' ];
            
            [ status, cmdout ] = system( cmd );
            
            fid = fopen( textResultsFile, 'w' );
            fprintf( fid, '%s', cmdout );
            fclose( fid );
            
            cd( oldFolder );
            fprintf('Weka training time used: %f seconds.\n', toc(tStart));
            
            %append results to csv file
            if(~isempty(obj.csvResultFileName))
                csvFile = [obj.resultFolderPath '\' 'cm.csv'];
                obj.appendWekaResult2Csv(textResultsFile, csvFile, obj.description);
            end
            
            
        end

        %% appendWekaResult2Csv Parses Weka result files in given folder and appends
        %   results in given csv file.
        function appendWekaResult2Csv(obj, textResultsFile, csvFile, description)

            
            csvFileId = fopen(csvFile, 'a');
            parser = WekaResultReader(textResultsFile);
            result = parser.run();
            fprintf(csvFileId, description);
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
    end
    
end

