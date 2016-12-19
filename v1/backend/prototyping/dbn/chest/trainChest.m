function [ chest ] = trainChest( chest, outputFolder )
    if ( isempty( chest ) )
        load( [ outputFolder '\CHEST.mat' ] );
    end

    chest.params.dataStratification = [ 0.6 0.2 0.2 ];
    chest.params.uniformClassDistribution = false;
    chest.params.hiddenLayers = 2;
    chest.params.hiddenUnitsCount = 1000;
    chest.params.maxEpochs = 10;
    chest.params.normalize = true;

    chest.dbn = accelerometerDBNTrain( chest.window.data, chest.window.labels, chest.params );

    save( [ outputFolder '\CHEST.mat' ], 'chest' );

    selfClassify( chest );
end