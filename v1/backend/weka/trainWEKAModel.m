function [ ] = trainWEKAModel( wekaPath, trainingFile, modelFile, resultsFile )
%TRAINWEKAMODEL Summary of this function goes here
%   Detailed explanation goes here

    oldFolder = cd( wekaPath );
    disp('Start training Weka classifier ...');
    cmd = [ 'java -Xmx6144m -cp weka.jar weka.classifiers.trees.RandomForest' ...
        ' -t "' trainingFile '"'...
        ' -d "' modelFile  '"' ];

    [ status, cmdout ] = system( cmd );

    fid = fopen( resultsFile, 'w' );
    fprintf( fid, '%s', cmdout );
    fclose( fid );
    
    cd( oldFolder );
    disp('... finished training Weka classifier.');
end
