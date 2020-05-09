%% Converter ratings
Vg=5;               % Input voltage
V=1.2;              % Output voltage


%I=0.1e-3;          % 100uA load (worst case)
%I=10e-3;           % 10mA load
%I=500e-3;          % 0.5A load
%I=1.5;             % 1.5A load
I=3.3;             % 3.3A load (rated condition)
%I=4;               % 4A load

fsw=50e3            % Switching frequency
Tsw=1/fsw           % Switching period

%Inductor
L=68e-6             % Inductance
RL=30e-3            % Internal resistance

%Capacitor
C=68e-6             % Capacitance
Resr=9e-3           % ESR value

%Load
R=V/I               % Load resistance


%Mosfet
Rdson=7.6e-3        % On-state resistance
Vf=0.78             % Anti-paralel diode forward voltage

%% DC analysis
%Duty cycle value
Duty=(V/Vg)*(1+((RL+Rdson)/R))      % Duty cycle value

%Efficiency
n=1/(1+((RL+Rdson)/R))              % Efficiency value

%Inductor ripple current
I_ripple=(((Rdson+RL)*I+V)*(1-Duty)*Tsw)/(2*L)

%Output voltage ripple (effect of "Resr" is neglected)
V_ripple=(I_ripple*Tsw)/(8*C)

%% Small signal AC analysis
s=tf('s')

Re=RL+Rdson

%Gvd
Gvd=((Vg*R)/(Re+R))*((1+s*C*Resr)/(((L*C*(R+Resr))/(Re+R))*s^2+((R*Re*C+Resr*Re*C+Resr*R*C+L)/(Re+R))*s+1))

%Gvi
Gvi=(R*(1+s*C*Resr))/(1+s*C*(R+Resr))

%Gid
Gid=Gvd/Gvi

%Gvg
Gvg=((Duty*R)/(Re+R))*((1+s*C*Resr)/(((L*C*(R+Resr))/(Re+R))*s^2+((R*Re*C+Resr*Re*C+Resr*R*C+L)/(Re+R))*s+1))

%Gig
Gig=Gvg/Gvi

%Zout
Zout=(-(R*Re)/(Re+R))*(1+s*(L/Re))*((1+s*C*Resr)/(((L*C*(R+Resr))/(Re+R))*s^2+((R*Re*C+Resr*Re*C+Resr*R*C+L)/(Re+R))*s+1))

%Giz
Giz=(R/(Re+R))*((1+s*C*Resr)/(((L*C*(R+Resr))/(Re+R))*s^2+((R*Re*C+Resr*Re*C+Resr*R*C+L)/(Re+R))*s+1))

%Gvi_load
Gvi_load=-(Re+s*L)

%% Compensator design
%Parameters for controller design
Vm=5;      % Peak of PWM generator
Rf=0.3;    % current sensing resistor
H=0.5;     % voltage sensor gain


%%% Current loop
figure(1)
Tiu=Rf*(1/Vm)*Gid
bode(Tiu)

Gci=(13.4*(1+(2*pi*4224)/s))/(1+s/(2*pi*25000))      % cut-off freq: 5kHz, PM:53
Ti=Tiu*Gci
bode(Ti)
legend('Tiu','Ti')

%closed-loop bode plots
figure(2)
Ti_cl=Ti/(1+Ti)
bode(Ti_cl)
legend('Ti,cl')

%closed-loop step responses
figure(3)
step(Ti_cl)
legend('Ti,cl_step')

figure(4)
Gig_cl=Gig/(1+Ti)
step(Gig_cl)
legend('Gig,cl_step')

figure(5)
Giz_cl=Giz/(1+Ti)
step(Giz_cl)
legend('Giz,cl_step')


%%% Voltage loop
figure(6)
Tvu=(1/Rf)*Gvi*H
bode(Tvu)
hold on

Gcv=(0.5465*(1+(2*pi*306)/s))/(1+s/(2*pi*5000))   %fcv=500Hz, PM:76
Tv=Tvu*Gcv
bode(Tv)
legend('Tvu','Tv')


%Closed loop bode plots
figure(7)
Tc_cl=Tv/(1+Tv)
bode(Tv/(1+Tv))
legend('Tv,cl')

%Closed loop step responses
figure(8)
step(Tv/(1+Tv))
legend('Tv,cl_step')

figure(9)
step((Gig*Gvi)/((1+Ti)*(1+Tv)))
legend('Gvg,cl_step')

figure(10)
step((Giz*Gvi)/(1+Tv))
legend('Zout,cl_step')


%Compensator parameters
Rc1=1e3;
Rc2=13.3404e3;
Cc2=2.8e-9;
Cc3=470e-12;

Ra=2e3;
Rb=2e3;
Rv2=546;
Cv2=0.94e-6;
Cv3=0.056e-6;

