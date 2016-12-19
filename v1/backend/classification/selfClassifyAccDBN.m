function [ ] = selfClassifyAccDBN( dataSet )
%SELFCLASSIFY Summary of this function goes here
%   Detailed explanation goes here

    testData = dataSet.window.data;
    testLabels = dataSet.window.labels;

    classifiedLabels = dataSet.dbn.net.getOutput( testData );

    [ cm ] = calcCM( dataSet.classes, classifiedLabels, testLabels );
    printCM( dataSet.classes, cm );
end
