filename = "E:\P2WANG.csv";
data = readtimetable(filename);

start_index=find(data{:, 11}>500, 1);
new_data=data(start_index:(start_index+9750), :);

Combined_EDA=new_data.Var5;
Printed_EDA=new_data.Var6;

smoothedCombined_EDA = smoothdata(Combined_EDA , 'movmean', 10);
smoothed3d_EDA = smoothdata(Printed_EDA , 'movmean', 10);

cal_combinededa=((1024+2.*smoothedCombined_EDA).*10000)./(521-smoothedCombined_EDA);
cal_3deda=((1024+2.*smoothed3d_EDA).*10000)./(521-smoothed3d_EDA);

new_data.Var5=(cal_combinededa-mean(cal_combinededa))./std(cal_combinededa);
new_data.Var6=(cal_3deda-mean(cal_3deda))./std(cal_3deda);

%% should change the file path and file name
%output_filename = 'C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\participant1\syns\Part1.csv';
output_filename = 'C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\participant5\syns\Part5.csv';
%output_filename ='C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\Wang\correctSync\syns\PartWang.csv';
writetimetable(new_data, output_filename);
