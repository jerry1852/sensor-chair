filename = 'CexamTest830p5.txt';
data = readmatrix(filename);
time_stamp=data(:, 1);

%% make a pin at zero time (synschronized signal begins)
begin_index=find(time_stamp==0);
data=data(begin_index:end, :);
rows = size(data, 1);


%% reconstruct time stamp
% initial time should be changed corresponding to video.
initial_time = datetime('2024-08-30 16:16:47.000', 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS');
initial_time.Format = 'MMM dd, yyyy HH:mm:ss.SSS';
duration_times = (0.5 * (1:rows))'; 
new_stamps = initial_time + milliseconds(duration_times); 

% Noraxon offset is 19.176s (maybe changed, need to check participant2)
offset = seconds(19.909);  
new_stamps = new_stamps + offset;  


ECG=data(:, 3);
HR=data(:, 5);
RR=data(:, 6);
syn=data(:, 7);
new_data = timetable(new_stamps, ECG, HR, RR, syn);
new_data=downsample(new_data, 80);

% changing all the time
new_data=new_data(1:end, :);
%% change the file path and file name
output_filename = 'C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\participant5\syns\Noraxon_participantp5.csv';
writetimetable(new_data, output_filename);

HR_filename='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\participant5\syns\HRNora2_P5.txt';
writematrix(new_data.HR, HR_filename);

ECG_filename='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\participant5\syns\ECGNora2_P5.txt';
writematrix(new_data.ECG, ECG_filename);

RR_filename='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\participant5\syns\RRNora2_P5.txt';
writematrix(new_data.RR, RR_filename);
% output_filename = 'C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\Wang\correctSync\syns\Noraxon_participantpWang.csv';
% writetimetable(new_data, output_filename);
% 
% HR_filename='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\Wang\correctSync\syns\HRNora2_PWang.txt';
% writematrix(new_data.HR, HR_filename);
% 
% ECG_filename='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\Wang\correctSync\syns\ECGNora2_PWang.txt';
% writematrix(new_data.ECG, ECG_filename);
% 
% RR_filename='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\Wang\correctSync\syns\RRNora2_PWang.txt';
% writematrix(new_data.RR, RR_filename);
