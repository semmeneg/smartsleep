function [ reconstructedSamples ] = reconstructDBN( DBN, testSamples )
%RECONSTRUCTDBN Summary of this function goes here
%   Detailed explanation goes here

    fprintf( '\nReconstructing sample from DBN...\n' );
    
    layerCount = length( DBN.layers );
    [ sampleDim, sampleCount ] = size( testSamples );
    
    reconstructedSamples = zeros( sampleDim, sampleCount );
    
    for k = 1 : sampleCount
        fprintf( '\tsample %d ... ', k );
        
        visibleProbabilities = testSamples( :, k )';
        
        % NOTE: according to Practical Guide of Hinton (page 6, 3.4) "When
        % the[y] [hidden units] are driven by reconstructions, always use
        % probabilities without sampling".
        % That is what we implement here: propagate the inputSample through
        % all hidden-layers using PROBABILITIES (and not binary values by
        % random thresholds) and NOT doing CD. After reaching the final
        % hidden-layer propagate the values down back to the first layer
        % back into the visible-units - the probabilities of the visible
        % units resemble then the reconstructed sample

        for i = 1 : layerCount
            RBM = DBN.layers{ i };

            hiddenProbabilities = hiddenProbRBM( RBM, visibleProbabilities );
            % hidden units become visible units of next layer
            visibleProbabilities = hiddenProbabilities;
        end
        
        for i = layerCount : -1 : 1
            RBM = DBN.layers{ i };

            visibleProbabilities = visibleProbRBM( RBM, hiddenProbabilities );
            % visible units become hidden units of previous layer
            hiddenProbabilities = visibleProbabilities;
        end
        
        reconstructedSamples( :, k ) = visibleProbabilities;
        fprintf( 'finished\n' );
    end
    
    fprintf( 'Reconstruction finished\n' );
end
