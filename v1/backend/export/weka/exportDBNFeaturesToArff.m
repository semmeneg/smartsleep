function [ ] = exportDBNFeaturesToArff( dataSet, arffFileName )
%EXPORTPCADATATOARFF Summary of this function goes here
%   Detailed explanation goes here

    % NOTE: features in DBN are only present when there are labels
    
    % open arff-file, always overwrite!
    fid = fopen( arffFileName, 'w+' );

    % save comments to the file
    fprintf( fid, '%% %s \n', 'created with FHV SmartSleep WEKA-Export skript' );
    fprintf( fid, '%% created on: %s \n\n', datestr( now ) );
    fprintf( fid, '%% created by: Jonathan Thaler (jonathan.thaler@fhv.at)' );
   
    % save sessionid as relation
    fprintf( fid, '\n\n@RELATION \''%s\''\n\n', dataSet.info.name );
    
    % create generic ATTRIBUTE entry for each dimension of pcaData
    for i = 1 : size( dataSet.dbn.features, 2 )
        fprintf( fid, '@ATTRIBUTE DBN_Component_%d NUMERIC\n', i );
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
    for i = 1 : size( dataSet.dbn.features, 1 )
        for j = 1 : size( dataSet.dbn.features, 2 ) 
            if ( isnan( dataSet.dbn.features( i, j ) ) )
                fprintf( fid, '?,' );
            else
                fprintf( fid, '%d,', dataSet.dbn.features( i, j ) );
            end
        end

        fprintf( fid, '%s', dataSet.activitiesInfo.classes{ dataSet.dbn.labels( i ) } );
       
        % new-line
        fprintf( fid, '\n' );
    end

    % close file
    fclose( fid );
end
