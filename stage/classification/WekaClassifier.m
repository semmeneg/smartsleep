% WekaClassification encapsulates Weka classification
%
classdef WekaClassifier
    properties
        arffFile = [];
        arffValidationFile = [];
        resultFolderPath = [];
        trainedModelFileName = [];
        textResultFileName = [];
        csvResultFileName = [];
        description = [];
    end
    
    methods
        %% Construct and initialize classifier.
        %
        % optional parameter: arffValidationFile (if not set, 10foldCross validation is applied)
        function obj = WekaClassifier(arffFile, arffValidationFile, resultFolderPath, trainedModelFileName, textResultFileName, csvResultFileName, description)
            obj.arffFile = arffFile;
            obj.arffValidationFile = arffValidationFile;
            obj.resultFolderPath = resultFolderPath;
            obj.trainedModelFileName = trainedModelFileName;
            obj.textResultFileName = textResultFileName;
            obj.csvResultFileName = csvResultFileName;
            obj.description = description;
            
        end
        
        %% Run the pipe
        function run(obj)
            
            Log.getLogger().infoStart(class(obj), 'run');
            
            % create directory for result files
            [status,message,messageid] = mkdir(obj.resultFolderPath);
            
            textResultsFile = [obj.resultFolderPath obj.textResultFileName];
            
            tStart = tic;
            fprintf('Start Weka classification training: %s.\n', datetime);
            oldFolder = cd( CONF.WEKA_PATH );
            % Weka trained modelfile
            modelFile = [obj.resultFolderPath obj.trainedModelFileName];
            if(~exist(modelFile, 'file')) %Train classifier
                if(isempty(obj.arffValidationFile)) %use default 10foldCross validation
                    cmd = [ 'java -Xmx6144m -cp weka.jar weka.classifiers.trees.RandomForest' ...
                        ' -t "' obj.arffFile '"'...
                        ' -d "' modelFile  '"' ];
                else
                    % TODO !!!!!! call Weka with training (arffFile) and
                    % validation file (arffValidationFile)
                end
            else %make predictions (classify) with a trained model
                cmd = [ 'java -Xmx6144m -cp weka.jar weka.classifiers.trees.RandomForest' ...
                        ' -T "' obj.arffFile '"'...
                        ' -l "' modelFile  '"' ];
            end
            
            
            
            [ status, cmdout ] = system( cmd );
            
            fid = fopen( textResultsFile, 'w' );
            fprintf( fid, '%s', cmdout );
            fclose( fid );
            
            cd( oldFolder );
            fprintf('Weka training time used: %f seconds.\n', toc(tStart));
            
            %append results to csv file
            if(~isempty(obj.csvResultFileName))
                csvFile = [obj.resultFolderPath 'cm.csv'];
                obj.appendWekaResult2Csv(textResultsFile, csvFile, obj.description);
            end
            
            Log.getLogger().infoEnd(class(obj), 'run');
            
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

