function [ ] = trainWEKAModel( wekaPath, trainingFile, modelFile, resultsFile )
%TRAINWEKAMODEL Summary of this function goes here
%   Detailed explanation goes here

    oldFolder = cd( wekaPath );

    cmd = [ 'java -Xmx1024m -cp weka.jar weka.classifiers.trees.RandomForest' ...
        ' -t "' trainingFile '"'...
        ' -d "' modelFile  '"' ];

    [ status, cmdout ] = system( cmd );

    fid = fopen( resultsFile, 'w' );
    fprintf( fid, '%s', cmdout );
    fclose( fid );
    
    cd( oldFolder );
end
