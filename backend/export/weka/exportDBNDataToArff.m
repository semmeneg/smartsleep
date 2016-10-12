function [ ] = exportDBNDataToArff( dataSet, arffFileName )

%GENARFF Summary of this function goes here
%   Detailed explanation goes here
    
    hasLabels = ( isfield( dataSet.dbn ,'labels' ) );
    
    % open arff-file, always overwrite!
    fid = fopen( arffFileName, 'w+' );

    % save comments to the file
    fprintf( fid, '%% %s \n', 'created with FHV SmartSleep WEKA-Export skript' );
    fprintf( fid, '%% created on: %s \n\n', datestr( now ) );
    fprintf( fid, '%% created by: Jonathan Thaler (jonathan.thaler@fhv.at)' );
   
    % save sessionid as relation
    fprintf( fid, '\n\n@RELATION \''%s\''\n\n', dataSet.info.name );

    inputDimensionPerChannel = ( dataSet.featureInfo.dbnSampling * dataSet.featureInfo.windowTime ) / 1000;
    
    % create ATTRIBUTE entry for each variable
    for i = 1 : length( dataSet.sensors )
        if ( isempty( dataSet.sensors{ i } ) )
            continue;
        end
        
        for j = 1 : length( dataSet.sensors{ i }.channels.names )
            for k = 1 : inputDimensionPerChannel
                fprintf( fid, '@ATTRIBUTE %s_%s_%d NUMERIC\n', ...
                    dataSet.sensors{ i }.name, ...
                    dataSet.sensors{ 1 }.channels.names{ j }, ...
                    k );
            end
        end
    end

    fprintf( fid, '@ATTRIBUTE class {' );

    for i = 1 : length( dataSet.activitiesInfo.classes )
        fprintf( fid, '%s', dataSet.activitiesInfo.classes{ i } );

        if ( i ~= length( dataSet.activitiesInfo.classes ) )
             fprintf( fid, ',' );
        end
    end
    
    fprintf( fid, '} \n' );
    
    % add data-section
    fprintf( fid, '\n@DATA \n');

    % append dataset for each fature-set
    for i = 1 : size( dataSet.dbn.data, 1 )
        for j = 1 : size( dataSet.dbn.data, 2 ) 
            if ( isnan( dataSet.dbn.data( i, j ) ) )
                fprintf( fid, '?,' );
            else
                fprintf( fid, '%d,', dataSet.dbn.data( i, j ) );
            end
        end

        if ( hasLabels )
            activityIdx = dataSet.dbn.labels( i );
            
            if ( isnan( activityIdx ) )
                fprintf( fid, '?' );
            else
                fprintf( fid, '%s', dataSet.activitiesInfo.classes{ activityIdx } );
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
