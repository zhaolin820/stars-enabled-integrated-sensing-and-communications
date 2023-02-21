clc
clear all
close all

addpath("functions\");
cvx_solver mosek

%% system parameters
para = para_init();
[BS_array, STAR_array, sensor_array] = generate_arrays(para);
[H, h] = generate_channel(para, BS_array, STAR_array);

%% target parameters
alpha = para.pathloss_indirect(para.target_loc(1))';
alpha = sqrt(10.^(-alpha/10));
[B, B_h, B_v] = FIM_pre(para, STAR_array, sensor_array);
target_para.alpha = alpha; 
target_para.phi_h = para.target_loc(2); target_para.phi_v = para.target_loc(3);
target_para.B = B; target_para.B_h = B_h; target_para.B_v = B_v;

%% PDD-based algorithm
[X] = algorithm_PDD(para, H, h, target_para);

%% Maximum Likelihood estimation
[spectrum] = MLE_estimation(para, X, H, target_para, STAR_array, sensor_array);



