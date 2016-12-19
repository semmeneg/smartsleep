% WekaArffFileWriter writes features and labes in ARFF file format used by the Weka library.
%
classdef WekaArffFileWriter
    
    properties
        features = [];
        labels = [];
        classes = [];
        arffFileName = [];
    end
    
    methods
        function obj = WekaArffFileWriter(features, labels, classes, arffFileName)
            obj.features = features;
            obj.labels = labels;
            obj.classes = classes;
            obj.arffFileName = arffFileName;
        end
        
        function run(obj)
            channelNames = cell( size(obj.features,2), 1 );
            
            for i = 1 : size(obj.features,2)
                channelNames{ i } = sprintf( 'FEATURE_%d', i );
            end
            
            tStart = tic;
            fprintf('Start saving features and labels to ARFF file for Weka: %s.\n', datetime);
            obj.exportGenericToWeka( obj.features, obj.labels, obj.classes, ...
                'DBN on raw data', obj.arffFileName, channelNames );
            fprintf('Time used creating ARFF file: %f seconds.\n', toc(tStart));
        end
        
        function [ ] = exportGenericToWeka( obj, data, labels, classes, name, arffFileName, channelNames )
            hasLabels = ~isempty( labels );
            
            % open arff-file, always overwrite!
            fid = fopen( arffFileName, 'w+' );
            
            % save comments to the file
            fprintf( fid, '%% %s \n', 'created with SmartSleep WEKA-Export skript' );
            fprintf( fid, '%% created on: %s \n\n', datestr( now ) );
            
            % save sessionid as relation
            fprintf( fid, '\n\n@RELATION \''%s\''\n\n', name );
            
            [ windowsCount, windowsSize ] = size( data );
            
            for j = 1 : length( channelNames )
                fprintf( fid, '@ATTRIBUTE %s NUMERIC\n', channelNames{ j } );
            end
            
            fprintf( fid, '@ATTRIBUTE class {' );
            
            for i = 1 : length( classes )
                fprintf( fid, '%s', classes{ i } );
                
                if ( i ~= length( classes ) )
                    fprintf( fid, ',' );
                end
            end
            
            fprintf( fid, '} \n' );
            
            % add data-section
            fprintf( fid, '\n@DATA \n');
            
            % append dataset for each fature-set
            for i = 1 : windowsCount
                for j = 1 : windowsSize
                    if ( isnan( data( i, j ) ) )
                        fprintf( fid, '?,' );
                    else
                        fprintf( fid, '%d,', data( i, j ) );
                    end
                end
                
                if ( hasLabels )
                    activityIdx = labels( i );
                    
                    if ( isnan( activityIdx ) )
                        fprintf( fid, '?' );
                    else
                        fprintf( fid, '%s', classes{ activityIdx } );
                    end
                else
                    fprintf( fid, '?' );
                end
                
                % new-line
                fprintf( fid, '\n' );
            end
            
            % close file
            fclose( fid );
        end
    end
    
end

