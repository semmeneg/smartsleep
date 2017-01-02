% Reads and parses Biovotion sensors raw data from CSV file.
%
classdef BiovotionCsvReader < AbstractSensorDataReader
    
    properties(Constant)
        TIMEFORMAT = 'yyyy/mm/dd HH:MM:SS';
        
    end
    
    properties
        filterTypeNumber = [];
    end
    
    methods
        function obj = BiovotionCsvReader(selectedChannels, filterTypeNumber)
            obj = obj@AbstractSensorDataReader(selectedChannels);
            if(nargin == 2)
                obj.filterTypeNumber = filterTypeNumber;
            end
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
                    warning( 'Biovotion CSV file:missing', 'Missing Biovotion data file in %s', fileNameAndPath );
                    return;
                end
                fileNameAndPath = [ file.folder '\' file.name ];
            else
                fileNameAndPath = fileNameAndPath;
            end
            
            
            % Workaround to get the variable names (header column names)
            % since the amount differs from the data column amounts (empty
            % columns but no delimiter).
            fid = fopen(fileNameAndPath, 'r');
            str = fgetl(fid);
            fclose(fid);
            vars = regexp(str, ',', 'split');
            if isempty(vars{end})
                vars = vars(1:end-1);
            end
            t = readtable( fileNameAndPath, 'delimiter', ',', 'headerlines', 1, 'readvariablenames', false);
            t.Properties.VariableNames = vars(1:size(t,2));
            
            filteredByTypeIdx = ismember(table2array(t( :, 'Type' )), obj.filterTypeNumber); 
            
            time = t( :, 'Timestamp' );
            timeStrs = table2cell( time(filteredByTypeIdx,:));
            
            dataSet.data = table2array( t( :, obj.selectedChannels ) );
            dataSet.data = dataSet.data(filteredByTypeIdx,:);
            
            dataSet.time = zeros( length(timeStrs), 1 );
            
            for i = 1 : length(timeStrs)
                dataSet.time( i ) = matlabTimeToUnixTime( datenum( timeStrs{ i }, obj.TIMEFORMAT ) );
            end
            dataSet.channelNames = obj.selectedChannels;
        end

    end
    
end

