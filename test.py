import numpy as np
from utils import *
from tensorflow.python.keras.layers import *

# ------------------------------------------
#  Load and generate simulation data
# ------------------------------------------
path = 'train_set/example/test'  # the path of the dictionary containing pcsi.mat and ecsi.mat
H, H_est = mat_load(path)
# use the estimated csi as the input of the BFNN
H_input = np.expand_dims(np.concatenate([np.real(H_est), np.imag(H_est)], 1), 1)
# H denotes the perfect csi
H = np.squeeze(H)
# generate  SNRs associated with different samples
SNR = np.power(10, np.random.randint(-20, 20, [H.shape[0], 1]) / 10)

# -----------------------
#  Construct the BFNN Model
# -----------------------
# imperfect CSI is used to output the vrf
imperfect_CSI = Input(name='imperfect_CSI', shape=(H_input.shape[1:4]), dtype=tf.float32)
# perfect_CSI is only used to compute the loss, and not required in prediction
perfect_CSI = Input(name='perfect_CSI', shape=(H.shape[1],), dtype=tf.complex64)
# the SNR is also fed into the BFNN
SNR_input = Input(name='SNR_input', shape=(1,), dtype=tf.float32)
temp = BatchNormalization()(imperfect_CSI)
temp = Flatten()(temp)
temp = BatchNormalization()(temp)
temp = Dense(256, activation='relu')(temp)
temp = BatchNormalization()(temp)
temp = Dense(128, activation='relu')(temp)
phase = Dense(Nt)(temp)
V_RF = Lambda(trans_Vrf, dtype=tf.complex64, output_shape=(Nt,))(phase)
rate = Lambda(Rate_func, dtype=tf.float32, output_shape=(1,))([perfect_CSI, V_RF, SNR_input])
model = Model(inputs=[imperfect_CSI, perfect_CSI, SNR_input], outputs=rate)
# the y_pred is the actual rate, thus the loss is y_pred, without labels
model.compile(optimizer='adam', loss=lambda y_true, y_pred: y_pred)
model.summary()

# -----------------------
#  Test Your Model
# -----------------------
rate = []
# load the trained model
# You can train the model by train.py or download it from the Google drive provided.
model.load_weights('./0db.h5')
for snr in range(-20, 25, 5):
    SNR = np.power(10, np.ones([H.shape[0], 1]) * snr / 10)
    y = model.evaluate(x=[H_input, H, SNR], y=H, batch_size=10000)
    rate.append(-y)
print(rate)

