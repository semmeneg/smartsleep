function [ chest ] = exportChest( rootFolder, outputFolder, weka )

    chest = createChest( [], [] );
    files = dir([rootFolder,'*.csv']);

    for i = 1 : length( files ) 
        file = files( i );
        csvData = csvread( sprintf( '%s/%s', rootFolder, file.name ) );

        d = csvData( :, 2:4 );
        l = csvData( :, 5 );

        chest.raw.data( end + ( 1 : length( d ) ), : ) = d;
        chest.raw.labels( end + ( 1 : length( l ) ), 1 ) = l;
    end

    % remove classes of 0
    chest.raw.data( find( chest.raw.labels == 0 ), : ) = [];
    chest.raw.labels( find( chest.raw.labels == 0 ) ) = [];

    [ chest.window ] = generateAccDataWindows( chest.params, chest.raw );

    save( [ outputFolder 'chest.mat' ], 'chest' );

    arffFile = [ outputFolder weka.arff.raw ];
    arffSpectralFile = [ outputFolder weka.arff.spectral ];
    
    exportAccDBNWeka( chest.window.data, chest.window.labels, chest.classes, ...
        'Chest-Dataset', arffFile, chest.params.mixChannels );
    exportAccDBNWeka( chest.window.spectral, chest.window.labels, chest.classes, ...
        'Chest-Dataset Spectral', arffSpectralFile, chest.params.mixChannels );
    
    trainWEKAModel( weka.path, arffFile, [ outputFolder weka.model.raw ] );
    trainWEKAModel( weka.path, arffSpectralFile, [ outputFolder weka.model.spectral ] );
end
