%% Converter ratings
Vg=72;               % Input voltage: 60V-90V
V=12;                % Output voltage: 12V

I=100e-6;           %I: 100uA-5A

fsw=100e3            % Switching frequency
Tsw=1/fsw           % Switching period

%Inductor
L=4e-3
% Inductance
RL=100e-3            % Internal resistance

%Capacitor
C=100e-6             % Capacitance
Resr=10e-3           % ESR value

%Load
R_noload=V/I               % Load resistance
R = 2.4;

%Mosfet
Rdson=100e-3        % On-state resistance
Vf=0.78             % Anti-paralel diode forward voltage


%% DC analysis
%Duty cycle value
Duty=(V/Vg)*(1+((RL+Rdson)/R))      % Duty cycle value

%% Small signal AC analysis
s=tf('s')

Re=RL+Rdson

%Gvd
Gvd=((Vg*R)/(Re+R))*((1+s*C*Resr)/(((L*C*(R+Resr))/(Re+R))*s^2+((R*Re*C+Resr*Re*C+Resr*R*C+L)/(Re+R))*s+1))

%Gvg
Gvg=((Duty*R)/(Re+R))*((1+s*C*Resr)/(((L*C*(R+Resr))/(Re+R))*s^2+((R*Re*C+Resr*Re*C+Resr*R*C+L)/(Re+R))*s+1))

%Zout
Zout=(-(R*Re)/(Re+R))*(1+s*(L/Re))*((1+s*C*Resr)/(((L*C*(R+Resr))/(Re+R))*s^2+((R*Re*C+Resr*Re*C+Resr*R*C+L)/(Re+R))*s+1))

%Gvd_noload
Gvd_noload = (Vg*(1+s*C*Resr))/(L*C*s^2+(Re+Resr)*C*s+1)
%Gvg_noload
Gvg_noload = ((Duty*R_noload)/(Re+R_noload))*((1+s*C*Resr)/(((L*C*(R_noload+Resr))/(Re+R_noload))*s^2+((R_noload*Re*C+Resr*Re*C+Resr*R_noload*C+L)/(Re+R_noload))*s+1))
%Zout_noload
Zout_noload = (-(R_noload*Re)/(Re+R_noload))*(1+s*(L/Re))*((1+s*C*Resr)/(((L*C*(R_noload+Resr))/(Re+R_noload))*s^2+((R_noload*Re*C+Resr*Re*C+Resr*R_noload*C+L)/(Re+R_noload))*s+1))

%% Compensator design
%Parameters for controller design
Vm=1;      % Peak of PWM generator
H=1;     % voltage sensor gain

% desired cut-off freq and phase margin
fc = 10e3;
PM = (52/180)*pi;

% pole and zero values of the compensator
fz = fc*sqrt((1-sin(PM))/(1+sin(PM)))
fp = fc*sqrt((1+sin(PM))/(1-sin(PM)))

wz = 2*pi*fz;
wp = 2*pi*fp;
wL = 0; 
wc = 2*pi*fc;

Tuo = 0.046;

Gco = sqrt((1+(wc/wp)^2)/(1+(wc/wz)^2))/Tuo

Gc = (Gco*(1+s/wz))/(1+s/wp)


figure(1)
Tu_noload = Gvd_noload*(1/Vm)*H
T_noload = Tu_noload*Gc
bode(Tu_noload)
legend('Uncompensated loop gain - no load case')

figure(2)
Tu = Gvd*(1/Vm)*H
T= Tu*Gc
bode(T_noload)
hold on
bode(T)
legend('No load case','Full load case' )

figure(3)
T_cl_noload = T_noload/(1+T_noload)
T_cl = T/(1+T)
bode(T_cl_noload)
hold on
bode(T_cl)
legend('No load case','Full load case' )

figure(4)
Gvg_cl_noload = Gvg_noload/(1+T_noload)
Gvg_cl = Gvg/(1+T)
bode(Gvg_cl_noload)
hold on
bode(Gvg_cl)
legend('No load case','Full load case' )

figure(5)
Zout_cl_noload = Zout_noload/(1+T_noload)
Zout_cl = Zout/(1+T)
bode(Zout_cl_noload)
hold on
bode(Zout_cl)
legend('No load case','Full load case')

