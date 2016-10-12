function [ hmp ] = trainHMP( hmp, outputFolder )
    if ( isempty( hmp ) )
        load( [outputFolder '\HMP.mat' ] );
    end
    
    hmp.params.dataStratification = [ 0.6 0.2 0.2 ];
    hmp.params.uniformClassDistribution = false;
    hmp.params.hiddenLayers = 3;
    hmp.params.hiddenUnitsCount = 1000;
    hmp.params.maxEpochs = 150;
    hmp.params.normalize = true;

    hmp.dbn = accelerometerDBNTrain( hmp.window.data, hmp.window.labels, hmp.params );

    save( [ outputFolder '\HMP.mat' ], 'hmp' );

    selfClassifyAccDBN( hmp );
end