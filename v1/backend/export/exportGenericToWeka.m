function [ ] = exportGenericToWeka( data, labels, classes, name, arffFileName, channelNames )
%GENARFF Summary of this function goes here
%   Detailed explanation goes here
    
    hasLabels = ~isempty( labels );
    
    % open arff-file, always overwrite!
    fid = fopen( arffFileName, 'w+' );

    % save comments to the file
    fprintf( fid, '%% %s \n', 'created with FHV SmartSleep WEKA-Export skript' );
    fprintf( fid, '%% created on: %s \n\n', datestr( now ) );
    fprintf( fid, '%% created by: Jonathan Thaler (jonathan.thaler@fhv.at)' );
   
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
