function [ ] = exportFeatureDataToArff( dataSet, arffFileName )

%GENARFF Summary of this function goes here
%   Detailed explanation goes here
    
    hasLabels = ( isfield( dataSet.features ,'labels' ) );
    
    % open arff-file, always overwrite!
    fid = fopen( arffFileName, 'w+' );

    % save comments to the file
    fprintf( fid, '%% %s \n', 'created with FHV SmartSleep WEKA-Export skript' );
    fprintf( fid, '%% created on: %s \n\n', datestr( now ) );
    fprintf( fid, '%% created by: Jonathan Thaler (jonathan.thaler@fhv.at)' );
   
    % save sessionid as relation
    fprintf( fid, '\n\n@RELATION \''%s\''\n\n', dataSet.info.name );

    % create ATTRIBUTE entry for each variable
    for i = 1 : length( dataSet.componentInfo.names )
        features = dataSet.componentInfo.features{ i };
        
        for j = 1 : length( features )
            f = features( j );
            
            compNameNoSpace = strrep( dataSet.componentInfo.names{ i }, ' ', '_' );
            featureName = dataSet.featureInfo.names{ f };

            fprintf( fid, '@ATTRIBUTE %s_%s NUMERIC\n', ...
                compNameNoSpace, ...
                featureName );
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
    for i = 1 : size( dataSet.features.data, 2 )
        for j = 1 : size( dataSet.features.data, 1 ) 
            if ( isnan( dataSet.features.data( j, i ) ) )
                fprintf( fid, '?,' );
            else
                fprintf( fid, '%d,', dataSet.features.data( j, i ) );
            end
        end

        if ( hasLabels )
            activityIdx = dataSet.features.labels( i );
            
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
