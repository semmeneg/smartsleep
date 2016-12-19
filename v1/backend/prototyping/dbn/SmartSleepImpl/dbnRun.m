MAX_EPOCHS = 10;

[ allTrainingData, allTestData ] = loadData();

%trainingData = allTrainingData.data( :, 1 : 10 );
trainingData = allTrainingData.data;

testData = allTestData.data( :, 1 : 10 );
%testData = allTestData.data;

[ trainingSampleDimension, trainingSampleCount ] = size( trainingData );
[ testSampleDimension, testSampleCount ] = size( testData );

randomorder = randperm( trainingSampleCount );
trainingData = trainingData( :, randomorder );

% create and pre-train DBN
DBN = createDBN( trainingSampleDimension, [ 10 ] );
[ DBN, finalOutput ] = pretrainDBN( DBN, trainingData, MAX_EPOCHS );

% test trained DBN by providing test-samples and let reconstruct them by 
% DBN and compare reconstruction to original test-sample
testReconstructions = reconstructDBN( DBN, testData );
for i = 1 : testSampleCount
    original = testData( :, i );
    rec = testReconstructions( :, i );
    
    figure;
    subplot(2,1,1);
    imshow( unflattenImage( original, 28, 28 ) );
    
    subplot(2,1,2);
    imshow( unflattenImage( rec, 28, 28 ) );
end