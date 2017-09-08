g=zeros(1,15);
clc;
close all
%peaks={g};
for i=1:1:15
    [c,fs]=audioread(songid {i});
    
    peaks={fingerprint(c,fs)};
    tuple = convert_to_pairs(cell2mat(peaks)); 
    add_to_table(tuple,i); 
end
[clipt,fst]=audioread('test.mp3');
tic
bestMatchID1 =  match_segment(clipt, fst)
duration=toc

