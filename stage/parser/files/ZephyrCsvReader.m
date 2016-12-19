% Reads and parses Zephyr raw data from CSV file.
%
classdef ZephyrCsvReader
    
    properties(Constant)
        TIMEFORMAT = 'dd/mm/yyyy HH:MM:SS';
    end
    
    properties
        fileNameAndPath = [];
        selectedChannels = [];
    end
    
    methods
        function obj = ZephyrCsvReader(fileNameAndPath, selectedChannels)
            obj.fileNameAndPath = fileNameAndPath;
            obj.selectedChannels = selectedChannels;
        end
        
        function [ zephyr ] = run(obj)
            
            zephyr = [];
            
            if (contains(obj.fileNameAndPath, '*'))
                file = dir(obj.fileNameAndPath);
                if ( isempty( file ) )
                    warning( 'Zephyr CSV file:missing', 'Missing Zephyr data file in %s', obj.fileNameAndPath );
                    return;
                end
                obj.fileNameAndPath = [ file.folder '\' file.name ];
            end
                
            t = readtable( obj.fileNameAndPath);
            
            tableSize = size( t, 1 );
            time = t( :, 'Time' );
            timeStrs = table2cell( time );
            
            zephyr.data = table2array( t( :, obj.selectedChannels ) );
            zephyr.time = zeros( tableSize, 1 );
            
            for i = 1 : tableSize
                zephyr.time( i ) = obj.matlabTimeToUnixTime( datenum( timeStrs{ i }, obj.TIMEFORMAT ) );
            end
        end
        
        function [ unixTime ] = matlabTimeToUnixTime(obj, matlabTime )
            unix_epoch = datenum(1970,1,1,0,0,0);
            unixTime = matlabTime * 86400 - unix_epoch * 86400;
        end
    end
    
end

