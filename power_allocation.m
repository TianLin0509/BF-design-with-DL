%%%%%%%%%%----- Performance of Adaptive Channel Estimation of MmWave Channels-----%%%%%%%
%%%%%%% --- Optimal Power Allocation Function -- Implement Corollary 2 -----------%%%%%%%
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
% Description: This code implements Optimal Power Allocation Corollary (2) described in 
% the paper: A. Alkhateeb, O. ElAyach, G. Leus, and R. W. Heath Jr., "Channel Estimation 
% and Hybrid Precoding for Millimeter Wave Cellular Systems," IEEE Journal of Selected 
% Topics in Signal Processing, vol.8, no.5, pp.831-846, Oct. 2014. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Pr]=power_allocation(Num_BS_Antennas,Num_BS_RFchains,BSAntennas_Index,G_BS,G_MS,K_BS,K_MS,Num_paths_est,Num_Qbits)

Num_steps=floor(max(log(G_BS/Num_paths_est)/log(K_BS),log(G_MS/Num_paths_est)/log(K_MS)));

% RF codebook
for g=1:1:G_BS
    AbG(:,g)=sqrt(1/Num_BS_Antennas)*exp(1j*(2*pi)*BSAntennas_Index*((g-1)/G_BS));
end

% Generating the hybrid beamforming vectors to obtain the beamformin gain
% of each adaptive hierarchical stage
KB_star=1:1:K_BS*Num_paths_est; % Best AoD ranges for the next stage
KM_star=1:1:K_MS*Num_paths_est; % Best AoA ranges for the next stage

for t=1:1:Num_steps
%Generating the "G" matrix in the paper used to construct the ideal
%training beamforming and combining matrices - These matrices capture the
%desired projection of the ideal beamforming/combining vectors on the
%quantized steering directions

%BS G matrix
G_matrix_BS=zeros(K_BS*Num_paths_est,G_BS);
Block_size_BS=G_BS/(Num_paths_est*K_BS^t);
Block_BS=[ones(1,Block_size_BS)];
for k=1:1:K_BS*Num_paths_est
    G_matrix_BS(k,(KB_star(k)-1)*Block_size_BS+1:(KB_star(k))*Block_size_BS)=Block_BS;
end

% Ideal vectors generation
F_UC=(AbG*AbG')^(-1)*(AbG)*G_matrix_BS';
F_UC=F_UC*diag(1./sqrt(diag(F_UC'*F_UC)));

% Hybrid Precoding Approximation
for m=1:1:K_BS*Num_paths_est
[F_HP(:,m)]=HybridPrecoding(F_UC(:,m),Num_BS_Antennas,Num_BS_RFchains,Num_Qbits);
end

Proj=F_HP(:,1)'*AbG;
G(t)=sum(Proj(1:Block_size_BS))/Block_size_BS;
end

% Optimal power allocation -- according to the paper theorems
Gc=sum(1./G);
Pr=(1/Gc)*1./G;
end
