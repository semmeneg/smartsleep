% Reads and parses Zephyr raw data from CSV file.
%
classdef ZephyrCsvReader < AbstractSensorDataReader
    
    properties(Constant)
        TIMEFORMAT = 'dd/mm/yyyy HH:MM:SS.FFF';
    end
    
    methods
        function obj = ZephyrCsvReader(selectedChannels)
           obj = obj@AbstractSensorDataReader(selectedChannels);
        end
        
         %%
        % Reads data and timestamps. Returns a strcut with a 'time' array, a 'data' matrix and the 'selectedChannels' array.
        % Concrete readers must implement this method.
        %
        % param fileNameAndPath        
        function [ dataSet ] = run(obj, fileNameAndPath)
            
            dataSet = [];
            
            if (contains(fileNameAndPath, '*'))
                file = dir(fileNameAndPath);
                if ( isempty( file ) )
                    warning( 'Zephyr CSV file:missing', 'Missing Zephyr data file in %s', fileNameAndPath );
                    return;
                end
                fileNameAndPath = [ file.folder '\' file.name ];
            end
                
            t = readtable( fileNameAndPath);
            
            tableSize = size( t, 1 );
            time = t( :, 'Time' );
            timeStrs = table2cell( time );
            
            dataSet.data = table2array( t( :, obj.selectedChannels ) );
            dataSet.data = str2double(dataSet.data);
            dataSet.time = zeros( tableSize, 1 );
            
            for i = 1 : tableSize
                dataSet.time( i ) = obj.matlabTimeToUnixTime( datenum( timeStrs{ i }, obj.TIMEFORMAT ) );
            end
            dataSet.channelNames = obj.selectedChannels;
        end
        
        function [ unixTime ] = matlabTimeToUnixTime(obj, matlabTime )
            unix_epoch = datenum(1970,1,1,0,0,0);
            unixTime = matlabTime * 86400 - unix_epoch * 86400;
        end
    end
    
end

