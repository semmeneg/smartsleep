function [ ] = genArff( dsout, arffFileName )
%GENARFF Summary of this function goes here
%   Detailed explanation goes here
    
    fprintf( 'Generating .arff-File %s\n', arffFileName );

     % check for validity of data-sizes
    if( length( size( dsout.Sensors.data ) ) ~= length( size( dsout.Time.Minutes ) ) )
        disp( 'Error: number of time-samples and feature-samples mismatch... ignoring genArff' );
        return;
    end
    
    if( length( size( dsout.Sensors.vnames ) ) ~= 2 )
        disp( 'Error: feature_var not in the correct format... ignoring genArff');
        return;
    end   
    
    if( length( size( dsout.Sensors.data ) ) ~= 2 )
        disp( 'Error: feature_data not in the correct format... ignoring genArff');
        return;
    end

    % open arff-file, always overwrite!
    fid = fopen( arffFileName, 'w+' );

    % save comments to the file
    fprintf( fid, '%% %s \n', 'created with smartSleepMat2arff skript' );
    fprintf( fid, '%% created on: %s \n\n', datestr( now ) );
    
    % save meta-info
    for i = 1 : size( dsout.Labels.vnames, 2 )
        fprintf( fid, '%% %s: %s\n', dsout.Labels.vnames{ 1, i }, dsout.Labels.tab{ 1, i } );
    end
    
    % save sessionid as relation
    fprintf( fid, '\n\n@RELATION %s\n\n', dsout.Labels.tab{ 1, 4 } );

    % attach additional time-ATTRIBUTE as it is a timeseries
    fprintf( fid, '@ATTRIBUTE timestamp DATE "yyyy-MM-dd HH:mm:ss"\n' );

    % create ATTRIBUTE entry for each variable
    for i = 1 : size( dsout.Sensors.vnames, 2 )
        fprintf( fid, '@ATTRIBUTE %s NUMERIC\n', dsout.Sensors.vnames{ i } );
    end

    % add data-section
    fprintf( fid, '\n@DATA \n');

    % append dataset for each fature-set
    for i = 1 : size( dsout.Sensors.data, 1 )
        % add timestamp to file
        fprintf( fid, '"%s",', datestr( dsout.Time.Time( i ), 'yyyy-mm-dd HH:MM:SS' ) );

        for j = 1 : size( dsout.Sensors.data, 2 )
            fprintf( fid, '%d,', dsout.Sensors.data( i, j ) );
        end

        % new-line
        fprintf( fid, '\n' );
    end

    % close file
    fclose( fid );
end

