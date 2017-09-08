snr = 0:0.1:3;
pe = zeros(size(snr));
[clip, fs] = audioread('test.mp3');
clipt = mean(clipt, 2);

tic
for i = 1:length(snr)
	counter = 0;
	for j = 1:20;
		y = awgn(clipt, snr(i));
        bestMatchID = match_segment(y, fst);
		if (bestMatchID ~= 8) 
			counter = counter+1;
		end
	end
	pe(i) = counter/20;
end
toc
[c,index]=max(pe)
