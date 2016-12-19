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
            
            filteredByTypeIdx = ismember(table2array(t( :, 'Type' )), obj.filterTypeNumber); 
            
            time = t( :, 'Timestamp' );
            timeStrs = table2cell( time(filteredByTypeIdx,:));
            
            data.data = table2array( t( :, obj.selectedChannels ) );
            data.data = data.data(filteredByTypeIdx,:);
            
            data.time = zeros( length(timeStrs), 1 );
            
            for i = 1 : length(timeStrs)
                data.time( i ) = matlabTimeToUnixTime( datenum( timeStrs{ i }, obj.TIMEFORMAT ) );
            end
        end

    end
    
end

