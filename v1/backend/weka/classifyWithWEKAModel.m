function [ cmdout, classificationData ] = classifyWithWEKAModel( wekaPath, ...
    modelFile, testFile, classifyInstances )
%RUNWEKA Summary of this function goes here
%   Detailed explanation goes here

    cmdout = [];
    classificationData = [];

    oldFolder = cd( wekaPath );

    cmd = [ 'java -cp weka.jar weka.classifiers.trees.RandomForest' ...
        ' -l "' modelFile '"'...
        ' -T "' testFile '"'...
        ' -o' ];
    
    if ( classifyInstances )
        cmd = [ cmd ' -p 0' ]
    end

    [ status, cmdout ] = system( cmd );

    cd( oldFolder );

    if ( false == classifyInstances )
        return;
    end
    
    REMOVE_START_LINES = 6;
    REMOVE_END_LINES = 2;

    lines = regexp( cmdout, '\n', 'split' );
    
    % remove unnecessary lines
    lines( 1 : REMOVE_START_LINES - 1 ) = [];
    lines( length( lines ) - REMOVE_END_LINES + 1 : length( lines ) ) = [];
    
    linesCount = length( lines );
 
    classificationData = zeros( linesCount, 3 );
    
    for i = 1 : linesCount
        % inst#     actual  predicted error prediction
        
        % remove whitespaces at the beginning and ending of the string
        l = strtrim( lines{ i } );
        % filter class-tokens using \w because can also contain ? for
        % unknown classes
        [ startIndices, endIndices ] = regexp( l, '\w*:' );
        % find error prediction value: can be comma value
        [ errorPredStartIdx, errorPredEndIdx ] = regexp( l, '\d[.]\d*' );
        
        % no comma-value: empty
        if ( isempty( errorPredStartIdx ) )
            % look for digits at end of the string
            [ errorPredStartIdx, errorPredEndIdx ] = regexp( l, '\d*' );
            errorPred = l( errorPredStartIdx( end ) : errorPredEndIdx( end ) );
        else
            % comma-value => extract
            errorPred = l( errorPredStartIdx( 1 ) : errorPredEndIdx( 1 ) );
        end

        classificationData( i, 3 ) = str2num( errorPred );
        
        predictedClassToken = l( startIndices( 2 ) : endIndices( 2 ) - 1 );
        classificationData( i, 1 ) = str2num( predictedClassToken );
        
        if ( '?' == l( endIndices( 1 ) + 1 ) )
            classificationData( i, 2 ) = nan;
        else
            actualClassToken = l( startIndices( 1 ) : endIndices( 1 ) - 1);
            classificationData( i, 2 ) = str2num( actualClassToken );
        end
    end
end
