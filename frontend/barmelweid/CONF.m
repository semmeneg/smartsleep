classdef CONF
    % Encapsulates some common configuration parameters
    %   
    
    properties(Constant)
        PATIENTS_DATA_PATH = 'C:\Data\Projects\SmartSleep\SmartSleep Data\Barmelweid\SmartSleepPatienten\';
        ALL_PATIENTS_DATA_PATH = 'C:\Data\Projects\SmartSleep\SmartSleep Data\Barmelweid\SmartSleepPatienten\SmartSleep\Events\';
        WEKA_PATH = 'C:\Program Files\Weka-3-8';
        
        %data sources and combinations
        EEG = 'EEG';
        MSR = 'MSR';
        ZEPHYR = 'ZEPHYR';
        MSR_ZEPHYR = 'MSR_ZEPHYR';
        EEG_MSR = 'EEG_MSR';
        EEG_ZEPHYR = 'EEG_ZEPHYR';
        EEG_MSR_ZEPHYR = 'EEG_MSR_ZEPHYR';
    end
    
    methods(Static)
        function setup()
            setenv('JAVA_HOME','C:\Program Files\Java\jdk1.8.0_102');
            setenv('PATH','C:\Program Files\Java\jdk1.8.0_102\bin');
        end
        
        function outputPath = getOutputPath()
            outputPath = [ CONF.ALL_PATIENTS_DATA_PATH 'Results\DBN' ];
        end
        
        function outputPath = getOutputPathWithTimestamp()
            outputPath = [ CONF.getOutputPath() '\' datestr(now,'yyyy-mm-dd_HH-MM-SS')];
        end
        
        function outputPath = getRawDataOutputPath()
            outputPath = [ CONF.ALL_PATIENTS_DATA_PATH 'Results\DBN_rawdata' ];
        end
        
        function outputPath = getRawDataOutputPathWithTimestamp()
            outputPath = [ CONF.getRawDataOutputPath() '\' datestr(now,'yyyy-mm-dd_HH-MM-SS') ];
        end        
    end

end
