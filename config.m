% ---���������Ϣ---%
% title='Faceocc2';
% seq_name = 'faceocc2';
% forMat = '.jpg'; % ���ݼ���ʽ
% dataPath = [ 'Datasets\' title '\img\']; % ���ݼ�·��
% rect=[118 57 82 98];    % Ŀ���ʼλ����Ϣ  x,y,w,h
% param.init_rect=rect;   % Ŀ���ʼλ����Ϣ  x,y,w,h
param.psize = [32 32];  % ͼ���һ���ߴ�
param.numsample=100;    % �����˲������ĺ�ѡ����
param.affsig=[4, 4, .0, .005, .005,.01]; %�������
%(0:01; 0:0005; 0:0005; 0:01; 4; 4��