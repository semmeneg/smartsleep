function [ featureArffFileName ] = exportSmartSleepToWEKA( dataSet, exportFolder, exportDBNData )
%EXPORTTOWEKA Summary of this function goes here
%   Detailed explanation goes here

    dataSetName = dataSet.info.name;

    featureArffFileName = sprintf( '%s\\%s.arff', exportFolder, dataSetName );
    % export data as labeled to ARFF for further processing in WEKA
    exportFeatureDataToArff( dataSet, featureArffFileName );
    
    if ( exportDBNData )
        dbnDataFileName = sprintf( '%s\\%s DBN Data.arff', exportFolder, dataSetName );
        % export data as labeled to ARFF for further processing in WEKA
        exportDBNDataToArff( dataSet, dbnDataFileName );

        if ( isfield( dataSet.dbn, 'features' ) )
            dbnFeaturesFileName = sprintf( '%s\\%s DBN Features.arff', exportFolder, dataSetName );
            % export DBN data as labeled to ARFF for further processing in WEKA
            exportDBNFeaturesToArff( dataSet, dbnFeaturesFileName );
        end
    end
end
