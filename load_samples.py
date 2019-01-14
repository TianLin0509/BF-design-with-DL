import numpy as np
import scipy.io as sio


def load_data_prefect_csi(flag):
    # 0: Large sample sets for training
    # 1: Small sample sets for testing
    if flag == 0:
        #  load the real and imag partition of the perfect CSI for training
        #  150000 samples are used during the training
        hr = sio.loadmat('./sample_set/h_real_train.mat')['Hr_nar']
        print('load training hr: shape is', hr.shape)
        hi = sio.loadmat('./sample_set/h_imag_train.mat')['Hi_nar']
        print('load training hi: shape is', hi.shape)

    if flag == 1:
        #  load the real and imag partition of the perfect CSI for testing
        #  10000 samples are used during the testing
        hr = sio.loadmat('./sample_set/h_real_test.mat')['Hr_nar']
        print('load testing hr: shape is', hr.shape)
        hi = sio.loadmat('./sample_set/h_imag_test.mat')['Hi_nar']
        print('load testing hi: shape is', hi.shape)

    return hr, hi


def load_data_estimated_csi(flag):
    # 0: Large sample sets for training
    # 1: Small sample sets for testing
    if flag == 0:
        #  load the real and imag partition of the estimated CSI for training
        #  150000 samples are used during the training
        hr = sio.loadmat('./sample_set/h_real_train2.mat')['Hr_nar']
        print('load training hr: shape is', hr.shape)
        hi = sio.loadmat('./sample_set/h_imag_train2.mat')['Hi_nar']
        print('load training hi: shape is', hi.shape)
        hr_est = sio.loadmat('./sample_set/h_est_real_train.mat')['Hr_est']
        print('load training estimated hr: shape is', hr_est.shape)
        hi_est = sio.loadmat('./sample_set/h_est_imag_train.mat')['Hi_est']
        print('load training estimated hi: shape is', hi_est.shape)
        noise_power = sio.loadmat('./sample_set/Noise_power_train.mat')['Noise_power']

    if flag == 1:
        #  load the real and imag partition of the estimated CSI for testing
        #  10000 samples are used during the testing
        hr = sio.loadmat('./sample_set/h_real_test2.mat')['Hr_nar']
        print('load testing hr: shape is', hr.shape)
        hi = sio.loadmat('./sample_set/h_imag_test2.mat')['Hi_nar']
        print('load testing hi: shape is', hi.shape)
        hr_est = sio.loadmat('./sample_set/h_est_real_test.mat')['Hr_est']
        print('load testing estimated hr: shape is', hr_est.shape)
        hi_est = sio.loadmat('./sample_set/h_est_imag_test.mat')['Hi_est']
        print('load testing estimated hi: shape is', hi_est.shape)
        noise_power = sio.loadmat('./sample_set/Noise_power_test.mat')['Noise_power']

    return hr, hi, hr_est, hi_est, noise_power


