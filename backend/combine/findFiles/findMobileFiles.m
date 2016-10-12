function [ dataSetParams ] = findMobileFiles( mobileDataFolder, dataSetParams )
%FINDMOBILEFILES Summary of this function goes here
%   Detailed explanation goes here

    MOBILE_ACCELERATION_FILE_END = 'ACCELEROMETER.csv';
    MOBILE_SPEED_FILE_END = 'SPEED.csv';

    dataSetParams.sensors.mobile.acc = [];
    dataSetParams.sensors.mobile.speed = [];
    % dataSetParams.sensors.mobile.gyro = [];
    
    mobileFiles = listDirFiles( mobileDataFolder, 'file' );

    for i = 1 : length( mobileFiles )
        file = mobileFiles{ i };
 
        if ( strfind( file.name, MOBILE_ACCELERATION_FILE_END ) == ...
                length( file.name ) - length( MOBILE_ACCELERATION_FILE_END ) + 1 )
            dataSetParams.sensors.mobile.acc = sprintf( '%s\\%s', mobileDataFolder, file.name );
        end
        
        if ( strfind( file.name, MOBILE_SPEED_FILE_END ) == ...
                length( file.name ) - length( MOBILE_SPEED_FILE_END ) + 1 )
            dataSetParams.sensors.mobile.speed = sprintf( '%s\\%s', mobileDataFolder, file.name );
        end
    end
    
    % if either one of both files are not found, then this is treated as
    % missing data - ignoring activity
    if ( isempty( dataSetParams.sensors.mobile.acc ) || ...
        isempty( dataSetParams.sensors.mobile.speed ) )
        dataSetParams = [];
    end
end
