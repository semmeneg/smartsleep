function [ dataSetParams ] = findMSRFiles( msrDataFolder, dataSetParams )
%FINDMSRFILES Summary of this function goes here
%   Detailed explanation goes here

    % NOTE need to distinguish between ankle and wrist MSR because wrist
    % MSR holds markers. Also wrist and ankle must be consistent accross
    % the whole combined data-set (e.g. it would lead to wrong training
    % when during some subset ankle and wrist are exchanged)

    %MSR_WRIST_FILE = 'wrist.mat';
    %MSR_ANKLE_FILE = 'ankle.mat';
    WRIST = 'wrist.mat';
    ANKLE = 'wrist.mat';

    dataSetParams.sensors.msr.wrist = [];
    dataSetParams.sensors.msr.ankle = [];

    msrFiles = listDirFiles( msrDataFolder, 'file' );

    for i = 1 : length( msrFiles )
        file = msrFiles{ i };
        
%         if ( strcmpi( MSR_WRIST_FILE, file.name ) )
%             dataSetParams.sensors.msr.wrist = sprintf( '%s\\%s', msrDataFolder, MSR_WRIST_FILE );
%         end
%         
%         if ( strcmpi( MSR_ANKLE_FILE, file.name ) )
%             dataSetParams.sensors.msr.ankle = sprintf( '%s\\%s', msrDataFolder, MSR_ANKLE_FILE );
%         end

        if ( strfind(file.name, WRIST ) )
            dataSetParams.sensors.msr.wrist = sprintf( '%s\\%s', msrDataFolder, file.name );
        end
        
        if ( strfind(file.name, ANKLE ) )
            dataSetParams.sensors.msr.ankle = sprintf( '%s\\%s', msrDataFolder, file.name );
        end
    end
    
    % if either one of both files are not found, then this is treated as
    % missing data - ignoring activity
    if ( isempty( dataSetParams.sensors.msr.wrist ) || ...
         isempty( dataSetParams.sensors.msr.ankle ) )
        dataSetParams = [];
    end
end
