%% Converter ratings
Vg=12;               % Input voltage: 12V-18V
V=5;              % Output voltage: 3.3V-5V

I=1e-6;               %I: 1uA-10A

fsw=50e3           % Switching frequency
Tsw=1/fsw           % Switching period

%Inductor
L=68e-6
% Inductance
RL=30e-3            % Internal resistance

%Capacitor
C=68e-6             % Capacitance
Resr=9e-3           % ESR value

%Load
R_noload=V/I               % Load resistance
R = 0.5;

%Mosfet
Rdson=7.6e-3        % On-state resistance
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
fc = 5e3;
PM = (52/180)*pi;

% pole and zero values of the compensator
fz = fc*sqrt((1-sin(PM))/(1+sin(PM)))
fp = fc*sqrt((1+sin(PM))/(1-sin(PM)))
fL = 400;

wz = 2*pi*fz;
wp= 2*pi*fp;
wL = 2*pi*fL;
wc = 2*pi*fc;

Tuo = 1.4;

Gco = sqrt((1+(wc/wp)^2)/((1+(wc/wz)^2)*(1+(wL/wc)^2)))/Tuo

Gc = (Gco*(1+s/wz)*(1+wL/s))/(1+s/wp)

%Compensator parameters
R1=30e3;

R2 = Gco*R1

C2 = 1/(R2*wL)

Z4 = 1/(wp)

C4 = (1/R1)*((1/wz)-Z4)

R4 = Z4/C4


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
T_cl_noload = T_noload/(1+T_noload)
T_cl = T/(1+T)
step(T_cl_noload)
hold on
step(T_cl)
legend('No load case','Full load case' )

figure(5)
Gvg_cl_noload = Gvg_noload/(1+T_noload)
Gvg_cl = Gvg/(1+T)
step(Gvg_cl_noload)
hold on
step(Gvg_cl)
legend('No load case','Full load case' )

figure(6)
Zout_cl_noload = Zout_noload/(1+T_noload)
Zout_cl = Zout/(1+T)
step(Zout_cl_noload)
hold on
step(Zout_cl)
legend('No load case','Full load case')


