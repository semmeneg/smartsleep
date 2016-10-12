function [ RBM, output ] = pretrainRBM( RBM, allSamples, MAX_EPOCHS, CD_STEPS )
%PRETRAINRBM Summary of this function goes here
%   Detailed explanation goes here

    % GENERAL NOTES ABOUT RBM
    %   Generative Model: it learns a probabilistic distribution over 
    %      multiple variable in some way. TODO: what do we get from such a
    %      model - what is the interpretation of the output-values?
    %
    %   Energy Based Model: it uses an energy-based function to assign a
    %       global optimization value to the network and optimizes this
    %       function, where it tries to optimizes it by finding
    %       network-state with the lowest possible energy
    %
    %   Pre-Training: a RBM is pre-trained in an unsupervised learning
    %       method by using training data. This pre-training does not yet
    %       allow to classify test-data but it sets the network in a state
    %       where it is not likely to fall into local optima
    
    % maxepoch  -- maximum number of epochs
    % numhid    -- number of hidden units 
    % batchdata -- the data that is divided into batches (numcases numdims numbatches)
    % restart   -- set to 1 if learning starts from beginning 

    epsilonw      = 0.05;   % Learning rate for weights 
    epsilonvb     = 0.05;   % Learning rate for biases of visible units 
    epsilonhb     = 0.05;   % Learning rate for biases of hidden units 

    weightcost  = 0.001;   
    initialmomentum  = 0.5;
    finalmomentum    = 0.9;

    rbmAll = [];
    reconstructedBinaryInputAll = [];
    hiddenValuesAll = [];
    errorsInEpochs = zeros( 1, MAX_EPOCHS );
    
    [ sampleDims, sampleCount ] = size( allSamples );
    samplesInBatch = 1;
 
    poshidprobs = zeros(samplesInBatch, RBM.hidNodes);       % positive phase hidden-unit probabilities
    neghidprobs = zeros(samplesInBatch, RBM.hidNodes);       % negative phase hidden-unit probabilities
    posprods    = zeros(RBM.visNodes, RBM.hidNodes);        % positive products
    negprods    = zeros(RBM.visNodes, RBM.hidNodes);        % negative products
    vishidinc  = zeros(RBM.visNodes, RBM.hidNodes);         % leraning adjustment (increment) of weight-matrix
    hidbiasinc = zeros(1, RBM.hidNodes);               % leraning adjustment (increment) of hidden-unit biases
    visbiasinc = zeros(1, RBM.visNodes);              % leraning adjustment (increment) of visible unit biases

    % iterate for epochs
    for epoch = 1 : MAX_EPOCHS
        fprintf('\t\tepoch %d ... ',epoch); 
        errsum = 0;

        RBMClone = RBM;
        
        reconstructedInput = zeros( sampleDims, sampleCount );
        hiddenValues = zeros( RBMClone.hidNodes, sampleCount );
        
        for s = 1 : sampleCount,
            inputData = allSamples( :, s )';
            
            % perform k steps of contrastive convergence
            for k = 1 : CD_STEPS
                [ posprods, poshidact, posvisact, ...
                    negprods, neghidact, negvisact, ...
                    negdata, binaryInputData, ...
                    reconstruction, hiddenProbs ] = CDStep( inputData, ...
                        RBMClone.W, RBMClone.a, RBMClone.b, ...
                        samplesInBatch, RBMClone.visNodes, RBMClone.hidNodes );

                % NOTE: at this point we have two relevant values for
                % error-calculation
                %   1. the content of the variable binaryInputData: holds the original 
                %       (training) data-vector fed into the network.
                %
                %   2. the content of the variable negdata: holds the
                %           reconstructed data-vector of the network.
                % 
                % note that both values are binary (out of {0,1}).
                %
                % thus the error is naturally calculated by taking the difference
                % between the original value (data) and the reconstructed value 
                % of the network (negdata). error-metrics are always done using
                % squared difference (because negative values can erase
                % positive)
                % practical interpretation: it delivers the amount of
                % wrong classified pixels
                err = sum( sum( ( binaryInputData - negdata ).^2 ) );
                err = err / CD_STEPS;
                % sum over all errors within an epoch
                errsum = err + errsum;

                % TODO: see Practical Guide (Hinton) 9.1
                if epoch>5,
                    momentum=finalmomentum;
                else
                    momentum=initialmomentum;
                end;
                %%%%%%%%% UPDATE WEIGHTS AND BIASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                
                % NOTE: divide all values produced by repeated CD by number
                % of steps to normalize
                posprods = posprods / CD_STEPS;
                negprods = negprods / CD_STEPS;
                
                posvisact = posvisact / CD_STEPS;
                negvisact = negvisact / CD_STEPS;
                
                poshidact = poshidact / CD_STEPS;
                neghidact = neghidact / CD_STEPS;
               
                % calculate update-values
                % NOTE: divide by numperbatch to normalize activation values
                % NOTE: multiply by momentum to accelerate/dampen training
                vishidinc = momentum * vishidinc + ...
                    epsilonw *( ( posprods-negprods ) / samplesInBatch - weightcost * RBMClone.W );

                visbiasinc = momentum * visbiasinc + ( epsilonvb / samplesInBatch ) * ( posvisact - negvisact );
                hidbiasinc = momentum * hidbiasinc + ( epsilonhb/ samplesInBatch ) * ( poshidact - neghidact );

                % apply hebbian learning: adjust weights/biases by delta (what fires
                % together, wires together)
                RBMClone.W = RBMClone.W + vishidinc;
                RBMClone.a = RBMClone.a + visbiasinc;
                RBMClone.b = RBMClone.b + hidbiasinc;
                %%%%%%%%%%%%%%%% END OF UPDATES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

                % the reconstructed sample becomes the input for the next
                % step of CD
                inputData = reconstruction;
            end
            
            reconstructedInput( :, s ) = reconstruction;
            hiddenValues( :, s ) = hiddenProbs;
        end

        errorsInEpochs( epoch ) = errsum;
        reconstructedBinaryInputAll{ epoch } = reconstructedInput;
        hiddenValuesAll{ epoch } = hiddenValues;
        rbmAll{ epoch } = RBMClone;
        
        RBM = RBMClone;
        
        fprintf('finished\n'); 
    end;

     [ v, idx ] = min( errorsInEpochs );
%     
%     RBM = rbmAll{ idx };
    output = hiddenValuesAll{ idx };
end
