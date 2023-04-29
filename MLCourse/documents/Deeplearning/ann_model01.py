import numpy
import pandas as pd
import keras
from keras.models import Sequential
from keras.layers import Dense

# load the data
data = pd.read_csv("train.csv", delimiter=",", index_col = False)
data = data
data = data.drop("Unnamed: 0", axis = 1)
# split the data into inputs and outputs
X = data.drop("salary",axis=1)
Y = data[["salary"]]
n_x = X.shape[1]

# define the model architecture
model = Sequential()
model.add(Dense(10, input_dim=n_x, activation='linear'))
model.add(Dense(1, activation='linear'))

# compile the model
model.compile(loss='mse', optimizer='adam', metrics=['mse'])
model.summary()
# train the model
history = model.fit(X, Y, epochs=100, batch_size=10,
validation_split = 0.1)

import matplotlib.pyplot as plt
plt.plot(history.history['mse'])
plt.title('MSE')
plt.ylabel('MSE')
plt.xlabel('epoch')
plt.legend(['train', 'test'], loc='upper left')
plt.show()



# save the model to disk
model.save("model.h5")
# save the history object as a pickle file
with open('history.pkl', 'wb') as f:
    pickle.dump(history.history, f)
