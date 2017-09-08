function bestMatchID = match_segment(clip, fs)
%function [bestMatchID, confidence] = match_segment(clip, fs)
%  This function requires the global variables 'hashtable' and 'numSongs'
%  in order to work properly.
%
%  This function is currently incomplete.


global hashtable
global numSongs

hashTableSize = size(hashtable,1);


peaks = match_segmentfingerprint(clip, fs);
clipTuples = convert_to_pairs(peaks);

% Construct the cell of matches
matches = cell(numSongs,1);
for k = 1:size(clipTuples, 1)
    
    clipHash = simple_hash(clipTuples(k,3),clipTuples(k,4), clipTuples(k,2)-clipTuples(k,1), hashTableSize);
%     k
%     clipTuples(k, :)
%     system('pause')
    
    % If an entry exists with this hash, find the song(s) with matching peak pairs
    if (~isempty(hashtable{clipHash, 1}))
        matchID = hashtable{clipHash, 1}; % row vector of collisions
        matchTime = hashtable{clipHash, 2}; % row vector of collisions
%         system('pause')
        % Calculate the time difference between clip pair and song pair
        matchTime = matchTime - clipTuples(k, 1);
                
        % Add matches to the lists for each individual song
        for n = 1:numSongs
            % INSERT CODE HERE
            matches{n} = [matches{n}, matchTime(matchID == n)];
        end
    end
end

% Find the counts of the mode of the time offset array for each song
numOfmatches = zeros(size(matches, 1), 1);
for k = 1:numSongs
    numOfmatches(k) = numel(matches{k});
end


% Song decision and confidence
[~, bestMatchID] = max(numOfmatches);
load('SONGID.mat')
songid{bestMatchID}

optional_plot = 0; % turn plot on or off

if optional_plot
    figure(3)
    clf
    y = zeros(length(matches),1);
    for k = 1:length(matches)
        subplot(length(matches),1,k)
        hist(matches{k},1000)
        y(k) = max(hist(matches{k},1000));
    end
    
    for k = 1:length(matches)
        subplot(length(matches),1,k)
        axis([-inf, inf, 0, max(y)])
    end

    subplot(length(matches),1,1)
    title('Histogram of offsets for each song')
end

end

function peaks = match_segmentfingerprint(y, Fs)
    Fs_ = 8000;
    y_ = resample(y, Fs_, Fs);

    window = 64*10^(-3)*Fs_;
    noverlap = 32*10^(-3)*Fs_;
    [S,F,T] = spectrogram(y_, window, noverlap, [], Fs_);
    S_ = abs(S);
    
    CS1 = circshift(S_, [0, 1]);
    CS2 = circshift(S_, [0, -1]);
    CS3 = circshift(S_, [1, 0]);
    CS4 = circshift(S_, [-1, 0]);
    CS5 = circshift(S_, [1, 1]);
    CS6 = circshift(S_, [1, -1]);
    CS7 = circshift(S_, [-1, 1]);
    CS8 = circshift(S_, [-1, -1]);
    
    temp1 = S_ > CS1;
    temp2 = S_ > CS2;
    temp3 = S_ > CS3;
    temp4 = S_ > CS4;
    temp5 = S_ > CS5;
    temp6 = S_ > CS6;
    temp7 = S_ > CS7;
    temp8 = S_ > CS8;
    
    P = temp1 & temp2 & temp3 & temp4 & temp5 & temp6 & temp7 & temp8;
    pickMat = P .* S_;
    
    % ************ recursive form**************
%     MAX = max(max(pickMat));
%     MIN = min(min(pickMat));  
%     numOfDitectedPicks1 = 0;
%     soundDur = T(end);
    numOfpicksPerSec = 30;
%     numOfItter = 0;
%     
%     while true
%         threshold = (MAX + MIN)/2;
%         temp1 = pickMat >= threshold;
%         numOfDitectedPicks2 = sum(sum(temp1));
%         
%         if numOfDitectedPicks2 == numOfDitectedPicks1
%             numOfItter = numOfItter + 1;
%         else
%             numOfItter = 0;
%         end
%         
%         if numOfItter == 100
%             break
%         end
%         
%         if numOfDitectedPicks2/soundDur > numOfpicksPerSec
%             MIN = threshold;
%         elseif numOfDitectedPicks2/soundDur <= numOfpicksPerSec
%             MAX = threshold;
%         end
%         
%         numOfDitectedPicks1 = numOfDitectedPicks2;
%     end
    
    % ***************sort form *****************
    temp = reshape(pickMat, 1, numel(pickMat));
    nonZeroPicks = temp(temp ~= 0);
    sortedPicks = sort(nonZeroPicks, 'descend');
    
    peakPerSec = zeros(1, length(sortedPicks));
    for i = 1:length(sortedPicks)
        peakPerSec(i) = i/T(end);
    end
    temp = abs(peakPerSec - numOfpicksPerSec);
    threshold = sortedPicks(temp == min(temp));
%     sum(sum(pickMat > threshold))/T(end)
    
    peaks = pickMat .* (pickMat > threshold);
end

function hash = simple_hash(f1, f2, deltaT, size)
%function hash = simple_hash(f1, f2, deltaT, size)
%
%  Hash function: produces index to a hash table
%
% This is just intended to be a chaotic function with roughly a uniform
% distribution over the range.

hash = mod(round( size*1000000*(log(abs(f1)+2) + 2*log(abs(f2)+2) + 3*log(abs(deltaT)+2)) ), size) + 1;

end