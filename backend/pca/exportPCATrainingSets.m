function [ ] = exportPCATrainingSets( allTrainingSets )
%EXPORTPCATRAININGSETS Summary of this function goes here
%   Detailed explanation goes here

    for i = 1 : length( allTrainingSets )
        parent = allTrainingSets{ i };
        
        for j = 1 : length( allTrainingSets )
            if ( i == j )
                continue;
            end
            
            copySet = allTrainingSets{ j };
            
            copySet.pca.reducedFeatures = pcaReduce( copySet.features', parent.pca.reductionMatrix );

            exportPCAArffLabeledFileName = sprintf( '%s PCA_BY %s LABELED.arff', copySet.info.name, parent.info.name );
            exportPCAArffUnlabeledFileName = sprintf( '%s PCA_BY %s UNLABELED.arff', copySet.info.name, parent.info.name );

            exportPCADataToArff( copySet, exportPCAArffLabeledFileName );
            exportPCADataToArff( copySet, exportPCAArffUnlabeledFileName );
        end
    end
end
