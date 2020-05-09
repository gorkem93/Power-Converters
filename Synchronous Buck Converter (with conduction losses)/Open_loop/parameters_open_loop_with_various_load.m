%% Converter ratings
Vg=5;               % Input voltage
V=1.2;              % Output voltage


%I=0.1e-3;          % 100uA load (worst case)
%I=10e-3;           % 10mA load
%I=500e-3;          % 0.5A load
%I=1.5;             % 1.5A load
I=3.33;            % 3.3A load (rated condition)
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


Vm=5   %Peak value of PWM generator voltage

