filename="D:\声学\totalsensors\t1017.csv";
ppg_data=readmatrix(filename);

data=struct;
data.ppg=struct;
data.ppg.RED=ppg_data(:, 9);
data.ppg.v=ppg_data(1:end, 10);%10

data.ppg.fs=25;

S = data.ppg;   % extract PPG data

windowSize = 5; 
%S.v = movmean(S.v, windowSize);

[b, a] = butter(4, [0.5, 3] / (data.ppg.fs / 2), 'bandpass');
S.v=filtfilt(b, a, S.v);



beat_detector = 'msptd';     % Select Incremental-Merge Segmentation beat detector
[peaks, onsets, mid_amps] = detect_ppg_beats(S, beat_detector);     % detect beats in PPG


intervals=diff(peaks);
heartrates=60./(intervals./data.ppg.fs);
for i=1:length(heartrates)
    if heartrates(i)<=150 && heartrates(i)>=40
    
        heartrates(i)=heartrates(i);
    else
        heartrates(i)=NaN;
    end
end
average_hr=mean(heartrates(~isnan(heartrates)))

hr=zeros(length(S.v), 1);
for i=1:length(peaks)-1
    hr(peaks(i):peaks(i+1))=heartrates(i);
end


 hr=smoothdata(hr, 1);
% 
 hr=smoothdata(hr, 1);
% 
% hr=smoothdata(hr, 1);

%% heart rate variability
hrv=zeros(length(S.v), 1);
hrvwindow_size=60;
hrvwindow_step=2;
num_window=floor((size(intervals, 1)-hrvwindow_size)/hrvwindow_step)+1;
for i=1:num_window
    start_index=(i-1)*hrvwindow_step+1;
    end_index=start_index+hrvwindow_size-1;
    hrv(peaks(start_index):peaks(end_index))=(std(intervals(start_index:end_index)/data.ppg.fs))*1000;
end
%%
figure('Position', [20,20,1000,350])     % Setup figure
subplot('Position', [0.05,0.17,0.92,0.82])
t = [0:length(S.v)-1]/S.fs;             % Make time vector
plot(t, S.v, 'b'), hold on,             % Plot PPG signal
plot(t(peaks), S.v(peaks), 'or'),       % Plot detected beats
ftsize = 20;                            % Tidy up plot
set(gca, 'FontSize', ftsize, 'YTick', [], 'Box', 'off');
ylabel('PPG', 'FontSize', ftsize),
xlabel('Time (s)', 'FontSize', ftsize)

%% blood oxygen
t=1;
window_size=t*data.ppg.fs;
spo2_size=10;
num_window=floor((size(data.ppg.RED, 1)-window_size)/spo2_size)+1;
spO2=zeros(length(data.ppg.RED), 1);
[b, a]=butter(3, 0.5/(data.ppg.fs/2), "high");
AC_RED=filtfilt(b, a, data.ppg.RED);
AC_v=filtfilt(b, a, data.ppg.v);
for i=1:num_window
    start_index=(i-1)*spo2_size+1;
    end_index=start_index+window_size-1;
    RED=data.ppg.RED(start_index:end_index);
    IR=data.ppg.v(start_index:end_index);
    RED_AC=RED-mean(RED);
    IR_AC=IR-mean(IR);
    ratio=(AC_RED(start_index:end_index)./(data.ppg.RED(start_index:end_index)-AC_RED(start_index:end_index)))./(AC_v(start_index:end_index)./mean(data.ppg.v(start_index:end_index)-AC_v(start_index:end_index)));
    spO2(start_index:end_index)=(-45.060.*ratio + 30.354).*ratio + 94.845;
end

for i=1:length(spO2)
    if spO2(i)>100 || spO2(i)<80
        spO2(i)=NaN;
    end
end

spO2=smoothdata(spO2, 'movmean', 100);

hr=hr(75:(end-15));


