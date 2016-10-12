function [ files ] = listFilesType( path, type )
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
           continue;
        end

        str = strfind( file.name, type );
        if ( isempty( str ) )
            continue;
        end
        
        if ( str ~= length( file.name ) - length( type ) + 1 )
            continue;
        end
            
        files{ end + 1 } = file;
    end
end
