function [ posprods, poshidact, posvisact, ...
    negprods, neghidact, negvisact, ...
    negdata, binaryInputData, ...
    reconstruction, hiddenProbs ] = CDStep( data, W, a, b, numperbatch, ...
        numdims, numhid )
%CD Summary of this function goes here
%   Detailed explanation goes here

    % NOTE: this function performs one step of CD without adapting the
    % weights which amounts to the calculation of the reconstructed value

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
    % then these hidden-unit probabilities are transformed into binary
    % values and then propagated back to calculate the probabilities the
    % visible units become 1 with the given binary hidden-unit values.
    % Note that the resulting probabilities of the visible units are the
    % reconstructed values of the training-samples.
    % these probabilities are then transformed to binary values and the
    % probabilities that the hidden units become 1 given the reconstructed
    % training-sample is calculated.
    % thus for 1-step actually 2 steps are performed:
    % 1. feed the training-data to the hidden units and back to calculate a
    % reconstruction of the training-data
    % 2. feed the reconstructed training-data to the hidden units again to
    % get a reconstruction of the hidden-unit data given the reconstructed
    % training-data

    % NOTE: need binary values. assume that data is a probability
    % value in range of [0..1] then set to 1 with a given random
    % probability. See Practical Guide by Hinton Formula (10)
    data = data > rand(numperbatch,numdims);
    binaryInputData = data;
    
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

    reconstruction = negdata;
    
    % again need binary values. assume that data is a probability
    % value in range of [0..1] then set to 1 with a given random
    % probability. See Practical Guide by Hinton Formula (10)
    negdata = negdata > rand(numperbatch,numdims);

    % NOTE: now again calculate the probability that the HIDDEN
    % units are set to 1 when having the previously calculated
    % binary values of the visible units
    neghidprobs = 1./(1 + exp(-negdata*(2*W) - hidbias));

    hiddenProbs = neghidprobs;

    % NOTE: this value is needed for calculating the
    % gradient (See Practical Guide (Hinton) Formula (5)).
    % <...>p denotes the averages with respect to distribution p =>
    % because we are doing only CD with 1 step, no normalization is
    % necessary - if more steps are performed one needs to
    % normalize
    negprods = negdata' * neghidprobs;     % calculate <vihj>model

    % NOTE: according to Practical Guide by Hinton, "A simplified
    % version of the same learning rule that uses the states of the
    % individual units instead of pairwise products is used for the
    % biases" (see passage after Formula (9))
    neghidact = sum(neghidprobs);
    negvisact = sum(negdata);

    %%%%%%%%% END OF NEGATIVE PHASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
