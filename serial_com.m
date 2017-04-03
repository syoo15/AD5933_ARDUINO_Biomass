% Arduino_AD5933 Serial Communication using MATLAB
% Date: 2017-03-03
% Press A = Temperature Measurement
% Press B = Impedance Measurement


% Note: fscanf print only one Serial print of Arduino. Need to be careful
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
    
     for i = 1:91
        % Data order will be: Frequency, Impedance, Phase
        freq = fscanf(a, '%i');
        imp = fscanf(a, '%f');
        phi = fscanf(a, '%f');
        
        % Save data into array for further data processing
        freq_array = [freq_array, freq];
        imp_array = [imp_array, imp];
        phi_array = [phi_array, phi];
       
     end
     
     file_name = input('Please type the file name: ', 's');
     disp('Press Enter')
     pause;
     name = strcat(file_name,'.csv');   % Full csv file name


     % Converting cell array into matrix form for plotting
     % Also make headers for csv file generation and merge all the data together into a single matrx
     A = cell2mat(freq_array);
     B = cell2mat(imp_array);
     C = cell2mat(phi_array);
     headers = {'Frequency','Impedance','Phase'};
     all_data = [A', B',C'];
     csvwrite_with_headers(name,all_data,headers);


     % Plot Code
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
     
     elseif ask_input == 'C'
        fclose(a);
        isconnected = 0;
        disp('Disconnecting from the device...')
end
end


% Button not working correctly
%serial_com_gui;



% Note for cut-off frequency calculation
% Max Z times sqrt(2) 
% Then using 1/2pi(RC) to find capacitance
