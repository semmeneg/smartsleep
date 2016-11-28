% Reads and parses Biovotion sensors raw data from CSV file.
%
classdef BiovotionCsvReader
    
    properties(Constant)
        TIMEFORMAT = 'yyyy/mm/dd HH:MM:SS';
        
    end
    
    properties
        fileNameAndPath = [];
        selectedChannels = [];
        filterTypeNumber = [];
    end
    
    methods
        function obj = BiovotionCsvReader(fileNameAndPath, selectedChannels, filterTypeNumber)
            obj.fileNameAndPath = fileNameAndPath;
            obj.selectedChannels = selectedChannels;
            if(nargin == 3)
                obj.filterTypeNumber = filterTypeNumber;
            end
        end
        
        function [ data ] = run(obj)
            
            data = [];
            
            if (contains(obj.fileNameAndPath, '*'))
                file = dir(obj.fileNameAndPath);
                if ( isempty( file ) )
                    warning( 'Biovotion CSV file:missing', 'Missing Biovotion data file in %s', obj.fileNameAndPath );
                    return;
                end
                obj.fileNameAndPath = [ file.folder '\' file.name ];
            else
                obj.fileNameAndPath = obj.fileNameAndPath;
            end
            
            
            % Workaround to get the variable names (header column names)
            % since the amount differs from the data column amounts (empty
            % columns but no delimiter).
            fid = fopen(obj.fileNameAndPath, 'r');
            str = fgetl(fid);
            fclose(fid);
            vars = regexp(str, ',', 'split');
            if isempty(vars{end})
                vars = vars(1:end-1);
            end
            t = readtable( obj.fileNameAndPath, 'delimiter', ',', 'headerlines', 1, 'readvariablenames', false);
            t.Properties.VariableNames = vars(1:size(t,2));
            
            tableSize = size( t, 1 );
            time = t( :, 'Timestamp' );
            timeStrs = table2cell( time );
            
            data.data = table2array( t( :, obj.selectedChannels ) );
%             data.data = str2double(data.data);
            data.time = zeros( tableSize, 1 );
            
            for i = 1 : tableSize
                data.time( i ) = obj.matlabTimeToUnixTime( datenum( timeStrs{ i }, obj.TIMEFORMAT ) );
            end
        end
        
        function [ unixTime ] = matlabTimeToUnixTime(obj, matlabTime )
            unix_epoch = datenum(1970,1,1,0,0,0);
            unixTime = matlabTime * 86400 - unix_epoch * 86400;
        end
    end
    
end

