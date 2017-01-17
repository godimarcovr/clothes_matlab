import csv
import os
import numpy as np
from keras.models import Sequential
from keras.layers import Activation, Dense, Dropout, Convolution2D, Flatten, Merge
from keras.utils import np_utils
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix
import scipy.io


TRAIN_DATASET_NAME = "balanced_specific_train"
TEST_DATASET_NAME = "balanced_specific_test"

def main():
    '''
    main
    '''

    #leggo dati di input
    os.chdir("data")

    train_mat = scipy.io.loadmat(TRAIN_DATASET_NAME + "__features.mat")
    cat_labels = []
    for cat in train_mat['categories_list']:
        cat_labels.append(cat[0][0])
    conv_train_features = train_mat['conv_train_vectors'].astype('float32')
    conv_train_features = np.reshape(conv_train_features
                                     , (conv_train_features.shape[0]
                                        , conv_train_features.shape[1]
                                        , conv_train_features.shape[2], 1))
    train_features = train_mat['train_vectors'].astype('float32')
    train_cats = train_mat['train_categories'].astype(int)
    feat_size = train_features.shape[1]
    conv_feat_size = (conv_train_features.shape[1], conv_train_features.shape[2])

    test_mat = scipy.io.loadmat(TEST_DATASET_NAME + "__features.mat")
    conv_test_features = test_mat['conv_test_vectors'].astype('float32')
    conv_test_features = np.reshape(conv_test_features
                                    , (conv_test_features.shape[0]
                                       , conv_test_features.shape[1]
                                       , conv_test_features.shape[2], 1))
    test_features = test_mat['test_to_test_vectors'].astype('float32')
    test_cats = test_mat['test_to_test_categories'].astype(int)


    os.chdir("..")

    print('train_features shape:', train_features.shape)
    print(train_features.shape[0], 'train samples')
    print(test_features.shape[0], 'test samples')

    num_classes = np.max(train_cats) + 1

    train_cats_categ = np_utils.to_categorical(train_cats, num_classes)
    test_cats_categ = np_utils.to_categorical(test_cats, num_classes)

    # convoluto
    model_conv = Sequential()
    model_conv.add(Convolution2D(12, 3, 3, input_shape=(conv_feat_size[0], conv_feat_size[1], 1)))
    model_conv.add(Activation('relu'))
    model_conv.add(Flatten())

    model_conv.add(Dropout(0.5))
    model_conv.add(Dense(20))
    model_conv.add(Activation('sigmoid'))

    #fully connected
    model = Sequential()
    model.add(Dropout(0.5, input_shape=(feat_size,)))
    model.add(Dense(100))
    model.add(Activation('sigmoid'))

    #merging
    merged_model = Sequential()
    merged_model.add(Merge([model_conv, model], mode='concat', concat_axis=1))

    merged_model.add(Dropout(0.45))
    merged_model.add(Dense(45))
    merged_model.add(Activation('sigmoid'))

    merged_model.add(Dropout(0.25))
    merged_model.add(Dense(num_classes))
    merged_model.add(Activation('softmax'))

    merged_model.compile(loss='categorical_crossentropy',
                         optimizer='adam',
                         metrics=['accuracy'])
    history = merged_model.fit([conv_train_features, train_features], train_cats_categ, nb_epoch=50
                               , validation_data=([conv_test_features, test_features]
                                                  , test_cats_categ)
                               , verbose=2)
    #matrice di confusione
    y_pred = merged_model.predict_classes([conv_test_features, test_features])
    conf = confusion_matrix(test_cats, y_pred)
    plt.figure()
    plt.imshow(conf, interpolation='nearest', cmap=plt.cm.Blues)
    plt.title('Confusion matrix')
    tick_marks = np.arange(len(cat_labels))
    plt.xticks(tick_marks, cat_labels, rotation=45)
    plt.yticks(tick_marks, cat_labels)
    plt.draw()
    # list all data in history
    print(history.history.keys())
    # summarize history for accuracy
    plt.figure()
    plt.plot(history.history['acc'])
    plt.plot(history.history['val_acc'])
    plt.title('model accuracy')
    plt.ylabel('accuracy')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper left')
    plt.draw()
    # summarize history for loss
    plt.figure()
    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('model loss')
    plt.ylabel('loss')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper left')
    plt.show()

if __name__ == "__main__":
    main()
