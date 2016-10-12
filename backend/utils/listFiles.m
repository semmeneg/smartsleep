function [ fileNames ] = listFiles( path, startsWith, fileType )
%LISTFILES Summary of this function goes here
%   Detailed explanation goes here

    fileNames = [];

    fileList = dir( path );
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

        % expand path
        fullFileName = sprintf( '%s\\%s', path, file.name );
            
        % walk file-list recursive if folder
        if ( 1 == file.isdir )
            % recursive call
            recursiveFileNames = listFiles( fullFileName, startsWith, fileType );
            fileNames = [ fileNames, recursiveFileNames ];
        
        % normal file
        else
            % check if the file is a matlab-file (ends with .mat)
            fileNameLen = length( file.name );
            fileTypeLen = length( fileType );
            isTypeFile = ( fileNameLen >= fileTypeLen && strcmp( file.name( fileNameLen - fileTypeLen + 1 : fileNameLen ), fileType ) );

            % ignore non-type files
            if ( 0 == isTypeFile )     
                continue;
            end
            
            startsWithLen = length( startsWith );
            isStartsWith = ( fileNameLen >= startsWithLen && strcmp( file.name( 1 : startsWithLen ), startsWith ) );
            % ignore non-starting with files
            if ( 0 == isStartsWith )     
                continue;
            end

            fileNames{ length( fileNames ) + 1 } = fullFileName;
        end
    end