function [ ] = dbnPreTrain_old( trainingData, maxepoch, numhid )
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
    
    %   Contrastive Divergence: TODO explain
    %   Gibbs Sampling:
    
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

    % numcases:     number of images in one batch
    % numdims:      number of pixels of a image in one batch
    % numbatches:   number of batches (number of images in MNIST)
    [numperbatch, numdims, numbatches]=size(trainingData);
    epoch=1;
    
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

            data = trainingData( :, :, batch );
  
            originalInput( :, batch ) = data;
            
            % NOTE: this function performs given steps of contrastive convergence

            % NOTE: this is an implementation of a 1-step CD
            % contrastive divergence was shown to follow no function but
            % it was shown empirically that it works suprisingly well for
            % training with only 1 step.

            % create bias copies for each image in the batch
            visbias = repmat(a,numperbatch,1);
            hidbias = repmat(2*b,numperbatch,1);   % TODO: why multiply with 2?

            % NOTE: the 1-step CD works as follows:
            % first a training-sample is propagated to the hidden units to 
            % calculate the probabilities of these hidden units become 1 
            % with the given training-sample. note that the training-sample
            % must be binary which is achieved by setting them to 1 when
            % their value (must be in range of [0..1]) is above a random
            % value.
            % then these hidden-unit probabilities are transformed into

            % NOTE: need binary values. assume that data is a probability
            % value in range of [0..1] then set to 1 with a given random
            % probability. See Practical Guide by Hinton Formula (10)
            data = data > rand(numperbatch,numdims);
            
            %%%%%%%%% START POSITIVE PHASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % NOTE: now calculate probabilities that the hidden units are set to 
            % 1 when having  the given data in the visbile units (training-data)
            % see Practical Guide (Hinton) Formula (7)
            % why negative? because using formula (7) where the
            %   argument to the sigmoid function receives a negative sign
            %   (because of formula (2) and (4)
            % TODO: why 2*W? probably because of 2*b in hidbias, but why
            % there? Better numerical stabilty?
            % => these values 'belong' to the hidden units
            poshidprobs = 1./(1 + exp(-data*(2*W) - hidbias));  

            % NOTE: this value is needed for calculating the
            % gradient (See Practical Guide (Hinton) Formula (5)).
            % <...>p denotes the averages with respect to distribution p =>
            % because we are doing only CD with 1 step, no normalization is
            % necessary - if more steps are performed one needs to
            % normalize
            posprods = data' * poshidprobs;         % calculate <vihj>data: activation of visible neurons

            % NOTE: according to Practical Guide by Hinton, "A simplified
            % version of the same learning rule that uses the states of the
            % individual units instead of pairwise products is used for the
            % biases" (see passage after Formula (9))
            poshidact = sum(poshidprobs);           
            posvisact = sum(data);                 
            %%%%%%%%% END OF POSITIVE PHASE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%% START NEGATIVE PHASE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % NOTE: this is the reconstruction phase 

            % NOTE: need binary values. poshidprobs is already a
            % probability which denotes the probability of the HIDDEN units 
            % becoming 1 when having the given data-vector (training-sample). 
            % transform now to binary value with a given random value 
            % => these values 'belong' to the hidden units
            % See Practical Guide by Hinton Formula (11)
            poshidstates = poshidprobs > rand(numperbatch,numhid);

            % NOTE: now calculate the probability of the VISIBLE units
            % becoming 1 when having the given hidden units. 
            % see Practical Guide (Hinton) Formula (8)
            % => these values 'belong' to the visible units
            negdata = 1./(1 + exp(-poshidstates*W' - visbias));

            reconstructedInput( :, batch ) = negdata;
 
            % again need binary values. assume that data is a probability
            % value in range of [0..1] then set to 1 with a given random
            % probability. See Practical Guide by Hinton Formula (10)
            negdata = negdata > rand(numperbatch,numdims);

            % NOTE: now again calculate the probability that the HIDDEN
            % units are set to 1 when having the previously calculated
            % binary values of the visible units
            neghidprobs = 1./(1 + exp(-negdata*(2*W) - hidbias));

            hiddenValues( :, batch ) = neghidprobs;
 
            % NOTE: this value is needed for calculating the
            % gradient (See Practical Guide (Hinton) Formula (5)).
            % <...>p denotes the averages with respect to distribution p =>
            % because we are doing only CD with 1 step, no normalization is
            % necessary - if more steps are performed one needs to
            % normalize
            negprods  = negdata' * neghidprobs;     % calculate <vihj>model

            % NOTE: according to Practical Guide by Hinton, "A simplified
            % version of the same learning rule that uses the states of the
            % individual units instead of pairwise products is used for the
            % biases" (see passage after Formula (9))
            neghidact = sum(neghidprobs);
            negvisact = sum(negdata);

            %%%%%%%%% END OF NEGATIVE PHASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            % NOTE: at this point we have two relevant values:
            %   1. the content of the variable data
            %   2. the content of the variable negdata
            % variable data holds the original (training) data-vector fed
            % into the network.
            % variable negdata holds the reconstructed data-vector of the
            % network.
            % both values are binary (out of {0,1}).
            % thus the error is naturally calculated by taking the difference
            % between the original value (data) and the reconstructed value 
            % of the network (negdata). error-metrics are always done using
            % squared difference (because negative values can erase
            % positive)
            % practical interpretation: it delivers the amount of
            % wrong classified pixels
            err = sum( sum( ( data - negdata ).^2 ) );
            % sum over all errors within an epoch
            errsum = err + errsum;
            
            % TODO: see Practical Guide (Hinton) 9.1
            if epoch>5,
                %momentum=finalmomentum;
            else
                momentum=initialmomentum;
            end;

            %%%%%%%%% UPDATE WEIGHTS AND BIASES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
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
            
%             % just display progress
%             if rem(batch,600)==0  
%                 figure(1); 
%                 dispims(negdata',28,28);
%                 drawnow
%             end 
        end

        errorsInEpochs( epoch ) = errsum;
        originalBinaryInputAll{ epoch } = originalInput;
        reconstructedBinaryInputAll{ epoch } = reconstructedInput;
        hiddenValuesAll{ epoch } = hiddenValues;
        
        %fprintf(1, 'epoch %4i error %6.1f  \n', epoch, errsum); 
    end;
    
    [ v, idx ] = min( errorsInEpochs );

    relativeError = v / ( numdims * numbatches )
        
    fprintf(1, 'best epoch was %4i with error %6.1f  \n', idx, v); 
    figure;

    subplot(3,1,1);
    plot( originalBinaryInputAll{ idx } );
    %imshow( originalBinaryInputAll{ idx } );
    subplot(3,1,2);
    plot( reconstructedBinaryInputAll{ idx } );
    %imshow( reconstructedBinaryInputAll{ idx } );
    subplot(3,1,3);
    %imshow( hiddenValuesAll{ idx } );
    plot( hiddenValuesAll{ idx } );
end
