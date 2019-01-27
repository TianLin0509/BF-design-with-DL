README
===========================
This is the simulation code for the paper `"Beamforming Design for Large-scale Antenna Arrays with the Help of Deep Learning Approach"` and
we highly respect reproducible research. 


****
## .py file
Due to the limitation of file size, we only upload the executable .py files in the github repository:     
* BFNN_Model.py : Architecture of the proposed BFNN model.      
* load_samples.py : used to load samples of train set or test set.    
* main_imperfect_CSI.py : simulate with imperfect CSI    
* main_perfect_CSI.py : simulate with perfect CSI   

****
## How to use the main.py file
After download the samples (see following), you can directly run the main_imperfect_CSI.py or main_perfect_CSI.py and then 
their are three option steps:
First, you will see
```
Please type 0 or 1 in the python console to choose Mode: 
 0: train  1: test 
```
As you can see, type 0 for training and 1 for testing.

If you choose the train mode, you need to further provide the path of samples. You can easily copy the absolute path
of the package (`Noticed is the path of the package`), then the program will load the sample data in the package.
For example, type ```C:\OneDrive\BFNN\sample_set``` in the python console.

If you choose the test mode, you need to further provide the path of the trained model. For example, 
type ```C:\OneDrive\BFNN\\trained_models\trained_20dB.h5```  in the python console.


****
## Samples and trained models
We have shared our generated samples and trained models by Google Driver. Please kindly refer to https://drive.google.com/drive/folders/1nSk9TftoCMA5iRUqC9GSK5g5a67Q8FRG?usp=sharing
After download the files, you can straightforwardly run main_erfect_CSI.py or main_imperfect_CSI.py.
Just easily copy the packages path in the python console, the program can load the data for training or testing.
Similar operation can help you load our trained model, which is corresponding to the results in our paper.
In addition, we also provide the matlab codes on onedrive so you can generate samples by yourself. If you still need more 
information, you can contact me via e-mail.
****
## End
My email is `lint17@fudan.edu.cn` and we  welcome discussions. As I'm new to programing, I have tried my best to 
add more comments in .py files for ease of comprehension. If you have any questions, you can contact me by email.
Sorry for my English, hopefully this work can be helpful to you.
