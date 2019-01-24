import numpy as np
import scipy.io as sio


def save_mat(x):
    sio.savemat('E:/WCL_MATLAB/DL_temp.mat', {'DL': x})
    return 0


def mat_load():
    path = input('copy the path of package containing the samples in the python console to load data: \n')
    hr = sio.loadmat(path + '/Hr_nar.mat')['Hr_nar']
    print('load testing hr: shape is', hr.shape)
    hi = sio.loadmat(path + '/Hi_nar.mat')['Hi_nar']
    print('load testing hi: shape is', hi.shape)
    hr_est = sio.loadmat(path + '/Hr_est.mat')['Hr_est']
    print('load training estimated hr: shape is', hr_est.shape)
    hi_est = sio.loadmat(path + '/Hi_est.mat')['Hi_est']
    print('load training estimated hi: shape is', hi_est.shape)
    return hr, hi, hr_est, hi_est




