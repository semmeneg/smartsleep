% Reads MSR raw data from a matlab file format.
classdef MSRMatlabReader < AbstractSensorDataReader
    
    methods
        function obj = MSRMatlabReader(selectedChannels)
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
                    warning( 'MSR file:missing', 'Missing MSR data file in %s', fileNameAndPath );
                    return;
                end
                fileNameAndPath = [ file.folder '\' file.name ];
            end
            
            load( fileNameAndPath );
            
            timeChannelIndex = 0;
               
            for i = 1 : length ( InfoChannelNames )
                if ( strcmpi( InfoChannelNames( i ), 'time' ) )
                    timeChannelIndex = i;
                end
                
                for j = 1 : length( obj.selectedChannels )
                    if ( strcmpi( InfoChannelNames( i ), obj.selectedChannels{ j } ) )
                        dataSet.data(:,j) = obj.removeAndInterpolateNan( MSR( i, : ) );
                        break;
                    end
                end
            end
            
            if ( timeChannelIndex == 0 )
                error( 'No time found in MSR' );
            end
            
            t = datenum( InfoStartTime, 'yyyy-mm-dd HH:MM:SS' );
            unixStartTimeInSeconds = matlabTimeToUnixTime( t );
            
            dataSet.time = MSR( timeChannelIndex, : )' + unixStartTimeInSeconds;
            dataSet.channelNames = obj.selectedChannels;
        end
        
        function [ x ] = removeAndInterpolateNan(obj, x )
            %REMOVENAN Summary of this function goes here
            %   Detailed explanation goes here
            
            firstNonNanIndex = find( ~isnan( x ), 1, 'first' );
            lastNonNanIndex = find( ~isnan( x ), 1, 'last' );
            
            % only nans, replace by 0
            if ( isempty( firstNonNanIndex ) )
                x = zeros( length( x ), 1 );
                return;
            end
            
            %ensure we start and end with NAN to be able to interpolate
            if ( 1 ~= firstNonNanIndex )
                x( 1 ) = x( firstNonNanIndex );
            end
            
            if ( length( x ) ~= lastNonNanIndex )
                x( end ) = x( lastNonNanIndex );
            end
            
            nanIndices = isnan( x );
            
            if ( ~isempty( nanIndices ) )
                allIdx = 1 : length( x );
                x( nanIndices ) = interp1( allIdx( ~nanIndices ), ...
                    x( ~nanIndices ), allIdx( nanIndices ), 'linear' );
            end
        end
    end
    
    
end

