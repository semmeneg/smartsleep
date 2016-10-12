function [ targetDataSet ] = copyDataSetInvariants( targetDataSet, sourceDataSet )
%COPYDATASETINVARIANTS Summary of this function goes here
%   Detailed explanation goes here

    targetDataSet.activitiesInfo.classes = sourceDataSet.activitiesInfo.classes;

    targetDataSet.featureInfo = sourceDataSet.featureInfo;
    targetDataSet.componentInfo = sourceDataSet.componentInfo;

    targetDataSet.sensors = cell( 1, length( sourceDataSet.sensors ) );
    
    for i = 1 : length( sourceDataSet.sensors )
        if ( isempty( sourceDataSet.sensors{ i } ) )
            continue;
        end
        
        targetDataSet.sensors{ i }.name = sourceDataSet.sensors{ i }.name;
        targetDataSet.sensors{ i }.channels = sourceDataSet.sensors{ i }.channels;
    end
end