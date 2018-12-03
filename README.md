# README

In this project, we use a third-part library [vlfeat](http://www.vlfeat.org/index.html) to extract HOG feature of the images. In order to ues this easily, it is recommended to add `vlfeat-x.x.x/toolbox` into the path.

In order to show the Chinese character correctly, it is needed to change the MATLAB coding method to 'UTF-8'. Otherwise it might be show as messy code.

The directory format is suitable to MacOS system. It is needed to change '/' into '\' if you use MATLAB on Windows.

## step1

Run `GetFeature` to extract HOG feature of training data. The feature data set will be saved as 'hogTrainData.mat'.
## step2

Run `trainModel` to train the model using feature data set from step1. Save the trained model as 'model.mat'.
## step3

Run `test` to see the accuracy of this model. In this case, it will be 97.55%.(You can skip this step)

## step4

Run `main` to run this program. Choose a photo from the file 'photo'(you can also choose photo from your own files.). The program will show the license plate number. It may not work in the whole time, beause it can be influenced by the angle of the picture, the photo-pixel problem and so on.

