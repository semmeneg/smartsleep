function [ chest ] = testDataToChestArff( outputFolder, rawData, samplingRate )
%TOWISDM Summary of this function goes here
%   Detailed explanation goes here

    chest = createChest( rawData, [] );
    
    % interpolate to fit sampling rate of WISDM
    chest.raw.data = resampleData( chest.raw.data, samplingRate, chest.params.sampleRate );
    
    [ chest.window ] = generateAccDataWindows( chest.params, chest.raw );
    
    exportAccDBNWeka( chest.window.data, chest.window.labels, chest.classes, ...
        'Chest-Dataset', [ outputFolder 'chest.arff' ], chest.params.mixChannels );
    exportAccDBNWeka( chest.window.spectral, chest.window.labels, chest.classes, ...
        'Chest-Dataset Spectral', [ outputFolder 'chest_spectral.arff' ], chest.params.mixChannels );
end
