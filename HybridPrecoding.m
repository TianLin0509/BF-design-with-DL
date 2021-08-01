%%%%%%%%%%----- Performance of Adaptive Channel Estimation of MmWave Channels-----%%%%%%%
%%%%%%%%%%------------------ Hybrid precoding approximation --------------------%%%%%%%%
% Author: Ahmed Alkhateeb                                              
% Date: April 2, 2015
%
% In order to use this code or any (modified) part of it in any publication, please cite 
% the paper: A. Alkhateeb, O. El Ayach, G. Leus, R. W. Heath Jr, “Channel Estimation and 
% Hybrid Precoding for Millimeter Wave Cellular Systems,” IEEE Journal of Selected Topics 
% in Signal Processing, vol.8, no.5, pp.831-846, Oct. 2014
% 
% This work is licensed under a Creative Commons Attribution-NonCommercial
% 4.0 International License (http://creativecommons.org/licenses/by-nc/4.0/).
%
% Description: This function constructs a hybrid precoding aproximation of the 
% optimal unconstrained precoders - This code is written to implement the algorithms 
% in the paper A. Alkhateeb, O. ElAyach, G. Leus, and R. W. Heath Jr., "Channel Estimation 
% and Hybrid Precoding for Millimeter Wave Cellular Systems," IEEE Journal of Selected 
% Topics in Signal Processing, vol.8, no.5, pp.831-846, Oct. 2014. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [F]=HybridPrecoding(Fopt,Num_Antennas,Num_RFchains,Num_Qbits)

% System parameters 
Kd=pi;  % Assuming: K=2pi/lambda, D=lambda/2
Num_Directions=2^Num_Qbits;
Step=2*pi/Num_Directions;
Antennas_index=0:1:Num_Antennas-1;
Theta_Quantized=0:Step:2*pi-.00001;

% RF codebook
for i=1:1:length(Theta_Quantized)
    Steering_Vec(:,i)=sqrt(1/Num_Antennas)*exp(1j*Antennas_index*Theta_Quantized(i));
end

% Initialization
Fres=Fopt; % Residual precoding matrix 
Frf=[];    % To carry the RF precoders
Steering_VecX=Steering_Vec; % The RF beamforming codebook

for m=1:1:Num_RFchains
    % Selecting the best RF beamforming vector
    Epsi=Steering_VecX'*Fres;
    [val,Ind_Direction]=max(diag(Epsi*Epsi'));
    Frf=[Frf Steering_Vec(:,Ind_Direction)];
    
    % Gram-Schmidt Procedure
    E=Steering_VecX(:,Ind_Direction);
    Proj_Prev_Directions=E*(E'*Steering_VecX/(E'*E));
    Steering_VecX=Steering_VecX-Proj_Prev_Directions; % Updating the dictionary
    
    % Digital precoding
    Fbb=Frf\Fopt;
    Fres=(Fres-Frf*Fbb)/sqrt(trace((Fres-Frf*Fbb)'*(Fres-Frf*Fbb)));
end

% Precoding vectors normalization
for i=1:1:size(Fopt,2)
    Fbb(:,i)=Fbb(:,i)/sqrt(trace((Frf*Fbb(:,i))'*(Frf*Fbb(:,i))));
end

% The final hybrid precoding matrix
F=Frf*Fbb;
end