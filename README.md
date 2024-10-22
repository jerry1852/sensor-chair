# sensor-chair
This reposity is for the CExAM project: Sensor chair. It contains all codings for measurement and calculation.

Measurement Coding:

Measuremen coding is based on the Arduino Ino. It consist of pressure sensors, EDA sensors, PPG sensros, microphones, LED, sunchronized signal, siwtch. In order to run the program, you need to install all the files in the totalsensor folder. In this folder, totalsensor.ino is main file. Just run it in the Arduino Ino.

Attention: In the totalsensor.ino, there in one line coding in line 110. You need to change the file name each time. And the format of the file should nnoe exceed 7 charaters. (Part1 or t1000 is a goog file name)

respiratory_cal：

This algorithm is used for calculating breathing rate using the pressure data. In the coding, I used two different methods to get the result. One is autocorrelation corresponding to the Microsoft's paper. Another is main lobe spectrum. Besides these two methods, there is one more method using peak detections, but not in this coding. 


