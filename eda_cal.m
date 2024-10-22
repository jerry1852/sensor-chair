filename="C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\participant1\ref.csv";
refData=readmatrix(filename); 
refData=refData(:, 2);
filename="C:\Users\Jerry Wang\OneDrive - Aalto University\2024_CExAM\Third Experiments\participant1\combined.csv";
measData =readmatrix(filename); 
measData =measData(:, 2);
% this range is about the delay time of the skin conductance response
% between palm and the top of fingers. I set it to 2s, because 
threshold = 50;


TP = 0;


for i = 1:length(refData)
    
    found = any(abs(measData - refData(i)) <= threshold);
    
    
    if found
        TP = TP + 1;
    end
end

disp(['True Positives: ', num2str(TP)]);
FP=length(measData)-TP;
FN=length(refData)-TP;
Precision=TP/(TP+FP);
Recall=TP/(TP+FN);
F1=2*(Precision*Recall)/(Precision+Recall);
