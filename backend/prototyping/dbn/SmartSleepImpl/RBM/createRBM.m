function [ RBM ] = createRBM( visibleNodes, hiddenNodes )
%CREATERBM Summary of this function goes here
%   Detailed explanation goes here

    RBM = [];
    
    RBM.visNodes = visibleNodes;
    RBM.hidNodes = hiddenNodes;

    RBM.W = 0.001 * randn( visibleNodes, hiddenNodes );   % visible-to-hidden weights (W Matrix)
    RBM.a = zeros( 1, visibleNodes );           % visible unit biases
    RBM.b = zeros( 1, hiddenNodes  );           % hidden-unit biases
end