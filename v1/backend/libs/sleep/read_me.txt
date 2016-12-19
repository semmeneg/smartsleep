These files are for reproducing the results presented in:
"Sleep Stage Classification using Unsupervised Feature Learning"
by Martin Längkvist, Lars Karlsson and Amy Loutfi

This package and the paper can be downloaded from: aass.oru.se\~mlt

Installation
-------------------------
1. Download DBN Toolbox from http://www.seas.upenn.edu/~wulsin/ and extract to "sleep\DBNtoolbox\"
2. Download night recordings (*.rec and *_stage.txt) from http://www.physionet.org/pn3/ucddb/ and put into "\sleep\data"
   The default code assumes that at least the following night recordings and annotations have been downloaded: 
     ucddb002.rec   ucddb002_stage.txt
     ucddb003.rec   ucddb003_stage.txt
     ucddb005.rec   ucddb005_stage.txt
     ucddb006.rec   ucddb006_stage.txt
     ucddb007.rec   ucddb007_stage.txt
3. To start the program, set matlab path to "installation path\sleep\" and run main.m from Matlab.

gl hf! 
/Martin