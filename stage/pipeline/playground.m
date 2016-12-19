% t = RBMFeaturesTrainerTest;
% t.run();


% LOG = Log.getLogger();
SETUP_LOG = SetupLog('C:/Temp/test.log');
SETUP_LOG.log('MSR & Zephyr');
SETUP_LOG.log('Pipeline: Rawdata > DBN > Weka(RandomForest,10foldCross)');

inputComponents = 2222;
SETUP_LOG.log(sprintf('%s %d', 'Rawdata components:', inputComponents));

layersConfig =[struct('hiddenUnitsCount', floor(inputComponents /2), 'maxEpochs', 100); ...
               struct('hiddenUnitsCount', floor(inputComponents * 2), 'maxEpochs', 200); ...
               struct('hiddenUnitsCount', floor(inputComponents * 4), 'maxEpochs', 300)];

rbmTrainer = RBMFeaturesTrainer(layersConfig, []);

SETUP_LOG.logDBN(rbmTrainer.getDBN());