function [ hmp ] = exportHMP( rootFolder, outputFolder, weka )

    hmp = createHMP( [], [] );

    folders = dir( rootFolder );

    for i = 1 : length( folders ) 
        folder = folders( i );
        if ( folder.isdir )
            if ( strcmp( folder.name, '.' ) || strcmp( folder.name, '..' ) )
                continue;
            end

            folderName = [ rootFolder folder.name '\' ];

            labelIdx = 0;

            for j = 1 : length( hmp.classes )
                c = hmp.classes{ j };
                str = strfind( folder.name, c );
                if ( isempty( str ) )
                    continue;
                end

                labelIdx = j;
                break;
            end

            if ( 0 == labelIdx )
                continue;
            end

            files = dir([ folderName, '*.txt' ]);
            for j = 1 : length( files )
                file = files( j );

                fileName = [ folderName file.name ];
                csvdData = csvread( fileName );

                csvdData( :, 1 ) = -14.709 + (csvdData(:, 1)/63)*(2*14.709);
                csvdData( :, 2 ) = -14.709 + (csvdData(:, 2)/63)*(2*14.709);
                csvdData( :, 3 ) = -14.709 + (csvdData(:, 3)/63)*(2*14.709);

                sampleCount = length( csvdData );

                hmp.raw.data( end + ( 1 : sampleCount ), : ) = csvdData;
                hmp.raw.labels( end + ( 1 : sampleCount ), 1 ) = labelIdx;
            end
        end
    end

    [ hmp.window ] = generateAccDataWindows( hmp.params, hmp.raw );

    save( [ outputFolder 'hmp.mat' ], 'hmp' );

    arffFile = [ outputFolder weka.arff.raw ];
    arffSpectralFile = [ outputFolder weka.arff.spectral ];
    
    exportAccDBNWeka( hmp.window.data, hmp.window.labels, hmp.classes, ...
        'HMP-Dataset', arffFile, hmp.params.mixChannels );
    exportAccDBNWeka( hmp.window.spectral, hmp.window.labels, hmp.classes, ...
        'HMP-Dataset Spectral', arffSpectralFile, hmp.params.mixChannels );
    
    trainWEKAModel( weka.path, arffFile, [ outputFolder weka.model.raw ] );
    trainWEKAModel( weka.path, arffSpectralFile, [ outputFolder weka.model.spectral ] );
end