function [ trainingData, testData ] = loadData()
%LOADMNIST Summary of this function goes here
%   Detailed explanation goes here

    fprintf( 'Loading data...\n' );
    
    trainingMatFile = 'dbnTraining.mat';
    testingMatFile = 'dbnTesting.mat';

    if ( exist( trainingMatFile, 'file') == 2 )
        fprintf( '\ttraining MAT-File found, loading... ' );
        
        load( trainingMatFile );
        
        fprintf( 'finished.\n' );
    
    else
        fprintf( '\ttraining MAT-File not found, loading from MNIST files train-images-idx3-ubyte & train-labels-idx1-ubyte... ' );
        
        [ trainingImages, trainingLabels ] = readMNIST( 'train-images.idx3-ubyte', 'train-labels.idx1-ubyte' );
        trainingImages = flattenImages( trainingImages );
        
        trainingData = struct( 'data', trainingImages, 'labels', trainingLabels );
        save( trainingMatFile, 'trainingData' );
        
        fprintf( 'finished\n' ); 
    end

    if ( exist( testingMatFile, 'file') == 2 )
        fprintf( '\ttesting MAT-File found, loading... ' );
        
        load( testingMatFile );
        
        fprintf( 'finished.\n' );
    
    else
        fprintf( '\ttesting MAT-File not found, loading from MNIST files t10k-images-idx3-ubyte & t10k-labels-idx1-ubyte... ' );
        
        [ testingImages, testingLabels ] = readMNIST( 't10k-images.idx3-ubyte', 't10k-labels.idx1-ubyte' );
        testingImages = flattenImages( testingImages );
        
        testData = struct( 'data', testingImages, 'labels', testingLabels );
        save( testingMatFile, 'testData' );
        
        fprintf( 'finished\n' ); 
    end
    
    fprintf( 'Finished loading data\n' );
end
