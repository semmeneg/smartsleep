function [ files ] = listDirFiles( path, type )
%LISTFILES Summary of this function goes here
%   Detailed explanation goes here

    files = [];

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

        if ( 1 == file.isdir )
            if ( ~ strcmpi( type, 'dir' ) )
                continue;
            end
        else
            if ( ~ strcmpi( type, 'file' ) )
                continue;
            end
        end

        files{ end + 1 } = file;
    end
end
