import csv
import os
import numpy as np
from keras.models import Sequential
from keras.layers import Activation, Dense, Dropout
from keras.utils import np_utils
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix
import scipy.io


TRAIN_DATASET_NAME = "balanced_specific_train"
TEST_DATASET_NAME = "balanced_specific_test"
# NN_CONF_FILENAME = "balanced_specific_train_NN_config.mat"

def main():
    '''
    main
    '''

    #leggo dati di input
    os.chdir("data")

    train_mat = scipy.io.loadmat(TRAIN_DATASET_NAME + "__features.mat")
    train_features = train_mat['train_vectors'].astype('float32')
    train_cats = train_mat['train_categories'].astype(int)
    feat_size = train_features.shape[1]

    test_mat = scipy.io.loadmat(TEST_DATASET_NAME + "__features.mat")
    test_features = test_mat['test_to_test_vectors'].astype('float32')
    test_cats = test_mat['test_to_test_categories'].astype(int)

    # train_features = []
    # with open(TRAIN_DATASET_NAME + "__features.csv", 'r') as csvfile:
    #     csvdata = csv.reader(csvfile, delimiter=',')
    #     for row in csvdata:
    #         train_features.append([float(x) for x in row])

    # feat_size = len(train_features[0])
    # train_features = np.array(train_features, ndmin=2)

    # test_features = []
    # with open(TEST_DATASET_NAME + "__features.csv", 'r') as csvfile:
    #     csvdata = csv.reader(csvfile, delimiter=',')
    #     for row in csvdata:
    #         test_features.append([float(x) for x in row])
    # test_features = np.array(test_features, ndmin=2)

    # train_cats = []
    # with open(TRAIN_DATASET_NAME + "__categories.csv", 'r') as csvfile:
    #     csvdata = csv.reader(csvfile, delimiter=',')
    #     for row in csvdata:
    #         train_cats.append(int(row[0]))
    # train_cats = np.array(train_cats, ndmin=1)

    # test_cats = []
    # with open(TEST_DATASET_NAME + "__categories.csv", 'r') as csvfile:
    #     csvdata = csv.reader(csvfile, delimiter=',')
    #     for row in csvdata:
    #         test_cats.append(int(row[0]))
    # test_cats = np.array(test_cats, ndmin=1)

    os.chdir("..")

    print('train_features shape:', train_features.shape)
    print(train_features.shape[0], 'train samples')
    print(test_features.shape[0], 'test samples')

    num_classes = np.max(train_cats) + 1

    train_cats_categ = np_utils.to_categorical(train_cats, num_classes)
    test_cats_categ = np_utils.to_categorical(test_cats, num_classes)

    model = Sequential()
    model.add(Dropout(0.25, input_shape=(feat_size,)))
    model.add(Dense(200))
    model.add(Activation('sigmoid'))

    model.add(Dropout(0.25))
    model.add(Dense(100))
    model.add(Activation('sigmoid'))

    model.add(Dropout(0.25))
    model.add(Dense(num_classes))
    model.add(Activation('softmax'))

    model.compile(loss='categorical_crossentropy',
                  optimizer='rmsprop',
                  metrics=['accuracy'])
    history = model.fit(train_features, train_cats_categ, nb_epoch=200
                        , validation_data=(test_features, test_cats_categ)
                        , verbose=2)
    #matrice di confusione
    y_pred = model.predict_classes(test_features)
    conf = confusion_matrix(test_cats, y_pred)
    plt.figure()
    plt.imshow(conf, interpolation='nearest', cmap=plt.cm.Blues)
    plt.title('Confusion matrix')
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
