function [ dataSetParams ] = findActivityFile( activityDataFolder, dataSetParams )
%FINDACTIVITYFILE Summary of this function goes here
%   Detailed explanation goes here
    
    MOBILE_ACTIVITY_FILE_END = 'ACTIVITIES.csv';

    dataSetParams.activities = [];
    
    activityFiles = listDirFiles( activityDataFolder, 'file' );

    for i = 1 : length( activityFiles )
        file = activityFiles{ i };
 
        if ( strfind( file.name, MOBILE_ACTIVITY_FILE_END ) == ...
                length( file.name ) - length( MOBILE_ACTIVITY_FILE_END ) + 1 )
            dataSetParams.activities = sprintf( '%s\\%s', activityDataFolder, file.name );
            return;
        end
    end
    
    dataSetParams = [];
end
