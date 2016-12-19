function [ ] = exportPCADataToArff( dataSet, arffFileName )
%EXPORTPCADATATOARFF Summary of this function goes here
%   Detailed explanation goes here

    hasLabels = ( isfield( dataSet.activitiesInfo ,'activities' ) );
    
    % open arff-file, always overwrite!
    fid = fopen( arffFileName, 'w+' );

    % save comments to the file
    fprintf( fid, '%% %s \n', 'created with FHV SmartSleep WEKA-Export skript' );
    fprintf( fid, '%% created on: %s \n\n', datestr( now ) );
    fprintf( fid, '%% created by: Jonathan Thaler (jonathan.thaler@fhv.at)' );
   
    % save sessionid as relation
    fprintf( fid, '\n\n@RELATION \''%s\''\n\n', dataSet.info.name );
    
    % create generic ATTRIBUTE entry for each dimension of pcaData
    for i = 1 : size( dataSet.pca.reducedFeatures, 1 )
        fprintf( fid, '@ATTRIBUTE PCA_Component_%d NUMERIC\n', i );
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
    for i = 1 : size( dataSet.pca.reducedFeatures, 2 )
        for j = 1 : size( dataSet.pca.reducedFeatures, 1 ) 
            if ( isnan( dataSet.pca.reducedFeatures( j, i ) ) )
                fprintf( fid, '?,' );
            else
                fprintf( fid, '%d,', dataSet.pca.reducedFeatures( j, i ) );
            end
        end
       
        if ( hasLabels )
            fprintf( fid, '%s', dataSet.activitiesInfo.classes{ dataSet.featureLabels( i ) } );
        else
            fprintf( fid, '?' );
        end

        % new-line
        fprintf( fid, '\n' );
    end

    % close file
    fclose( fid );
end
