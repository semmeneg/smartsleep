
% state 1: healthy
% state 2: fever
states = [ 1 2 ];

% 1: normal
% 2: cold
% 3: dizzy
observationSymbols = [ 1 2 3 ];

observations = [ 1 2 3 ];

startingProb = [ 0.6 0.4 ];
transProb = [ 0.7 0.3; 0.4 0.6 ];
emissProb = [ 0.5 0.4 0.1; 0.1 0.3 0.6 ];

t = 1;
v = zeros( 1, length( states ) );
o = observationSymbols( t );
estimatedStates = zeros( 1, length( observations ) );

% calculate initial distribution
for i = 1 : length( states )
    emissProbOfObservationInGivenState = emissProb( i, o );
    
    v( i ) = startingProb( i ) * emissProbOfObservationInGivenState;
end

% find maximum probability
[ maxStateProb, maxState ] = max( v ) ;
estimatedStates( t ) = maxState;

% calculate from t+1 until T
for t = 2 : length( observations )
    o = observationSymbols( t );
    
    % in each step calculate the probability that the given observation o
    % is produced by all states (then select the state with highest
    % probability, see below)
    for i = 1 : length( states )
        emissProbOfObservationInGivenState = emissProb( i, o );
        stateToStateProbability = transProb( maxState, i );
        
        v( i ) = maxStateProb * stateToStateProbability * emissProbOfObservationInGivenState;
    end
    
    % all probabilities are calculated for each state and stored in v
    % find state with highest probability - this will be the max state in next iteration
    [ maxStateProb, maxState ] = max( v ) ;
    estimatedStates( t ) = maxState;
end

estimatedStates = hmmviterbi( observations, transProb, emissProb );