% This is a demo to run the tracker
% run.m

seqs=configSeqs;
numSeq=length(seqs);
% pathAnno = './anno/';
times=1;
% results=cell(1,times);
% time=1;

for idxSeq=1:length(seqs)
    s = seqs{idxSeq};
    s.len = s.endFrame - s.startFrame + 1;
    s.s_frames = cell(s.len,1);
    runDemo(s,times);
    %     resultMat=['./results/' s.name '_HWJ'];
    %     save(resultMat,'results');
end