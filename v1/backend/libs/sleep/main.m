%% Introduction
% This is the main file for duplicating the results in
% "Sleep Stage Classification using Unsupervised Feature Learning"
% by Martin Längkvist, Lars Karlsson and Amy Loutfi
%
% This package and the paper can be downloaded from: aass.oru.se\~mlt

%% Initialize
% This section intitializes parameters

clear all

dataFolder = 'E:\FH\Job\SmartSleep Data\SleepClassificationPaper\ucddb';

%cd('D:\Dropbox\FH\SmartSleep FH\Dev\MATLAB\backend\libs\sleep') % set matlab path to installation path\sleep\
%filek = {'02' '03' '05' '06' '07' '08' '09' '10' '11' '12' '13' '14' '15' '17' '18' '19' '20' '21' '22' '23' '24' '25' '26' '27' '28'}; %uncomment if all night recordings were downloaded
filek = {'02' '03' '05' '06' '07'}; % If only the first 5 night recordings were downloaded
nfiles = length(filek);

%% Load and preprocess data and labels. Save to .mat files
prepath = [ dataFolder '/data/ucddb0' ];
for k=1:nfiles
    fprintf('Loading data... File %i of %i\n', k, nfiles);
    x=cell(1,4); Fs=cell(1,4); Label=cell(1,4); Dimension=cell(1,4); Coef = cell(1,4);
    HDR=[];
    for i = 1:4
        [x{i}, Fs{i}, Start_date, Start_time, Label{i}, Dimension{i}, Coef{i}, Nmb_chans, N] = readedf_2([prepath filek{k} '.rec'], i-1, 0, inf );
    end
    s = [x{4} interp(x{1},2) interp(x{2},2) interp(x{3},2)]; %interp to upsample EOG and EMG signals
    clear x
    HDR.Label = {Label{4} Label{1} Label{2} Label{3}};
    HDR.SampleRate = Fs{4};
    HDR.datafile = [prepath filek{k} '.rec'];
    HDR.EEG = 1;
    HDR.EOG = 2:3;
    HDR.EMG = 4;
    HDR.simtime = rows(s)/HDR.SampleRate;
    
    % Notch filter
    w0 = 50*(2/HDR.SampleRate);
    [b,a] = iirnotch(w0, w0/35);
    s = filtfilt(b, a, s);
    
    % Bandpass filter
    s(:,1) = bpfilter(s(:,1), [0.3 HDR.SampleRate/2]);
    s(:,2:3) = bpfilter(s(:,2:3), [0.3 HDR.SampleRate/2]);
    s(:,4) = bpfilter(s(:,4), [10 HDR.SampleRate/2]);
    
    % Downsample by 2
    s = s(1:2:end,:);
    HDR.SampleRate = HDR.SampleRate/2;
    
    % Replace NaN and Inf with 0
    s(isnan(s)) = 0;
    s(isinf(s)) = 0;
    
    % Convert to single
    s = single(s);
    
    % Load annotations. Change to my liking.
    v = load([prepath filek{k} '_stage.txt']);
    v = single(myupsample(v, 30*HDR.SampleRate));
    temp = v;
    v(temp==0)=5; % Wake
    v(temp==1)=4; % REM
    v(temp==2)=3; % Stage 1
    v(temp==3)=2; % Stage 2
    v(temp==4)=1; % Stage 3
    v(temp==5)=1; % Stage 4
    v(temp==6)=0; % Artifact
    v(temp==7)=0; % Indeterminate
    
    % Make s and v equal length
    [s, v] = mybalance(s, v);
    
    save([ dataFolder '/data/p' filek{k}],'s', 'HDR', 'v')
    clear s v temp HDR
end


%% Extract features
featurenames = {'EEG delta' 'EEG theta' 'EEG alpha' 'EEG beta' 'EEG gamma' 'EOG delta' 'EOG theta' 'EOG alpha' 'EOG beta' 'EOG gamma' 'EMG delta' 'EMG theta' 'EMG alpha' 'EMG beta' 'EMG gamma' 'EMG median' 'EOG corr' 'EEG kurtosis' 'EOG kurtosis' 'EMG kurtosis' 'EOG std' 'EEG entropy' 'EOG entropy' 'EMG entropy' 'EEG spectral mean' 'EOG spectral mean' 'EMG spectral mean' 'EEG fractal exponent'};
E = cell(1,nfiles);
truestate = cell(1,nfiles);
for i = 1 : nfiles
    fprintf('Extracting features... File %i of %i\n', i, nfiles);
    load([ dataFolder '\data\p' filek{i} '.mat']);
    E{i} = sect2E(s, HDR.SampleRate, HDR.SampleRate);
    truestate{i} = downsample(v, HDR.SampleRate);
end

save Eucddb E truestate featurenames


%% Perform Sequential Backwards Search (SBS)

% Load feature matrix
load Eucddb
% for ii=1:nfiles
%     subplot(6,5,ii); plot(E{1}(:,ii)); title(featurenames{ii}); axis tight
% end

% Pre-process feature matrix
for i = 1:nfiles
    % Make sure E and truestate are the same length
    E{i} = E{i}(1:rows(truestate{i}),:);
    
    % Replace NaN and Inf with 0
    E{i}(isnan(E{i})) = 0;
    E{i}(isinf(E{i})) = 0;
    
    % Normalize some features
    E{i}(:,1:2) = asin(sqrt(E{i}(:,1:2)));              % 'delta, theta EEG'
    E{i}(:,3:5) = log10(E{i}(:,3:5)./(1-E{i}(:,3:5)));  % 'alpha, beta, high EEG'
    E{i}(:,16)=E{i}(:,16)./median(E{i}(:,16));          % 'median EMG'
    E{i}(:,18)=log10(1+E{i}(:,18));                     % 'kurtosis EEG'
    E{i}(:,19)=log10(1+E{i}(:,19));                     % 'kurtosis EOG 1'
    E{i}(:,20)=log10(1+E{i}(:,20));                     % 'kurtosis EMG'
    E{i}(:,21)=log10(1+E{i}(:,21));                     % 'std EOG 1'
    E{i}(:,22)=log10(1+E{i}(:,22));                     % 'entropy EEG'
    E{i}(:,23)=log10(1+E{i}(:,23));                     % 'entropy EOG 1'
    E{i}(:,24)=log10(1+E{i}(:,24));                     % 'entropy EMG'
    
    % Subtract mean and divide by standard division
    E{i} = zscore(E{i});
end

% Parameters for SBS
NDimensions = 5;  % number of PCA components
NComponents = 5;  % number of GMM components
nstate = 5;       % number of classes
maxsamples = 1000; % maximum GMM training examples (10000 is used in article)
pseudoA = 0.01*ones(5, 5);
pseudoB = 0.01*ones(5, NComponents);

file = struct();

for testingset = 1:nfiles
    % Reset feature vectors
    defaultfeat = []; % Select features that should be guaranteed to be selected in the SBS-algorithm
    feat = 1:28;      % Features to chose from in the SBS-algorithm
    
    % Divide into training, validation, and test sets
    [trainingsets validationsets] = split(removerows((1:nfiles)', testingset)', [0.5 0.5]); %50-50 between train and test
    
    %Reduced Training set
    % The following data is removed:
    %  - 30 second before and after a sleep stage change
    %  - Rows with NaN or Inf values
    %  - Data with annotated artifacts or indetermined are
    %  - Any duplicate rows
    %  - Random data from each sleep stage until class balance
    %  - Further remove data to cap at maxsamples
    % Data is sorted
    E_train = [];
    truestate_train = [];
    for i = trainingsets
        SwitchIndex = min(abs([diff(downsample(truestate{i}, 30)); 0]),1);
        SwitchIndex = min(SwitchIndex + circshift(SwitchIndex,1),1);
        SwitchIndex = myupsample(SwitchIndex,30);
        NanInfIndex = sum(isnan(E{i})+isinf(E{i}),2)>0;
        Stage0Index = truestate{i}==0;
        removeIndex=SwitchIndex+NanInfIndex+Stage0Index;
        E_temp = removerows(E{i}, find(removeIndex>0));
        truestate_temp = removerows(double(truestate{i}), find(removeIndex>0));
        E_train = [E_train; E_temp];
        truestate_train = [truestate_train; truestate_temp];
    end
    [E_train I]=unique(E_train, 'rows');
    truestate_train=truestate_train(I);
    selectedSamples = [];
    samplesPerStage = min(hist(truestate_train,1:5));
    for i=1:5
        a = find(truestate_train==i);
        k = randperm(length(a));
        selectedSamples = [selectedSamples; a(k(1:samplesPerStage))];
    end
    E_train = E_train(selectedSamples,:);
    truestate_train = truestate_train(selectedSamples);
    if length(truestate_train)>maxsamples
        k = randperm(length(truestate_train));
        E_train=E_train(k(1:maxsamples),:);
        truestate_train=truestate_train(k(1:maxsamples));
    end
    
    % Training HMM set
    % The following data is removed:
    %  - Rows with NaN or Inf values
    %  - Data with annotated artifacts or indetermined are
    E_trainHMM = [];
    truestate_trainHMM = [];
    for i = trainingsets
        NanInfIndex = sum(isnan(E{i})+isinf(E{i}),2)>0;
        Stage0Index = truestate{i}==0;
        removeIndex=NanInfIndex+Stage0Index;
        E_temp = removerows(E{i}, find(removeIndex>0));
        truestate_temp = removerows(double(truestate{i}), find(removeIndex>0));
        E_trainHMM = [E_trainHMM; E_temp];
        truestate_trainHMM = [truestate_trainHMM; truestate_temp];
    end
    
    % Validation set
    % The following data is removed:
    %  - Rows with NaN or Inf values
    %  - Data with annotated artifacts or indetermined are
    E_val = [];
    truestate_val = [];
    for i = validationsets
        NanInfIndex = sum(isnan(E{i})+isinf(E{i}),2)>0;
        Stage0Index = truestate{i}==0;
        removeIndex=NanInfIndex+Stage0Index;
        E_temp = removerows(E{i}, find(removeIndex>0));
        truestate_temp = removerows(double(truestate{i}), find(removeIndex>0));
        E_val = [E_val; E_temp];
        truestate_val = [truestate_val; truestate_temp];
    end
    
    % SBS algorithm
    for resultrow = length(feat)+length(defaultfeat):-1:max(NDimensions,length(defaultfeat))+1
        validation=zeros(1,length(feat));
        for resultcol = 1:length(feat)
            fprintf('File %i of %i. Removing feature %i of %i\n', testingset, nfiles, resultcol, length(feat));
            
            % Remove one feature from subset of features
            SBSfeat=[removerows(feat',resultcol)' defaultfeat];
            
            % Train PCA and GMM with reduced training set
            coefs = princomp(E_train(:,SBSfeat));
            E_trainPCA = E_train(:,SBSfeat)*coefs(:,1:NDimensions);
            obj = gmdistribution.fit(E_trainPCA, NComponents, 'Start', truestate_train);
            
            % Train HMM with not reduced training set
            [outcome nlog P] = cluster(obj, E_trainHMM(:,SBSfeat)*coefs(:,1:NDimensions));
            [A B] = hmmestimate(outcome, truestate_trainHMM, 'Pseudotransitions', pseudoA , 'Pseudoemissions', pseudoB);
            
            % Validate selected features using classification accuracy from validation set
            outcome = cluster(obj, E_val(:,SBSfeat)*coefs(:,1:NDimensions));
            state = hmmviterbi(outcome, A, B);
            acc = PlotResult(state, truestate_val, false);
            
            % Store result
            validation(resultcol) = acc;
        end
        
        % Remove feature that gave best result
        [val, row] = max(validation);
        removedfeat = feat(row);
        feat = removerows(feat',row)';
        
        % Store results
        file(testingset).iteration(resultrow).val=val;
        file(testingset).iteration(resultrow).removedfeat = removedfeat;
        file(testingset).iteration(resultrow).feat = feat;
    end
end

save SBSresults file

% Plot results
for i=1:nfiles
    figure;
    accuracy = [file(i).iteration(28:-1:5).val];
    plot(accuracy, 'x-')
    removedfeatvector = [file(i).iteration(28:-1:5).removedfeat];
    set(gca, 'YMinorGrid','on', 'position', [0.13 0.25 0.775 0.65], 'XTick', 1:length(removedfeatvector), 'XTickLabel', featurenames(removedfeatvector));
    axis tight; axis([1 length(removedfeatvector) 0.6 0.8])
    rotateticklabel(gca,90); ylabel('Classification accuracy [%]');
end


%% Calculate classification accuracy on testing sets (feat-GOHMM)
load SBSresults
maxsamples = 10000;

for testingset = 1:nfiles
    % Divide into training and test sets
    trainingsets = removerows((1:nfiles)', testingset)';
    
    %Reduced Training set
    % The following data is removed:
    %  - 30 second before and after a sleep stage change
    %  - Rows with NaN or Inf values
    %  - Data with annotated artifacts or indetermined are
    %  - Any duplicate rows
    %  - Random data from each sleep stage until class balance
    %  - Further remove data to cap at maxsamples
    % Data is sorted
    E_train = [];
    truestate_train = [];
    for i = trainingsets
        SwitchIndex = min(abs([diff(downsample(truestate{i}, 30)); 0]),1);
        SwitchIndex = min(SwitchIndex + circshift(SwitchIndex,1),1);
        SwitchIndex = myupsample(SwitchIndex,30);
        NanInfIndex = sum(isnan(E{i})+isinf(E{i}),2)>0;
        Stage0Index = truestate{i}==0;
        removeIndex=SwitchIndex+NanInfIndex+Stage0Index;
        E_temp = removerows(E{i}, find(removeIndex>0));
        truestate_temp = removerows(double(truestate{i}), find(removeIndex>0));
        E_train = [E_train; E_temp];
        truestate_train = [truestate_train; truestate_temp];
    end
    [E_train I]=unique(E_train, 'rows');
    truestate_train=truestate_train(I);
    selectedSamples = [];
    samplesPerStage = min(hist(truestate_train,1:5));
    for i=1:5
        a = find(truestate_train==i);
        k = randperm(length(a));
        selectedSamples = [selectedSamples; a(k(1:samplesPerStage))];
    end
    E_train = E_train(selectedSamples,:);
    truestate_train = truestate_train(selectedSamples);
    if length(truestate_train)>maxsamples
        k = randperm(length(truestate_train));
        E_train=E_train(k(1:maxsamples),:);
        truestate_train=truestate_train(k(1:maxsamples));
    end
    
    % Training HMM set
    % The following data is removed:
    %  - Rows with NaN or Inf values
    %  - Data with annotated artifacts or indetermined are
    E_trainHMM = [];
    truestate_trainHMM = [];
    for i = trainingsets
        NanInfIndex = sum(isnan(E{i})+isinf(E{i}),2)>0;
        Stage0Index = truestate{i}==0;
        removeIndex=NanInfIndex+Stage0Index;
        E_temp = removerows(E{i}, find(removeIndex>0));
        truestate_temp = removerows(double(truestate{i}), find(removeIndex>0));
        E_trainHMM = [E_trainHMM; E_temp];
        truestate_trainHMM = [truestate_trainHMM; truestate_temp];
    end
    
    % Testing set
    % The following data is removed:
    %  - Rows with NaN or Inf values
    %  - Data with annotated artifacts or indetermined are
    E_test = [];
    truestate_test = [];
    for i = testingset
        NanInfIndex = sum(isnan(E{i})+isinf(E{i}),2)>0;
        Stage0Index = truestate{i}==0;
        removeIndex=NanInfIndex+Stage0Index;
        E_temp = removerows(E{i}, find(removeIndex>0));
        truestate_temp = removerows(double(truestate{i}), find(removeIndex>0));
        E_test = [E_test; E_temp];
        truestate_test = [truestate_test; truestate_temp];
    end
    
    % Select best feature subset
    SBSfeat=file(testingset).iteration(5+argmax([file(testingset).iteration(:).val])).feat;
    
    % Train PCA and GMM with reduced training set
    coefs = princomp(E_train(:,SBSfeat));
    E_trainPCA = E_train(:,SBSfeat)*coefs(:,1:NDimensions);
    obj = gmdistribution.fit(E_trainPCA, NComponents, 'Start', truestate_train); %prevents ill-conditioned covariance matrix
    
    % Train HMM with not reduced training set
    [outcome nlog P] = cluster(obj, E_trainHMM(:,SBSfeat)*coefs(:,1:NDimensions));
    [A B] = hmmestimate(outcome, truestate_trainHMM, 'Pseudotransitions', pseudoA , 'Pseudoemissions', pseudoB);
    
    % Validate selected features using classification accuracy from validation set
    outcome = cluster(obj, E_test(:,SBSfeat)*coefs(:,1:NDimensions));
    state = hmmviterbi(outcome, A, B);
    figure(testingset)
    acc = PlotResult(state, truestate_test, true);
end

%% DBN on features (feat-DBN)
clear all;
nfiles = 5;
%addpath('.\DBNtoolbox\code') %Code for DBN

% Load feature matrix
load('Eucddb.mat')

% Normalize features
for i = 1:nfiles
    % Make E and truestate the same length
    E{i} = E{i}(1:rows(truestate{i}),:);
    
    % Replace NaN and Inf with 0
    E{i}(isnan(E{i})) = 0;
    E{i}(isinf(E{i})) = 0;
    
    % Normalize some features
    E{i}(:,1:2) = asin(sqrt(E{i}(:,1:2)));         % 'delta, theta EEG'
    E{i}(:,3:5) = log10(E{i}(:,3:5)./(1-E{i}(:,3:5)));  % 'alpha, beta, high EEG'
    E{i}(:,16)=E{i}(:,16)./median(E{i}(:,16));        % 'median EMG'
    E{i}(:,18)=log10(1+E{i}(:,18));                     % 'kurtosis EEG'
    E{i}(:,19)=log10(1+E{i}(:,19));                     % 'kurtosis EOG 1'
    E{i}(:,20)=log10(1+E{i}(:,20));                     % 'kurtosis EMG'
    E{i}(:,21)=log10(1+E{i}(:,21));                     % 'std EOG 1'
    E{i}(:,22)=log10(1+E{i}(:,22));                     % 'entropy EEG'
    E{i}(:,23)=log10(1+E{i}(:,23));                     % 'entropy EOG 1'
    E{i}(:,24)=log10(1+E{i}(:,24));                     % 'entropy EMG'
    
    % Subtract mean and divide by standard division
    E{i} = zscore(E{i});
    
    % Divide by (max(feature)-min(feature)) and adding 0.5 to keep values around [0 1]
    E{i}=bsxfun(@rdivide, E{i}, (max(E{i})-min(E{i}))) + 0.5;
end

results=struct([]);

for testingsets=1:nfiles
    %Divide into training and testing set
    trainingsets = removerows((1:nfiles)',testingsets)';
    data=[];
    labels=[];
    testdata=[];
    testlabels=[];
    for i=trainingsets
        SwitchIndex = min(abs([diff(downsample(truestate{i},30)); 0]),1);
        SwitchIndex = min(SwitchIndex + circshift(SwitchIndex,1),1); %remove 30s before and after switch
        SwitchIndex = myupsample(SwitchIndex,30);
        E{i}=E{i}(SwitchIndex~=1,:);
        truestate{i}=truestate{i}(SwitchIndex~=1,:);
        
        data=[data; E{i}];
        labels=[labels; truestate{i}];
    end
    for i=testingsets
        testdata=[testdata; E{i}];
        testlabels=[testlabels; truestate{i}];
    end
    
    % Balance samples based on category prevalence
    rand('state',0);
    samplesPerClass=min([sum(labels==1) sum(labels==2) sum(labels==3) sum(labels==4) sum(labels==5)]);
    newdata=[];
    newlabel=[];
    for i=1:5
        row = find(labels==i);
        selectedSamples=randperm(length(row));
        newlabel=[newlabel; labels(row(selectedSamples(1:samplesPerClass)))];
        newdata=[newdata; data(row(selectedSamples(1:samplesPerClass)),:)];
    end
    data=newdata;
    labels=newlabel;
    clear newlabel newdata selectedSamples samplesPerClass
    
    % Divide training set into train and validation subsets
    rand('state',0);
    k=randperm(length(data));
    %k=randperm(250000);
    traindata=data(k(1:floor(length(data)*5/6)),:);
    valdata=data(k(floor(length(data)*5/6)+1:end),:);
    trainlabels=labels(k(1:floor(length(data)*5/6)));
    vallabels=labels(k(floor(length(data)*5/6)+1:end));
    fprintf('Train \t Val\n');
    for labeliter=1:5;
        fprintf('%i \t %i\n', sum(trainlabels==labeliter), sum(vallabels==labeliter));
    end
    
    % ---------------------------- Train --------------------------------------
    layerSize = [50 50]; %200 200 is used in article
    
    % Parameters
    rbmParams.numEpochs = 20; %100 is used in article
    rbmParams.verbosity = 1;
    rbmParams.miniBatchSize = 1000;
    rbmParams.attemptLoad = 0;
    dbnParams.numEpochs = 10; % 50 is used in article
    dbnParams.verbosity = 1;
    dbnParams.miniBatchSize = 1000;
    dbnParams.attemptLoad = 0;
    
    % remove any previously trained model .mat files, otherwise it will load it and continue training
    dnntic = tic;
    nnLayers = GreedyLayerTrain(traindata, valdata, layerSize, 'RBM', rbmParams);
    dnnObj = DeepNN(nnLayers, dbnParams);
    fprintf('Unsupervised backprop...\n');
    dnnObj.Train(traindata, valdata);
    fprintf('Supervised backprop...\n');
    dnnObj.Train(traindata, valdata, trainlabels, vallabels);
    fprintf('Finished training DeepNN.\n\n');
    simtime = toc(dnntic);
    
    %Inference on train data
    [topActivs, ~] = dnnObj.PropLayerActivs(data);
    [~,ytrain] = max(topActivs,[],2);
    ytrain=single(ytrain);
    
    %HMM on inference results
    [A, B] = hmmestimate(ytrain, labels, 'PSEUDOTRANSITIONS', 0.001*ones(5, 5), 'PSEUDOEMISSIONS',0.001*ones(5, 5));
    
    %Inference on test data
    [topActivs2, ~] = dnnObj.PropLayerActivs(testdata);
    [~, ytest] = max(topActivs2,[],2);
    ytest=single(ytest);
    
    ytestHMM = hmmviterbi(ytest, A, B)';
    
    figure;
    subplot(2,1,1); acc=plotResult(ytest,testlabels);
    subplot(2,1,2); accHMM=plotResult(ytestHMM,testlabels);
    drawnow
    
    results(testingsets).acc=acc;
    results(testingsets).accHMM=accHMM;
    results(testingsets).ytest=ytest;
    results(testingsets).ytestHMM=ytestHMM;
    results(testingsets).A=A;
    results(testingsets).B=B;
    results(testingsets).simtime=simtime;
    results(testingsets).nnLayers=nnLayers;
    results(testingsets).dnnObj=dnnObj;
    results(testingsets).testlabels=testlabels;
    
    save resultsFEAT results
end

%% DBN on raw data (raw-DBN)
clear all;
nfiles = 5;
filek = {'02' '03' '05' '06' '07'};
%addpath('.\DBNtoolbox\code\');

% Create visible layer
C=cell(nfiles,1);
Clabel=cell(nfiles,1);
for i=1:nfiles
    %Raw data preprocessing
    cutoff=[0.3 0.4 0.4 0.5]; %raw data not scaled to Hz yet.
    load(['.\data\p' filek{i} '.mat']);
    h = HDR.SampleRate;
    EEG=s(:,1);
    EOG1=s(:,2);
    EOG2=s(:,3);
    EMG=s(:,4);
    
    % Cut-off signals
    EEG(EEG<-cutoff(1))=-cutoff(1);
    EEG(EEG>cutoff(1))=cutoff(1);
    EOG1(EOG1<-cutoff(2))=-cutoff(2);
    EOG1(EOG1>cutoff(2))=cutoff(2);
    EOG2(EOG2<-cutoff(3))=-cutoff(3);
    EOG2(EOG2>cutoff(3))=cutoff(3);
    EMG(EMG<-cutoff(4))=-cutoff(4);
    EMG(EMG>cutoff(4))=cutoff(4);
    
    % Normalize to [0 1] values
    EEG=EEG/(cutoff(1)*2)+0.5;
    EOG1=EOG1/(cutoff(2)*2)+0.5;
    EOG2=EOG2/(cutoff(3)*2)+0.5;
    EMG=EMG/(cutoff(4)*2)+0.5;
    
    % Segment into 1 second windows
    EEG = reshape(EEG,h,length(EEG)/h)';
    EOG1 = reshape(EOG1,h,length(EOG1)/h)';
    EOG2 = reshape(EOG2,h,length(EOG2)/h)';
    EMG = reshape(EMG,h,length(EMG)/h)';
    Clabel{i}=downsample(v,h);
    C{i}=[EEG EOG1 EOG2 EMG]; %concatenate signals
    clear s v HDR EEG EOG1 EOG2 EMG cutoff
end

results=struct([]);
for testingsets=1:nfiles
    % Divide into training and testing sets
    trainingsets = removerows((1:nfiles)',testingsets)';
    data=[];
    labels=[];
    testdata=[];
    testlabels=[];
    for i=trainingsets
        SwitchIndex = min(abs([diff(downsample(Clabel{i},30)); 0]),1);
        SwitchIndex = min(SwitchIndex + circshift(SwitchIndex,1),1);
        SwitchIndex = myupsample(SwitchIndex,30);
        C{i}=C{i}(SwitchIndex~=1,:);
        Clabel{i}=Clabel{i}(SwitchIndex~=1,:);
        data=[data; C{i}];
        labels=[labels; Clabel{i}];
    end
    for i=testingsets
        testdata=[testdata; C{i}];
        testlabels=[testlabels; Clabel{i}];
    end
    clear C Clabel
    
    % Balance samples based on category prevalence
    rand('state',0);
    samplesPerClass=min([sum(labels==1) sum(labels==2) sum(labels==3) sum(labels==4) sum(labels==5)]);
    templabels=[];
    tempdata=[];
    for i=1:5
        row = find(labels==i);
        selectedSamples=randperm(length(row));
        tempdata=[tempdata; data(row(selectedSamples(1:samplesPerClass)),:)];
        templabels=[templabels; labels(row(selectedSamples(1:samplesPerClass)))];
    end
    clear selectedSamples samplesPerClass row
    
    % Divide training set into train and validation subsets
    rand('state',0);
    k=randperm(length(tempdata));
    traindata=tempdata(k(1:floor(length(tempdata)*5/6)),:);
    valdata=tempdata(k(floor(length(tempdata)*5/6)+1:end),:);
    trainlabels=templabels(k(1:floor(length(tempdata)*5/6)));
    vallabels=templabels(k(floor(length(tempdata)*5/6)+1:end));
    fprintf('Train \t Val\n');
    for labeliter=1:5;
        fprintf('%i \t %i\n', sum(trainlabels==labeliter), sum(vallabels==labeliter));
    end
    clear tempdata templabels k
    
    % ---------------------------- Train --------------------------------------
    layerSize = [200 200]; % 200-200 used in article
    
    % Parameters
    % Initial hidden biases can be changed in NNLayer.m row 498
    rbmParams.numEpochs = 300; %300 used in article
    rbmParams.verbosity = 1;
    rbmParams.miniBatchSize = 1000;
    rbmParams.attemptLoad = 0;
    % set DBN params
    dbnParams.numEpochs = 50; % 50 used in article
    dbnParams.verbosity = 1;
    dbnParams.miniBatchSize = 1000;
    dbnParams.attemptLoad = 0;
    
    % remove any previously trained model .mat files, otherwise it will load it and continue training
    dnntic = tic;
    nnLayers = GreedyLayerTrain(traindata, valdata, layerSize, 'RBM', rbmParams);
    dnnObj = DeepNN(nnLayers, dbnParams);
    fprintf('Unsupervised backprop...\n');
    dnnObj.Train(traindata, valdata);
    fprintf('Supervised backprop...\n');
    dnnObj.Train(traindata, valdata, trainlabels, vallabels);
    fprintf('Finished training DeepNN.\n\n');
    simtime = toc(dnntic);
    
    %Inference on train data
    [topActivs, a] = dnnObj.PropLayerActivs(data);
    [~,ytrain] = max(topActivs,[],2);
    ytrain=single(ytrain);
    
    % Train HMM on inference from train data
    [A, B] = hmmestimate(ytrain, labels, 'PSEUDOTRANSITIONS', 0.001*ones(5, 5), 'PSEUDOEMISSIONS',0.001*ones(5, 5));
    
    %Inference on test data
    [topActivs2, ~] = dnnObj.PropLayerActivs(testdata);
    [~, ytest] = max(topActivs2,[],2);
    ytest=single(ytest);
    
    % Test results from HMM
    ytestHMM = hmmviterbi(ytest, A, B)';
    
    figure;
    subplot(2,1,1); acc=PlotResult(ytest,testlabels);
    subplot(2,1,2); accHMM=PlotResult(ytestHMM,testlabels);
    drawnow
    
    results(testingsets).acc=acc;
    results(testingsets).accHMM=accHMM;
    results(testingsets).ytest=ytest;
    results(testingsets).ytestHMM=ytestHMM;
    results(testingsets).A=A;
    results(testingsets).B=B;
    results(testingsets).simtime=simtime;
    results(testingsets).nnLayers=nnLayers;
    results(testingsets).dnnObj=dnnObj;
    
    % Save after each iteration
    save resultsRAW results
end
