function [ ] = processSmartSleepFolder( inputPath, outputPath, genCorrPlotsFlag, genArffFlag, genEdgeDetectFlag )

    fileList = dir( inputPath );
    numFiles = size( fileList, 1 );

    % iterate over all files (normal files and directories)
    for i = 1 : numFiles
        file = fileList( i );
        c = strfind( file.name, '.' );
        
        % ignore invalid files, starting with . (., .., .svn )
        if ( ~isempty( c ) )
            if ( 1 == c( 1 ) )
                continue;
            end
        end

        % construct full input file-name
        fullInputFileName = sprintf( '%s\\%s', inputPath, file.name );
        % construct full output file-name
        fullOutputFileName = sprintf( '%s\\%s', outputPath, file.name );
            
        % walk file-list recursive if folder
        if ( 1 == file.isdir )
            % recursive call
            processSmartSleepFolder( fullInputFileName, fullOutputFileName, genCorrPlotsFlag, genArffFlag, genEdgeDetectFlag );
        
        % normal file
        else
            % check if the file is a matlab-file (ends with .mat)
            fileNameLen = length( file.name );
            isMatFile = ( fileNameLen >= 4 && strcmp( file.name( fileNameLen - 3 : fileNameLen ), '.mat' ) );

            % ignore non-matlab files
            if ( 0 == isMatFile )     
                continue;
            end
            
            % lazy creation of folders => create only when it contains
            % a .mat file, empty folders/folders with no matlab files wont
            % be created
            if ~exist( outputPath, 'dir' )
                mkdir( outputPath );
            end
  
            % process .mat-file and optionally generate .arff-file
            processSmartSleepMat( fullInputFileName, fullOutputFileName, genCorrPlotsFlag, genArffFlag, genEdgeDetectFlag );
        end
    end
end
