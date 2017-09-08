function peaks2=fingerprint(clip,fs)

clip=mean(clip,2);
clip=clip-mean(clip);
clip=resample(clip,8000,fs);
window  = 8000*64*10^(-3);
noverlap = 8000*32*10^(-3);
[S,F,T] = spectrogram(clip, window, noverlap, [], 8000); 
x=1:1:size(S,2);
y=1:1:size(S,1);
s_abs=abs(S);
%surf(x,y,s_abs);
cs1=circshift(s_abs,[0,1]);
cs2=circshift(s_abs,[1,1]);
cs3=circshift(s_abs,[2,1]);
cs4=circshift(s_abs,[1,0]);
cs5=circshift(s_abs,[2,0]);
cs6=circshift(s_abs,[0,-1]);
cs7=circshift(s_abs,[1,-1]);
cs8=circshift(s_abs,[2,-1]);
p1=(s_abs>cs1);
p2=(s_abs>cs2);
p3=(s_abs>cs3);
p4=(s_abs>cs4);
p5=(s_abs>cs5);
p6=(s_abs>cs6);
p7=(s_abs>cs7);
p8=(s_abs>cs8);
p=p1&p2&p3&p4&p5&p6&p7&p8;
peaks=p.*s_abs;
%imagesc(logical(peaks)) 
%colormap(1-gray) 
sorted=sort(peaks);
sorted=sort(sorted,2);
threshold=sorted(size(sorted,1),size(sorted,2)-29)./T(end);
peaks2=(peaks>threshold).*peaks;
%figure
%imagesc(logical(peaks2)) 
%colormap(1-gray) 
end
