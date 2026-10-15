%% System Parameters
m_w = 0.040;     % wheel mass (kg)
m_b = 0.708;     % body mass (kg)
r   = 0.0325;    % wheel radius(m)
L   = 0.042;     % distance of CoM (m)
g   = 9.81;      % gravity acceleration(m/s^2)
I_b = 0.0014455; % moment of inertia of the body (kg.m^2)

%% Derived Constants
M1 = 3*m_w + m_b;
M2 = m_b * L;
I_t = m_b*L^2 + I_b;
Dt = M1*I_t- M2^2; %determinant

%% State-space Matrices
A = [0 1 0 0; 0 0 -M2*m_b*g*L/Dt 0; 0 0 0 1; 0 0 M1 *m_b*g*L/Dt 0];
B = [0; (I_t/r +M2)/Dt; 0; -(M1+M2/r)/Dt ];

%% for PID
A_aug =[A, zeros(4,1); -1, 0, 0, 0, 0];
B_aug =[B;0];

%% Controller Gains (K_PID and K_LQR) Constants
K_pid = [-0.304472, -0.138352, -0.317058, -0.026825, 0.315673];
K_lqr = [-0.447214, -1.036294, -5.170126, -0.523897]; %R=5
tau_max_actual =0.6374;

%% Theta0 scanning
theta0_list_deg = [1,2,3,5,7,10];
t = 0:0.01:30; %time from 0 sec to 30 secs, 10ms period

for i= 1:length(theta0_list_deg)
    theta0 = theta0_list_deg(i) * pi/180;
    
    %LQR
    x0_lqr= [0;0;theta0;0];
    [Y_lqr, U_lqr] = simulate_saturated(A, B, K_lqr, x0_lqr, t, tau_max_actual);
    [Ts_lqr,Tr_lqr,~,Mp_lqr, rms_theta_lqr, rms_tau_lqr, peak_tau_lqr] = sweep_metrics(Y_lqr(:,3)*180/pi, U_lqr, t, theta0*180/pi);
    x_final_lqr = Y_lqr(end,1)*100;
    rms_x_lqr =sqrt(mean((Y_lqr(:,1)*100).^2));
    max_x_lqr =max(abs(Y_lqr(:,1)*100));
    
    %PID
    x0_pid= [0;0;theta0;0;0];
    [Y_pid, U_pid] = simulate_saturated(A_aug, B_aug, K_pid, x0_pid, t, tau_max_actual);
    [Ts_pid,Tr_pid,~,Mp_pid, rms_theta_pid, rms_tau_pid, peak_tau_pid] = sweep_metrics(Y_pid(:,3)*180/pi, U_pid, t, theta0*180/pi);
    x_final_pid = Y_pid(end,1)*100;
    rms_x_pid =sqrt(mean((Y_pid(:,1)*100).^2));
    max_x_pid =max(abs(Y_pid(:,1)*100));
    

    fprintf('theta0=%d deg\n', theta0_list_deg(i));
    fprintf('  LQR: Ts=%.2f  RMS_theta=%.2f  peak_tau=%.4f  RMS_tau=%.4f  RMS_x=%.2f  max_x=%.2f  x_final=%.2f\n',Ts_lqr, rms_theta_lqr, peak_tau_lqr, rms_tau_lqr, rms_x_lqr, max_x_lqr, x_final_lqr );
    fprintf('  PID: Ts=%.2f  RMS_theta=%.2f  peak_tau=%.4f  RMS_tau=%.4f  RMS_x=%.2f  max_x=%.2f  x_final=%.2f\n',Ts_pid, rms_theta_pid, peak_tau_pid, rms_tau_pid, rms_x_pid, max_x_pid, x_final_pid );
end
%%Functions

function [Y,U] = simulate_saturated(A,B,K,x0,t,tau_max)
 [~,Y] = ode45(@(tt,x)sat_dynamics(x,A,B,K,tau_max),t,x0);
  U=zeros(length(t),1);
 
 for k= 1:length(t)
    tau_cmd = -K* Y(k,:)';
    U(k)= max(-tau_max, min(tau_max, tau_cmd));
 end
end

function dx = sat_dynamics(x,A,B,K,tau_max)
 tau_cmd = -K * x;
 tau_act= max(-tau_max, min(tau_max, tau_cmd));
 dx= A*x +B*tau_act;
end

function [Ts, Tr, overshoot, overshoot_pct, rms_theta, rms_torque, peak_torque] = sweep_metrics(theta_deg, u, t, theta0_deg)

thr= 0.02*theta0_deg;
idx_settle = find(abs(theta_deg) > thr);
if isempty(idx_settle)
    Ts = NaN;
else
    Ts = t(idx_settle(end));
end
    idx_90 = find(theta_deg <=0.9*theta0_deg, 1, 'first');
    idx_10 = find(theta_deg <=0.1*theta0_deg, 1, 'first');

if isempty(idx_90)|| isempty(idx_10)
Tr = NaN;
else
Tr = t(idx_10)- t(idx_90);
end

overshoot = abs(min(theta_deg));
overshoot_pct = (overshoot/theta0_deg)*100;
rms_theta = sqrt(mean(theta_deg.^2));
rms_torque = sqrt(mean(u.^2));
peak_torque = max(abs(u));
end


    

