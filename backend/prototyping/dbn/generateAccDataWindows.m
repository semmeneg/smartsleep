function [ window ] = generateAccDataWindows( params, raw )
%GENERATEDATAWINDOWS Summary of this function goes here
%   Detailed explanation goes here

    hasLabels = false == isempty( raw.labels );
    
    windowSampleSize = floor( ( params.windowSizeTime * params.sampleRate ) / 1000 );
    windowStepSize = floor( windowSampleSize * ( 1.0 - params.windowOverlapRatio ) );

    channelCount = 3;
    totalSamples = length( raw.data );
    windowCount = floor( totalSamples / windowStepSize ) - 2; % remove one window-count because last overlap will get out of bounds
    
    windowSamples = channelCount * windowSampleSize;
    windowSpectralSamples = channelCount * floor( windowSampleSize / 2.0 );
    
    window.data = zeros( windowCount, windowSamples );
    window.spectral = zeros( windowCount, windowSpectralSamples );
    
    if ( hasLabels )
        window.labels = zeros( windowCount, 1 );
    else
        window.labels = [];
    end
    
    fromIdx = 1;
    
    for i = 1 : windowCount
        toIdx = fromIdx + windowSampleSize - 1;

        windowData = raw.data( fromIdx : toIdx, : );
        
        if ( hasLabels )
            window.labels( i ) = mode( raw.labels( fromIdx : toIdx ) );
        end
        
        fftData = fft( windowData );
        Px = fftData .* conj( fftData ) / ( windowSampleSize * windowSampleSize ); 
        windowSpectralData = Px( 1 : floor( windowSampleSize / 2.0 ), : );
        
        if ( params.mixChannels )
             windowData = windowData';
             windowSpectralData = windowSpectralData';
        end

        window.data( i, : ) = reshape( windowData, 1, windowSamples );
        window.spectral( i, : ) = reshape( windowSpectralData, 1, windowSpectralSamples );
        
        fromIdx = fromIdx + windowStepSize;
    end
end
