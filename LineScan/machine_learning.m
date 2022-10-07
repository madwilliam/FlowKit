train_path = '/home/zhw272/Desktop/matlab_sementic_segmentation/train';
test_path = '/home/zhw272/Desktop/matlab_sementic_segmentation/test';

image = FileHandler.load_image_data('/home/zhw272/Desktop/matlab_sementic_segmentation/train/train.tiff');

test = imageDatastore(test_path);
load('/home/zhw272/Desktop/matlab_sementic_segmentation/gTruth.mat','gTruth')
train = pixelLabelDatastore(gTruth);
classes = ["stripe",'background'];
tbl = countEachLabel(train)

[imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionCamVidData(test,train);
numTrainingImages = numel(imdsTrain.Files)
numValImages = numel(imdsVal.Files)
numTestingImages = numel(imdsTest.Files)

imageSize = [120,300];
numClasses = numel(classes);
lgraph = deeplabv3plusLayers(imageSize, numClasses, "resnet18");

pxLayer = pixelClassificationLayer('Name','labels','Classes',tbl.Name,'ClassWeights',classWeights);
lgraph = replaceLayer(lgraph,"classification",pxLayer);

% Define validation data.
dsVal = combine(imdsVal,pxdsVal);

% Define training options. 
options = trainingOptions('sgdm', ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',10,...
    'LearnRateDropFactor',0.3,...
    'Momentum',0.9, ...
    'InitialLearnRate',1e-3, ...
    'L2Regularization',0.005, ...
    'ValidationData',dsVal,...
    'MaxEpochs',30, ...  
    'MiniBatchSize',8, ...
    'Shuffle','every-epoch', ...
    'CheckpointPath', tempdir, ...
    'VerboseFrequency',2,...
    'Plots','training-progress',...
    'ValidationPatience', 4);

doTraining = false;
if doTraining    
    [net, info] = trainNetwork(dsTrain,lgraph,options);
else
    pretrainedNetwork = fullfile(pretrainedFolder,'deeplabv3plusResnet18CamVid.mat');  
    data = load(pretrainedNetwork);
    net = data.net;
end

I = readimage(imdsTest,35);
C = semanticseg(I, net);

Display the results.
B = labeloverlay(I,C,'Colormap',cmap,'Transparency',0.4);
imshow(B)
pixelLabelColorbar(cmap, classes);