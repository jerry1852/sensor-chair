% This algorithm  is based on the paper which is publised by Microsoft. (Only the algorithm, not coding)
% In the future, I can improve it by using weighted coefficient.
filename="D:\声学\totalsensors\t1017.csv";
data=readmatrix(filename);


data=data(1:end, 2:5);
% now we use 4 pressure sensors, two upper ones are mounted on the position
% of shoulder blade, one is in the spine, one is on the abodomen.

% now we only use two, but I don't want to decline it now.
num_sensors=4;
sensor_data=zeros(size(data, 1), num_sensors);
% this fs is regulated by arduino.
sample_rate=25;

% this filter is to used to filter unneeded signal, normal human repsritory
% is between 5-40 per minutes
[b,a] = butter(1,[0.02 0.7]/(sample_rate/2),"bandpass");
[d,c] = cheby1(2,1,[0.03 0.05]/(sample_rate/2),"stop");

%% subtract the signal and do the filtering

%sensor_data=filtfilt(b, a, data);

% Segment filtering, because the signal is so long, I guess this segement
% filter will be more suitbale for filtering. However, it doesn;t improve
% the normal breathing rate calculation, only optimize rapid breathing.
sub_time = 40;
length_win = sub_time * sample_rate;
num_win = floor(size(data, 1) / length_win);


buffer_size = round(0.1 * length_win); 

for i = 1:num_win
    start_index = (i-1) * length_win + 1;
    end_index = start_index + length_win - 1;


    padded_start_index = max(1, start_index - buffer_size);
    padded_end_index = min(size(data, 1), end_index + buffer_size);

    for n = 1:num_sensors

        padded_data = data(padded_start_index:padded_end_index, n);


        filtered_data = filtfilt(b, a, padded_data);

        filtered_data = filtfilt(d, c,  filtered_data);

        sensor_data(start_index:end_index, n) = filtered_data((start_index-padded_start_index+1):(end_index-padded_start_index+1));
    end
end

%%

figure(1);
plot(sensor_data);

% here we use the DSST methods, check this method more detailed from the
% paper.Compared to the paper configuration, here we use shorter window and
% slide window length.
window_length=15;%15
step_length=1;%1

window_size=window_length*sample_rate;
step_size=step_length*sample_rate;

num_window=floor((size(sensor_data, 1)-window_size)/step_size)+1;

% details: get the filtered 4 channel sensors signal, using DSST to
% seperate different windows. Based on them ,we calculate different period
% breathing rate. If one set is all zeros, we considered it is unvalid. If
% the breathing rate is below 5 or above 40, we consider they are unvalid.
% If four sensors' breathing rate stand variance is above 2, we consider
% they are unvalid.
% fIANLL, we calculate the mean of 4 sensors' repritory rate.
respiratory=zeros(num_window, num_sensors);
maxenergy_indices = zeros(num_window, num_sensors); 
for m=1:num_window
    start_index=(m-1)*step_size+1;
    end_index=start_index+window_size-1;
    for n=1:num_sensors
        % exact the signal
        data_window=sensor_data(start_index:end_index,n);
        % movement supression
        data_window=data_window-mean(data_window);
        %% fourier spectrum citizen(we don't use this spectrum method)
        % L = length(data_window(:,1));
        % X = data_window(:, 1);
        % window = hamming(L)';
        % X = X .* window;
        % X = X - mean(X);
        % Y = fft(X);
        % P2 = abs(Y/L);
        % P1 = P2(1:round(L/2)+1);
        % P1 = P1 / max(P1);
        % f = sample_rate*(0:(L/2))/L;
        % [pks,locs] = findpeaks(P1, 'SortStr','descend');
        % maxenergy_index=f(locs(1));
        % %maxenergy_indices(m, n) = maxbandenergy(f, pks, locs, P1); % 存储maxenergy_index值
        % if maxenergy_index<=0.055
        %     respiratory(m,n)=maxenergy_index*60;
        % else
        
            % if the set of date are all 0, the position is not proper, the
            % datas are not valid, but we can continue. 
              if all(data_window == 0)
                respiratory(m, n) = NaN;
                continue;
              end
            % we wanna find the first peak of autocorrealtion, and its reverse
            % is respiritory.
            [autocorr, lags]=xcorr(data_window, 'coeff');
            [~, position]=findpeaks(autocorr);
            if isempty(position)
                respiratory(m,n) = NaN;
                continue;
            end
            % we want find positive position
            first_peak_index=find(lags(position) > 0, 1);
            if isempty(first_peak_index)
                 respiratory(m,n) = NaN;
                 continue;
            end
            % calculate the repritory. From the first lag(means the breathing frequency, but sample points)
            first_peak=position(first_peak_index);
            peak_lag=lags(first_peak)/sample_rate;
            if peak_lag == 0
                respiratory(m,n)= NaN;
            else
                if (60 / peak_lag)<40 && (60 / peak_lag)>=2
                    respiratory(m,n)=60 / peak_lag;
                else
                    respiratory(m,n)=NaN;
                end
            end
     end
 end
%end

respiratory=smoothdata(respiratory, 1);
respiratory=smoothdata(respiratory, 1);
respiratory=smoothdata(respiratory, 1);

% Due to the chaning of pressure sensors, we don't need it anymore.
% respiratory_rates = zeros(num_window, 1);
% for m = 1:num_window
%     valid_rates = respiratory(m, ~isnan(respiratory(m, :)));
%     if std(valid_rates) <= 4 && ~isempty(valid_rates)
%         respiratory_rates(m) = mean(valid_rates);
%     else
%         respiratory_rates(m) = NaN;
%     end
% end

% % the results are between 25.
% respiratory_rates = respiratory_rates(~isnan(respiratory_rates));
% % the valid rate is between 40-63%.
% valid_rate=size(respiratory_rates, 1)/num_window*100;
% mean_rate=mean(respiratory_rates)

% expand the calculated breathing rate, for each segment expend one
% breathing rate. (In another word, update breathing rate per second)
res_time=zeros(size(data, 1), num_sensors);
for h=1:num_sensors
    for i=1:num_window
        start_index=(i-1)*step_size+1;
        end_index=start_index+window_size-1;
        res_time(start_index:end_index, h)=respiratory(i, h);
    end
end

% now we only have 2 sensors
Breathing_rate=res_time(:, [2,4]);

figure(2);
plot(sensor_data(:,2));
hold on;
plot(sensor_data(:,4));
hold off;

