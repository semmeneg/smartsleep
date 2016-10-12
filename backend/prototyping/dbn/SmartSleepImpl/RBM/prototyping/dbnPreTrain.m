function [ ] = dbnPreTrain( trainingData, maxepoch, numhid )
%DPN Summary of this function goes here
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

    % numperbatch:  number of images in one batch
    % numdims:      number of pixels of a image in one batch
    % numbatches:   number of batches (number of images in MNIST)
    [numperbatch, numdims, numbatches]=size(trainingData);
    epoch=1;
    
    % TODO: when set to higher levels, the reconstructed signal drifts 
    % further and further away from the original (error increases)
    CD_STEPS = 1;
    
    originalBinaryInputAll = [];
    reconstructedBinaryInputAll = [];
    hiddenValuesAll = [];
    errorsInEpochs = zeros( 1, maxepoch );
    
    % Initializing symmetric weights and biases. 
    W = 0.001*randn(numdims, numhid);  % visible-to-hidden weights (W Matrix)
    b = zeros(1,numhid);               % hidden-unit biases
    a = zeros(1,numdims);              % visible unit biases

    poshidprobs = zeros(numperbatch,numhid);       % positive phase hidden-unit probabilities
    neghidprobs = zeros(numperbatch,numhid);       % negative phase hidden-unit probabilities
    posprods    = zeros(numdims,numhid);        % positive products
    negprods    = zeros(numdims,numhid);        % negative products
    vishidinc  = zeros(numdims,numhid);         % leraning adjustment (increment) of weight-matrix
    hidbiasinc = zeros(1,numhid);               % leraning adjustment (increment) of hidden-unit biases
    visbiasinc = zeros(1,numdims);              % leraning adjustment (increment) of visible unit biases
    
    % iterate for epochs
    for epoch = epoch:maxepoch
        %fprintf(1,'epoch %d\r',epoch); 
        errsum=0;

        originalInput = zeros( numdims, numbatches );
        reconstructedInput = zeros( numdims, numbatches );

        hiddenValues = zeros( numhid, numbatches );
        
        % for each batch...
        for batch = 1:numbatches,
            %fprintf(1,'epoch %d batch %d\r',epoch,batch); 

            originalData = trainingData( :, :, batch );
            inputData = originalData;
            
            % perform k steps of contrastive convergence
            for k = 1 : CD_STEPS
                [ posprods, poshidact, posvisact, ...
                    negprods, neghidact, negvisact, ...
                    negdata, binaryInputData, ...
                    reconstruction, hiddenProbs ] = CDStep( inputData, ...
                        W, a, b, numperbatch, numdims, numhid );

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
                    epsilonw *( ( posprods-negprods ) / numperbatch - weightcost * W );

                visbiasinc = momentum * visbiasinc + ( epsilonvb / numperbatch ) * ( posvisact - negvisact );
                hidbiasinc = momentum * hidbiasinc + ( epsilonhb/ numperbatch ) * ( poshidact - neghidact );

                % apply hebbian learning: adjust weights/biases by delta (what fires
                % together, wires together)
                W = W + vishidinc;
                a = a + visbiasinc;
                b = b + hidbiasinc;
                %%%%%%%%%%%%%%%% END OF UPDATES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

                % the reconstructed sample becomes the input for the next
                % step of CD
                inputData = reconstruction;
            end
            
            originalInput( :, batch ) = originalData;
            reconstructedInput( :, batch ) = reconstruction;
            hiddenValues( :, batch ) = hiddenProbs;
        end

        errorsInEpochs( epoch ) = errsum;
        originalBinaryInputAll{ epoch } = originalInput;
        reconstructedBinaryInputAll{ epoch } = reconstructedInput;
        hiddenValuesAll{ epoch } = hiddenValues;
        
        %fprintf(1, 'epoch %4i error %6.1f  \n', epoch, errsum); 
    end;

    [ v, idx ] = min( errorsInEpochs );

    relativeError = v / ( numdims * numbatches );
        
    fprintf(1, 'best epoch was %4i with relative error of %6.1f%%, absolute error = %4i \n', idx, ( relativeError * 100 ), v ); 
    figure;

    subplot(2,1,1);
    %plot( originalBinaryInputAll{ idx } );
    %imshow( originalBinaryInputAll{ idx } );
    imshow( unflattenImage( originalBinaryInputAll{ idx },28,28 ) );
    subplot(2,1,2);
    %plot( reconstructedBinaryInputAll{ idx } );
    %imshow( reconstructedBinaryInputAll{ idx } );
    imshow( unflattenImage( reconstructedBinaryInputAll{ idx },28,28 ));
    %subplot(3,1,3);
    %imshow( hiddenValuesAll{ idx } );
    %plot( hiddenValuesAll{ idx } );
end
