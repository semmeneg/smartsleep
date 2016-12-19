function [ hpm ] = testDataToHPMArff( outputFolder, rawData, samplingRate )
%TOWISDM Summary of this function goes here
%   Detailed explanation goes here

    hpm = createHMP( rawData, [] );
    
    % interpolate to fit sampling rate of WISDM
    hpm.raw.data = resampleData( hpm.raw.data, samplingRate, hpm.params.sampleRate );
    
    [ hpm.window ] = generateAccDataWindows( hpm.params, hpm.raw );
    
    exportAccDBNWeka( hpm.window.data, hpm.window.labels, hpm.classes, ...
        'HPM-Dataset', [ outputFolder 'hpm.arff' ], hpm.params.mixChannels );
    exportAccDBNWeka( hpm.window.data, hpm.window.labels, hpm.classes, ...
        'HPM-Dataset Spectral', [ outputFolder 'hpm_spectral.arff' ], hpm.params.mixChannels );
end
