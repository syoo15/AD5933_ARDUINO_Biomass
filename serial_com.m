% Arduino_AD5933 Serial Communication using MATLAB
% Automatically store measured data everytime users press B and plot in log scale
% Date: 2017-03-03
% Author: Seokchan Yoo
% Press A = Temperature Measurement
% Press B = Impedance Measurement
% Note: fscanf print only one Serial print of Arduino. Need to be careful
% Note2: First run calibration step then proceed into while loop until users Press C to close serial connection with Arduino

clc;
clear all;

a = serial('COM3','BaudRate',115200);
fopen(a);
isconnected = 1;       % Boolean Expression for while loop

%start = fscanf(a);      % Read from void setup initialize statement
%disp(start)
start = fscanf(a);      % Read from void setup initialize statement
disp(start)

% Running calibration step
cal_input = input('Enter p when calibration setup is ready: ', 's');
if cal_input == 'p'
    fprintf(a,'%c','p');
    pause(2);       % Is there a way to pause program until calibration is done?
    start = fscanf(a); 
    disp(start)
else
    disp('Incorrect input. Please enter p')
end

while isconnected ==1
ask_input = input('Enter A for temperature measurement, B for impedance measurement, C to exit: ', 's');

if ask_input == 'A'
    % Cleaning any existing data and initializing arrays
	temp_array = {}; 

	% Real-time temperature plotting
    for i = 1:20
        fprintf(a,'%c','A');
        output(i) = fscanf(a,'%f');            % Read from serial communication
        temp_array = [temp_array, output];
        drawnow;
        plot(output,'ro-', 'linewidth',3);
        hold on;
        pause(1);
    end

elseif ask_input == 'B'
    % Cleaning any existing data and initializing arrays
    freq_array = {};
	imp_array = {};
	phi_array = {};
    fprintf(a,'%c','B');
    
     for i = 1:91			% This must be matched to the # of step in Arduino Code
        % Data order will be: Frequency, Impedance, Phase
        freq = fscanf(a, '%i');
        imp = fscanf(a, '%f');
        phi = fscanf(a, '%f');
        
        % Save data into array for further data processing
        freq_array = [freq_array, freq];
        imp_array = [imp_array, imp];
        phi_array = [phi_array, phi];
       
     end
     
     file_name = input('Please type the file name: ', 's');			% Ask user input for csv file
     disp('Press Enter')
     pause;								% Pause next lines of code until users press Enter
     name = strcat(file_name,'.csv');   % Full csv file name


     % Converting cell array into matrix form for plotting
     % Also make headers for csv file generation and merge all the data together into a single matrx
     A = cell2mat(freq_array);
     B = cell2mat(imp_array);
     C = cell2mat(phi_array);
     headers = {'Frequency','Impedance','Phase'};
     all_data = [A', B',C'];
     csvwrite_with_headers(name,all_data,headers);


     % Plot Bode diagram of impedance and phase
     figure
     semilogx(A,B)
     title('Frequency vs. Impedance')
     xlabel('Frequency (kHz)')
     ylabel('Impedance (ohms)')
     %xlim([1000, 100000])
     
     figure
     semilogx(A,C)
     title('Frequency vs. Phase')
     xlabel('Frequency (kHz)')
     ylabel('Phase (rad)')
     %xlim([1000, 100000])
     
    % Note for cut-off frequency calculation
    % Max(Z) times sqrt(2) 
    % For parallel RC circuit, max value will be R
    % Then using f = 1/2pi(RC) to find capacitance
    % 1/(f*2pi*R) = C

    cut = (1/sqrt(2))*10000;		% 10000 is the value of R in parallel with a capacitor
    [c idx] = min(abs(B-cut));		% Find an index of closest value in impedance array
    closestVal = B(idx);
    %disp(closestVal)

    closeF = A(idx);				% Find frequency 
    cap = 1/(closeF*2*pi*10000);	% Calculate cut-off frequency 
    disp('Estimated Capacitance value is: '+ cap)						% Display estimated capacitance value
     
     elseif ask_input == 'C'
        fclose(a);
        isconnected = 0;
        disp('Disconnecting from the device...')
end
end

