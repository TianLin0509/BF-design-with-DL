function [pcsi, ecsi] = channel_gen_LOS(pnr_dB,ITER, Num_paths, Lest,Nrf, Nt, Nr)
%Revised from Adaptive_Channel_Estimation_Multi_Path.m
%2019.01.22

%------------------------System Parameters---------------------------------
Num_BS_Antennas=Nt; % BS antennas
BSAntennas_Index=0:1:Num_BS_Antennas-1; % Indices of the BS Antennas
Num_BS_RFchains=Nrf; % BS RF chains

Num_MS_Antennas=Nr; % MS antennas
MSAntennas_Index=0:1:Num_MS_Antennas-1; % Indices of the MS Antennas
Num_MS_RFchains=Nrf;  % MS RF chains
Num_Qbits=7;  % Number of phase shifters quantization bits

%---------------------- Simulation Parameters-------------------------------
%ITER=1000; % Number of independent realizations (to be averaged over)
%PNR = [0]; % PNR for channel estimation

% % ---------------------Channel Parameters ---------------------------------
%Num_paths=3; % Number of channel paths
Num_paths_est=Lest; % Number of desired estimated paths
Carrier_Freq=28*10^9; % Carrier frequency
lambda=3*10^8/Carrier_Freq; % Wavelength
n_pathloss=3; % Pathloss constant
Tx_Rx_dist=50; % Distance between BS and MS
ro=((lambda/(4*pi*5))^2)*(5/Tx_Rx_dist)^n_pathloss; % Pathloss
Pt_avg=10^(.7); % Average total transmitted power
Pr_avg=Pt_avg*ro; % Average received power

%---------------- Channel Estimation Algorithm Parameters------------------
switch Num_paths_est
    case 1
        G_BS=256; % Required resolution for BS AoD
        G_MS=256; % Required resolution for MS AoA
    case 2
        G_BS=256; % Required resolution for BS AoD
        G_MS=256; % Required resolution for MS AoA
    case 3
        G_BS=192; % Required resolution for BS AoD
        G_MS=192; % Required resolution for MS AoA
end

G_BS = Num_paths_est * 64;
G_MS = Num_paths_est * 64;
K_BS=2;  % Number of Beamforming vectors per stage
K_MS=2;  % Number of Measurement vectors per stage


S=floor(max(log(G_BS/Num_paths_est)/log(K_BS),log(G_MS/Num_paths_est)/log(K_MS))); % Number of iterations

% Optimized power allocation
Pr_alloc=power_allocation(Num_BS_Antennas,Num_BS_RFchains,BSAntennas_Index,G_BS,G_MS,K_BS,K_MS,Num_paths_est,Num_Qbits);
Pr=abs(Pr_avg*Pr_alloc*S);


% Beamsteering vectors generation
for g=1:1:G_BS
    AbG(:,g)=sqrt(1/Num_BS_Antennas)*exp(1j*(2*pi)*BSAntennas_Index*((g-1)/G_BS));
end

% Am generation
for g=1:1:G_MS
    AmG(:,g)=sqrt(1/Num_MS_Antennas)*exp(1j*(2*pi)*MSAntennas_Index*((g-1)/G_MS));
end
%--------------------------------------------------------------------------
ecsi = zeros(ITER,Num_MS_Antennas,Num_BS_Antennas);
error_NMSE = zeros(ITER,1);
pcsi=zeros(ITER,Num_MS_Antennas,Num_BS_Antennas);
t1 = clock;
for iter=1:1:ITER
    if mod(iter,100)==0
        iter
    end
    % Channel Generation
    
    % Channel parameters (angles of arrival and departure and path gains)
    AoD= pi*rand(1,Num_paths) - pi/2;
    AoA= pi*rand(1,Num_paths) - pi/2;
%         AoD=2*pi*rand(1,Num_paths);
%     AoA=2*pi*rand(1,Num_paths);
    alpha=(sqrt(1/2)*sqrt(1/Num_paths)*(randn(1,Num_paths)+1j*randn(1,Num_paths)));
    alpha(1) = 1; % gain of the LoS
    alpha(2:Num_paths) = 10^(-0.5)*(randn(1,Num_paths-1)+1i*randn(1,Num_paths-1))/sqrt(2);
    % Channel construction
    Channel=zeros(Num_MS_Antennas,Num_BS_Antennas);
    for l=1:1:Num_paths
        Abh(:,l)=sqrt(1/Num_BS_Antennas)*exp(1j*BSAntennas_Index*AoD(l));
        Amh(:,l)=sqrt(1/Num_MS_Antennas)*exp(1j*MSAntennas_Index*AoA(l));
        Channel=Channel+sqrt(Num_BS_Antennas*Num_MS_Antennas)*alpha(l)*Amh(:,l)*Abh(:,l)';
    end
    pcsi(iter,:,:) = Channel;
    
    pnr=10^(0.1*pnr_dB);
    No=Pr_avg/pnr;  %Noise power
    %Algorithm parameters initialization
    KB_final=[]; % To keep the indecis of the estimated AoDs
    KM_final=[]; % To keep the indecis of the estimated AoAs
    yv_for_path_estimation=zeros(K_BS*K_MS*Num_paths_est^2,1); % To keep received vectors
    
    for l=1:1:Num_paths_est % An iterations for each path
        KB_star=1:1:K_BS*Num_paths_est; % Best AoD ranges for the next stage
        KM_star=1:1:K_MS*Num_paths_est; % Best AoA ranges for the next stage
        
        for t=1:1:S
            
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
            
            %MS G matrix generation
            G_matrix_MS=zeros(K_MS*Num_paths_est,G_MS);
            Block_size_MS=G_MS/(Num_paths_est*K_MS^t);
            Block_MS=[ones(1,Block_size_MS)];
            for k=1:1:K_MS*Num_paths_est
                G_matrix_MS(k,(KM_star(k)-1)*Block_size_MS+1:(KM_star(k))*Block_size_MS)=Block_MS;
            end
            
            % Ideal vectors generation
            F_UC=(AbG*AbG')^(-1)*(AbG)*G_matrix_BS';
            W_UC=(AmG*AmG')^(-1)*(AmG)*G_matrix_MS';
            
            % Ideal vectors normalization
            F_UC=F_UC*diag(1./sqrt(diag(F_UC'*F_UC)));
            W_UC=W_UC*diag(1./sqrt(diag(W_UC'*W_UC)));
            
            % Hybrid Precoding Approximation
            for m=1:1:K_BS*Num_paths_est
                [F_HP(:,m)]=HybridPrecoding(F_UC(:,m),Num_BS_Antennas,Num_BS_RFchains,Num_Qbits);
            end
            for n=1:1:K_MS*Num_paths_est
                [W_HP(:,n)]=HybridPrecoding(W_UC(:,n),Num_MS_Antennas,Num_MS_RFchains,Num_Qbits);
            end
            
            % Noise calculations
            Noise=W_HP'*(sqrt(No/2)*(randn(Num_MS_Antennas,K_BS*Num_paths_est)+1j*randn(Num_MS_Antennas,K_BS*Num_paths_est)));
            
            % Received signal
            Y=sqrt(Pr(t))*W_HP'*Channel*F_HP+Noise;
            yv=reshape(Y,K_BS*K_MS*Num_paths_est^2,1); % vectorized received signal
            if(t==S)
                yv_for_path_estimation=yv_for_path_estimation+yv/sqrt(Pr(t));
            end
            
            % Subtracting the contribution of previously estimated paths
            for i=1:1:length(KB_final)
                A1=transpose(F_HP)*conj(AbG(:,KB_final(i)+1));
                A2=W_HP'*AmG(:,KM_final(i)+1);
                Prev_path_cont=kron(A1,A2);
                Alp=  yv' * Prev_path_cont;
                yv=yv-Alp*Prev_path_cont/(Prev_path_cont'*Prev_path_cont);
            end
            
            % Maximum power angles estimation
            Y=reshape(yv,K_MS*Num_paths_est,K_BS*Num_paths_est);
            [val mX]=max(abs(Y));
            Max=max(val);
            [KM_temp KB_temp]=find(abs(Y)==Max);
            KM_max(1)=KM_temp(1);
            KB_max(1)=KB_temp(1);
            
            % Keeping the best angle in a history matrix (the T matrix in Algorithm 3)
            KB_hist(l,t)=KB_star(KB_max(1));
            KM_hist(l,t)=KM_star(KM_max(1));
            
            % Final AoAs/AoDs
            if(t==S)
                KB_final=[KB_final KB_star(KB_max(1))-1];
                KM_final=[KM_final KM_star(KM_max(1))-1];
                W_paths(l,:,:)=W_HP;
                F_paths(l,:,:)=F_HP;
            end
            
            
            TempB=KB_star;
            TempM=KM_star;
            
            % Adjusting the directions of the next stage (The adaptive search)
            for ln=1:1:l
                KB_star((ln-1)*K_BS+1:ln*K_BS)=(KB_hist(ln,t)-1)*K_BS+1:1:(KB_hist(ln,t))*K_BS;
                KM_star((ln-1)*K_MS+1:ln*K_MS)=(KM_hist(ln,t)-1)*K_MS+1:1:(KM_hist(ln,t))*K_MS;
            end
            
        end % -- End of estimating the lth path
        
    end %--- End of estimation of the channel
    
    
    % Estimated angles
    AoD_est=2*pi*KB_final/G_BS;
    AoA_est=2*pi*KM_final/G_MS;
    
    % Estimated paths
    Wx=zeros(Num_MS_Antennas,K_MS*Num_paths_est);
    Fx=zeros(Num_BS_Antennas,K_BS*Num_paths_est);
    Epsix=zeros(K_BS*K_MS*Num_paths_est^2,Num_paths_est);
    
    for l=1:1:Num_paths_est
        Epsi=[];
        Wx(:,:)=W_paths(l,:,:);
        Fx(:,:)=F_paths(l,:,:);
        for i=1:1:length(KB_final)
            A1=transpose(Fx)*conj(AbG(:,KB_final(i)+1));
            A2=Wx'*AmG(:,KM_final(i)+1);
            E=kron(A1,A2);
            Epsi=[Epsi E];
        end
        Epsix=Epsix+Epsi;
    end
    alpha_est=Epsix\yv_for_path_estimation;
    
    % Reconstructing the estimated channel
    Channel_est=zeros(Num_MS_Antennas,Num_BS_Antennas);
    for l=1:1:Num_paths_est
        Abh_est(:,l)=sqrt(1/Num_BS_Antennas)*exp(1j*BSAntennas_Index*AoD_est(l));
        Amh_est(:,l)=sqrt(1/Num_MS_Antennas)*exp(1j*MSAntennas_Index*AoA_est(l));
        Channel_est=Channel_est+alpha_est(l)*Amh_est(:,l)*Abh_est(:,l)';
    end
    ecsi(iter,:,:) = Channel_est;
    error_NMSE(iter)=(norm(Channel_est-Channel,'fro')/norm(Channel,'fro'))^2;
    if (iter==20)
        disp('产生信道所需时间:')
        mytoc(t1,ITER);
    end
end
disp('error_NMSE:')
mean(error_NMSE)
% index = find(error_NMSE>100);
% error_NMSE(index) = [];
% ecsi(index,:,:) = [];
% pcsi(index,:,:) = [];
disp('error_NMSE:')
mean(error_NMSE)

