function [ classifiedLabels, errors, errRate ] = classifyTestSet( trainedSet, testSet, stream )
%CLASSIFYTESTSET Summary of this function goes here
%   Detailed explanation goes here

    errors = [];
    
    % TODO: get an error-estimate/probability for each output 
    classifiedLabels = trainedSet.dbn.classificator.getOutput( testSet.dbn.data );

    if ( isfield( trainedSet, 'uniqueActivitiesMappings' ) )
        classifiedLabels = trainedSet.uniqueActivitiesMappings.backward( classifiedLabels );
    end

    % test-set has labels too, can calculate the errors and CM
    if ( isfield( testSet.dbn, 'labels' ) )
        testLabels = testSet.dbn.labels;
        if ( isfield( testSet, 'uniqueActivitiesMappings' ) )
            testLabels = testSet.uniqueActivitiesMappings.backward( testLabels );
        end
    
        errors = classifiedLabels ~= testLabels;
        errRate = sum( errors ) / length( testLabels ) ;
        
        % calculate confusion-matrix
        [ cm ] = calcCM( trainedSet.activitiesInfo.classes, classifiedLabels, testLabels );
        % print out results of the confusion-matrix
        printCM( stream, trainedSet.activitiesInfo.classes, cm );
    end
end
