filename = 'opensignals_0021083516b8_2024-08-30_16-15-03p5';
data = readmatrix(filename);
rows = size(data, 1);

Res = data(:, 6);
EDA = data(:, 7);
ECG = data(:, 8);
smoothed_EDA = smoothdata(EDA , 'movmean', 10);
EDA_resistance=1./smoothed_EDA;
Standard_EDA=(EDA_resistance-mean(EDA_resistance))./std(EDA_resistance);

initial_time = datetime('2024-08-30 16:15:8.205', 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS');
initial_time.Format = 'MMM dd, yyyy HH:mm:ss.SSS';
duration_times = (10 * (1:rows))'; 
new_stamps = initial_time + milliseconds(duration_times); 


new_data = timetable(new_stamps, duration_times, Res, ECG, Standard_EDA);

%% exact the circle period(exact time based on the video)
% target time should be changed
target_time=datetime('2024-08-30 16:17:08.000', 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS');
% 5 milliseconds is due to the sample rate of bitalino (100Hz)
begin_index=find(isbetween(new_data.new_stamps, target_time - milliseconds(5), target_time + milliseconds(5), 'closed'));

new_data=downsample(new_data(begin_index:end, :), 4);

%%
output_filename = 'C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\participant5\syns\bitalino_participantp5.csv';
writetimetable(new_data, output_filename);

RES_filename='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\participant5\syns\RESBi2_P5.txt';
writematrix(new_data.Res, RES_filename);

EDA_filename='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\participant5\syns\EDABi2_P5.txt';
writematrix(new_data.Standard_EDA, EDA_filename);

ECG_filename='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\participant5\syns\ECGBi2_P5.txt';
writematrix(new_data.ECG, ECG_filename);

% output_filename = 'C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\Wang\correctSync\syns\bitalino_participantpWang.csv';
% writetimetable(new_data, output_filename);
% 
% RES_filename='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\Wang\correctSync\syns\RESBi2_PWang.txt';
% writematrix(new_data.Res, RES_filename);
% 
% EDA_filename='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\Wang\correctSync\syns\EDABi2_PWang.txt';
% writematrix(new_data.Standard_EDA, EDA_filename);
% 
% ECG_filename='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\Wang\correctSync\syns\ECGBi2_PWang.txt';
% writematrix(new_data.ECG, ECG_filename);


