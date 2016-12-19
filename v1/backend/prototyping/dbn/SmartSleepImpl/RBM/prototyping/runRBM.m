[ trainingData, testData ] = loadData();

% NOTE ACCORDING TO CONTINUOUS DATA:
%   it seems that it is ok to train with data which is continuous in
%   range [ 0 .. 1 ]!!! at least the toronto-code does it this way
%   => transform the smart-sleep data also into 0..1 to solve the problem 
%   of the continuous values.

% NOTE ACCORDING TO MINI-BATCHES:
% toronto-code uses minibatches with 100 images
% not used now, one batch consists of exactly one image

numhid = 10;
maxepoch = 10;

% TODO: need to feed better training-data, this data is just noise
%trainingData = rand( 1, 2, 1000 );
%trainingData = zeros( 1, 4, 1000 );
%trainingData = abs( sin(0:pi/100:2*pi) );

data = zeros( 1, 28*28, 1 );
data( 1, :, 1 : 10 ) = trainingData.data( :, 1 : 10 ); 

% NOTE: this is not yet the real training because pre-training is
% unsupervised! training is then the process of backpropagating the error
% through the network using labels 
dbnPreTrain( data, maxepoch, numhid );