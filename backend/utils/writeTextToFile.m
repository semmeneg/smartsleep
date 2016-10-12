function [ ] = writeTextToFile( text, fileName )
%WRITETEXTTOFILE Summary of this function goes here
%   Detailed explanation goes here

    fileID = fopen( fileName,'w');
    fprintf( fileID, '%s', text );
    fclose( fileID );
end
