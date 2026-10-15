%% Actuator Saturation
K_lqr = K;
x0_lqr= x0;
tau_stall_datasheet = 0.4903; % single motor, in 12V (datasheet)
V_rated = 12;
V_actual = 7.8; % real battery voltage(measured)

tau_stall_actual_single = tau_stall_datasheet *(V_actual/V_rated);
tau_max_actual = 2 * tau_stall_actual_single; % 2 motors

fprintf('Single motor stall tork (12V, datasheet)    : %.4f N.m\n', tau_stall_datasheet);
fprintf('Single motor stall tork (real %.1fV battery): %.4f N.m\n', V_actual,tau_stall_actual_single);
fprintf('Two motors combined tau_max, actual         : %.4f N.m\n', tau_max_actual);

%LQR, saturation

[y_lqr_sat, u_lqr_sat]= simulate_saturated(A,B,K_lqr, x0_lqr, t, tau_max_actual);

%PID, saturation

[y_pid_sat, u_pid_sat]= simulate_saturated(A_aug,B_aug,K_pid, x0_pid, t, tau_max_actual);

%% Comparision Graphs ( actual vs saturation)

figure('Units', 'normalized', 'Position', [0.25 0.05 0.05 0.85]);
subplot(4,1,1);
plot(t_lqr, y_lqr(:,3)*180/pi,'LineWidth',1.5); %% convert from radian to angle
hold on;
plot(t, y_lqr_sat(:,3)*180/pi,'LineWidth',1.5);
ylabel('\theta (deg)');
title('LQR: Actuator Saturation Effect');
legend('LQR(actual)','LQR(saturation)');
grid on;
ylim([-0.7 5.3]);
yticks(0:1:5);

subplot(4,1,2);
plot(t_lqr, u_lqr,'LineWidth',1.5);
hold on;
plot(t, u_lqr_sat , '--' , 'LineWidth',1.5); 
plot ([t(1) t(end)],[tau_max_actual tau_max_actual],'r:', 'LineWidth',1);
plot ([t(1) t(end)],[-tau_max_actual -tau_max_actual],'r:', 'LineWidth',1);
ylabel('\tau (N.m)');
xlabel('Time (s)');
legend('LQR(actual)','LQR(saturation)', '\tau_{max,actual}');
grid on;
ylim([-0.7 0.7]);
yticks(-0.5:0.25:0.5);

subplot(4,1,3);
plot(t_pid, y_pid(:,3)*180/pi,'LineWidth',1.5); %% convert from radian to angle
hold on;
plot(t, y_pid_sat(:,3)*180/pi,'LineWidth',1.5);
ylabel('\theta (deg)');
title('PID: Actuator Saturation Effect');
legend('PID(actual)','PID(saturation)');
grid on;
ylim([-3.3 5.3]);
yticks(-2:2:4);

subplot(4,1,4);
plot(t_pid, u_pid,'LineWidth',1.5);
hold on;
plot(t, u_pid_sat , '--' , 'LineWidth',1.5); 
plot ([t(1) t(end)],[tau_max_actual tau_max_actual],'r:', 'LineWidth',1);
plot ([t(1) t(end)],[-tau_max_actual -tau_max_actual],'r:', 'LineWidth',1);
ylabel('\tau (N.m)');
xlabel('Time (s)');
legend('PID(actual)','PID(saturation)', '\tau_{max,actual}');
grid on;
ylim([-0.7 0.7]);
yticks(-0.5:0.25:0.5);

%% Functions
function[Y,U]=simulate_saturated(A,B,K,x0,t,tau_max)
 [~,Y]=ode45(@(tt,x)sat_dynamics(x,A,B,K,tau_max),t,x0);
 U=zeros(length(t),1);
 for k=1:length(t)
    tau_cmd= -K*Y(k,:)';
    U(k) = max(-tau_max,min(tau_max,tau_cmd));
 end
end

function dx = sat_dynamics(x,A,B,K,tau_max)
 tau_cmd = -K*x;
 tau_act= max(-tau_max, min(tau_max,tau_cmd));
 dx= A*x +B*tau_act;
end


