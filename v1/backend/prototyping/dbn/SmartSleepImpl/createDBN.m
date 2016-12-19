function [ DBN ] = createDBN( visibleInputCount, hiddenLayerNodes )
%CREATEDBN Summary of this function goes here
%   Detailed explanation goes here

    DBN = [];
    
    hiddenLayerCount = length( hiddenLayerNodes );
    
    if ( hiddenLayerNodes == 0 )
        error( 'need at least one hidden layer' );
    end
    
    fprintf( '\nCreating DBN with %d hidden layers...\n', hiddenLayerCount );
    
    fprintf( '\tRBM for hidden layer 1 ... ' );
    
    visibleNodes = visibleInputCount;
    hiddenNodes = hiddenLayerNodes( 1 );
    
    DBN.layers{ 1 } = createRBM( visibleNodes, hiddenNodes );

    fprintf( 'finished\n' );
    
    for i = 2 : hiddenLayerCount
        fprintf( '\tRBM for hidden layer %d ... ', i );
        
        visibleNodes = hiddenLayerNodes( i - 1 );
        hiddenNodes = hiddenLayerNodes( i );
    
        DBN.layers{ i } = createRBM( visibleNodes, hiddenNodes );
        
        fprintf( 'finished\n' );
    end
    
    fprintf( 'Finished creating DBN\n' );
end
