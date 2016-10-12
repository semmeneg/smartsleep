function [ DBN, finalOutput ] = pretrainDBN( DBN, trainingSamples, MAX_EPOCHS )
%TRAINDBN Summary of this function goes here
%   Detailed explanation goes here

    fprintf( '\nPre-Training DBN using %d EPOCHS...\n', MAX_EPOCHS );
    
    CD_STEPS = 1;
    layerCount = length( DBN.layers );
    input = trainingSamples;

    for i = 1 : layerCount
        fprintf( '\tRBM of layer %d ... \n', i );
    
        RBM = DBN.layers{ i };

        [ RBM, output ] = pretrainRBM( RBM, input, MAX_EPOCHS, CD_STEPS );
        
        DBN.layers{ i } = RBM;
        input = output;
        
        fprintf( '\tRBM of layer %d finished\n', i );
    end

    finalOutput = output;
    
    fprintf( 'Finished pre-training DBN\n' );
end
