

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from tensorflow import keras

from tensorflow.keras import layers
from tensorflow.keras.applications.vgg16 import VGG16
from tensorflow.python.keras.models import Sequential
from tensorflow.python.keras.layers import Dense, Flatten, GlobalAveragePooling2D
from tensorflow.python.keras.applications.resnet import preprocess_input
from tensorflow.python.keras.preprocessing.image import ImageDataGenerator
from sklearn.utils import class_weight
from tensorflow.python.keras import optimizers
from tensorflow.keras.applications.resnet50 import ResNet50
from tensorflow.keras.callbacks import ReduceLROnPlateau, EarlyStopping, ModelCheckpoint, LearningRateScheduler

import cv2
import math
from IPython.display import clear_output


import os

IMG_SIZE = 224
NUM_EPOCHS = 20
NUM_CLASSES = 3
TRAIN_BATCH_SIZE = 77
TEST_BATCH_SIZE = 1

#Now lets Create a preTrain ResNet50 Model
def create_model():
    my_new_model = Sequential()
    resnet_weights_path = '../input/resnet50/resnet50_weights_tf_dim_ordering_tf_kernels_notop.h5'
    resnet = ResNet50(include_top=True, pooling='avg', weights='imagenet')
    # You can do resnet.summary() to see what are the layers that are inbuilt in ResNet50 pre-trained model
    my_new_model.add(resnet)
    my_new_model.layers[0].trainable = False
    my_new_model.add(Dense(NUM_CLASSES, activation='softmax')) 
    opt = keras.optimizers.Adam(learning_rate=0.01)
    my_new_model.compile(optimizer=opt, loss='categorical_crossentropy', metrics=['accuracy'])
    return my_new_model



def train_model( model ):
    data_generator_with_aug = ImageDataGenerator(preprocessing_function=preprocess_input,
                                width_shift_range=0.1,
                                height_shift_range=0.1,
                                #sear_range=0.01,
                                zoom_range=[0.9, 1.25],
                                horizontal_flip=True,
                                vertical_flip=False,
                                data_format='channels_last',
                                brightness_range=[0.5, 1.5]
                               )
                                       
    train_generator = data_generator_with_aug.flow_from_directory(
            '/content/drive/My Drive/datasets/img_data/train',
            target_size=(IMG_SIZE, IMG_SIZE),
            batch_size=TRAIN_BATCH_SIZE,
            class_mode='categorical')
    
   
    validation_generator = data_generator_with_aug.flow_from_directory(
            '/content/drive/My Drive/datasets/img_data/test',
            target_size=(IMG_SIZE, IMG_SIZE),
            batch_size=TEST_BATCH_SIZE,
            shuffle = False,
            class_mode='categorical')
    
        
    checkpointer = ModelCheckpoint(filepath = "FireDetection.hdf5", verbose = 1, save_best_only=True) #This will save the model as we train 
    H = model.fit(
            train_generator,
            steps_per_epoch=train_generator.n/TRAIN_BATCH_SIZE,
            epochs=NUM_EPOCHS,
            validation_data=validation_generator,
            validation_steps=1,
            callbacks= [checkpointer]
            )
    return model, train_generator,validation_generator



def get_label_dict(train_generator ):
    labels = (train_generator.class_indices)
    label_dict = dict((v,k) for k,v in labels.items())
    return  label_dict



def get_labels( generator ):
    generator.reset()
    labels = []
    for i in range(len(generator)):
        labels.extend(np.array(generator[i][1]) )
    return np.argmax(labels, axis =1)


def get_pred_labels( test_generator):
    test_generator.reset()
    pred_vec=model.predict_generator(test_generator,
                                     steps=test_generator.n, #test_generator.batch_size
                                     verbose=1)
    return np.argmax( pred_vec, axis = 1), np.max(pred_vec, axis = 1)



def draw_prediction( frame, class_string ): # For Visualizition the label in screen
    x_start = frame.shape[1] -600
    cv2.putText(frame, class_string, (x_start, 75), cv2.FONT_HERSHEY_SIMPLEX, 2.5, (255, 0, 0), 2, cv2.LINE_AA)
    return frame


def prepare_image_for_prediction( img): #Before passing the test data into model.predt() we need to do some changes
    img = np.expand_dims(img, axis=0)
    return preprocess_input(img)

model = create_model()

trained_model_l, train_generator,validation_generator = train_model(model)
label_dict_l = get_label_dict(train_generator )



def get_display_string(pred_class, label_dict):
    txt = ""
    for c, confidence in pred_class:
        txt += label_dict[c]
        if c :
            txt += '['+ str(confidence) +']'

    return txt



model_json = model.to_json()
with open("Fire-model.json","w") as json_file:
  json_file.write(model_json)

label_dict_l



def predict(  model, video_path, label_dict ):
    
    vs = cv2.VideoCapture(video_path)

    fps = math.floor(vs.get(cv2.CAP_PROP_FPS))
    ret_val = True
    writer = 0
    
    while True:
        ret_val, frame = vs.read()
        if not ret_val:
            break
       
        resized_frame = cv2.resize(frame, (IMG_SIZE, IMG_SIZE))
        frame_for_pred = prepare_image_for_prediction( resized_frame )
        pred_vec = model.predict(frame_for_pred)
        #print(pred_vec)
        pred_class =[]
        confidence = np.round(pred_vec.max(),2) 
        
        if confidence > 0.4:
            pc = pred_vec.argmax()
            pred_class.append( (pc, confidence) )
        else:
            pred_class.append( (0, 0) )
        if pred_class:
            txt = get_display_string(pred_class, label_dict)       
            frame = draw_prediction( frame, txt )
   
        if cv2.waitKey(1) & 0xFF == ord('q'): # Quit if Q/q is pressed
            break
        # write the out
        cv2.imshow("Video",frame)
        
    vs.release()
    cv2.destroyAllWindows()


with open('Fire-model.json', 'r') as json_file:
    json_savedModel= json_file.read()

model_Fire = tf.keras.models.model_from_json(json_savedModel)
model_Fire.load_weights('FireDetection.hdf5')
model_Fire.compile(optimizer = "Adam", loss = "categorical_crossentropy", metrics = ["accuracy"])



video_path = 'C:\\Users\\ashis\\Downloads\\Video\\fire.mp4'
predict ( model_Fire, video_path, label_dict_l)

